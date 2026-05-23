import 'package:equatable/equatable.dart';

/// Statistics calculator for collection stats
class StatsCalculator {
  StatsCalculator._();

  /// Calculate stats from status map
  static StatsData calculate({
    required Map<int, int> statusMap,
    required int totalStickers,
  }) {
    if (statusMap.isEmpty || totalStickers == 0) {
      return const StatsData(
        ownedCount: 0,
        missingCount: 0,
        repeatedCount: 0,
        completionPercent: 0,
        totalStickers: 0,
      );
    }

    final ownedCount = statusMap.values.where((count) => count > 0).length;
    final missingCount = totalStickers - ownedCount;
    final repeatedCount = statusMap.values
        .where((count) => count > 1)
        .fold(0, (sum, count) => sum + (count - 1));
    final completionPercent = ownedCount / totalStickers * 100;

    return StatsData(
      ownedCount: ownedCount,
      missingCount: missingCount,
      repeatedCount: repeatedCount,
      completionPercent: completionPercent,
      totalStickers: totalStickers,
    );
  }
}

/// Immutable stats data
class StatsData extends Equatable {
  final int ownedCount;
  final int missingCount;
  final int repeatedCount;
  final double completionPercent;
  final int totalStickers;

  const StatsData({
    required this.ownedCount,
    required this.missingCount,
    required this.repeatedCount,
    required this.completionPercent,
    required this.totalStickers,
  });

  @override
  List<Object?> get props => [
        ownedCount,
        missingCount,
        repeatedCount,
        completionPercent,
        totalStickers,
      ];
}