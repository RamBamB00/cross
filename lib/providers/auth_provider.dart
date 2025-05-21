import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool _isLoading = false;
  bool _isGuestMode = false;

  AuthProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      // Only enter guest mode if there's no user and we're not already in guest mode
      if (user == null && !_isGuestMode) {
        // Don't automatically enter guest mode
        _isGuestMode = false;
      }
      notifyListeners();
    });
  }

  User? get currentUser => _user;
  bool get isLoading => _isLoading;
  bool get isGuestMode => _isGuestMode;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> enterGuestMode() async {
    print('Entering guest mode');
    _isGuestMode = true;
    _user = null;  // Ensure user is null in guest mode
    notifyListeners();
    print('Guest mode set to: $_isGuestMode');
  }

  void exitGuestMode() {
    _isGuestMode = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isGuestMode = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document in Firestore
      if (userCredential.user != null) {
        print('Creating user document in Firestore for: ${userCredential.user!.uid}');
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'preferences': {
            'darkMode': false,
            'language': 'en',
          },
        });
        print('User document created successfully');
        _isGuestMode = false;
      }
    } catch (e) {
      print('Error during registration: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signOut();
      enterGuestMode(); // Enter guest mode after signing out
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> savePreferences(Map<String, dynamic> preferences) async {
    if (_user != null && !_isGuestMode) {
      print('Saving preferences for user: ${_user!.uid}');
      try {
        await _firestore.collection('users').doc(_user!.uid).set({
          'preferences': preferences,
        }, SetOptions(merge: true));
        print('Preferences saved successfully');
      } catch (e) {
        print('Error saving preferences: ${e}');
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>?> getPreferences() async {
    if (_user != null && !_isGuestMode) {
      print('Getting preferences for user: ${_user!.uid}');
      try {
        final doc = await _firestore.collection('users').doc(_user!.uid).get();
        print('Retrieved preferences: ${doc.data()?['preferences']}');
        return doc.data()?['preferences'] as Map<String, dynamic>?;
      } catch (e) {
        print('Error getting preferences: $e');
        return null;
      }
    }
    return null;
  }
} 