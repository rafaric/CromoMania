import '../entities/album.dart';
import '../entities/album_group.dart';
import '../entities/sticker.dart';
import '../entities/team.dart';

/// Repository interface for album operations.
abstract class AlbumRepository {
  Future<List<Album>> getAlbums();

  Future<Album?> getAlbumById(int id);

  Future<List<AlbumGroup>> getGroupsForAlbum(int albumId);

  Future<List<Team>> getTeamsForGroup(int albumId, String groupId);

  Future<Team?> getTeamById(int id);

  Future<List<Sticker>> getStickersForTeam(int teamId);

  Future<List<Sticker>> getStickersForAlbum(int albumId);

  Future<bool> isAlbumsTableEmpty();

  Future<int> getTotalStickerCount();
}
