/// Sync status enum for UI display
enum SyncStatus {
  idle,
  syncing,
  synced,
  offline,
  error,
}

/// Extension for SyncStatus display
extension SyncStatusExtension on SyncStatus {
  /// Get display string for status
  String get displayName {
    switch (this) {
      case SyncStatus.idle:
        return 'Ready';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.error:
        return 'Error';
    }
  }

  /// Get icon for status
  String get iconName {
    switch (this) {
      case SyncStatus.idle:
        return 'cloud_queue';
      case SyncStatus.syncing:
        return 'sync';
      case SyncStatus.synced:
        return 'cloud_done';
      case SyncStatus.offline:
        return 'cloud_off';
      case SyncStatus.error:
        return 'error_outline';
    }
  }
}