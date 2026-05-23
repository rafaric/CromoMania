import 'package:drift/drift.dart';

/// Sync queue table for managing offline-first sync operations.
/// Each row represents a pending change that needs to be synced to Firestore.
class SyncQueueItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get stickerId => text()();
  TextColumn get operation => text()(); // 'upsert' or 'delete'
  TextColumn get payload => text()(); // JSON-encoded sticker data
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get processedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [{id}];
}