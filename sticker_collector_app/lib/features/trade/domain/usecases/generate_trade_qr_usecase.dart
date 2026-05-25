import 'dart:convert';

/// Use case for generating QR payload from current collection
class GenerateTradeQRUseCase {
  /// Generate JSON payload for QR code
  String execute({
    required String uid,
    required List<int> missingStickerIds,
    required List<int> repeatedStickerIds,
    String albumId = 'panini_wc2026',
    int expirySeconds = 600,
  }) {
    final payload = {
      'v': 1,
      'uid': uid,
      'ts': DateTime.now().millisecondsSinceEpoch,
      'exp': expirySeconds,
      'album': albumId,
      'missing': missingStickerIds,
      'repeated': repeatedStickerIds,
    };
    return jsonEncode(payload);
  }
}