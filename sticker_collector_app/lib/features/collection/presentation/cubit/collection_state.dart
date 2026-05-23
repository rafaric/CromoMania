import 'package:equatable/equatable.dart';

/// Collection state status
enum CollectionStatus { initial, loading, loaded, error }

/// Collection feature state
class CollectionState extends Equatable {
  final CollectionStatus status;
  final Map<int, int> statusMap; // stickerId -> count
  final int totalStickers;
  final String? errorMessage;

  const CollectionState({
    this.status = CollectionStatus.initial,
    this.statusMap = const {},
    this.totalStickers = 0,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, statusMap, totalStickers, errorMessage];

  /// Get count for a specific sticker
  int getCount(int stickerId) => statusMap[stickerId] ?? 0;

  /// Get count of owned stickers (count > 0)
  int get ownedCount {
    if (statusMap.isEmpty) return 0;
    return statusMap.values.where((count) => count > 0).length;
  }

  /// Get count of missing stickers
  int get missingCount => totalStickers - ownedCount;

  /// Get count of repeated stickers (excess over 1 per sticker)
  int get repeatedCount {
    if (statusMap.isEmpty) return 0;
    return statusMap.values
        .where((count) => count > 1)
        .fold(0, (sum, count) => sum + (count - 1));
  }

  /// Get completion percentage
  double get completionPercent {
    if (totalStickers == 0) return 0;
    return (ownedCount / totalStickers * 100);
  }

  CollectionState copyWith({
    CollectionStatus? status,
    Map<int, int>? statusMap,
    int? totalStickers,
    String? errorMessage,
  }) {
    return CollectionState(
      status: status ?? this.status,
      statusMap: statusMap ?? this.statusMap,
      totalStickers: totalStickers ?? this.totalStickers,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}