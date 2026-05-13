import 'dart:io';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/scan_mode.dart';

/// Represents the current status of the scanner.
enum ScannerStatus {
  initial,
  cameraReady,
  capturing,
  processing,
  error,
}

/// Sentinel used to explicitly clear nullable fields in [copyWith].
const _cleared = Object();

/// Immutable state for the scanner BLoC.
class ScannerState extends Equatable {
  final ScannerStatus status;
  final CameraController? cameraController;
  final bool isFlashOn;
  final ScanMode scanMode;
  final List<File> capturedPages;
  final String? errorMessage;

  /// True when the last page addition came from the gallery picker.
  final bool addedFromGallery;

  const ScannerState({
    this.status = ScannerStatus.initial,
    this.cameraController,
    this.isFlashOn = false,
    this.scanMode = ScanMode.unique,
    this.capturedPages = const [],
    this.errorMessage,
    this.addedFromGallery = false,
  });

  bool get isCameraReady => status == ScannerStatus.cameraReady;
  bool get isCapturing => status == ScannerStatus.capturing;
  bool get hasPages => capturedPages.isNotEmpty;
  int get pageCount => capturedPages.length;

  /// Pass the sentinel [clearCameraController] to explicitly set the
  /// camera controller to `null` (normal `null` means "keep current value").
  ScannerState copyWith({
    ScannerStatus? status,
    Object? cameraController = _cleared,
    bool? isFlashOn,
    ScanMode? scanMode,
    List<File>? capturedPages,
    String? errorMessage,
    bool? addedFromGallery,
  }) {
    return ScannerState(
      status: status ?? this.status,
      cameraController: identical(cameraController, _cleared)
          ? this.cameraController
          : cameraController as CameraController?,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      scanMode: scanMode ?? this.scanMode,
      capturedPages: capturedPages ?? this.capturedPages,
      errorMessage: errorMessage,
      addedFromGallery: addedFromGallery ?? false,
    );
  }

  @override
  List<Object?> get props => [
        status,
        cameraController,
        isFlashOn,
        scanMode,
        capturedPages,
        errorMessage,
        addedFromGallery,
      ];
}
