# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`softy_scanner` is a Flutter/Dart package (SDK ^3.9.0, Flutter >=1.17.0) that provides a full-screen document scanner UI. It supports single-page and multi-page capture modes, flash control, gallery import, and returns captured images as a `ScanResult`. State management uses BLoC (`flutter_bloc`).

## Common Commands

- **Get dependencies:** `flutter pub get`
- **Run all tests:** `flutter test`
- **Run a single test file:** `flutter test test/scanner_bloc_test.dart`
- **Analyze code:** `flutter analyze` (uses `flutter_lints` rules)

## Architecture — Clean Architecture (data / domain / presentation)

```
lib/
  softy_scanner.dart                       ← barrel export (public API)
  src/
    domain/                                ← DOMAIN LAYER (no dependencies on Flutter/plugins)
      entities/
        scan_mode.dart                     ← ScanMode enum (unique / multiple)
        scan_result.dart                   ← ScanResult returned to the host app
        scanner_config.dart                ← ScannerConfig (colors, labels, resolution)
      repositories/
        camera_repository.dart             ← abstract CameraRepository
        gallery_repository.dart            ← abstract GalleryRepository
      usecases/
        initialize_camera_usecase.dart
        capture_photo_usecase.dart
        toggle_flash_usecase.dart
        pick_from_gallery_usecase.dart
        dispose_camera_usecase.dart

    data/                                  ← DATA LAYER (plugin implementations)
      datasources/
        camera_data_source.dart            ← wraps `camera` plugin
        gallery_data_source.dart           ← wraps `image_picker` plugin
      repositories/
        camera_repository_impl.dart        ← implements CameraRepository
        gallery_repository_impl.dart       ← implements GalleryRepository

    presentation/                          ← PRESENTATION LAYER (BLoC + UI)
      bloc/
        scanner_event.dart                 ← sealed ScannerEvent classes
        scanner_state.dart                 ← ScannerState with ScannerStatus enum
        scanner_bloc.dart                  ← ScannerBloc orchestrates use cases
      screens/
        scanner_screen.dart                ← SoftyScannerScreen (assembles DI + BlocProvider)
      widgets/
        scanner_top_bar.dart               ← Cancel + flash toggle
        scanner_bottom_bar.dart            ← Composes mode toggle, capture, gallery, thumbnail
        scan_mode_toggle.dart              ← Unique / Multiple pill toggle
        capture_button.dart                ← Shutter button
        thumbnail_preview.dart             ← Last-page thumbnail + count badge + Continue
```

**Key data flow:** Host app calls `SoftyScannerScreen.launch()` → screen assembles data sources, repos, use cases, and provides `ScannerBloc` → BLoC processes events via use cases → UI rebuilds from `ScannerState` → screen pops with `ScanResult`.

**Dependency rule:** domain depends on nothing; data depends on domain; presentation depends on domain and data (for DI assembly only).

## Dependencies

- `camera` — live camera preview and capture
- `image_picker` — gallery import
- `flutter_bloc` — state management
- `equatable` — value equality for BLoC state/events
- `bloc_test` (dev) — BLoC testing utilities
