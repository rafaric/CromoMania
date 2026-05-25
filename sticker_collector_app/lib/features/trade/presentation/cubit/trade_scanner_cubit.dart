import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/parse_qr_usecase.dart';
import 'trade_scanner_state.dart';

/// Cubit for managing QR scanner state
class TradeScannerCubit extends Cubit<TradeScannerState> {
  final ParseQRUseCase _parseQRUseCase;

  TradeScannerCubit(this._parseQRUseCase) : super(TradeScannerState.initial());

  /// Handle when QR code is scanned
  void onQRScanned(String rawValue) {
    final result = _parseQRUseCase.execute(rawValue);

    if (!result.isValid) {
      emit(TradeScannerState.invalid(result.errorMessage ?? 'Invalid QR code'));
      return;
    }

    final data = result.data!;

    // Check if expired
    if (data.isExpired) {
      emit(TradeScannerState.expired());
      return;
    }

    emit(TradeScannerState.parsed(data));
  }

  /// Reset scanner to idle state
  void reset() {
    emit(TradeScannerState.initial());
  }

  /// Handle permission denied
  void onPermissionDenied() {
    emit(TradeScannerState.permissionDenied());
  }

  /// Handle permission granted
  void onPermissionGranted() {
    emit(TradeScannerState.scanning());
  }

  /// Request camera permission (set to scanning state, actual permission handled by widget)
  void requestPermission() {
    emit(state.copyWith(status: TradeScannerStatus.requestingPermission));
  }
}