import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _gameStateBox = 'gameState';
  static const String _userPrefsBox = 'userPrefs';
  static const String _pendingSyncBox = 'pendingSync';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_gameStateBox);
    await Hive.openBox(_userPrefsBox);
    await Hive.openBox(_pendingSyncBox);
  }

  // Game state storage
  static Future<void> saveGameState(Map<String, dynamic> gameState) async {
    final box = Hive.box(_gameStateBox);
    await box.put('currentGame', gameState);
  }

  static Map<String, dynamic>? getGameState() {
    final box = Hive.box(_gameStateBox);
    return box.get('currentGame');
  }

  // User preferences storage
  static Future<void> saveUserPrefs(Map<String, dynamic> prefs) async {
    final box = Hive.box(_userPrefsBox);
    await box.put('preferences', prefs);
  }

  static Map<String, dynamic>? getUserPrefs() {
    final box = Hive.box(_userPrefsBox);
    return box.get('preferences');
  }

  // Pending sync storage
  static Future<void> addPendingSync(Map<String, dynamic> data) async {
    final box = Hive.box(_pendingSyncBox);
    final pendingList = box.get('pendingItems', defaultValue: <Map<String, dynamic>>[]);
    pendingList.add(data);
    await box.put('pendingItems', pendingList);
  }

  static List<Map<String, dynamic>> getPendingSync() {
    final box = Hive.box(_pendingSyncBox);
    return List<Map<String, dynamic>>.from(
      box.get('pendingItems', defaultValue: <Map<String, dynamic>>[]),
    );
  }

  static Future<void> clearPendingSync() async {
    final box = Hive.box(_pendingSyncBox);
    await box.put('pendingItems', <Map<String, dynamic>>[]);
  }

  // Auth token storage
  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  static Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
  }
} 