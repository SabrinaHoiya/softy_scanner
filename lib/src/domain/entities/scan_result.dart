import 'dart:io';

import 'package:equatable/equatable.dart';

/// The result returned by the scanner when the user finishes or cancels.
class ScanResult extends Equatable {
  /// The list of captured image files (empty if cancelled).
  final List<File> scannedPages;

  /// Whether the user cancelled the scanner.
  final bool isCancelled;

  /// The user-provided title for this scan (set in the review screen).
  final String? title;

  /// The generated PDF file (set after the user confirms in PDF preview).
  final File? pdfFile;

  const ScanResult({
    required this.scannedPages,
    this.isCancelled = false,
    this.title,
    this.pdfFile,
  });

  /// A convenience constructor for a cancelled result.
  const ScanResult.cancelled()
      : scannedPages = const [],
        isCancelled = true,
        title = null,
        pdfFile = null;

  /// Whether any pages were captured.
  bool get hasPages => scannedPages.isNotEmpty;

  /// The number of captured pages.
  int get pageCount => scannedPages.length;

  /// Whether a PDF was generated.
  bool get hasPdf => pdfFile != null;

  @override
  List<Object?> get props => [scannedPages, isCancelled, title, pdfFile];
}
