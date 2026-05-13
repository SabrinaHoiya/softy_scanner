import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softy_scanner/softy_scanner.dart';

// ── Fake repositories ─────────────────────────────────────────────────────────

class FakeCameraRepository implements CameraRepository {
  bool initCalled = false;
  bool disposeCalled = false;
  int captureCount = 0;
  bool flashState = false;

  @override
  Future<CameraController> initialize({
    required ResolutionPreset resolution,
  }) async {
    initCalled = true;
    // We can't construct a real CameraController without a device,
    // so this test only validates the BLoC logic around errors.
    throw CameraException('test', 'No camera in test environment');
  }

  @override
  Future<File> takePicture(CameraController controller) async {
    captureCount++;
    return File('/tmp/fake_$captureCount.jpg');
  }

  @override
  Future<bool> toggleFlash(
    CameraController controller, {
    required bool currentlyOn,
  }) async {
    flashState = !currentlyOn;
    return flashState;
  }

  @override
  Future<void> dispose(CameraController controller) async {
    disposeCalled = true;
  }
}

class FakeGalleryRepository implements GalleryRepository {
  @override
  Future<File?> pickSingleImage() async => File('/tmp/gallery_single.jpg');

  @override
  Future<List<File>> pickMultipleImages() async => [
        File('/tmp/gallery_1.jpg'),
        File('/tmp/gallery_2.jpg'),
      ];

  @override
  Future<File> ensureCompatibleFormat(File file) async => file;

  @override
  Future<List<File>> ensureCompatibleFormats(List<File> files) async => files;
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late FakeCameraRepository fakeCameraRepo;
  late FakeGalleryRepository fakeGalleryRepo;

  ScannerBloc createBloc({ScannerConfig? config}) {
    config ??= ScannerConfig();
    return ScannerBloc(
      initializeCamera: InitializeCameraUseCase(fakeCameraRepo),
      capturePhoto: CapturePhotoUseCase(fakeCameraRepo),
      toggleFlash: ToggleFlashUseCase(fakeCameraRepo),
      pickFromGallery: PickFromGalleryUseCase(fakeGalleryRepo),
      disposeCamera: DisposeCameraUseCase(fakeCameraRepo),
      config: config,
    );
  }

  setUp(() {
    fakeCameraRepo = FakeCameraRepository();
    fakeGalleryRepo = FakeGalleryRepository();
  });

  group('ScannerBloc', () {
    test('initial state has correct defaults', () {
      final bloc = createBloc();
      expect(bloc.state.status, ScannerStatus.initial);
      expect(bloc.state.isFlashOn, isFalse);
      expect(bloc.state.scanMode, ScanMode.multiple);
      expect(bloc.state.capturedPages, isEmpty);
      bloc.close();
    });

    test('initial state respects config.initialMode', () {
      final bloc = createBloc(
        config: ScannerConfig(initialMode: ScanMode.multiple),
      );
      expect(bloc.state.scanMode, ScanMode.multiple);
      bloc.close();
    });

    blocTest<ScannerBloc, ScannerState>(
      'ScannerInitialized emits error when camera fails',
      build: createBloc,
      act: (bloc) => bloc.add(const ScannerInitialized()),
      expect: () => [
        isA<ScannerState>()
            .having((s) => s.status, 'status', ScannerStatus.error)
            .having(
                (s) => s.errorMessage, 'errorMessage', contains('Failed')),
      ],
    );

    blocTest<ScannerBloc, ScannerState>(
      'ScannerModeChanged updates scanMode',
      build: createBloc,
      act: (bloc) => bloc.add(const ScannerModeChanged(ScanMode.multiple)),
      expect: () => [
        isA<ScannerState>()
            .having((s) => s.scanMode, 'scanMode', ScanMode.multiple),
      ],
    );

    blocTest<ScannerBloc, ScannerState>(
      'ScannerPageRemoved removes page at index',
      build: createBloc,
      seed: () => ScannerState(
        status: ScannerStatus.cameraReady,
        capturedPages: [File('/a.jpg'), File('/b.jpg'), File('/c.jpg')],
      ),
      act: (bloc) => bloc.add(const ScannerPageRemoved(1)),
      expect: () => [
        isA<ScannerState>().having(
          (s) => s.capturedPages.length,
          'pageCount',
          2,
        ),
      ],
    );
  });
}
