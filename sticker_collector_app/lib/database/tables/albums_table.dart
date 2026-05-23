import 'package:drift/drift.dart';

/// Albums table for storing album template definitions
class Albums extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get publisher => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get totalStickers => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}