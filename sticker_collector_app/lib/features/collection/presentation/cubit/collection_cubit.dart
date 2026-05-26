import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/repositories/collection_repository_impl.dart';
import '../../../../sync/presentation/cubit/sync_cubit.dart';
import '../../domain/entities/collection_status.dart' as entity;
import 'collection_state.dart';

/// Cubit for managing collection state with tap/long-press state machine
class CollectionCubit extends Cubit<CollectionState> {
  final CollectionRepositoryImpl _repository;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _userId = AppConstants.defaultUserId;
  SyncCubit? _syncCubit;

  CollectionCubit(this._repository) : super(const CollectionState()) {
    // Use Firebase UID if user is authenticated
    final user = _auth.currentUser;
    if (user != null) {
      _userId = user.uid;
    }
  }

  /// Set sync cubit reference for cloud sync
  void setSyncCubit(SyncCubit syncCubit) {
    _syncCubit = syncCubit;
  }

  /// Prepare state for an authenticated user before sync/restore completes.
  void beginUserSession(String userId) {
    _userId = userId;
    emit(
      state.copyWith(
        status: CollectionStatus.loading,
        statusMap: const {},
        totalStickers: state.totalStickers > 0 ? state.totalStickers : 992,
      ),
    );
  }

  /// Update user ID and refresh collection from cloud (call after sign in)
  void updateUserId() {
    final user = _auth.currentUser;
    if (user != null) {
      _userId = user.uid;
      loadCollectionFromCloud();
    }
  }

  /// Get current user ID
  String get currentUserId => _userId;

  /// Load collection from local database
  Future<void> loadCollection() async {
    emit(state.copyWith(status: CollectionStatus.loading));

    try {
      final statuses = await _repository.getStatusesForUser(_userId);
      final statusMap = <int, int>{};
      for (final status in statuses) {
        statusMap[status.stickerId] = status.count;
      }
      emit(
        state.copyWith(
          status: CollectionStatus.loaded,
          statusMap: statusMap,
          totalStickers: state.totalStickers > 0 ? state.totalStickers : 992,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CollectionStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Load collection from cloud first, then merge with local (call after sign in)
  Future<void> loadCollectionFromCloud() async {
    emit(state.copyWith(status: CollectionStatus.loading));

    try {
      // Load from local first (for offline-first)
      final localStatuses = await _repository.getStatusesForUser(_userId);
      final localMap = <int, int>{};
      for (final status in localStatuses) {
        localMap[status.stickerId] = status.count;
      }

      // Try to merge with cloud data if SyncCubit is available
      if (_syncCubit != null) {
        final pendingSyncCount = await _syncCubit!.getPendingCountForUser(
          _userId,
        );
        final cloudMap = await _syncCubit!.loadCloudData(_userId);
        final preferCloudValues = pendingSyncCount == 0;

        final mergedMap = Map<int, int>.from(localMap);
        for (final entry in cloudMap.entries) {
          final stickerId = int.tryParse(entry.key);
          if (stickerId == null) continue;

          final hasLocalValue = mergedMap.containsKey(stickerId);
          if (preferCloudValues || !hasLocalValue) {
            mergedMap[stickerId] = entry.value;
          }

          await _repository.saveStatus(
            entity.CollectionStatus(
              id: 0,
              stickerId: stickerId,
              userId: _userId,
              count: mergedMap[stickerId] ?? entry.value,
            ),
          );
        }
        emit(
          state.copyWith(
            status: CollectionStatus.loaded,
            statusMap: mergedMap,
            totalStickers: state.totalStickers > 0 ? state.totalStickers : 992,
          ),
        );
      } else {
        // No sync available, use local only
        emit(
          state.copyWith(
            status: CollectionStatus.loaded,
            statusMap: localMap,
            totalStickers: state.totalStickers > 0 ? state.totalStickers : 992,
          ),
        );
      }
    } catch (e) {
      // On error, fall back to local-only
      loadCollection();
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
    final newCount = (currentCount + delta).clamp(
      0,
      AppConstants.maxStickerCount,
    );

    // Immutable map update
    final newMap = Map<int, int>.from(state.statusMap);
    newMap[stickerId] = newCount;

    emit(state.copyWith(statusMap: newMap));

    // Persist asynchronously (fire-and-forget for responsiveness)
    _persistStatus(stickerId, newCount);
  }

  /// Persist status to database and trigger cloud sync
  Future<void> _persistStatus(int stickerId, int count) async {
    try {
      await _repository.saveStatus(_createStatus(stickerId, count));

      // Trigger cloud sync if SyncCubit is available
      if (_syncCubit != null) {
        _syncCubit!.queueChange(stickerId.toString(), {
          'stickerId': stickerId,
          'count': count,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// Create a CollectionStatus entity
  entity.CollectionStatus _createStatus(int stickerId, int count) {
    return entity.CollectionStatus(
      id: 0,
      stickerId: stickerId,
      userId: _userId,
      count: count,
    );
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
