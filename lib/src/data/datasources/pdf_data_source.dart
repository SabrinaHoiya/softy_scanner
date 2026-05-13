import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Handles PDF generation and file operations.
class PdfDataSource {
  /// Generate a PDF with each image as a full page.
  Future<File> generatePdf({
    required List<File> imageFiles,
    required String title,
  }) async {
    // Convert all images to JPEG/PNG bytes the pdf package can handle.
    final futures = imageFiles.map((f) async {
      final bytes = await f.readAsBytes();
      if (_isJpeg(bytes) || _isPng(bytes)) return bytes;
      // Use Flutter's native codec — supports HEIC, WebP, etc.
      return _convertToJpegNative(bytes);
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

  /// Decode any image using the platform's native codec and re-encode as PNG.
  Future<Uint8List> _convertToJpegNative(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (byteData == null) {
      throw Exception('Failed to convert image for PDF');
    }
    return Uint8List.sublistView(byteData.buffer.asUint8List());
  }

  bool _isJpeg(Uint8List bytes) =>
      bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8;

  bool _isPng(Uint8List bytes) =>
      bytes.length >= 4 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47;
}
