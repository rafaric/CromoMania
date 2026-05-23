import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/entities/user_profile.dart';
import '../domain/repositories/auth_repository.dart';

/// Firebase implementation of AuthRepository
class FirebaseAuthService implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<UserProfile> signInWithGoogle() async {
    try {
      // Trigger Google Sign In flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Google sign-in was cancelled');
      }

      // Get auth credentials from Google
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with credentials
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      // Return user profile
      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Firebase sign-in failed');
      }

      return UserProfile.fromFirebaseUser(user);
    } on PlatformException catch (e) {
      throw AuthException('Google sign-in error: ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw AuthException('Firebase error: ${e.message}');
    }
  }

  @override
  UserProfile? get currentUserProfile {
    final user = currentUser;
    if (user == null) return null;
    return UserProfile.fromFirebaseUser(user);
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }
}

/// Custom exception for auth errors
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}