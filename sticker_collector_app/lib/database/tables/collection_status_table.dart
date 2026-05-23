import 'package:drift/drift.dart';
import 'stickers_table.dart';

/// Collection statuses table for tracking user's sticker collection state
class CollectionStatuses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get stickerId => integer().references(Stickers, #id)();
  TextColumn get userId => text().withDefault(const Constant('default_user'))();
  IntColumn get count => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {stickerId, userId},
      ];
}