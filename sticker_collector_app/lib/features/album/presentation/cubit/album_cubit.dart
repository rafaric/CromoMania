import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/album_repository_impl.dart';
import 'album_state.dart';

/// Cubit for managing album hierarchy state.
class AlbumCubit extends Cubit<AlbumState> {
  final AlbumRepositoryImpl _repository;

  AlbumCubit(this._repository) : super(const AlbumState());

  Future<void> loadAlbums() async {
    emit(state.copyWith(status: AlbumStatus.loading));

    try {
      await _repository.initializeDatabase();
      final albums = await _repository.getAlbums();
      emit(state.copyWith(status: AlbumStatus.loaded, albums: albums));
    } catch (e) {
      emit(
        state.copyWith(status: AlbumStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> selectAlbum(int albumId) async {
    emit(state.copyWith(status: AlbumStatus.loading));

    try {
      final album = await _repository.getAlbumById(albumId);
      if (album == null) {
        emit(
          state.copyWith(
            status: AlbumStatus.error,
            errorMessage: 'Album not found',
          ),
        );
        return;
      }

      final groups = await _repository.getGroupsForAlbum(albumId);
      final allStickers = await _repository.getStickersForAlbum(albumId);

      emit(
        state.copyWith(
          status: AlbumStatus.loaded,
          selectedAlbum: album,
          groups: groups,
          teams: const [],
          allStickers: allStickers,
          clearSelectedGroup: true,
          clearSelectedTeam: true,
          currentTeamStickers: const [],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AlbumStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> selectGroup(String groupId) async {
    final album = state.selectedAlbum;
    if (album == null) return;

    emit(state.copyWith(status: AlbumStatus.loading));

    try {
      final group = state.groups.where((g) => g.id == groupId).firstOrNull;
      if (group == null) {
        emit(
          state.copyWith(
            status: AlbumStatus.error,
            errorMessage: 'Group not found',
          ),
        );
        return;
      }

      final teams = await _repository.getTeamsForGroup(album.id, groupId);
      emit(
        state.copyWith(
          status: AlbumStatus.loaded,
          selectedGroup: group,
          teams: teams,
          clearSelectedTeam: true,
          currentTeamStickers: const [],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AlbumStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> selectTeam(int teamId) async {
    emit(state.copyWith(status: AlbumStatus.loading));

    try {
      final team = await _repository.getTeamById(teamId);
      if (team == null) {
        emit(
          state.copyWith(
            status: AlbumStatus.error,
            errorMessage: 'Team not found',
          ),
        );
        return;
      }

      final stickers = await _repository.getStickersForTeam(teamId);
      emit(
        state.copyWith(
          status: AlbumStatus.loaded,
          selectedTeam: team,
          currentTeamStickers: stickers,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AlbumStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void clearTeam() {
    emit(
      state.copyWith(clearSelectedTeam: true, currentTeamStickers: const []),
    );
  }

  void clearGroup() {
    emit(
      state.copyWith(
        clearSelectedGroup: true,
        teams: const [],
        clearSelectedTeam: true,
        currentTeamStickers: const [],
      ),
    );
  }

  void clearAlbum() {
    emit(
      state.copyWith(
        clearSelectedAlbum: true,
        groups: const [],
        clearSelectedGroup: true,
        teams: const [],
        clearSelectedTeam: true,
        currentTeamStickers: const [],
      ),
    );
  }

  Future<int> getTotalStickerCount() => _repository.getTotalStickerCount();
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
