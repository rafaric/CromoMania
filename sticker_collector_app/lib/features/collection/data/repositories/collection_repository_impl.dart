import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/collection_status.dart' as entity;
import '../../domain/repositories/collection_repository.dart';

/// Implementation of CollectionRepository using local data source
class CollectionRepositoryImpl implements CollectionRepository {
  final AppDatabase _db;

  CollectionRepositoryImpl(this._db);

  @override
  Future<List<entity.CollectionStatus>> getStatusesForUser(String userId) async {
    final statuses = await _db.getStatusesForUser(userId);
    return statuses.map(_mapStatusToEntity).toList();
  }

  @override
  Future<Map<int, entity.CollectionStatus>> getStatusMap(String userId) async {
    final statuses = await _db.getStatusMap(userId);
    return statuses.map(
      (key, value) => MapEntry(key, _mapStatusToEntity(value)),
    );
  }

  @override
  Future<entity.CollectionStatus?> getStatusForSticker(
      int stickerId, String userId) async {
    final status = await _db.getStatusForSticker(stickerId, userId);
    return status != null ? _mapStatusToEntity(status) : null;
  }

  @override
  Future<void> saveStatus(entity.CollectionStatus status) async {
    await _db.upsertCollectionStatus(CollectionStatusesCompanion(
      stickerId: Value(status.stickerId),
      userId: Value(status.userId),
      count: Value(status.count),
    ));
  }

  @override
  Future<void> saveStatuses(List<entity.CollectionStatus> statuses) async {
    for (final status in statuses) {
      await saveStatus(status);
    }
  }

  @override
  Future<void> initializeDefaultStatuses(
      String userId, List<int> stickerIds) async {
    await _db.initializeDefaultStatuses(userId, stickerIds);
  }

  // ============== Mappers ==============

  entity.CollectionStatus _mapStatusToEntity(CollectionStatuse status) {
    return entity.CollectionStatus(
      id: status.id,
      stickerId: status.stickerId,
      userId: status.userId,
      count: status.count,
    );
  }
}