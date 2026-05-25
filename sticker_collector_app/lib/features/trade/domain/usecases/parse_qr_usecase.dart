import 'dart:convert';
import '../entities/scanned_qr_data.dart';

/// Errors for QR parsing
enum QRParseError {
  invalidJson,
  missingField,
  wrongVersion,
  missingTimestamp,
  missingExpiry,
}

/// Result of parsing a QR code
class ParseQRResult {
  final ScannedQRData? data;
  final QRParseError? error;
  final String? errorMessage;

  const ParseQRResult._({
    this.data,
    this.error,
    this.errorMessage,
  });

  factory ParseQRResult.success(ScannedQRData data) => ParseQRResult._(data: data);

  factory ParseQRResult.failure(QRParseError error, String message) =>
      ParseQRResult._(error: error, errorMessage: message);

  bool get isValid => data != null;
}

/// Use case for parsing QR code payload
class ParseQRUseCase {
  /// Parse JSON QR payload into ScannedQRData
  ParseQRResult execute(String rawQR) {
    if (rawQR.isEmpty) {
      return ParseQRResult.failure(
        QRParseError.invalidJson,
        'Empty QR code data',
      );
    }

    Map<String, dynamic> json;
    try {
      json = jsonDecode(rawQR) as Map<String, dynamic>;
    } catch (e) {
      return ParseQRResult.failure(
        QRParseError.invalidJson,
        'Invalid QR code format',
      );
    }

    // Validate required fields
    final version = json['v'];
    if (version == null) {
      return ParseQRResult.failure(
        QRParseError.missingField,
        'Missing version field',
      );
    }

    if (version != 1) {
      return ParseQRResult.failure(
        QRParseError.wrongVersion,
        'Incompatible QR version: $version',
      );
    }

    final uid = json['uid'];
    if (uid == null) {
      return ParseQRResult.failure(
        QRParseError.missingField,
        'Missing user ID field',
      );
    }

    final ts = json['ts'];
    if (ts == null) {
      return ParseQRResult.failure(
        QRParseError.missingTimestamp,
        'Missing timestamp field',
      );
    }

    final exp = json['exp'];
    if (exp == null) {
      return ParseQRResult.failure(
        QRParseError.missingExpiry,
        'Missing expiry field',
      );
    }

    final missing = (json['missing'] as List<dynamic>?)?.cast<int>() ?? [];
    final repeated = (json['repeated'] as List<dynamic>?)?.cast<int>() ?? [];
    final album = json['album'] as String? ?? 'panini_wc2026';

    return ParseQRResult.success(ScannedQRData(
      version: version,
      partnerUid: uid,
      timestamp: ts,
      expirySeconds: exp,
      albumId: album,
      missing: missing,
      repeated: repeated,
    ));
  }
}