import 'package:equatable/equatable.dart';

import '../../domain/entities/album.dart';
import '../../domain/entities/album_group.dart';
import '../../domain/entities/sticker.dart';
import '../../domain/entities/team.dart';

enum AlbumStatus { initial, loading, loaded, error }

class AlbumState extends Equatable {
  final AlbumStatus status;
  final List<Album> albums;
  final Album? selectedAlbum;
  final List<AlbumGroup> groups;
  final AlbumGroup? selectedGroup;
  final List<Team> teams;
  final Team? selectedTeam;
  final List<Sticker> currentTeamStickers;
  final List<Sticker> allStickers;
  final String? errorMessage;

  const AlbumState({
    this.status = AlbumStatus.initial,
    this.albums = const [],
    this.selectedAlbum,
    this.groups = const [],
    this.selectedGroup,
    this.teams = const [],
    this.selectedTeam,
    this.currentTeamStickers = const [],
    this.allStickers = const [],
    this.errorMessage,
  });

  List<int> get allStickerIds => allStickers.map((s) => s.id).toList();

  @override
  List<Object?> get props => [
    status,
    albums,
    selectedAlbum,
    groups,
    selectedGroup,
    teams,
    selectedTeam,
    currentTeamStickers,
    allStickers,
    errorMessage,
  ];

  AlbumState copyWith({
    AlbumStatus? status,
    List<Album>? albums,
    Album? selectedAlbum,
    bool clearSelectedAlbum = false,
    List<AlbumGroup>? groups,
    AlbumGroup? selectedGroup,
    bool clearSelectedGroup = false,
    List<Team>? teams,
    Team? selectedTeam,
    bool clearSelectedTeam = false,
    List<Sticker>? currentTeamStickers,
    List<Sticker>? allStickers,
    String? errorMessage,
  }) {
    return AlbumState(
      status: status ?? this.status,
      albums: albums ?? this.albums,
      selectedAlbum: clearSelectedAlbum
          ? null
          : (selectedAlbum ?? this.selectedAlbum),
      groups: groups ?? this.groups,
      selectedGroup: clearSelectedGroup
          ? null
          : (selectedGroup ?? this.selectedGroup),
      teams: teams ?? this.teams,
      selectedTeam: clearSelectedTeam
          ? null
          : (selectedTeam ?? this.selectedTeam),
      currentTeamStickers: currentTeamStickers ?? this.currentTeamStickers,
      allStickers: allStickers ?? this.allStickers,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
