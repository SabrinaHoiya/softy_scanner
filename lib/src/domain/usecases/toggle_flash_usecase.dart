import 'package:camera/camera.dart';

import '../repositories/camera_repository.dart';

/// Toggles the camera flash on or off.
class ToggleFlashUseCase {
  final CameraRepository _repository;

  const ToggleFlashUseCase(this._repository);

  /// Returns the new flash state (`true` = on).
  Future<bool> call(CameraController controller, {required bool currentlyOn}) {
    return _repository.toggleFlash(controller, currentlyOn: currentlyOn);
  }
}
