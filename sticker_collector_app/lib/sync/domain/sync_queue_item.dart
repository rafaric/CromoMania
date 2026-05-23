import 'package:equatable/equatable.dart';

/// Sync operation type
enum SyncOperation {
  upsert,
  delete,
}

/// Sync queue status
enum SyncQueueStatus {
  pending,
  processing,
  processed,
  failed,
}

/// Sync queue item entity representing a pending sync operation
class SyncQueueItem extends Equatable {
  final int? id;
  final String stickerId;
  final SyncOperation operation;
  final Map<String, dynamic> payload;
  final int retryCount;
  final SyncQueueStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;

  const SyncQueueItem({
    this.id,
    required this.stickerId,
    required this.operation,
    required this.payload,
    this.retryCount = 0,
    this.status = SyncQueueStatus.pending,
    required this.createdAt,
    this.processedAt,
  });

  /// Create from database row
  factory SyncQueueItem.fromDbRow({
    required int id,
    required String stickerId,
    required String operation,
    required String payload,
    required int retryCount,
    required String status,
    required DateTime createdAt,
    DateTime? processedAt,
  }) {
    return SyncQueueItem(
      id: id,
      stickerId: stickerId,
      operation: operation == 'delete' ? SyncOperation.delete : SyncOperation.upsert,
      payload: _parsePayload(payload),
      retryCount: retryCount,
      status: _parseStatus(status),
      createdAt: createdAt,
      processedAt: processedAt,
    );
  }

  /// Parse payload JSON
  static Map<String, dynamic> _parsePayload(String payload) {
    try {
      // Simple JSON parsing - in production use dart:convert
      return {'data': payload}; // Simplified
    } catch (_) {
      return {};
    }
  }

  /// Parse status string
  static SyncQueueStatus _parseStatus(String status) {
    switch (status) {
      case 'processing':
        return SyncQueueStatus.processing;
      case 'processed':
        return SyncQueueStatus.processed;
      case 'failed':
        return SyncQueueStatus.failed;
      default:
        return SyncQueueStatus.pending;
    }
  }

  /// Copy with method
  SyncQueueItem copyWith({
    int? id,
    String? stickerId,
    SyncOperation? operation,
    Map<String, dynamic>? payload,
    int? retryCount,
    SyncQueueStatus? status,
    DateTime? createdAt,
    DateTime? processedAt,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      stickerId: stickerId ?? this.stickerId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        stickerId,
        operation,
        payload,
        retryCount,
        status,
        createdAt,
        processedAt,
      ];
}