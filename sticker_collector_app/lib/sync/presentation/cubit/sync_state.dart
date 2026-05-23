import 'package:equatable/equatable.dart';
import '../../domain/sync_status.dart';

/// Sync state class
class SyncState extends Equatable {
  final SyncStatus status;
  final int pendingCount;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  const SyncState({
    this.status = SyncStatus.idle,
    this.pendingCount = 0,
    this.lastSyncedAt,
    this.errorMessage,
  });

  /// Initial state
  const SyncState.initial() : this();

  /// Copy with method
  SyncState copyWith({
    SyncStatus? status,
    int? pendingCount,
    DateTime? lastSyncedAt,
    String? errorMessage,
  }) {
    return SyncState(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Check if syncing
  bool get isSyncing => status == SyncStatus.syncing;

  /// Check if offline
  bool get isOffline => status == SyncStatus.offline;

  /// Get display status
  String get displayStatus {
    switch (status) {
      case SyncStatus.idle:
        return 'Ready';
      case SyncStatus.syncing:
        return 'Syncing $pendingCount items...';
      case SyncStatus.synced:
        final timeAgo = _formatTimeAgo(lastSyncedAt);
        return 'Synced $timeAgo';
      case SyncStatus.offline:
        return 'Offline - $pendingCount pending';
      case SyncStatus.error:
        return 'Sync error: $errorMessage';
    }
  }

  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  List<Object?> get props => [status, pendingCount, lastSyncedAt, errorMessage];
}