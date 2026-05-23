import '../../domain/entities/album.dart';
import '../../domain/entities/section.dart';
import '../../domain/entities/sticker.dart';
import '../../domain/repositories/album_repository.dart';
import '../datasources/local/album_local_datasource.dart';

/// Implementation of AlbumRepository using local data source
class AlbumRepositoryImpl implements AlbumRepository {
  final AlbumLocalDataSource _localDataSource;

  AlbumRepositoryImpl(this._localDataSource);

  @override
  Future<List<Album>> getAlbums() => _localDataSource.getAlbums();

  @override
  Future<Album?> getAlbumById(int id) => _localDataSource.getAlbumById(id);

  @override
  Future<List<Section>> getSectionsForAlbum(int albumId) =>
      _localDataSource.getSectionsForAlbum(albumId);

  @override
  Future<Section?> getSectionById(int id) => _localDataSource.getSectionById(id);

  @override
  Future<List<Sticker>> getStickersForSection(int sectionId) =>
      _localDataSource.getStickersForSection(sectionId);

  @override
  Future<List<Sticker>> getStickersForAlbum(int albumId) =>
      _localDataSource.getStickersForAlbum(albumId);

  @override
  Future<bool> isAlbumsTableEmpty() => _localDataSource.isAlbumsTableEmpty();

  @override
  Future<int> getTotalStickerCount() => _localDataSource.getTotalStickerCount();

  /// Initialize database with seed data if needed
  Future<void> initializeDatabase() => _localDataSource.seedIfNeeded();
}