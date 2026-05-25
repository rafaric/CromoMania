import 'package:equatable/equatable.dart';
import '../../domain/entities/scanned_qr_data.dart';

/// Scanner page state machine
enum TradeScannerStatus {
  idle,
  requestingPermission,
  scanning,
  parsed,
  expired,
  invalid,
  permissionDenied,
}

/// State for TradeScannerCubit
class TradeScannerState extends Equatable {
  final TradeScannerStatus status;
  final ScannedQRData? scannedData;
  final String? errorMessage;
  final bool permissionGranted;

  const TradeScannerState({
    this.status = TradeScannerStatus.idle,
    this.scannedData,
    this.errorMessage,
    this.permissionGranted = false,
  });

  @override
  List<Object?> get props => [status, scannedData, errorMessage, permissionGranted];

  factory TradeScannerState.initial() => const TradeScannerState();

  factory TradeScannerState.permissionDenied() => const TradeScannerState(
        status: TradeScannerStatus.permissionDenied,
        permissionGranted: false,
        errorMessage: 'Camera permission required to scan QR codes',
      );

  factory TradeScannerState.scanning() => const TradeScannerState(
        status: TradeScannerStatus.scanning,
        permissionGranted: true,
      );

  factory TradeScannerState.parsed(ScannedQRData data) => TradeScannerState(
        status: TradeScannerStatus.parsed,
        scannedData: data,
        permissionGranted: true,
      );

  factory TradeScannerState.expired() => const TradeScannerState(
        status: TradeScannerStatus.expired,
        errorMessage: 'This QR code has expired. Ask your friend to generate a new one.',
      );

  factory TradeScannerState.invalid(String message) => TradeScannerState(
        status: TradeScannerStatus.invalid,
        errorMessage: message,
      );

  TradeScannerState copyWith({
    TradeScannerStatus? status,
    ScannedQRData? scannedData,
    String? errorMessage,
    bool? permissionGranted,
  }) {
    return TradeScannerState(
      status: status ?? this.status,
      scannedData: scannedData ?? this.scannedData,
      errorMessage: errorMessage ?? this.errorMessage,
      permissionGranted: permissionGranted ?? this.permissionGranted,
    );
  }
}