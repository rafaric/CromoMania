import 'package:equatable/equatable.dart';

/// User profile entity representing authenticated Firebase user
class UserProfile extends Equatable {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final DateTime? createdAt;

  const UserProfile({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.createdAt,
  });

  /// Create from Firebase User
  factory UserProfile.fromFirebaseUser(dynamic user) {
    return UserProfile(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestoreMap() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Create from Firestore document
  factory UserProfile.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      displayName: data['displayName'] as String?,
      email: data['email'] as String?,
      photoUrl: data['photoUrl'] as String?,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [uid, displayName, email, photoUrl, createdAt];
}