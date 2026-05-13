import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/scan_mode.dart';
import '../../domain/entities/scanner_config.dart';
import '../../domain/usecases/capture_photo_usecase.dart';
import '../../domain/usecases/dispose_camera_usecase.dart';
import '../../domain/usecases/initialize_camera_usecase.dart';
import '../../domain/usecases/pick_from_gallery_usecase.dart';
import '../../domain/usecases/toggle_flash_usecase.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';

/// BLoC that orchestrates scanner interactions through use cases.
class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final InitializeCameraUseCase _initializeCamera;
  final CapturePhotoUseCase _capturePhoto;
  final ToggleFlashUseCase _toggleFlash;
  final PickFromGalleryUseCase _pickFromGallery;
  final DisposeCameraUseCase _disposeCamera;
  final ScannerConfig config;

  ScannerBloc({
    required InitializeCameraUseCase initializeCamera,
    required CapturePhotoUseCase capturePhoto,
    required ToggleFlashUseCase toggleFlash,
    required PickFromGalleryUseCase pickFromGallery,
    required DisposeCameraUseCase disposeCamera,
    required this.config,
  })  : _initializeCamera = initializeCamera,
        _capturePhoto = capturePhoto,
        _toggleFlash = toggleFlash,
        _pickFromGallery = pickFromGallery,
        _disposeCamera = disposeCamera,
        super(ScannerState(scanMode: config.initialMode)) {
    on<ScannerInitialized>(_onInitialized);
    on<ScannerCapturePressed>(_onCapturePressed);
    on<ScannerFlashToggled>(_onFlashToggled);
    on<ScannerModeChanged>(_onModeChanged);
    on<ScannerGalleryPressed>(_onGalleryPressed);
    on<ScannerPageRemoved>(_onPageRemoved);
    on<ScannerPagesCleared>(_onPagesCleared);
    on<ScannerDisposed>(_onDisposed);
  }

  Future<void> _onInitialized(
    ScannerInitialized event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      final controller = await _initializeCamera(
        resolution: _mapResolution(config.resolution),
      );
      emit(state.copyWith(
        status: ScannerStatus.cameraReady,
        cameraController: controller,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ScannerStatus.error,
        errorMessage: 'Failed to initialize camera: $e',
      ));
    }
  }

  Future<void> _onCapturePressed(
    ScannerCapturePressed event,
    Emitter<ScannerState> emit,
  ) async {
    if (!state.isCameraReady || state.cameraController == null) return;

    emit(state.copyWith(status: ScannerStatus.capturing));

    try {
      final file = await _capturePhoto(state.cameraController!);
      final updatedPages = List.of(state.capturedPages)..add(file);
      emit(state.copyWith(
        status: ScannerStatus.cameraReady,
        capturedPages: updatedPages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ScannerStatus.cameraReady,
        errorMessage: 'Capture failed: $e',
      ));
    }
  }

  Future<void> _onFlashToggled(
    ScannerFlashToggled event,
    Emitter<ScannerState> emit,
  ) async {
    if (state.cameraController == null) return;

    try {
      final isOn = await _toggleFlash(
        state.cameraController!,
        currentlyOn: state.isFlashOn,
      );
      emit(state.copyWith(isFlashOn: isOn));
    } catch (_) {
      // Silently ignore flash failures (e.g., device without flash).
    }
  }

  void _onModeChanged(
    ScannerModeChanged event,
    Emitter<ScannerState> emit,
  ) {
    emit(state.copyWith(scanMode: event.mode));
  }

  Future<void> _onGalleryPressed(
    ScannerGalleryPressed event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      if (state.scanMode == ScanMode.multiple) {
        final files = await _pickFromGallery.pickMultiple();
        if (files.isEmpty) return;
        final updatedPages = List.of(state.capturedPages)..addAll(files);
        emit(state.copyWith(
          capturedPages: updatedPages,
          addedFromGallery: true,
        ));
      } else {
        final file = await _pickFromGallery.pickSingle();
        if (file == null) return;
        final updatedPages = List.of(state.capturedPages)..add(file);
        emit(state.copyWith(
          capturedPages: updatedPages,
          addedFromGallery: true,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Gallery pick failed: $e',
      ));
    }
  }

  void _onPageRemoved(
    ScannerPageRemoved event,
    Emitter<ScannerState> emit,
  ) {
    if (event.index >= 0 && event.index < state.capturedPages.length) {
      final updatedPages = List.of(state.capturedPages)..removeAt(event.index);
      emit(state.copyWith(capturedPages: updatedPages));
    }
  }

  void _onPagesCleared(
    ScannerPagesCleared event,
    Emitter<ScannerState> emit,
  ) {
    emit(state.copyWith(capturedPages: const []));
  }

  Future<void> _onDisposed(
    ScannerDisposed event,
    Emitter<ScannerState> emit,
  ) async {
    final controller = state.cameraController;
    // Clear the controller from state FIRST so the UI stops rendering it.
    emit(state.copyWith(
      status: ScannerStatus.initial,
      cameraController: null,
    ));
    if (controller != null) {
      await _disposeCamera(controller);
    }
  }

  ResolutionPreset _mapResolution(CameraResolution resolution) {
    switch (resolution) {
      case CameraResolution.low:
        return ResolutionPreset.low;
      case CameraResolution.medium:
        return ResolutionPreset.medium;
      case CameraResolution.high:
        return ResolutionPreset.high;
      case CameraResolution.veryHigh:
        return ResolutionPreset.veryHigh;
      case CameraResolution.max:
        return ResolutionPreset.max;
    }
  }
}
