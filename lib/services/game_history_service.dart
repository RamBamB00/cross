import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/game_history.dart';

class GameHistoryService {
  static const String _historyBox = 'gameHistory';
  static const String _pendingSyncBox = 'pendingHistorySync';

  static Future<void> init() async {
    await Hive.openBox<Map>(_historyBox);
    await Hive.openBox<List<Map>>(_pendingSyncBox);
  }

  // Save game history to both Firebase and local storage
  static Future<void> saveGameHistory(GameHistory game) async {
    // Always save to local storage first
    final box = Hive.box<Map>(_historyBox);
    await box.put(game.id, game.toMap());

    // Try to save to Firebase if online
    try {
      await FirebaseFirestore.instance
          .collection('gameHistory')
          .doc(game.id)
          .set(game.toFirestoreMap());
    } catch (e) {
      print('Error saving to Firebase: $e');
      // If Firebase save fails, add to pending sync
      final pendingBox = Hive.box<List<Map>>(_pendingSyncBox);
      final pendingList = pendingBox.get('pendingItems', defaultValue: <Map>[]) ?? <Map>[];
      pendingList.add(game.toMap());
      await pendingBox.put('pendingItems', pendingList);
    }
  }

  // Get game history from Firebase or local storage
  static Future<List<GameHistory>> getGameHistory(String userId) async {
    List<GameHistory> games = [];
    
    // Always try to get from local storage first
    final box = Hive.box<Map>(_historyBox);
    final localGames = box.values
        .map((map) => GameHistory.fromMap(
            DateTime.now().millisecondsSinceEpoch.toString(), 
            Map<String, dynamic>.from(map)))
        .where((game) => game.userId == userId)
        .toList();
    
    // Try to get from Firebase if online
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('gameHistory')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        games = snapshot.docs
            .map((doc) => GameHistory.fromMap(doc.id, doc.data()))
            .toList();
        
        // Update local storage with Firebase data
        for (var game in games) {
          await box.put(game.id, game.toMap());
        }
      }
    } catch (e) {
      print('Error fetching from Firebase: $e');
      // If Firebase fails, use local storage data
      games = localGames;
    }

    // If no games from Firebase, use local games
    if (games.isEmpty) {
      games = localGames;
    }

    // Sort games by timestamp
    games.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return games;
  }

  // Search game history
  static Future<List<GameHistory>> searchGameHistory(
    String userId, {
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    String? result,
  }) async {
    List<GameHistory> games = await getGameHistory(userId);

    // Apply filters
    if (searchQuery != null && searchQuery.isNotEmpty) {
      games = games.where((game) {
        final searchLower = searchQuery.toLowerCase();
        return game.playerHand.join(' ').toLowerCase().contains(searchLower) ||
            game.dealerHand.join(' ').toLowerCase().contains(searchLower) ||
            game.result.toLowerCase().contains(searchLower);
      }).toList();
    }

    if (startDate != null) {
      games = games.where((game) => game.timestamp.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      games = games.where((game) => game.timestamp.isBefore(endDate)).toList();
    }

    if (result != null && result.isNotEmpty) {
      games = games.where((game) => game.result == result).toList();
    }

    return games;
  }

  // Sync pending games
  static Future<void> syncPendingGames() async {
    final pendingBox = Hive.box<List<Map>>(_pendingSyncBox);
    final pendingList = pendingBox.get('pendingItems', defaultValue: <Map>[]) ?? <Map>[];

    if (pendingList.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    final collection = FirebaseFirestore.instance.collection('gameHistory');

    for (final game in pendingList) {
      final docRef = collection.doc();
      batch.set(docRef, game);
    }

    try {
      await batch.commit();
      await pendingBox.put('pendingItems', <Map>[]);
    } catch (e) {
      print('Error syncing pending games: $e');
    }
  }

  // Clear all local history
  static Future<void> clearLocalHistory() async {
    final box = Hive.box<Map>(_historyBox);
    await box.clear();
    final pendingBox = Hive.box<List<Map>>(_pendingSyncBox);
    await pendingBox.clear();
  }
} 