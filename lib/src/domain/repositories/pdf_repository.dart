import 'dart:io';

/// Abstract contract for PDF generation and saving operations.
abstract class PdfRepository {
  /// Generate a PDF from the given [imageFiles] and return the PDF file.
  Future<File> generatePdf({
    required List<File> imageFiles,
    required String title,
  });

  /// Save the [pdfFile] to the device's documents directory with [fileName].
  Future<File> savePdf({
    required File pdfFile,
    required String fileName,
  });
}
