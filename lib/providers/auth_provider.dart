import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
    serverClientId: '306171284793-d3lltr71mlsknbqfe4a9guvvbfpgqv8k.apps.googleusercontent.com',
  );
  
  User? _currentUser;
  bool _isGuestMode = false;
  bool _isLoading = false;
  StreamSubscription<User?>? _authStateSubscription;

  AuthProvider() {
    _init();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  User? get currentUser => _currentUser;
  bool get isGuestMode => _isGuestMode;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Cancel any existing subscription
      await _authStateSubscription?.cancel();
      
      // Set up new auth state listener
      _authStateSubscription = _auth.authStateChanges().listen((User? user) {
        if (!_isGuestMode) {
          _currentUser = user;
          notifyListeners();
        }
      });
    } catch (e) {
      print('Error in _init: $e');
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> enterGuestMode() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentUser != null) {
        await _auth.signOut();
      }
      _currentUser = null;
      _isGuestMode = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> exitGuestMode() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isGuestMode = false;
      // Re-initialize auth state listener
      await _init();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        _currentUser = userCredential.user;
        _isGuestMode = false;
      }
    } catch (e) {
      _currentUser = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google Sign In was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        _currentUser = userCredential.user;
        _isGuestMode = false;
        
        // Create or update user document
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'displayName': userCredential.user!.displayName,
          'photoURL': userCredential.user!.photoURL,
          'lastSignIn': FieldValue.serverTimestamp(),
          'createdAt': userCredential.additionalUserInfo?.isNewUser == true
              ? FieldValue.serverTimestamp()
              : FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Google Sign In Error: $e');
      _currentUser = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        _currentUser = userCredential.user;
        _isGuestMode = false;
      }
    } catch (e) {
      _currentUser = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signOut();
      _currentUser = null;
      _isGuestMode = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> savePreferences(Map<String, dynamic> preferences) async {
    if (_currentUser != null && !_isGuestMode) {
      print('Saving preferences for user: ${_currentUser!.uid}');
      try {
        await _firestore.collection('users').doc(_currentUser!.uid).set({
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
    if (_currentUser != null && !_isGuestMode) {
      print('Getting preferences for user: ${_currentUser!.uid}');
      try {
        final doc = await _firestore.collection('users').doc(_currentUser!.uid).get();
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