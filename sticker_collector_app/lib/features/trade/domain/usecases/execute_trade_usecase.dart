import '../entities/trade_offer.dart';
import '../entities/trade_record.dart';
import '../repositories/trade_repository.dart';

/// Use case for executing a trade
class ExecuteTradeUseCase {
  final TradeRepository tradeRepository;
  final Future<void> Function(int stickerId, int delta)? onUpdateSticker;
  final int Function(int stickerId)? getStickerCount;
  final List<int> Function()? getMissingIds;
  final List<int> Function()? getRepeatedIds;

  ExecuteTradeUseCase({
    required this.tradeRepository,
    this.onUpdateSticker,
    this.getStickerCount,
    this.getMissingIds,
    this.getRepeatedIds,
  });

  /// Execute a trade offer
  Future<TradeResult> execute({
    required TradeOffer offer,
    required String partnerName,
  }) async {
    // Validate user has required stickers
    for (final sticker in offer.youGive) {
      final currentCount = getStickerCount?.call(sticker.stickerId) ?? sticker.availableCount;
      if (currentCount <= 1) {
        return TradeResult.error('You no longer have sticker #${sticker.stickerId} to trade');
      }
    }

    // Update collection - decrement given stickers
    for (final sticker in offer.youGive) {
      await onUpdateSticker?.call(sticker.stickerId, -1);
    }

    // Update collection - increment received stickers
    for (final sticker in offer.youReceive) {
      await onUpdateSticker?.call(sticker.stickerId, 1);
    }

    // Record to history
    final record = TradeRecord(
      partnerId: offer.partnerData.partnerUid,
      partnerName: partnerName,
      stickersGiven: offer.youGive.length,
      givenIds: offer.youGive.map((s) => s.stickerId).toList(),
      stickersReceived: offer.youReceive.length,
      receivedIds: offer.youReceive.map((s) => s.stickerId).toList(),
      tradedAt: DateTime.now(),
      tradeType: 'qr_bidirectional',
    );

    await tradeRepository.saveTradeRecord(record);

    return TradeResult.success();
  }
}