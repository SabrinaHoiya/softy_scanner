import 'dart:io';

import '../../domain/repositories/gallery_repository.dart';
import '../datasources/gallery_data_source.dart';

/// Concrete implementation of [GalleryRepository] backed by [GalleryDataSource].
class GalleryRepositoryImpl implements GalleryRepository {
  final GalleryDataSource _dataSource;

  const GalleryRepositoryImpl(this._dataSource);

  @override
  Future<File?> pickSingleImage() => _dataSource.pickSingleImage();

  @override
  Future<List<File>> pickMultipleImages() => _dataSource.pickMultipleImages();

  @override
  Future<File> ensureCompatibleFormat(File file) =>
      _dataSource.ensureCompatibleFormat(file);

  @override
  Future<List<File>> ensureCompatibleFormats(List<File> files) =>
      _dataSource.ensureCompatibleFormats(files);
}
