import 'dart:io';

import 'package:camera/camera.dart';

/// Handles direct interaction with the device camera via the `camera` plugin.
class CameraDataSource {
  /// Discover available cameras and initialize a [CameraController]
  /// using the back-facing camera (falls back to the first available).
  Future<CameraController> initialize({
    required ResolutionPreset resolution,
  }) async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw CameraException('noCameras', 'No cameras available on this device');
    }

    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      backCamera,
      resolution,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await controller.initialize();
    return controller;
  }

  /// Capture a still image and return it as a [File].
  Future<File> takePicture(CameraController controller) async {
    final xFile = await controller.takePicture();
    return File(xFile.path);
  }

  /// Set flash mode. Returns the new state (`true` = on).
  Future<bool> toggleFlash(
    CameraController controller, {
    required bool currentlyOn,
  }) async {
    final newMode = currentlyOn ? FlashMode.off : FlashMode.torch;
    await controller.setFlashMode(newMode);
    return !currentlyOn;
  }

  /// Dispose of the camera controller.
  Future<void> dispose(CameraController controller) async {
    await controller.dispose();
  }
}
