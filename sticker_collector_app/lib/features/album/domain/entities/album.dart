import 'package:equatable/equatable.dart';

/// Album entity representing a sticker album template
class Album extends Equatable {
  final int id;
  final String name;
  final String? publisher;
  final String? description;
  final int totalStickers;
  final DateTime createdAt;

  const Album({
    required this.id,
    required this.name,
    this.publisher,
    this.description,
    required this.totalStickers,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, publisher, description, totalStickers, createdAt];

  Album copyWith({
    int? id,
    String? name,
    String? publisher,
    String? description,
    int? totalStickers,
    DateTime? createdAt,
  }) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      publisher: publisher ?? this.publisher,
      description: description ?? this.description,
      totalStickers: totalStickers ?? this.totalStickers,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}