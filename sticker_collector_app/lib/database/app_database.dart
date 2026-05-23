import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables/albums_table.dart';
import 'tables/sections_table.dart';
import 'tables/stickers_table.dart';
import 'tables/collection_status_table.dart';

part 'app_database.g.dart';

/// Main application database using Drift
@DriftDatabase(tables: [Albums, Sections, Stickers, CollectionStatuses])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For testing: inject a query executor
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations go here
      },
    );
  }

  // ============== Album Operations ==============

  /// Get all albums
  Future<List<Album>> getAllAlbums() => select(albums).get();

  /// Get album by ID
  Future<Album?> getAlbumById(int id) =>
      (select(albums)..where((a) => a.id.equals(id))).getSingleOrNull();

  /// Count albums (for seeding decision)
  Future<int> countAlbums() => select(albums).get().then((r) => r.length);

  /// Insert album and return ID
  Future<int> insertAlbum(AlbumsCompanion album) =>
      into(albums).insert(album);

  // ============== Section Operations ==============

  /// Get all sections for an album
  Future<List<Section>> getSectionsForAlbum(int albumId) =>
      (select(sections)
            ..where((s) => s.albumId.equals(albumId))
            ..orderBy([(s) => OrderingTerm.asc(s.orderIndex)]))
          .get();

  /// Get section by ID
  Future<Section?> getSectionById(int id) =>
      (select(sections)..where((s) => s.id.equals(id))).getSingleOrNull();

  /// Insert section and return ID
  Future<int> insertSection(SectionsCompanion section) =>
      into(sections).insert(section);

  // ============== Sticker Operations ==============

  /// Get all stickers for a section
  Future<List<Sticker>> getStickersForSection(int sectionId) =>
      (select(stickers)..where((s) => s.sectionId.equals(sectionId))).get();

  /// Get all stickers for an album
  Future<List<Sticker>> getStickersForAlbum(int albumId) async {
    final albumSections = await getSectionsForAlbum(albumId);
    final allStickers = <Sticker>[];
    for (final section in albumSections) {
      final sectionStickers = await getStickersForSection(section.id);
      allStickers.addAll(sectionStickers);
    }
    return allStickers;
  }

  /// Get sticker by ID
  Future<Sticker?> getStickerById(int id) =>
      (select(stickers)..where((s) => s.id.equals(id))).getSingleOrNull();

  /// Insert sticker and return ID
  Future<int> insertSticker(StickersCompanion sticker) =>
      into(stickers).insert(sticker);

  /// Count all stickers
  Future<int> countAllStickers() => select(stickers).get().then((r) => r.length);

  // ============== Collection Status Operations ==============

  /// Get all collection statuses for a user
  Future<List<CollectionStatuse>> getStatusesForUser(String userId) =>
      (select(collectionStatuses)..where((c) => c.userId.equals(userId))).get();

  /// Get status map for quick lookup (stickerId -> status)
  Future<Map<int, CollectionStatuse>> getStatusMap(String userId) async {
    final statuses = await getStatusesForUser(userId);
    return {for (var s in statuses) s.stickerId: s};
  }

  /// Get status for a specific sticker
  Future<CollectionStatuse?> getStatusForSticker(
      int stickerId, String userId) =>
      (select(collectionStatuses)
            ..where((c) =>
                c.stickerId.equals(stickerId) & c.userId.equals(userId)))
          .getSingleOrNull();

  /// Insert or update collection status
  Future<int> upsertCollectionStatus(CollectionStatusesCompanion status) =>
      into(collectionStatuses).insertOnConflictUpdate(status);

  /// Initialize default statuses for all stickers
  Future<void> initializeDefaultStatuses(
      String userId, List<int> stickerIds) async {
    await batch((batch) {
      batch.insertAll(
        collectionStatuses,
        stickerIds
            .map((id) => CollectionStatusesCompanion(
                  stickerId: Value(id),
                  userId: Value(userId),
                  count: const Value(0),
                ))
            .toList(),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sticker_collector.db'));
    return NativeDatabase.createInBackground(file);
  });
}