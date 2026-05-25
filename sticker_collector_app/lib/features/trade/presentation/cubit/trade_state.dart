import 'package:equatable/equatable.dart';
import '../../domain/entities/trade_record.dart';

/// Trade feature state
enum TradeStateStatus { initial, loading, loaded, error }

/// State for TradeCubit
class TradeState extends Equatable {
  final TradeStateStatus status;
  final List<TradeRecord> history;
  final String? errorMessage;

  const TradeState({
    this.status = TradeStateStatus.initial,
    this.history = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, history, errorMessage];

  factory TradeState.initial() => const TradeState(status: TradeStateStatus.initial);

  factory TradeState.loading() => const TradeState(status: TradeStateStatus.loading);

  factory TradeState.loaded(List<TradeRecord> history) => TradeState(
        status: TradeStateStatus.loaded,
        history: history,
      );

  factory TradeState.error(String message) => TradeState(
        status: TradeStateStatus.error,
        errorMessage: message,
      );

  TradeState copyWith({
    TradeStateStatus? status,
    List<TradeRecord>? history,
    String? errorMessage,
  }) {
    return TradeState(
      status: status ?? this.status,
      history: history ?? this.history,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}