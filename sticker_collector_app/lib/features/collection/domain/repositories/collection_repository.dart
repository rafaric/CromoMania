import '../entities/collection_status.dart';

/// Repository interface for collection operations
abstract class CollectionRepository {
  /// Get all collection statuses for a user
  Future<List<CollectionStatus>> getStatusesForUser(String userId);

  /// Get status map for quick lookup (stickerId -> status)
  Future<Map<int, CollectionStatus>> getStatusMap(String userId);

  /// Get status for a specific sticker
  Future<CollectionStatus?> getStatusForSticker(int stickerId, String userId);

  /// Save or update collection status
  Future<void> saveStatus(CollectionStatus status);

  /// Batch save collection statuses
  Future<void> saveStatuses(List<CollectionStatus> statuses);

  /// Initialize default status for all stickers (for new user)
  Future<void> initializeDefaultStatuses(String userId, List<int> stickerIds);
}