import 'package:cloud_firestore/cloud_firestore.dart';

class GameHistory {
  final String id;
  final String userId;
  final DateTime timestamp;
  final String result; // 'win', 'lose', 'tie'
  final List<String> playerHand;
  final List<String> dealerHand;
  final int playerScore;
  final int dealerScore;

  GameHistory({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.result,
    required this.playerHand,
    required this.dealerHand,
    required this.playerScore,
    required this.dealerScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'timestamp': timestamp.millisecondsSinceEpoch, // Store as milliseconds for Hive
      'result': result,
      'playerHand': playerHand,
      'dealerHand': dealerHand,
      'playerScore': playerScore,
      'dealerScore': dealerScore,
    };
  }

  // For Firebase
  Map<String, dynamic> toFirestoreMap() {
    return {
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp), // Use Timestamp for Firebase
      'result': result,
      'playerHand': playerHand,
      'dealerHand': dealerHand,
      'playerScore': playerScore,
      'dealerScore': dealerScore,
    };
  }

  factory GameHistory.fromMap(String id, Map<String, dynamic> map) {
    DateTime timestamp;
    if (map['timestamp'] is Timestamp) {
      timestamp = (map['timestamp'] as Timestamp).toDate();
    } else {
      timestamp = DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int);
    }

    return GameHistory(
      id: id,
      userId: map['userId'] as String,
      timestamp: timestamp,
      result: map['result'] as String,
      playerHand: List<String>.from(map['playerHand'] as List),
      dealerHand: List<String>.from(map['dealerHand'] as List),
      playerScore: map['playerScore'] as int,
      dealerScore: map['dealerScore'] as int,
    );
  }
} 