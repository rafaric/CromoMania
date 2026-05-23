import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// PDF export status
enum PdfExportStatus { initial, generating, ready, sharing, error }

/// PDF export filter options
enum ExportFilter {
  full,
  missingOnly,
  section,
}

/// PDF export state
class PdfExportState extends Equatable {
  final PdfExportStatus status;
  final Uint8List? pdfBytes;
  final ExportFilter filter;
  final String? errorMessage;

  const PdfExportState({
    this.status = PdfExportStatus.initial,
    this.pdfBytes,
    this.filter = ExportFilter.full,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, pdfBytes, filter, errorMessage];

  PdfExportState copyWith({
    PdfExportStatus? status,
    Uint8List? pdfBytes,
    ExportFilter? filter,
    String? errorMessage,
  }) {
    return PdfExportState(
      status: status ?? this.status,
      pdfBytes: pdfBytes ?? this.pdfBytes,
      filter: filter ?? this.filter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}