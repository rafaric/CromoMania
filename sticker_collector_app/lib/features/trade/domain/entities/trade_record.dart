import 'package:equatable/equatable.dart';

/// Completed trade record for history
class TradeRecord extends Equatable {
  final int? id;
  final String partnerId;
  final String partnerName;
  final int stickersGiven;
  final List<int> givenIds;
  final int stickersReceived;
  final List<int> receivedIds;
  final DateTime tradedAt;
  final String tradeType;

  const TradeRecord({
    this.id,
    required this.partnerId,
    required this.partnerName,
    required this.stickersGiven,
    required this.givenIds,
    required this.stickersReceived,
    required this.receivedIds,
    required this.tradedAt,
    this.tradeType = 'qr_bidirectional',
  });

  /// Get relative time string (e.g., "2h", "1d")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(tradedAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w';
    } else {
      return '${(difference.inDays / 30).floor()}mo';
    }
  }

  @override
  List<Object?> get props => [
        id,
        partnerId,
        partnerName,
        stickersGiven,
        givenIds,
        stickersReceived,
        receivedIds,
        tradedAt,
        tradeType,
      ];

  TradeRecord copyWith({
    int? id,
    String? partnerId,
    String? partnerName,
    int? stickersGiven,
    List<int>? givenIds,
    int? stickersReceived,
    List<int>? receivedIds,
    DateTime? tradedAt,
    String? tradeType,
  }) {
    return TradeRecord(
      id: id ?? this.id,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      stickersGiven: stickersGiven ?? this.stickersGiven,
      givenIds: givenIds ?? this.givenIds,
      stickersReceived: stickersReceived ?? this.stickersReceived,
      receivedIds: receivedIds ?? this.receivedIds,
      tradedAt: tradedAt ?? this.tradedAt,
      tradeType: tradeType ?? this.tradeType,
    );
  }
}