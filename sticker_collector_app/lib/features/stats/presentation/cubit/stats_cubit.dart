import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/stats_calculator.dart';
import 'stats_state.dart';

/// Cubit for managing stats state
class StatsCubit extends Cubit<StatsState> {
  StatsCubit() : super(const StatsState());

  /// Recalculate stats from collection state
  void recalculateStats({
    required Map<int, int> statusMap,
    required int totalStickers,
  }) {
    emit(state.copyWith(status: StatsStatus.loading));

    final statsData = StatsCalculator.calculate(
      statusMap: statusMap,
      totalStickers: totalStickers,
    );

    emit(StatsState.fromData(statsData));
  }

  /// Update stats from collection cubit state
  void updateFromCollection({
    required Map<int, int> statusMap,
    required int totalStickers,
  }) {
    final statsData = StatsCalculator.calculate(
      statusMap: statusMap,
      totalStickers: totalStickers,
    );

    emit(StatsState.fromData(statsData));
  }
}