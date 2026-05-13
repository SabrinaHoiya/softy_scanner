import 'dart:io';
import 'dart:typed_data';

import '../repositories/image_edit_repository.dart';

/// Applies a crop to an image.
class CropImageUseCase {
  final ImageEditRepository _repository;

  const CropImageUseCase(this._repository);

  Future<File> call(File file, Uint8List croppedBytes) =>
      _repository.applyCrop(file, croppedBytes);
}
