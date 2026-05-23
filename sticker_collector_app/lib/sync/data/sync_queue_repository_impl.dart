import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../domain/sync_status.dart';

/// Repository interface for sync queue operations
abstract class SyncQueueRepository {
  /// Add an item to the sync queue
  Future<int> addToQueue({
    required String stickerId,
    required String operation,
    required String payload,
  });

  /// Get all pending items
  Future<List<Map<String, dynamic>>> getPendingItems();

  /// Mark an item as processed
  Future<void> markAsProcessed(int id);

  /// Increment retry count for an item
  Future<void> incrementRetry(int id);

  /// Mark an item as failed
  Future<void> markAsFailed(int id, String error);

  /// Get count of pending items
  Future<int> getPendingCount();

  /// Clean up processed items
  Future<void> cleanupProcessed();
}

/// Implementation of SyncQueueRepository using Drift database
class SyncQueueRepositoryImpl implements SyncQueueRepository {
  final AppDatabase _database;

  SyncQueueRepositoryImpl(this._database);

  @override
  Future<int> addToQueue({
    required String stickerId,
    required String operation,
    required String payload,
  }) async {
    return _database.insertSyncQueueItem(
      SyncQueueItemsCompanion(
        stickerId: Value(stickerId),
        operation: Value(operation),
        payload: Value(payload),
        retryCount: const Value(0),
        status: const Value('pending'),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingItems() async {
    final dbItems = await _database.getPendingSyncItems();
    
    return dbItems.map((dbItem) => {
      'id': dbItem.id,
      'stickerId': dbItem.stickerId,
      'operation': dbItem.operation,
      'payload': dbItem.payload,
      'retryCount': dbItem.retryCount,
      'status': dbItem.status,
      'createdAt': dbItem.createdAt,
      'processedAt': dbItem.processedAt,
    }).toList();
  }

  @override
  Future<void> markAsProcessed(int id) async {
    await _database.markSyncItemProcessed(id);
  }

  @override
  Future<void> incrementRetry(int id) async {
    await _database.incrementSyncRetryCount(id);
  }

  @override
  Future<void> markAsFailed(int id, String error) async {
    await _database.markSyncItemFailed(id);
  }

  @override
  Future<int> getPendingCount() async {
    return _database.getPendingSyncCount();
  }

  @override
  Future<void> cleanupProcessed() async {
    await _database.deleteProcessedSyncItems();
  }
}