import 'package:equatable/equatable.dart';
import '../../domain/stats_calculator.dart';

/// Stats state status
enum StatsStatus { initial, loading, loaded }

/// Stats feature state
class StatsState extends Equatable {
  final StatsStatus status;
  final int ownedCount;
  final int missingCount;
  final int repeatedCount;
  final double completionPercent;
  final int totalStickers;
  final String? errorMessage;

  const StatsState({
    this.status = StatsStatus.initial,
    this.ownedCount = 0,
    this.missingCount = 0,
    this.repeatedCount = 0,
    this.completionPercent = 0,
    this.totalStickers = 0,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        status,
        ownedCount,
        missingCount,
        repeatedCount,
        completionPercent,
        totalStickers,
        errorMessage,
      ];

  StatsState copyWith({
    StatsStatus? status,
    int? ownedCount,
    int? missingCount,
    int? repeatedCount,
    double? completionPercent,
    int? totalStickers,
    String? errorMessage,
  }) {
    return StatsState(
      status: status ?? this.status,
      ownedCount: ownedCount ?? this.ownedCount,
      missingCount: missingCount ?? this.missingCount,
      repeatedCount: repeatedCount ?? this.repeatedCount,
      completionPercent: completionPercent ?? this.completionPercent,
      totalStickers: totalStickers ?? this.totalStickers,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Create from StatsData
  factory StatsState.fromData(StatsData data) {
    return StatsState(
      status: StatsStatus.loaded,
      ownedCount: data.ownedCount,
      missingCount: data.missingCount,
      repeatedCount: data.repeatedCount,
      completionPercent: data.completionPercent,
      totalStickers: data.totalStickers,
    );
  }
}