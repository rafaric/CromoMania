import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/trade_repository.dart';
import 'trade_state.dart';

/// Cubit for managing trade state and history
class TradeCubit extends Cubit<TradeState> {
  final TradeRepository _repository;

  TradeCubit(this._repository) : super(TradeState.initial());

  /// Load trade history from repository
  Future<void> loadHistory() async {
    emit(state.copyWith(status: TradeStateStatus.loading));

    try {
      final history = await _repository.getTradeHistory();
      emit(TradeState.loaded(history));
    } catch (e) {
      emit(TradeState.error('Failed to load trade history: $e'));
    }
  }

  /// Refresh history after a trade
  Future<void> refreshHistory() async {
    try {
      final history = await _repository.getTradeHistory();
      emit(state.copyWith(
        status: TradeStateStatus.loaded,
        history: history,
      ));
    } catch (e) {
      // Keep existing history but report error
      emit(state.copyWith(
        errorMessage: 'Failed to refresh history: $e',
      ));
    }
  }

  /// Clear any error state
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}