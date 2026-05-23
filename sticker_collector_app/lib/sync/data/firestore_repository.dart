import 'package:cloud_firestore/cloud_firestore.dart';

/// Repository interface for Firestore operations
abstract class FirestoreRepository {
  /// Upsert a sticker document
  Future<void> upsertSticker(String uid, String stickerId, Map<String, dynamic> data);

  /// Delete a sticker document
  Future<void> deleteSticker(String uid, String stickerId);

  /// Get a single sticker document
  Future<Map<String, dynamic>?> getSticker(String uid, String stickerId);

  /// Get all stickers for a user
  Future<Map<String, dynamic>> getAllStickers(String uid);

  /// Watch stickers collection for real-time updates
  Stream<QuerySnapshot> watchStickers(String uid);

  /// Update user profile
  Future<void> updateProfile(String uid, Map<String, dynamic> data);

  /// Get user profile
  Future<Map<String, dynamic>?> getProfile(String uid);
}

/// Firestore implementation of FirestoreRepository
class FirestoreRepositoryImpl implements FirestoreRepository {
  final FirebaseFirestore _firestore;

  FirestoreRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get user stickers collection reference
  CollectionReference<Map<String, dynamic>> _stickersCollection(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('stickers');
  }

  /// Get user profile document reference
  DocumentReference<Map<String, dynamic>> _profileDoc(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('me');
  }

  @override
  Future<void> upsertSticker(
    String uid,
    String stickerId,
    Map<String, dynamic> data,
  ) async {
    final docRef = _stickersCollection(uid).doc(stickerId);
    await docRef.set(data, SetOptions(merge: true));
  }

  @override
  Future<void> deleteSticker(String uid, String stickerId) async {
    final docRef = _stickersCollection(uid).doc(stickerId);
    await docRef.delete();
  }

  @override
  Future<Map<String, dynamic>?> getSticker(
    String uid,
    String stickerId,
  ) async {
    final docRef = _stickersCollection(uid).doc(stickerId);
    final doc = await docRef.get();
    return doc.data();
  }

  @override
  Future<Map<String, dynamic>> getAllStickers(String uid) async {
    final snapshot = await _stickersCollection(uid).get();
    final result = <String, dynamic>{};
    for (final doc in snapshot.docs) {
      result[doc.id] = doc.data();
    }
    return result;
  }

  @override
  Stream<QuerySnapshot> watchStickers(String uid) {
    return _stickersCollection(uid).snapshots();
  }

  @override
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    final docRef = _profileDoc(uid);
    await docRef.set(data, SetOptions(merge: true));
  }

  @override
  Future<Map<String, dynamic>?> getProfile(String uid) async {
    final doc = await _profileDoc(uid).get();
    return doc.data();
  }
}