import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/sync_status.dart';
import '../../domain/sync_engine.dart';
import '../../data/sync_queue_repository_impl.dart';
import '../../data/firestore_repository.dart';
import 'sync_state.dart';

/// Cubit for managing sync state
class SyncCubit extends Cubit<SyncState> {
  final FirestoreRepository _firestoreRepo;
  final SyncQueueRepositoryImpl _syncQueueRepo;
  late final SyncEngine _syncEngine;

  SyncCubit({required this._firestoreRepo, required this._syncQueueRepo})
    : super(const SyncState.initial()) {
    _initSyncEngine();
  }

  void _initSyncEngine() {
    _syncEngine = SyncEngine(
      firestoreRepo: _firestoreRepo,
      syncQueueRepo: _syncQueueRepo,
    );

    _syncEngine.onStatusChanged = _onEngineStatusChanged;
  }

  void _onEngineStatusChanged(SyncEngineStatus status) {
    switch (status) {
      case SyncEngineStatus.idle:
        emit(state.copyWith(status: SyncStatus.idle));
        break;
      case SyncEngineStatus.syncing:
        _updatePendingCount();
        emit(state.copyWith(status: SyncStatus.syncing));
        break;
      case SyncEngineStatus.synced:
        emit(
          state.copyWith(
            status: SyncStatus.synced,
            lastSyncedAt: DateTime.now(),
          ),
        );
        break;
      case SyncEngineStatus.offline:
        emit(state.copyWith(status: SyncStatus.offline));
        break;
      case SyncEngineStatus.error:
        emit(
          state.copyWith(status: SyncStatus.error, errorMessage: 'Sync failed'),
        );
        break;
    }
  }

  /// Initialize sync for a user
  Future<void> initialize(String userId) async {
    emit(state.copyWith(status: SyncStatus.syncing));

    try {
      await _syncEngine.initialize(userId);
      await _updatePendingCount();
    } catch (e) {
      emit(
        state.copyWith(status: SyncStatus.error, errorMessage: e.toString()),
      );
    }
  }

  /// Queue a change for sync
  Future<void> queueChange(String stickerId, Map<String, dynamic> data) async {
    print('SyncCubit: queueChange called for sticker $stickerId');
    await _syncEngine.queueChange(stickerId, data);
    await _updatePendingCount();

    // Show syncing status if not already
    if (state.status != SyncStatus.syncing) {
      emit(state.copyWith(status: SyncStatus.syncing));
    }
  }

  /// Update pending count from queue
  Future<void> _updatePendingCount() async {
    final count = await _syncQueueRepo.getPendingCount();
    emit(state.copyWith(pendingCount: count));
  }

  /// Load cloud data from Firestore and return as Map<stickerId, count>
  /// Call this after login to restore collection from cloud
  Future<Map<String, int>> loadCloudData(String userId) async {
    try {
      final cloudStickers = await _firestoreRepo.getAllStickers(userId);

      // Convert to Map<stickerId (String), count>
      final result = <String, int>{};
      for (final entry in cloudStickers.entries) {
        // The stickerId might be stored as string or int
        final stickerId = entry.key;
        final data = entry.value as Map<String, dynamic>?;
        if (data != null && data.containsKey('count')) {
          result[stickerId] = data['count'] as int? ?? 0;
        }
      }

      return result;
    } catch (e) {
      print('SyncCubit: Error loading cloud data: $e');
      return {};
    }
  }

  /// Set online status
  void setOnlineStatus(bool isOnline) {
    _syncEngine.setOnlineStatus(isOnline);

    if (!isOnline) {
      _updatePendingCount();
    }
  }

  /// Clear sync state (on sign out)
  void clearSync() {
    _syncEngine.dispose();
    emit(const SyncState.initial());
  }

  @override
  Future<void> close() {
    _syncEngine.dispose();
    return super.close();
  }
}
