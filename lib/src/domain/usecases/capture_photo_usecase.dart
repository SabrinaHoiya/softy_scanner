import 'dart:io';

import 'package:camera/camera.dart';

import '../repositories/camera_repository.dart';

/// Captures a single photo from the active camera.
class CapturePhotoUseCase {
  final CameraRepository _repository;

  const CapturePhotoUseCase(this._repository);

  Future<File> call(CameraController controller) {
    return _repository.takePicture(controller);
  }
}
