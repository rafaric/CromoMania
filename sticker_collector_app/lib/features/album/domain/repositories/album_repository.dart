import '../entities/album.dart';
import '../entities/section.dart';
import '../entities/sticker.dart';

/// Repository interface for album operations
abstract class AlbumRepository {
  /// Get all albums
  Future<List<Album>> getAlbums();

  /// Get album by ID
  Future<Album?> getAlbumById(int id);

  /// Get all sections for an album
  Future<List<Section>> getSectionsForAlbum(int albumId);

  /// Get section by ID
  Future<Section?> getSectionById(int id);

  /// Get all stickers for a section
  Future<List<Sticker>> getStickersForSection(int sectionId);

  /// Get all stickers for an album
  Future<List<Sticker>> getStickersForAlbum(int albumId);

  /// Check if albums table is empty
  Future<bool> isAlbumsTableEmpty();

  /// Get total sticker count
  Future<int> getTotalStickerCount();
}