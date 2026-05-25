import '../entities/scanned_qr_data.dart';
import '../entities/trade_offer.dart';

/// Use case for calculating trade offer from two collections
class CalculateTradeOfferUseCase {
  /// Calculate trade offer from scanned QR and user's collection
  /// 
  /// [partnerData] - The parsed QR data from the partner
  /// [myStatusMap] - Map of stickerId -> count (0=missing, 1=have one, 2+=repeated)
  /// [stickerLookup] - Optional map of stickerId -> Sticker for names
  TradeOffer execute({
    required ScannedQRData partnerData,
    required Map<int, int> myStatusMap,
    Map<int, StickerLookupData>? stickerLookup,
  }) {
    final stickers = stickerLookup ?? {};

    // Calculate what user can give (what partner needs that user has extras of)
    final youGiveIds = <int>[];
    for (final missingId in partnerData.missing) {
      final myCount = myStatusMap[missingId] ?? 0;
      if (myCount > 1) {
        // User has at least 2, can give 1
        youGiveIds.add(missingId);
      }
    }

    // Calculate what user receives (what user needs that partner has extras of)
    final youReceiveIds = <int>[];
    for (final repeatedId in partnerData.repeated) {
      final myCount = myStatusMap[repeatedId] ?? 0;
      if (myCount == 0) {
        // User is missing this sticker
        youReceiveIds.add(repeatedId);
      }
    }

    // Build StickerToGive list with metadata
    final youGive = youGiveIds.map((id) {
      final count = myStatusMap[id] ?? 0;
      final lookup = stickers[id];
      return StickerToGive(
        stickerId: id,
        stickerNumber: lookup?.stickerNumber ?? id,
        stickerName: lookup?.stickerName ?? 'Sticker #$id',
        availableCount: count,
      );
    }).toList();

    // Build StickerToReceive list with metadata
    final youReceive = youReceiveIds.map((id) {
      final lookup = stickers[id];
      return StickerToReceive(
        stickerId: id,
        stickerNumber: lookup?.stickerNumber ?? id,
        stickerName: lookup?.stickerName ?? 'Sticker #$id',
      );
    }).toList();

    return TradeOffer(
      partnerData: partnerData,
      youGive: youGive,
      youReceive: youReceive,
      expiresAt: partnerData.expiresAt,
    );
  }
}

/// Lookup data for stickers (to display names/numbers)
class StickerLookupData {
  final int stickerNumber;
  final String stickerName;

  const StickerLookupData({
    required this.stickerNumber,
    required this.stickerName,
  });
}