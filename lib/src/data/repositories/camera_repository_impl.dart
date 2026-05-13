import 'dart:io';

import 'package:camera/camera.dart';

import '../../domain/repositories/camera_repository.dart';
import '../datasources/camera_data_source.dart';

/// Concrete implementation of [CameraRepository] backed by [CameraDataSource].
class CameraRepositoryImpl implements CameraRepository {
  final CameraDataSource _dataSource;

  const CameraRepositoryImpl(this._dataSource);

  @override
  Future<CameraController> initialize({
    required ResolutionPreset resolution,
  }) =>
      _dataSource.initialize(resolution: resolution);

  @override
  Future<File> takePicture(CameraController controller) =>
      _dataSource.takePicture(controller);

  @override
  Future<bool> toggleFlash(
    CameraController controller, {
    required bool currentlyOn,
  }) =>
      _dataSource.toggleFlash(controller, currentlyOn: currentlyOn);

  @override
  Future<void> dispose(CameraController controller) =>
      _dataSource.dispose(controller);
}
