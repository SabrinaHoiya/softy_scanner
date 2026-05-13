import 'package:camera/camera.dart';

import '../repositories/camera_repository.dart';

/// Initializes the device camera with the given resolution.
class InitializeCameraUseCase {
  final CameraRepository _repository;

  const InitializeCameraUseCase(this._repository);

  Future<CameraController> call({required ResolutionPreset resolution}) {
    return _repository.initialize(resolution: resolution);
  }
}
