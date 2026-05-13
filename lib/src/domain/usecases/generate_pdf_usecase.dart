import 'dart:io';

import '../repositories/pdf_repository.dart';

/// Generates a PDF from a list of scanned images.
class GeneratePdfUseCase {
  final PdfRepository _repository;

  const GeneratePdfUseCase(this._repository);

  Future<File> call({
    required List<File> imageFiles,
    required String title,
  }) =>
      _repository.generatePdf(imageFiles: imageFiles, title: title);
}
