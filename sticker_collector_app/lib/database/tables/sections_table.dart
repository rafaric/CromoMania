import 'package:drift/drift.dart';
import 'albums_table.dart';

/// Sections table for grouping stickers within an album
class Sections extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get albumId => integer().references(Albums, #id)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  IntColumn get orderIndex => integer()();
}