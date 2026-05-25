import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../../../core/constants/app_constants.dart';
import '../../../../../database/app_database.dart';
import '../../../domain/entities/album.dart' as entity;
import '../../../domain/entities/section.dart' as entity;
import '../../../domain/entities/sticker.dart' as entity;

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

    final seed = await _loadSeedAlbum();

    await _db.transaction(() async {
      final albumId = await _db.insertAlbum(
        AlbumsCompanion(
          name: Value(seed.name),
          publisher: Value(seed.publisher),
          description: Value(seed.description),
          totalStickers: Value(seed.totalStickers),
        ),
      );

      for (final sectionData in seed.sections) {
        final sectionId = await _db.insertSection(
          SectionsCompanion(
            albumId: Value(albumId),
            name: Value(sectionData.name),
            orderIndex: Value(sectionData.orderIndex),
          ),
        );

        for (final stickerData in sectionData.stickers) {
          await _db.insertSticker(
            StickersCompanion(
              sectionId: Value(sectionId),
              stickerNumber: Value(stickerData.number),
              name: Value(stickerData.name),
              isSpecial: Value(stickerData.isSpecial),
            ),
          );
        }
      }

      final stickerIds = await _getAllStickerIds(albumId);
      if (stickerIds.isNotEmpty) {
        await _db.initializeDefaultStatuses(
          AppConstants.defaultUserId,
          stickerIds,
        );
      }
    });
  }

  Future<_SeedAlbum> _loadSeedAlbum() async {
    final rawJson = await rootBundle.loadString('assets/album.json');
    final jsonMap = jsonDecode(rawJson) as Map<String, dynamic>;
    final albumMap = jsonMap['album'] as Map<String, dynamic>;
    final sectionsJson = albumMap['secciones'] as List<dynamic>;

    final sections = <_SeedSection>[];
    var orderIndex = 0;

    for (final dynamic sectionEntry in sectionsJson) {
      final sectionMap = sectionEntry as Map<String, dynamic>;
      final groupName = sectionMap['grupo'] as String;
      final teamEntries = sectionMap['equipos'] as List<dynamic>?;

      if (teamEntries != null) {
        for (final dynamic teamEntry in teamEntries) {
          final teamMap = teamEntry as Map<String, dynamic>;
          final teamName = teamMap['pais'] as String;
          final codes = (teamMap['codigos'] as List<dynamic>).cast<String>();

          sections.add(
            _SeedSection(
              name: '$groupName - $teamName',
              orderIndex: orderIndex++,
              stickers: codes
                  .map(
                    (code) => _SeedSticker(
                      number: code,
                      name: code,
                      isSpecial: false,
                    ),
                  )
                  .toList(),
            ),
          );
        }
        continue;
      }

      final sectionName = sectionMap['nombre'] as String? ?? groupName;
      final codes = (sectionMap['codigos'] as List<dynamic>).cast<String>();
      final isSpecialSection = groupName == 'Especiales';

      sections.add(
        _SeedSection(
          name: sectionName,
          orderIndex: orderIndex++,
          stickers: codes
              .map(
                (code) => _SeedSticker(
                  number: code,
                  name: code,
                  isSpecial: isSpecialSection,
                ),
              )
              .toList(),
        ),
      );
    }

    final countedTotal = sections.fold<int>(
      0,
      (sum, section) => sum + section.stickers.length,
    );
    final declaredTotal = albumMap['total_figuras'] as int;

    return _SeedAlbum(
      name: 'Panini FIFA World Cup 2026',
      publisher: 'Panini',
      description:
          'Official FIFA World Cup USA-Canada-Mexico 2026 Sticker Album',
      totalStickers: countedTotal == declaredTotal
          ? declaredTotal
          : countedTotal,
      sections: sections,
    );
  }

  Future<List<int>> _getAllStickerIds(int albumId) async {
    final sectionList = await _db.getSectionsForAlbum(albumId);
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

class _SeedAlbum {
  final String name;
  final String publisher;
  final String description;
  final int totalStickers;
  final List<_SeedSection> sections;

  const _SeedAlbum({
    required this.name,
    required this.publisher,
    required this.description,
    required this.totalStickers,
    required this.sections,
  });
}

class _SeedSection {
  final String name;
  final int orderIndex;
  final List<_SeedSticker> stickers;

  const _SeedSection({
    required this.name,
    required this.orderIndex,
    required this.stickers,
  });
}

class _SeedSticker {
  final String number;
  final String name;
  final bool isSpecial;

  const _SeedSticker({
    required this.number,
    required this.name,
    required this.isSpecial,
  });
}
