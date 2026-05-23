import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  /// Callback when sync status changes
  void Function(SyncEngineStatus)? onStatusChanged;

  SyncEngine({
    required FirestoreRepository firestoreRepo,
    required SyncQueueRepository syncQueueRepo,
  })  : _firestoreRepo = firestoreRepo,
        _syncQueueRepo = syncQueueRepo;

  /// Initialize sync engine for a user
  Future<void> initialize(String userId) async {
    _currentUserId = userId;
    
    // Start listening to remote changes
    _remoteChangesSubscription = _firestoreRepo.watchStickers(userId).listen(
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
      print('SyncEngine: Cannot queue - no user ID');
      return;
    }

    print('SyncEngine: Queuing sticker $stickerId with data: $data');

    // Add to local queue
    await _syncQueueRepo.addToQueue(
      stickerId: stickerId,
      operation: 'upsert',
      payload: data.toString(),
    );
    print('SyncEngine: Added to queue successfully');
    
    // If online, process immediately
    if (_isOnline && !_isSyncing) {
      print('SyncEngine: Online and not syncing - processing now');
      await _processQueue();
    } else {
      print('SyncEngine: Not processing now. online=$_isOnline, syncing=$_isSyncing');
    }
  }

  /// Process the sync queue
  Future<void> _processQueue() async {
    if (_currentUserId == null) {
      print('SyncEngine: Cannot process queue - no user ID');
      return;
    }
    
    _isSyncing = true;
    _updateStatus(SyncEngineStatus.syncing);

    try {
      final pendingItems = await _syncQueueRepo.getPendingItems();
      print('SyncEngine: Found ${pendingItems.length} pending items');
      
      for (final item in pendingItems) {
        final id = item['id'] as int?;
        if (id == null) continue;
        
        final stickerId = item['stickerId'] as String;
        final operation = item['operation'] as String;
        final payload = item['payload'] as String;
        final retryCount = item['retryCount'] as int? ?? 0;
        
        try {
          print('SyncEngine: Syncing sticker $stickerId to Firestore');
          // Process based on operation type
          if (operation == 'upsert') {
            // Parse payload back to map (simplified for now)
            final data = {'payload': payload, 'syncedAt': DateTime.now().toIso8601String()};
            await _firestoreRepo.upsertSticker(
              _currentUserId!,
              stickerId,
              data,
            );
            print('SyncEngine: Successfully synced sticker $stickerId');
          } else {
            await _firestoreRepo.deleteSticker(
              _currentUserId!,
              stickerId,
            );
          }
          
          // Mark as processed
          await _syncQueueRepo.markAsProcessed(id);
          print('SyncEngine: Marked $stickerId as processed');
        } catch (e) {
          print('SyncEngine: Error syncing sticker $stickerId: $e');
          // Increment retry count
          await _syncQueueRepo.incrementRetry(id);
          
          // If too many retries, mark as failed
          if (retryCount >= 3) {
            await _syncQueueRepo.markAsFailed(id, e.toString());
          }
        }
      }
      
      // Clean up processed items
      await _syncQueueRepo.cleanupProcessed();
      
      // Check if there are still pending items
      final remainingCount = await _syncQueueRepo.getPendingCount();
      if (remainingCount == 0) {
        _updateStatus(SyncEngineStatus.synced);
      } else {
        _updateStatus(SyncEngineStatus.syncing);
      }
    } catch (e) {
      _updateStatus(SyncEngineStatus.error);
    } finally {
      _isSyncing = false;
    }
  }

  /// Handle remote changes from Firestore
  void _onRemoteChange(QuerySnapshot snapshot) {
    // TODO: Implement conflict resolution
    // For now, just log the changes
    for (final change in snapshot.docChanges) {
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
enum SyncEngineStatus {
  idle,
  syncing,
  synced,
  offline,
  error,
}