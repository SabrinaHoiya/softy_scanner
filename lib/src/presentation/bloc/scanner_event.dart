import 'package:equatable/equatable.dart';

import '../../domain/entities/scan_mode.dart';

/// Base class for all scanner events.
sealed class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize the camera.
class ScannerInitialized extends ScannerEvent {
  const ScannerInitialized();
}

/// User tapped the capture button.
class ScannerCapturePressed extends ScannerEvent {
  const ScannerCapturePressed();
}

/// User toggled flash on/off.
class ScannerFlashToggled extends ScannerEvent {
  const ScannerFlashToggled();
}

/// User switched between unique / multiple mode.
class ScannerModeChanged extends ScannerEvent {
  final ScanMode mode;

  const ScannerModeChanged(this.mode);

  @override
  List<Object?> get props => [mode];
}

/// User tapped the gallery button.
class ScannerGalleryPressed extends ScannerEvent {
  const ScannerGalleryPressed();
}

/// User removed a captured page by index.
class ScannerPageRemoved extends ScannerEvent {
  final int index;

  const ScannerPageRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

/// Clear all captured pages (e.g. after all images were deleted in review/PDF).
class ScannerPagesCleared extends ScannerEvent {
  const ScannerPagesCleared();
}

/// Dispose camera resources (called when the screen is disposed).
class ScannerDisposed extends ScannerEvent {
  const ScannerDisposed();
}
