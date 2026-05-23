import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/section.dart';
import '../../domain/entities/sticker.dart';
import '../../data/repositories/album_repository_impl.dart';
import 'album_state.dart';

/// Cubit for managing album state
class AlbumCubit extends Cubit<AlbumState> {
  final AlbumRepositoryImpl _repository;

  AlbumCubit(this._repository) : super(const AlbumState());

  /// Load albums and initialize database if needed
  Future<void> loadAlbums() async {
    emit(state.copyWith(status: AlbumStatus.loading));

    try {
      // Seed database if needed
      await _repository.initializeDatabase();
      
      // Load albums
      final albums = await _repository.getAlbums();
      
      emit(state.copyWith(
        status: AlbumStatus.loaded,
        albums: albums,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AlbumStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Select an album and load its sections
  Future<void> selectAlbum(int albumId) async {
    emit(state.copyWith(status: AlbumStatus.loading));

    try {
      final album = await _repository.getAlbumById(albumId);
      if (album == null) {
        emit(state.copyWith(
          status: AlbumStatus.error,
          errorMessage: 'Album not found',
        ));
        return;
      }

      final sections = await _repository.getSectionsForAlbum(albumId);

      emit(state.copyWith(
        status: AlbumStatus.loaded,
        selectedAlbum: album,
        sections: sections,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AlbumStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Select a section and load its stickers
  Future<void> selectSection(int sectionId) async {
    emit(state.copyWith(status: AlbumStatus.loading));

    try {
      final section = await _repository.getSectionById(sectionId);
      if (section == null) {
        emit(state.copyWith(
          status: AlbumStatus.error,
          errorMessage: 'Section not found',
        ));
        return;
      }

      final stickers = await _repository.getStickersForSection(sectionId);

      emit(state.copyWith(
        status: AlbumStatus.loaded,
        selectedSection: section,
        currentSectionStickers: stickers,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AlbumStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Clear selected section
  void clearSection() {
    emit(state.copyWith(
      clearSelectedSection: true,
      currentSectionStickers: [],
    ));
  }

  /// Clear selected album
  void clearAlbum() {
    emit(state.copyWith(
      clearSelectedAlbum: true,
      sections: [],
      clearSelectedSection: true,
      currentSectionStickers: [],
    ));
  }

  /// Get total sticker count
  Future<int> getTotalStickerCount() => _repository.getTotalStickerCount();
}