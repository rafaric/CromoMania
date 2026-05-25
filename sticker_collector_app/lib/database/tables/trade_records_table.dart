import 'package:drift/drift.dart';

/// Trade records table for history
class TradeRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get partnerId => text()();
  TextColumn get partnerName => text().withDefault(const Constant('Anonymous'))();
  IntColumn get stickersGiven => integer().withDefault(const Constant(0))();
  TextColumn get givenIds => text().nullable()(); // JSON array [1,2,3]
  IntColumn get stickersReceived => integer().withDefault(const Constant(0))();
  TextColumn get receivedIds => text().nullable()(); // JSON array [4,5,6]
  IntColumn get tradedAt => integer()(); // Unix timestamp
  TextColumn get tradeType => text().withDefault(const Constant('qr_bidirectional'))();
}