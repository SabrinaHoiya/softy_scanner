import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Handles PDF generation and file operations.
/// Heavy image processing runs on background isolates via [compute].
class PdfDataSource {
  /// Generate a PDF with each image as a full page.
  Future<File> generatePdf({
    required List<File> imageFiles,
    required String title,
  }) async {
    // Pre-process all images in parallel on background isolates.
    final futures = imageFiles.map((f) async {
      final bytes = await f.readAsBytes();
      return _needsConversion(bytes)
          ? await compute(_convertToJpegIsolate, bytes)
          : bytes;
    });
    final allBytes = await Future.wait(futures);

    final pdf = pw.Document();
    for (final bytes in allBytes) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (context) => pw.Center(
            child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
          ),
        ),
      );
    }

    final tempDir = await getTemporaryDirectory();
    final sanitized = title.replaceAll(RegExp(r'[^\w\s\-]'), '_');
    final file = File('${tempDir.path}/$sanitized.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Copy the PDF to the app's documents directory.
  Future<File> savePdf({
    required File pdfFile,
    required String fileName,
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final sanitized = fileName.replaceAll(RegExp(r'[^\w\s\-]'), '_');
    final destination = File('${docsDir.path}/$sanitized.pdf');
    return pdfFile.copy(destination.path);
  }

  bool _needsConversion(Uint8List bytes) =>
      !_isJpeg(bytes) && !_isPng(bytes);

  bool _isJpeg(Uint8List bytes) =>
      bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8;

  bool _isPng(Uint8List bytes) =>
      bytes.length >= 4 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47;
}

/// Top-level function for [compute] — decodes any image format and
/// re-encodes as JPEG on a background isolate.
Uint8List _convertToJpegIsolate(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception('Unable to decode image');
  return Uint8List.fromList(img.encodeJpg(decoded, quality: 95));
}
