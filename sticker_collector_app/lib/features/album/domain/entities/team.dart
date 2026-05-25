import 'package:equatable/equatable.dart';

/// Team node inside an album group.
class Team extends Equatable {
  final int id;
  final int albumId;
  final String groupId;
  final String groupName;
  final String name;
  final int orderIndex;
  final int stickerCount;
  final List<int> stickerIds;

  const Team({
    required this.id,
    required this.albumId,
    required this.groupId,
    required this.groupName,
    required this.name,
    required this.orderIndex,
    required this.stickerCount,
    this.stickerIds = const [],
  });

  String get fullName => groupName == name ? name : '$groupName - $name';

  @override
  List<Object?> get props => [
    id,
    albumId,
    groupId,
    groupName,
    name,
    orderIndex,
    stickerCount,
    stickerIds,
  ];
}
