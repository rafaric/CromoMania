import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/pdf_generator.dart';
import '../../domain/pdf_export_service.dart';
import 'pdf_export_state.dart';

/// Cubit for managing PDF export state
class PdfExportCubit extends Cubit<PdfExportState> {
  final PdfExportService _service;

  PdfExportCubit(this._service) : super(const PdfExportState());

  /// Generate PDF with current filter
  Future<void> generatePdf({
    required String albumName,
    required String sectionName,
    required List<PdfStickerData> stickers,
    required Map<int, int> statusMap,
    ExportFilter filter = ExportFilter.full,
  }) async {
    emit(state.copyWith(
      status: PdfExportStatus.generating,
      filter: filter,
    ));

    try {
      // Apply filter to stickers
      final filteredStickers = _applyFilter(stickers, statusMap, filter);

      final pdfBytes = await _service.generateCollectionPdf(
        albumName: albumName,
        sectionName: sectionName,
        stickers: filteredStickers,
        statusMap: statusMap,
      );

      emit(state.copyWith(
        status: PdfExportStatus.ready,
        pdfBytes: pdfBytes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PdfExportStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Share generated PDF
  Future<void> sharePdf() async {
    if (state.pdfBytes == null) return;

    emit(state.copyWith(status: PdfExportStatus.sharing));

    try {
      await _service.sharePdf(
        state.pdfBytes!,
        filterName: state.filter.name,
      );

      emit(state.copyWith(status: PdfExportStatus.ready));
    } catch (e) {
      emit(state.copyWith(
        status: PdfExportStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Apply filter to stickers
  List<PdfStickerData> _applyFilter(
    List<PdfStickerData> stickers,
    Map<int, int> statusMap,
    ExportFilter filter,
  ) {
    switch (filter) {
      case ExportFilter.full:
      case ExportFilter.section:
        return stickers;
      case ExportFilter.missingOnly:
        return stickers.where((s) => (statusMap[s.id] ?? 0) == 0).toList();
    }
  }

  /// Reset state
  void reset() {
    emit(const PdfExportState());
  }
}