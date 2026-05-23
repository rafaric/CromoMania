import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/repositories/collection_repository_impl.dart';
import 'collection_state.dart';

/// Cubit for managing collection state with tap/long-press state machine
class CollectionCubit extends Cubit<CollectionState> {
  final CollectionRepositoryImpl _repository;
  final String _userId = AppConstants.defaultUserId;

  CollectionCubit(this._repository) : super(const CollectionState());

  /// Load collection from database
  Future<void> loadCollection() async {
    emit(state.copyWith(status: CollectionStatus.loading));

    try {
      final statuses = await _repository.getStatusesForUser(_userId);
      final statusMap = <int, int>{};
      for (final status in statuses) {
        statusMap[status.stickerId] = status.count;
      }
      final totalStickers = statusMap.length;

      emit(state.copyWith(
        status: CollectionStatus.loaded,
        statusMap: statusMap,
        totalStickers: totalStickers,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CollectionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Set total sticker count (called after album loads)
  void setTotalStickerCount(int count) {
    if (state.totalStickers != count) {
      emit(state.copyWith(totalStickers: count));
    }
  }

  /// Increment sticker count (tap action)
  void incrementSticker(int stickerId) {
    _updateStickerCount(stickerId, delta: 1);
  }

  /// Decrement sticker count (long-press action)
  void decrementSticker(int stickerId) {
    _updateStickerCount(stickerId, delta: -1);
  }

  /// Update sticker count with delta
  void _updateStickerCount(int stickerId, {required int delta}) {
    final currentCount = state.getCount(stickerId);
    final newCount = (currentCount + delta).clamp(0, AppConstants.maxStickerCount);

    // Immutable map update
    final newMap = Map<int, int>.from(state.statusMap);
    newMap[stickerId] = newCount;

    emit(state.copyWith(statusMap: newMap));

    // Persist asynchronously (fire-and-forget for responsiveness)
    _persistStatus(stickerId, newCount);
  }

  /// Persist status to database
  Future<void> _persistStatus(int stickerId, int count) async {
    try {
      await _repository.saveStatus(
        _createStatus(stickerId, count),
      );
    } catch (e) {
      // Handle error silently for now
      // Could emit error state if needed
    }
  }

  /// Create a CollectionStatus entity
  dynamic _createStatus(int stickerId, int count) {
    return _StatusData(stickerId: stickerId, userId: _userId, count: count);
  }

  /// Batch update for multiple stickers
  Future<void> updateStickers(List<int> stickerIds, int count) async {
    final newMap = Map<int, int>.from(state.statusMap);
    for (final id in stickerIds) {
      newMap[id] = count;
    }
    emit(state.copyWith(statusMap: newMap));

    // Persist all
    for (final id in stickerIds) {
      await _persistStatus(id, count);
    }
  }
}

/// Simple data class for status
class _StatusData {
  final int stickerId;
  final String userId;
  final int count;

  _StatusData({
    required this.stickerId,
    required this.userId,
    required this.count,
  });
}