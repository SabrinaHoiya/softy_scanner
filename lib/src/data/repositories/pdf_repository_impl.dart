import 'dart:io';

import '../../domain/repositories/pdf_repository.dart';
import '../datasources/pdf_data_source.dart';

/// Concrete implementation of [PdfRepository].
class PdfRepositoryImpl implements PdfRepository {
  final PdfDataSource _dataSource;

  const PdfRepositoryImpl(this._dataSource);

  @override
  Future<File> generatePdf({
    required List<File> imageFiles,
    required String title,
  }) =>
      _dataSource.generatePdf(imageFiles: imageFiles, title: title);

  @override
  Future<File> savePdf({
    required File pdfFile,
    required String fileName,
  }) =>
      _dataSource.savePdf(pdfFile: pdfFile, fileName: fileName);
}
