import '../entities/trade_record.dart';

/// Abstract repository for trade operations
abstract class TradeRepository {
  /// Save a completed trade record
  Future<int> saveTradeRecord(TradeRecord record);

  /// Get all trade history for user
  Future<List<TradeRecord>> getTradeHistory();

  /// Get recent trades (last N)
  Future<List<TradeRecord>> getRecentTrades({int limit = 10});

  /// Delete old trade records
  Future<void> pruneOldTrades({int keepDays = 90});
}