import 'package:equatable/equatable.dart';
import 'scanned_qr_data.dart';

/// Sticker info for trade - user gives to partner
class StickerToGive extends Equatable {
  final int stickerId;
  final int stickerNumber;
  final String stickerName;
  final int availableCount; // How many user has (for validation)

  const StickerToGive({
    required this.stickerId,
    required this.stickerNumber,
    required this.stickerName,
    required this.availableCount,
  });

  bool get canGive => availableCount > 1; // Can only give if have more than 1

  @override
  List<Object?> get props => [stickerId, stickerNumber, stickerName, availableCount];
}

/// Sticker info for trade - user receives from partner
class StickerToReceive extends Equatable {
  final int stickerId;
  final int stickerNumber;
  final String stickerName;

  const StickerToReceive({
    required this.stickerId,
    required this.stickerNumber,
    required this.stickerName,
  });

  @override
  List<Object?> get props => [stickerId, stickerNumber, stickerName];
}

/// Calculated trade offer for confirmation
class TradeOffer extends Equatable {
  final ScannedQRData partnerData;
  final List<StickerToGive> youGive;
  final List<StickerToReceive> youReceive;
  final DateTime expiresAt;

  const TradeOffer({
    required this.partnerData,
    required this.youGive,
    required this.youReceive,
    required this.expiresAt,
  });

  /// Whether trade has mutual benefit (both sides give)
  bool get hasTrade => youGive.isNotEmpty && youReceive.isNotEmpty;

  /// Whether trade has any exchange
  bool get hasExchange => youGive.isNotEmpty || youReceive.isNotEmpty;

  /// Count of stickers user receives
  int get youReceiveCount => youReceive.length;

  /// Count of stickers user gives
  int get youGiveCount => youGive.length;

  @override
  List<Object?> get props => [partnerData, youGive, youReceive, expiresAt];

  TradeOffer copyWith({
    ScannedQRData? partnerData,
    List<StickerToGive>? youGive,
    List<StickerToReceive>? youReceive,
    DateTime? expiresAt,
  }) {
    return TradeOffer(
      partnerData: partnerData ?? this.partnerData,
      youGive: youGive ?? this.youGive,
      youReceive: youReceive ?? this.youReceive,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

/// Result of a trade execution
class TradeResult extends Equatable {
  final bool success;
  final String? errorMessage;

  const TradeResult._({
    required this.success,
    this.errorMessage,
  });

  factory TradeResult.success() => const TradeResult._(success: true);

  factory TradeResult.error(String message) => TradeResult._(
        success: false,
        errorMessage: message,
      );

  @override
  List<Object?> get props => [success, errorMessage];
}