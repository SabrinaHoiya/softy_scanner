import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/camera_data_source.dart';
import '../../data/datasources/gallery_data_source.dart';
import '../../data/repositories/camera_repository_impl.dart';
import '../../data/repositories/gallery_repository_impl.dart';
import '../../domain/entities/scan_mode.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/entities/scanner_config.dart';
import '../../domain/usecases/capture_photo_usecase.dart';
import '../../domain/usecases/dispose_camera_usecase.dart';
import '../../domain/usecases/initialize_camera_usecase.dart';
import '../../domain/usecases/pick_from_gallery_usecase.dart';
import '../../domain/usecases/toggle_flash_usecase.dart';
import '../bloc/scanner_bloc.dart';
import '../bloc/scanner_event.dart';
import '../bloc/scanner_state.dart';
import '../widgets/scanner_bottom_bar.dart';
import '../widgets/scanner_top_bar.dart';
import 'review_screen.dart';

/// Full-screen scanner page.
///
/// Push this screen and `await` the [ScanResult]:
/// ```dart
/// final result = await SoftyScannerScreen.launch(context);
/// ```
class SoftyScannerScreen extends StatelessWidget {
  final ScannerConfig config;

  /// When `true`, the scanner auto-pops after one capture (used by
  /// review/PDF "Ajouter" buttons to add a single page).
  /// When `false` (default), unique mode navigates to the review screen
  /// just like multiple mode.
  final bool quickCapture;

  SoftyScannerScreen({
    super.key,
    ScannerConfig? config,
    this.quickCapture = false,
  }) : config = config ?? ScannerConfig();

  /// Convenience method to push the scanner and return a [ScanResult].
  static Future<ScanResult> launch(
    BuildContext context, {
    ScannerConfig? config,
    bool quickCapture = false,
  }) async {
    config ??= ScannerConfig();
    final result = await Navigator.of(context).push<ScanResult>(
      MaterialPageRoute(
        builder: (_) => SoftyScannerScreen(
          config: config,
          quickCapture: quickCapture,
        ),
      ),
    );
    return result ?? const ScanResult.cancelled();
  }

  @override
  Widget build(BuildContext context) {
    final cameraDataSource = CameraDataSource();
    final galleryDataSource = GalleryDataSource();
    final cameraRepo = CameraRepositoryImpl(cameraDataSource);
    final galleryRepo = GalleryRepositoryImpl(galleryDataSource);

    return BlocProvider(
      create: (_) => ScannerBloc(
        initializeCamera: InitializeCameraUseCase(cameraRepo),
        capturePhoto: CapturePhotoUseCase(cameraRepo),
        toggleFlash: ToggleFlashUseCase(cameraRepo),
        pickFromGallery: PickFromGalleryUseCase(galleryRepo),
        disposeCamera: DisposeCameraUseCase(cameraRepo),
        config: config,
      )..add(const ScannerInitialized()),
      child: _ScannerView(config: config, quickCapture: quickCapture),
    );
  }
}

class _ScannerView extends StatelessWidget {
  final ScannerConfig config;
  final bool quickCapture;

  const _ScannerView({required this.config, required this.quickCapture});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScannerBloc, ScannerState>(
      listenWhen: (prev, curr) =>
          curr.hasPages && !prev.hasPages ||
          curr.capturedPages.length != prev.capturedPages.length,
      listener: (context, state) {
        if (!state.hasPages) return;

        if (quickCapture) {
          // Quick-capture mode: just pop with the captured page(s).
          Navigator.of(context).pop(
            ScanResult(scannedPages: state.capturedPages),
          );
        } else if (state.addedFromGallery) {
          // Gallery pick: always go straight to review.
          _navigateToReview(context, state.capturedPages);
        } else if (state.scanMode == ScanMode.unique) {
          // Normal unique mode: go straight to review after one capture.
          _navigateToReview(context, state.capturedPages);
        }
        // Multiple mode (camera): user taps "Continue" manually.
      },
      builder: (context, state) {
        return PopScope(
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) {
              context.read<ScannerBloc>().add(const ScannerDisposed());
            }
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Column(
              children: [
                    ScannerTopBar(
                      config: config,
                      isFlashOn: state.isFlashOn,
                      onCancel: () => Navigator.of(context).pop(
                        const ScanResult.cancelled(),
                      ),
                      onToggleFlash: () => context
                          .read<ScannerBloc>()
                          .add(const ScannerFlashToggled()),
                    ),
                    Expanded(child: _buildCameraPreview(state)),
                    ScannerBottomBar(
                      config: config,
                      scanMode: state.scanMode,
                      isCapturing: state.isCapturing,
                      capturedPages: state.capturedPages,
                      onModeChanged: (mode) => context
                          .read<ScannerBloc>()
                          .add(ScannerModeChanged(mode)),
                      onCapture: () => context
                          .read<ScannerBloc>()
                          .add(const ScannerCapturePressed()),
                      onGallery: () => context
                          .read<ScannerBloc>()
                          .add(const ScannerGalleryPressed()),
                      onContinue: () => _navigateToReview(
                        context,
                        state.capturedPages,
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _navigateToReview(
    BuildContext context,
    List<File> pages,
  ) async {
    context.read<ScannerBloc>().add(const ScannerDisposed());

    final result = await Navigator.of(context).push<ScanResult>(
      MaterialPageRoute(
        builder: (_) => ReviewScreen(
          initialPages: pages,
          config: config,
        ),
      ),
    );

    if (result != null && context.mounted) {
      Navigator.of(context).pop(result);
    } else if (context.mounted) {
      // All images were deleted or user went back — clear old pages
      // and re-initialize the camera fresh.
      final bloc = context.read<ScannerBloc>();
      bloc.add(const ScannerPagesCleared());
      bloc.add(const ScannerInitialized());
    }
  }

  Widget _buildCameraPreview(ScannerState state) {
    if (state.status == ScannerStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.errorMessage ?? 'An unknown error occurred',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final camera = state.cameraController;
    if (!state.isCameraReady ||
        camera == null ||
        !camera.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: camera.value.previewSize?.height ?? 1,
            height: camera.value.previewSize?.width ?? 1,
            child: CameraPreview(camera),
          ),
        ),
      ),
    );
  }
}
