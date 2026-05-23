import 'package:firebase_auth/firebase_auth.dart';
import '../entities/user_profile.dart';

/// Abstract interface for authentication operations
abstract class AuthRepository {
  /// Stream of auth state changes
  Stream<User?> get authStateChanges;

  /// Sign in with Google
  Future<UserProfile> signInWithGoogle();

  /// Sign out
  Future<void> signOut();

  /// Get current user
  User? get currentUser;

  /// Get current user profile
  UserProfile? get currentUserProfile {
    final user = currentUser;
    if (user == null) return null;
    return UserProfile.fromFirebaseUser(user);
  }
}