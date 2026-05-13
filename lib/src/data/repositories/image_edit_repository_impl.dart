import 'dart:io';
import 'dart:typed_data';

import '../../domain/repositories/image_edit_repository.dart';
import '../datasources/image_edit_data_source.dart';

/// Concrete implementation of [ImageEditRepository].
class ImageEditRepositoryImpl implements ImageEditRepository {
  final ImageEditDataSource _dataSource;

  const ImageEditRepositoryImpl(this._dataSource);

  @override
  Future<File> rotate(File file, {int quarterTurns = 1}) =>
      _dataSource.rotate(file, quarterTurns: quarterTurns);

  @override
  Future<File> applyCrop(File file, Uint8List croppedBytes) =>
      _dataSource.applyCrop(file, croppedBytes);
}
