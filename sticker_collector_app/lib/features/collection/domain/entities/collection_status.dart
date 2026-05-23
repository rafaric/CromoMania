import 'package:equatable/equatable.dart';

/// Collection status entity representing user's ownership of a sticker
class CollectionStatus extends Equatable {
  final int id;
  final int stickerId;
  final String userId;
  final int count;

  const CollectionStatus({
    required this.id,
    required this.stickerId,
    required this.userId,
    required this.count,
  });

  /// Whether the sticker is missing (count = 0)
  bool get isMissing => count == 0;

  /// Whether the sticker is owned (count = 1)
  bool get isOwned => count == 1;

  /// Whether the sticker is repeated (count > 1)
  bool get isRepeated => count > 1;

  @override
  List<Object?> get props => [id, stickerId, userId, count];

  CollectionStatus copyWith({
    int? id,
    int? stickerId,
    String? userId,
    int? count,
  }) {
    return CollectionStatus(
      id: id ?? this.id,
      stickerId: stickerId ?? this.stickerId,
      userId: userId ?? this.userId,
      count: count ?? this.count,
    );
  }
}