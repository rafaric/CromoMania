import 'package:drift/drift.dart';
import '../../../../../database/app_database.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../domain/entities/album.dart' as entity;
import '../../../domain/entities/section.dart' as entity;
import '../../../domain/entities/sticker.dart' as entity;
import 'seed_data.dart';

/// Local data source for album operations with seeding support
class AlbumLocalDataSource {
  final AppDatabase _db;

  AlbumLocalDataSource(this._db);

  /// Check if albums table is empty
  Future<bool> isAlbumsTableEmpty() async {
    final count = await _db.countAlbums();
    return count == 0;
  }

  /// Seed database with WC 2026 album data
  Future<void> seedIfNeeded() async {
    if (!await isAlbumsTableEmpty()) return;

    await _db.transaction(() async {
      // 1. Insert album
      final albumId = await _db.insertAlbum(AlbumsCompanion(
        name: Value(SeedData.album['name'] as String),
        publisher: Value(SeedData.album['publisher'] as String),
        description: Value(SeedData.album['description'] as String),
        totalStickers: Value(SeedData.album['totalStickers'] as int),
      ));

      // 2. Insert sections and stickers
      for (final sectionData in SeedData.sections) {
        final sectionId = await _db.insertSection(SectionsCompanion(
          albumId: Value(albumId),
          name: Value(sectionData['name'] as String),
          orderIndex: Value(sectionData['orderIndex'] as int),
        ));

        // Insert stickers for this section
        final sectionIndex = sectionData['orderIndex'] as int;
        final stickerList = SeedData.stickers[sectionIndex] ?? [];

        for (final stickerData in stickerList) {
          await _db.insertSticker(StickersCompanion(
            sectionId: Value(sectionId),
            stickerNumber: Value(stickerData['number'] as String),
            name: Value(stickerData['name'] as String),
            isSpecial: Value(stickerData['isSpecial'] as bool),
          ));
        }
      }

      // 3. Initialize collection statuses for all stickers
      final stickerIds = await _getAllStickerIds();
      if (stickerIds.isNotEmpty) {
        await _db.initializeDefaultStatuses(AppConstants.defaultUserId, stickerIds);
      }
    });
  }

  Future<List<int>> _getAllStickerIds() async {
    final sectionList = await _db.getSectionsForAlbum(1);
    final stickerIds = <int>[];
    for (final section in sectionList) {
      final stickers = await _db.getStickersForSection(section.id);
      stickerIds.addAll(stickers.map((s) => s.id));
    }
    return stickerIds;
  }

  // ============== Read Operations ==============

  /// Get all albums
  Future<List<entity.Album>> getAlbums() async {
    final albums = await _db.getAllAlbums();
    return albums.map(_mapAlbumToEntity).toList();
  }

  /// Get album by ID
  Future<entity.Album?> getAlbumById(int id) async {
    final album = await _db.getAlbumById(id);
    return album != null ? _mapAlbumToEntity(album) : null;
  }

  /// Get all sections for an album
  Future<List<entity.Section>> getSectionsForAlbum(int albumId) async {
    final sections = await _db.getSectionsForAlbum(albumId);
    return sections.map(_mapSectionToEntity).toList();
  }

  /// Get section by ID
  Future<entity.Section?> getSectionById(int id) async {
    final section = await _db.getSectionById(id);
    return section != null ? _mapSectionToEntity(section) : null;
  }

  /// Get all stickers for a section
  Future<List<entity.Sticker>> getStickersForSection(int sectionId) async {
    final stickers = await _db.getStickersForSection(sectionId);
    return stickers.map(_mapStickerToEntity).toList();
  }

  /// Get all stickers for an album
  Future<List<entity.Sticker>> getStickersForAlbum(int albumId) async {
    final stickers = await _db.getStickersForAlbum(albumId);
    return stickers.map(_mapStickerToEntity).toList();
  }

  /// Get total sticker count
  Future<int> getTotalStickerCount() async {
    return await _db.countAllStickers();
  }

  // ============== Mappers ==============

  entity.Album _mapAlbumToEntity(Album album) {
    return entity.Album(
      id: album.id,
      name: album.name,
      publisher: album.publisher,
      description: album.description,
      totalStickers: album.totalStickers,
      createdAt: album.createdAt,
    );
  }

  entity.Section _mapSectionToEntity(Section section) {
    return entity.Section(
      id: section.id,
      albumId: section.albumId,
      name: section.name,
      orderIndex: section.orderIndex,
    );
  }

  entity.Sticker _mapStickerToEntity(Sticker sticker) {
    return entity.Sticker(
      id: sticker.id,
      sectionId: sticker.sectionId,
      stickerNumber: sticker.stickerNumber,
      name: sticker.name,
      isSpecial: sticker.isSpecial,
    );
  }
}