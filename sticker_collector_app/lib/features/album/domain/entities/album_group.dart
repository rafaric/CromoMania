import 'package:equatable/equatable.dart';

/// Group of teams inside an album.
class AlbumGroup extends Equatable {
  final String id;
  final int albumId;
  final String name;
  final int orderIndex;
  final int teamCount;
  final int stickerCount;

  const AlbumGroup({
    required this.id,
    required this.albumId,
    required this.name,
    required this.orderIndex,
    required this.teamCount,
    required this.stickerCount,
  });

  @override
  List<Object?> get props => [
    id,
    albumId,
    name,
    orderIndex,
    teamCount,
    stickerCount,
  ];
}
