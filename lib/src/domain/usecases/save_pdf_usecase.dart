import 'dart:io';

import '../repositories/pdf_repository.dart';

/// Saves a PDF file to the device's documents directory.
class SavePdfUseCase {
  final PdfRepository _repository;

  const SavePdfUseCase(this._repository);

  Future<File> call({required File pdfFile, required String fileName}) =>
      _repository.savePdf(pdfFile: pdfFile, fileName: fileName);
}
