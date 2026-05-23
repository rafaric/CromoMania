import 'package:equatable/equatable.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/section.dart';
import '../../domain/entities/sticker.dart';

/// Album state status
enum AlbumStatus { initial, loading, loaded, error }

/// Album feature state
class AlbumState extends Equatable {
  final AlbumStatus status;
  final List<Album> albums;
  final Album? selectedAlbum;
  final List<Section> sections;
  final Section? selectedSection;
  final List<Sticker> currentSectionStickers;
  final String? errorMessage;

  const AlbumState({
    this.status = AlbumStatus.initial,
    this.albums = const [],
    this.selectedAlbum,
    this.sections = const [],
    this.selectedSection,
    this.currentSectionStickers = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        status,
        albums,
        selectedAlbum,
        sections,
        selectedSection,
        currentSectionStickers,
        errorMessage,
      ];

  AlbumState copyWith({
    AlbumStatus? status,
    List<Album>? albums,
    Album? selectedAlbum,
    bool clearSelectedAlbum = false,
    List<Section>? sections,
    Section? selectedSection,
    bool clearSelectedSection = false,
    List<Sticker>? currentSectionStickers,
    String? errorMessage,
  }) {
    return AlbumState(
      status: status ?? this.status,
      albums: albums ?? this.albums,
      selectedAlbum: clearSelectedAlbum ? null : (selectedAlbum ?? this.selectedAlbum),
      sections: sections ?? this.sections,
      selectedSection: clearSelectedSection ? null : (selectedSection ?? this.selectedSection),
      currentSectionStickers: currentSectionStickers ?? this.currentSectionStickers,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}