import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a document for the user's preferences
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'isDarkMode': false,
        'languageCode': 'en',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Save user preferences
  Future<void> saveUserPreferences(
    String userId, {
    required bool isDarkMode,
    required String languageCode,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isDarkMode': isDarkMode,
        'languageCode': languageCode,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  // Get user preferences
  Future<Map<String, dynamic>?> getUserPreferences(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email.');
      case 'wrong-password':
        return Exception('Wrong password provided.');
      case 'email-already-in-use':
        return Exception('Email is already in use.');
      case 'weak-password':
        return Exception('Password is too weak.');
      case 'invalid-email':
        return Exception('Email address is invalid.');
      default:
        return Exception(e.message ?? 'An error occurred during authentication.');
    }
  }

  Exception _handleFirestoreException(FirebaseException e) {
    return Exception(e.message ?? 'An error occurred with the database.');
  }
} 