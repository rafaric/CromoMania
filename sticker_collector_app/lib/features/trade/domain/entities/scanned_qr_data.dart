import 'package:equatable/equatable.dart';

/// Raw data parsed from QR code payload
class ScannedQRData extends Equatable {
  final int version;
  final String partnerUid;
  final int timestamp;
  final int expirySeconds;
  final String albumId;
  final List<int> missing;
  final List<int> repeated;

  const ScannedQRData({
    required this.version,
    required this.partnerUid,
    required this.timestamp,
    required this.expirySeconds,
    required this.albumId,
    required this.missing,
    required this.repeated,
  });

  /// Check if QR has expired
  bool get isExpired {
    final ageSeconds = (DateTime.now().millisecondsSinceEpoch - timestamp) / 1000;
    return ageSeconds > expirySeconds;
  }

  /// Get time remaining in seconds
  int get remainingSeconds {
    final ageSeconds = (DateTime.now().millisecondsSinceEpoch - timestamp) / 1000;
    return (expirySeconds - ageSeconds).clamp(0, expirySeconds).toInt();
  }

  /// Get expiration DateTime
  DateTime get expiresAt {
    return DateTime.fromMillisecondsSinceEpoch(timestamp + (expirySeconds * 1000));
  }

  @override
  List<Object?> get props => [version, partnerUid, timestamp, expirySeconds, albumId, missing, repeated];

  ScannedQRData copyWith({
    int? version,
    String? partnerUid,
    int? timestamp,
    int? expirySeconds,
    String? albumId,
    List<int>? missing,
    List<int>? repeated,
  }) {
    return ScannedQRData(
      version: version ?? this.version,
      partnerUid: partnerUid ?? this.partnerUid,
      timestamp: timestamp ?? this.timestamp,
      expirySeconds: expirySeconds ?? this.expirySeconds,
      albumId: albumId ?? this.albumId,
      missing: missing ?? this.missing,
      repeated: repeated ?? this.repeated,
    );
  }

  @override
  String toString() {
    return 'ScannedQRData(v:$version, uid:$partnerUid, missing:${missing.length}, repeated:${repeated.length})';
  }
}