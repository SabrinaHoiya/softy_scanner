import 'dart:io';

import 'package:camera/camera.dart';

/// Abstract contract for camera operations.
/// The data layer provides the concrete implementation.
abstract class CameraRepository {
  /// Initialize the camera and return the [CameraController].
  Future<CameraController> initialize({
    required ResolutionPreset resolution,
  });

  /// Take a picture and return the captured [File].
  Future<File> takePicture(CameraController controller);

  /// Toggle flash on the given [controller].
  /// Returns `true` if flash is now on, `false` if off.
  Future<bool> toggleFlash(CameraController controller, {required bool currentlyOn});

  /// Release all camera resources.
  Future<void> dispose(CameraController controller);
}
