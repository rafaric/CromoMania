import 'package:drift/drift.dart';
import 'sections_table.dart';

/// Stickers table for storing sticker template definitions
class Stickers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sectionId => integer().references(Sections, #id)();
  TextColumn get stickerNumber => text().withLength(min: 1, max: 20)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  BoolColumn get isSpecial => boolean().withDefault(const Constant(false))();
}