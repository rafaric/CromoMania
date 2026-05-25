import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../../../core/constants/app_constants.dart';
import '../../../../../database/app_database.dart';
import '../../../domain/entities/album.dart' as entity;
import '../../../domain/entities/album_group.dart' as entity;
import '../../../domain/entities/sticker.dart' as entity;
import '../../../domain/entities/team.dart' as entity;

/// Local data source for album operations with seeding support.
class AlbumLocalDataSource {
  final AppDatabase _db;

  AlbumLocalDataSource(this._db);

  Future<bool> isAlbumsTableEmpty() async {
    final count = await _db.countAlbums();
    return count == 0;
  }

  Future<void> seedIfNeeded() async {
    if (!await isAlbumsTableEmpty()) return;

    final dataset = await _loadDataset();

    await _db.transaction(() async {
      final albumId = await _db.insertAlbum(
        AlbumsCompanion(
          name: Value(dataset.name),
          publisher: Value(dataset.publisher),
          description: Value(dataset.description),
          totalStickers: Value(dataset.totalStickers),
        ),
      );

      for (final team in dataset.flattenedTeams) {
        final sectionId = await _db.insertSection(
          SectionsCompanion(
            albumId: Value(albumId),
            name: Value(team.name),
            orderIndex: Value(team.orderIndex),
          ),
        );

        for (final sticker in team.stickers) {
          await _db.insertSticker(
            StickersCompanion(
              sectionId: Value(sectionId),
              stickerNumber: Value(sticker.number),
              name: Value(sticker.name),
              isSpecial: Value(sticker.isSpecial),
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

  Future<List<int>> _getAllStickerIds(int albumId) async {
    final sections = await _db.getSectionsForAlbum(albumId);
    final stickerIds = <int>[];
    for (final section in sections) {
      final stickers = await _db.getStickersForSection(section.id);
      stickerIds.addAll(stickers.map((s) => s.id));
    }
    return stickerIds;
  }

  Future<_AlbumDataset> _loadDataset() async {
    final rawJson = await rootBundle.loadString('assets/album.json');
    final jsonMap = jsonDecode(rawJson) as Map<String, dynamic>;
    final albumMap = jsonMap['album'] as Map<String, dynamic>;
    final sectionsJson = albumMap['secciones'] as List<dynamic>;

    final groups = <_SeedGroup>[];
    var teamOrder = 0;

    for (var groupIndex = 0; groupIndex < sectionsJson.length; groupIndex++) {
      final sectionMap = sectionsJson[groupIndex] as Map<String, dynamic>;
      final groupName =
          (sectionMap['nombre'] as String?) ?? (sectionMap['grupo'] as String);
      final groupId = sectionMap['grupo'] as String;
      final teamEntries = sectionMap['equipos'] as List<dynamic>?;

      if (teamEntries != null) {
        final teams = teamEntries.map((entry) {
          final teamMap = entry as Map<String, dynamic>;
          final codes = (teamMap['codigos'] as List<dynamic>).cast<String>();
          final teamName = teamMap['pais'] as String;
          return _SeedTeam(
            groupId: groupId,
            groupName: groupName,
            name: teamName,
            orderIndex: teamOrder++,
            stickers: codes
                .map(
                  (code) =>
                      _SeedSticker(number: code, name: code, isSpecial: false),
                )
                .toList(),
          );
        }).toList();

        groups.add(
          _SeedGroup(
            id: groupId,
            name: groupName,
            orderIndex: groupIndex,
            teams: teams,
          ),
        );
        continue;
      }

      final codes = (sectionMap['codigos'] as List<dynamic>).cast<String>();
      final isSpecialGroup = groupId == 'Especiales';
      groups.add(
        _SeedGroup(
          id: groupId,
          name: groupName,
          orderIndex: groupIndex,
          teams: [
            _SeedTeam(
              groupId: groupId,
              groupName: groupName,
              name: groupName,
              orderIndex: teamOrder++,
              stickers: codes
                  .map(
                    (code) => _SeedSticker(
                      number: code,
                      name: code,
                      isSpecial: isSpecialGroup,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      );
    }

    final countedTotal = groups.fold<int>(
      0,
      (sum, group) =>
          sum +
          group.teams.fold<int>(0, (tSum, team) => tSum + team.stickers.length),
    );
    final declaredTotal = albumMap['total_figuras'] as int;

    return _AlbumDataset(
      name: 'Panini FIFA World Cup 2026',
      publisher: 'Panini',
      description:
          'Official FIFA World Cup USA-Canada-Mexico 2026 Sticker Album',
      totalStickers: countedTotal == declaredTotal
          ? declaredTotal
          : countedTotal,
      groups: groups,
    );
  }

  Future<List<entity.Album>> getAlbums() async {
    final albums = await _db.getAllAlbums();
    return albums.map(_mapAlbumToEntity).toList();
  }

  Future<entity.Album?> getAlbumById(int id) async {
    final album = await _db.getAlbumById(id);
    return album != null ? _mapAlbumToEntity(album) : null;
  }

  Future<List<entity.AlbumGroup>> getGroupsForAlbum(int albumId) async {
    final dataset = await _loadDataset();
    return dataset.groups
        .map(
          (group) => entity.AlbumGroup(
            id: group.id,
            albumId: albumId,
            name: group.name,
            orderIndex: group.orderIndex,
            teamCount: group.teams.length,
            stickerCount: group.teams.fold<int>(
              0,
              (sum, team) => sum + team.stickers.length,
            ),
          ),
        )
        .toList();
  }

  Future<List<entity.Team>> getTeamsForGroup(
    int albumId,
    String groupId,
  ) async {
    final mappedTeams = await _mapPersistedTeams(albumId);
    return mappedTeams.where((team) => team.groupId == groupId).toList();
  }

  Future<entity.Team?> getTeamById(int id) async {
    final teamSection = await _db.getSectionById(id);
    if (teamSection == null) return null;

    final mappedTeams = await _mapPersistedTeams(teamSection.albumId);
    for (final team in mappedTeams) {
      if (team.id == id) return team;
    }
    return null;
  }

  Future<List<entity.Sticker>> getStickersForTeam(int teamId) async {
    final stickers = await _db.getStickersForSection(teamId);
    return stickers.map(_mapStickerToEntity).toList();
  }

  Future<List<entity.Sticker>> getStickersForAlbum(int albumId) async {
    final stickers = await _db.getStickersForAlbum(albumId);
    return stickers.map(_mapStickerToEntity).toList();
  }

  Future<int> getTotalStickerCount() async {
    return _db.countAllStickers();
  }

  Future<List<entity.Team>> _mapPersistedTeams(int albumId) async {
    final dataset = await _loadDataset();
    final sections = await _db.getSectionsForAlbum(albumId);
    final flattenedTeams = dataset.flattenedTeams;
    final limit = sections.length < flattenedTeams.length
        ? sections.length
        : flattenedTeams.length;
    final teams = <entity.Team>[];

    for (var index = 0; index < limit; index++) {
      final section = sections[index];
      final seedTeam = flattenedTeams[index];
      teams.add(
        entity.Team(
          id: section.id,
          albumId: albumId,
          groupId: seedTeam.groupId,
          groupName: seedTeam.groupName,
          name: seedTeam.name,
          orderIndex: seedTeam.orderIndex,
          stickerCount: seedTeam.stickers.length,
        ),
      );
    }

    return teams;
  }

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

class _AlbumDataset {
  final String name;
  final String publisher;
  final String description;
  final int totalStickers;
  final List<_SeedGroup> groups;

  const _AlbumDataset({
    required this.name,
    required this.publisher,
    required this.description,
    required this.totalStickers,
    required this.groups,
  });

  List<_SeedTeam> get flattenedTeams => [
    for (final group in groups) ...group.teams,
  ];
}

class _SeedGroup {
  final String id;
  final String name;
  final int orderIndex;
  final List<_SeedTeam> teams;

  const _SeedGroup({
    required this.id,
    required this.name,
    required this.orderIndex,
    required this.teams,
  });
}

class _SeedTeam {
  final String groupId;
  final String groupName;
  final String name;
  final int orderIndex;
  final List<_SeedSticker> stickers;

  const _SeedTeam({
    required this.groupId,
    required this.groupName,
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
