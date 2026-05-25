import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/trade_record.dart' as domain;
import '../../domain/repositories/trade_repository.dart';

/// Implementation of TradeRepository using Drift database
class TradeRepositoryImpl implements TradeRepository {
  final AppDatabase _database;

  TradeRepositoryImpl(this._database);

  @override
  Future<int> saveTradeRecord(domain.TradeRecord record) async {
    final companion = TradeRecordsCompanion(
      partnerId: Value(record.partnerId),
      partnerName: Value(record.partnerName),
      stickersGiven: Value(record.stickersGiven),
      givenIds: Value(record.givenIds.isNotEmpty ? jsonEncode(record.givenIds) : null),
      stickersReceived: Value(record.stickersReceived),
      receivedIds: Value(record.receivedIds.isNotEmpty ? jsonEncode(record.receivedIds) : null),
      tradedAt: Value(record.tradedAt.millisecondsSinceEpoch),
      tradeType: Value(record.tradeType),
    );

    return await _database.insertTradeRecord(companion);
  }

  @override
  Future<List<domain.TradeRecord>> getTradeHistory() async {
    final records = await _database.getAllTradeRecords();
    return records.map(_mapToEntity).toList();
  }

  @override
  Future<List<domain.TradeRecord>> getRecentTrades({int limit = 10}) async {
    final records = await _database.getRecentTradeRecords(limit: limit);
    return records.map(_mapToEntity).toList();
  }

  @override
  Future<void> pruneOldTrades({int keepDays = 90}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
    await _database.pruneOldTradeRecords(cutoffDate.millisecondsSinceEpoch);
  }

  domain.TradeRecord _mapToEntity(TradeRecord dbRecord) {
    List<int> givenIds = [];
    List<int> receivedIds = [];
    
    if (dbRecord.givenIds != null && dbRecord.givenIds!.isNotEmpty) {
      try {
        givenIds = (jsonDecode(dbRecord.givenIds!) as List).cast<int>();
      } catch (_) {}
    }
    
    if (dbRecord.receivedIds != null && dbRecord.receivedIds!.isNotEmpty) {
      try {
        receivedIds = (jsonDecode(dbRecord.receivedIds!) as List).cast<int>();
      } catch (_) {}
    }
    
    return domain.TradeRecord(
      id: dbRecord.id,
      partnerId: dbRecord.partnerId,
      partnerName: dbRecord.partnerName,
      stickersGiven: dbRecord.stickersGiven,
      givenIds: givenIds,
      stickersReceived: dbRecord.stickersReceived,
      receivedIds: receivedIds,
      tradedAt: DateTime.fromMillisecondsSinceEpoch(dbRecord.tradedAt),
      tradeType: dbRecord.tradeType,
    );
  }
}