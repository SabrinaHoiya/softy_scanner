import 'package:camera/camera.dart';

import '../repositories/camera_repository.dart';

/// Releases all camera resources.
class DisposeCameraUseCase {
  final CameraRepository _repository;

  const DisposeCameraUseCase(this._repository);

  Future<void> call(CameraController controller) {
    return _repository.dispose(controller);
  }
}
