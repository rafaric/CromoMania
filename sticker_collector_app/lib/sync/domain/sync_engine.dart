import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../data/firestore_repository.dart';
import '../data/sync_queue_repository_impl.dart';

/// Sync engine for managing offline-first cloud synchronization
class SyncEngine {
  final FirestoreRepository _firestoreRepo;
  final SyncQueueRepository _syncQueueRepo;

  String? _currentUserId;
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _remoteChangesSubscription;
  bool _isOnline = true;
  bool _isSyncing = false;
  bool _hasQueuedChangesWhileSyncing = false;

  /// Callback when sync status changes
  void Function(SyncEngineStatus)? onStatusChanged;

  SyncEngine({required this._firestoreRepo, required this._syncQueueRepo});

  /// Initialize sync engine for a user
  Future<void> initialize(String userId) async {
    _currentUserId = userId;

    // Start listening to remote changes
    _remoteChangesSubscription = _firestoreRepo
        .watchStickers(userId)
        .listen(
          _onRemoteChange,
          onError: (error) {
            _updateStatus(SyncEngineStatus.error);
          },
        );

    // Process any pending items
    await _processQueue();
  }

  /// Queue a change for sync
  Future<void> queueChange(String stickerId, Map<String, dynamic> data) async {
    if (_currentUserId == null) {
      return;
    }

    await _syncQueueRepo.addToQueue(
      stickerId: stickerId,
      operation: 'upsert',
      payload: jsonEncode({...data, 'userId': _currentUserId}),
    );

    if (_isOnline && !_isSyncing) {
      await _processQueue();
    } else if (_isSyncing) {
      _hasQueuedChangesWhileSyncing = true;
    }
  }

  /// Process the sync queue
  Future<void> _processQueue() async {
    if (_currentUserId == null) {
      return;
    }

    _isSyncing = true;
    _updateStatus(SyncEngineStatus.syncing);

    try {
      final pendingItems = await _syncQueueRepo.getPendingItems();

      for (final item in pendingItems) {
        final id = item['id'] as int?;
        if (id == null) continue;

        final stickerId = item['stickerId'] as String;
        final operation = item['operation'] as String;
        final payload = item['payload'] as String;
        final retryCount = item['retryCount'] as int? ?? 0;

        try {
          if (operation == 'upsert') {
            final data = _deserializePayload(payload, stickerId);
            final payloadUserId = data['userId'] as String?;
            final isLegacyUnscopedItem = payloadUserId == null;
            final belongsToCurrentUser = payloadUserId == _currentUserId;

            if (isLegacyUnscopedItem &&
                _currentUserId != AppConstants.defaultUserId) {
              continue;
            }

            if (!isLegacyUnscopedItem && !belongsToCurrentUser) {
              continue;
            }

            data['syncedAt'] = DateTime.now().toIso8601String();
            await _firestoreRepo.upsertSticker(
              _currentUserId!,
              stickerId,
              data,
            );
          } else {
            await _firestoreRepo.deleteSticker(_currentUserId!, stickerId);
          }

          await _syncQueueRepo.markAsProcessed(id);
        } catch (e) {
          await _syncQueueRepo.incrementRetry(id);

          // If too many retries, mark as failed
          if (retryCount >= 3) {
            await _syncQueueRepo.markAsFailed(id, e.toString());
          }
        }
      }

      // Clean up processed items
      await _syncQueueRepo.cleanupProcessed();

      // Check if there are still pending items for the current user
      final remainingCount = await _getCurrentUserPendingCount();
      if (remainingCount == 0) {
        _updateStatus(SyncEngineStatus.synced);
      } else {
        _updateStatus(SyncEngineStatus.syncing);
      }
    } catch (e) {
      _updateStatus(SyncEngineStatus.error);
    } finally {
      _isSyncing = false;

      final currentUserPendingCount = await _getCurrentUserPendingCount();
      final shouldProcessAgain =
          _isOnline &&
          (_hasQueuedChangesWhileSyncing || currentUserPendingCount > 0);
      _hasQueuedChangesWhileSyncing = false;

      if (shouldProcessAgain) {
        await _processQueue();
      }
    }
  }

  Map<String, dynamic> _deserializePayload(
    String payload,
    String stickerId,
  ) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      // Fall through to legacy payload parsing.
    }

    final countMatch = RegExp(r'count:\s*(\d+)').firstMatch(payload);
    final updatedAtMatch = RegExp(r'updatedAt:\s*([^,}\n]+)').firstMatch(
      payload,
    );
    final legacyStickerIdMatch = RegExp(
      r'stickerId:\s*(\d+)',
    ).firstMatch(payload);

    return {
      'stickerId': int.tryParse(legacyStickerIdMatch?.group(1) ?? stickerId) ??
          int.parse(stickerId),
      'count': int.tryParse(countMatch?.group(1) ?? '0') ?? 0,
      'updatedAt': updatedAtMatch?.group(1)?.trim() ??
          DateTime.now().toIso8601String(),
      'migratedFromLegacyQueue': true,
      'userId': null,
    };
  }

  Future<int> _getCurrentUserPendingCount() async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      return 0;
    }

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
          return payloadUserId == currentUserId;
        }
      } catch (_) {
        return currentUserId == AppConstants.defaultUserId;
      }

      return false;
    }).length;
  }

  /// Handle remote changes from Firestore
  void _onRemoteChange(QuerySnapshot snapshot) {
    // TODO: Implement conflict resolution
    // For now, just log the changes
    for (final _ in snapshot.docChanges) {
      // Compare timestamps and resolve conflicts
      // Using last-write-wins strategy
    }
  }

  /// Set online status
  void setOnlineStatus(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;

      if (_isOnline) {
        // Connectivity restored, process queue
        _processQueue();
      } else {
        _updateStatus(SyncEngineStatus.offline);
      }
    }
  }

  /// Update sync status
  void _updateStatus(SyncEngineStatus status) {
    onStatusChanged?.call(status);
  }

  /// Get pending items count
  Future<int> getPendingCount() async {
    return _syncQueueRepo.getPendingCount();
  }

  /// Dispose sync engine
  void dispose() {
    _connectivitySubscription?.cancel();
    _remoteChangesSubscription?.cancel();
    _currentUserId = null;
  }
}

/// Sync engine status
enum SyncEngineStatus { idle, syncing, synced, offline, error }
