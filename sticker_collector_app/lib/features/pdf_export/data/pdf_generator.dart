import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// PDF generator for collection export
class PdfGenerator {
  /// Generate collection PDF
  Future<Uint8List> generateCollectionPdf({
    required String albumName,
    required String sectionName,
    required List<PdfStickerData> stickers,
    required Map<int, int> statusMap,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildHeader(albumName, sectionName),
          pw.SizedBox(height: 16),

          // Summary
          _buildSummary(stickers, statusMap),
          pw.SizedBox(height: 24),

          // Stickers table
          _buildStickerTable(stickers, statusMap),
          pw.SizedBox(height: 24),

          // Legend
          _buildLegend(),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(String albumName, String sectionName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          sectionName.isNotEmpty ? sectionName : albumName,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Generated: ${DateTime.now().toIso8601String().split('T').first}',
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSummary(List<PdfStickerData> stickers, Map<int, int> statusMap) {
    final owned = stickers.where((s) => (statusMap[s.id] ?? 0) > 0).length;
    final missing = stickers.length - owned;

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          pw.Text('Total: ${stickers.length}'),
          pw.Text('Owned: $owned'),
          pw.Text('Missing: $missing'),
        ],
      ),
    );
  }

  pw.Widget _buildStickerTable(List<PdfStickerData> stickers, Map<int, int> statusMap) {
    return pw.TableHelper.fromTextArray(
      headers: ['#', 'Name', 'Status'],
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey300,
      ),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
      },
      cellStyle: const pw.TextStyle(fontSize: 10),
      data: stickers.map((s) {
        final count = statusMap[s.id] ?? 0;
        return [
          s.number,
          s.name,
          _statusSymbol(count),
        ];
      }).toList(),
    );
  }

  String _statusSymbol(int count) {
    if (count == 0) return '[ ]';
    if (count == 1) return '[✓]';
    return '[+$count]';
  }

  pw.Widget _buildLegend() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Legend:', style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
          )),
          pw.SizedBox(height: 4),
          pw.Text('[ ] = Missing (not in collection)'),
          pw.Text('[✓] = Owned (have this sticker)'),
          pw.Text('[+n] = Repeated (have n copies)'),
        ],
      ),
    );
  }
}

/// Sticker data for PDF generation
class PdfStickerData {
  final int id;
  final String number;
  final String name;
  final String sectionName;

  const PdfStickerData({
    required this.id,
    required this.number,
    required this.name,
    required this.sectionName,
  });
}