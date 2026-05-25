import '../../domain/entities/album.dart';
import '../../domain/entities/album_group.dart';
import '../../domain/entities/sticker.dart';
import '../../domain/entities/team.dart';
import '../../domain/repositories/album_repository.dart';
import '../datasources/local/album_local_datasource.dart';

/// Implementation of AlbumRepository using local data source.
class AlbumRepositoryImpl implements AlbumRepository {
  final AlbumLocalDataSource _localDataSource;

  AlbumRepositoryImpl(this._localDataSource);

  @override
  Future<List<Album>> getAlbums() => _localDataSource.getAlbums();

  @override
  Future<Album?> getAlbumById(int id) => _localDataSource.getAlbumById(id);

  @override
  Future<List<AlbumGroup>> getGroupsForAlbum(int albumId) =>
      _localDataSource.getGroupsForAlbum(albumId);

  @override
  Future<List<Team>> getTeamsForGroup(int albumId, String groupId) =>
      _localDataSource.getTeamsForGroup(albumId, groupId);

  @override
  Future<Team?> getTeamById(int id) => _localDataSource.getTeamById(id);

  @override
  Future<List<Sticker>> getStickersForTeam(int teamId) =>
      _localDataSource.getStickersForTeam(teamId);

  @override
  Future<List<Sticker>> getStickersForAlbum(int albumId) =>
      _localDataSource.getStickersForAlbum(albumId);

  @override
  Future<bool> isAlbumsTableEmpty() => _localDataSource.isAlbumsTableEmpty();

  @override
  Future<int> getTotalStickerCount() => _localDataSource.getTotalStickerCount();

  /// Initialize database with seed data if needed.
  Future<void> initializeDatabase() => _localDataSource.seedIfNeeded();
}
