import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
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
    await _syncEngine.queueChange(stickerId, data);
    await _updatePendingCount();

    if (state.status != SyncStatus.syncing) {
      emit(state.copyWith(status: SyncStatus.syncing));
    }
  }

  /// Update pending count from queue
  Future<void> _updatePendingCount() async {
    final count = await _syncQueueRepo.getPendingCount();
    emit(state.copyWith(pendingCount: count));
  }

  /// Load cloud data from Firestore and return a stickerId-to-count map.
  /// Call this after login to restore collection from cloud.
  Future<Map<String, int>> loadCloudData(String userId) async {
    try {
      final cloudStickers = await _firestoreRepo.getAllStickers(userId);
      final result = <String, int>{};

      for (final entry in cloudStickers.entries) {
        final stickerId = entry.key;
        final data = entry.value as Map<String, dynamic>?;
        if (data == null) continue;

        final count = _extractCount(data);
        if (count != null) {
          result[stickerId] = count;
        }
      }

      return result;
    } catch (_) {
      return {};
    }
  }

  int? _extractCount(Map<String, dynamic> data) {
    final directCount = data['count'];
    if (directCount is int) return directCount;
    if (directCount is num) return directCount.toInt();

    final payload = data['payload'];
    if (payload is Map<String, dynamic>) {
      final nestedCount = payload['count'];
      if (nestedCount is int) return nestedCount;
      if (nestedCount is num) return nestedCount.toInt();
    }

    if (payload is String) {
      try {
        final decoded = jsonDecode(payload);
        if (decoded is Map<String, dynamic>) {
          final nestedCount = decoded['count'];
          if (nestedCount is int) return nestedCount;
          if (nestedCount is num) return nestedCount.toInt();
        }
      } catch (_) {
        final match = RegExp(r'count:\s*(\d+)').firstMatch(payload);
        if (match != null) {
          return int.tryParse(match.group(1)!);
        }
      }
    }

    return null;
  }

  Future<int> getPendingCount() async {
    return _syncQueueRepo.getPendingCount();
  }

  Future<int> getPendingCountForUser(String userId) async {
    final pendingItems = await _syncQueueRepo.getPendingItems();
    return pendingItems.where((item) {
      final payload = item['payload'] as String?;
      if (payload == null || payload.isEmpty) {
        return false;
      }

      try {
        final decoded = jsonDecode(payload);
        if (decoded is Map<String, dynamic>) {
          final payloadUserId = decoded['userId'] as String?;
          return payloadUserId == userId;
        }
      } catch (_) {
        return userId == AppConstants.defaultUserId;
      }

      return false;
    }).length;
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
