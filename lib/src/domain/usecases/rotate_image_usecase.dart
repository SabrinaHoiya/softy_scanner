import 'dart:io';

import '../repositories/image_edit_repository.dart';

/// Rotates an image by [quarterTurns] × 90° clockwise.
class RotateImageUseCase {
  final ImageEditRepository _repository;

  const RotateImageUseCase(this._repository);

  Future<File> call(File file, {int quarterTurns = 1}) =>
      _repository.rotate(file, quarterTurns: quarterTurns);
}
