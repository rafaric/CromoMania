import 'package:equatable/equatable.dart';

/// Section entity representing a group of stickers within an album
class Section extends Equatable {
  final int id;
  final int albumId;
  final String name;
  final int orderIndex;

  const Section({
    required this.id,
    required this.albumId,
    required this.name,
    required this.orderIndex,
  });

  @override
  List<Object?> get props => [id, albumId, name, orderIndex];

  Section copyWith({
    int? id,
    int? albumId,
    String? name,
    int? orderIndex,
  }) {
    return Section(
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
      name: name ?? this.name,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}