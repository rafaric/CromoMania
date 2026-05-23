import 'package:equatable/equatable.dart';

/// Sticker entity representing a single sticker template
class Sticker extends Equatable {
  final int id;
  final int sectionId;
  final String stickerNumber;
  final String name;
  final bool isSpecial;

  const Sticker({
    required this.id,
    required this.sectionId,
    required this.stickerNumber,
    required this.name,
    required this.isSpecial,
  });

  @override
  List<Object?> get props => [id, sectionId, stickerNumber, name, isSpecial];

  Sticker copyWith({
    int? id,
    int? sectionId,
    String? stickerNumber,
    String? name,
    bool? isSpecial,
  }) {
    return Sticker(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      stickerNumber: stickerNumber ?? this.stickerNumber,
      name: name ?? this.name,
      isSpecial: isSpecial ?? this.isSpecial,
    );
  }
}