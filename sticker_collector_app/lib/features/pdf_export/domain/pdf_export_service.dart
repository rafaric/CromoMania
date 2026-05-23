import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import '../data/pdf_generator.dart';

/// Service for PDF export operations
class PdfExportService {
  final PdfGenerator _generator;

  PdfExportService(this._generator);

  /// Generate collection PDF
  Future<Uint8List> generateCollectionPdf({
    required String albumName,
    required String sectionName,
    required List<PdfStickerData> stickers,
    required Map<int, int> statusMap,
  }) async {
    return await _generator.generateCollectionPdf(
      albumName: albumName,
      sectionName: sectionName,
      stickers: stickers,
      statusMap: statusMap,
    );
  }

  /// Share PDF via native share sheet
  Future<void> sharePdf(
    Uint8List pdfBytes, {
    required String filterName,
    String? shareText,
  }) async {
    final filename = _generateFilename(filterName);

    final file = XFile.fromData(
      pdfBytes,
      mimeType: 'application/pdf',
      name: filename,
    );

    await Share.shareXFiles(
      [file],
      text: shareText ?? 'My sticker collection',
    );
  }

  String _generateFilename(String filterName) {
    final timestamp = DateTime.now().toIso8601String().split('T').first;
    return 'wc2026_${filterName}_$timestamp.pdf';
  }
}