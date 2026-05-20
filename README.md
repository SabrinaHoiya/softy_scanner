# Softy Scanner

A full-featured Flutter document scanner with camera capture, gallery import, image editing, and PDF generation.

[![pub package](https://img.shields.io/pub/v/softy_scanner.svg)](https://pub.dev/packages/softy_scanner)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Screenshots

| Scanner | Review & Edit | PDF Preview |
|---------|---------------|-------------|
| ![Scanner](https://raw.githubusercontent.com/SabrinaHoiya/softy_scanner/main/screenshots/scanner.png) | ![Review](https://raw.githubusercontent.com/SabrinaHoiya/softy_scanner/main/screenshots/review-edit.png) | ![PDF Preview](https://raw.githubusercontent.com/SabrinaHoiya/softy_scanner/main/screenshots/pdf-preview.png) |

## Features

- **Single & multi-page capture** -- scan one document or batch-capture multiple pages
- **Flash control** -- toggle the device flash on/off
- **Gallery import** -- pick images from the device gallery
- **Image editing** -- crop and rotate scanned pages
- **PDF generation** -- combine scanned pages into a single PDF
- **Page management** -- reorder, select, and delete pages before saving
- **Localization** -- built-in support for English, French, and Arabic with full label customization
- **Theming** -- customize accent color, bar color, and camera resolution
- **Clean Architecture** -- domain / data / presentation layers with BLoC state management

## Getting Started

### 1. Add the dependency

```yaml
dependencies:
  softy_scanner: ^0.0.1
```

### 2. Platform setup

#### Android

Add camera and storage permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

Set the minimum SDK version in `android/app/build.gradle`:

```groovy
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

#### iOS

Add the following keys to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan documents.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to import images.</string>
```

## Usage

### Basic usage

```dart
import 'package:softy_scanner/softy_scanner.dart';

final result = await SoftyScannerScreen.launch(context);

if (!result.isCancelled) {
  print('Scanned ${result.pageCount} page(s)');
  print('PDF: ${result.pdfFile?.path}');
}
```

### With configuration

```dart
final result = await SoftyScannerScreen.launch(
  context,
  config: ScannerConfig(
    initialMode: ScanMode.multiple,
    allowModeSwitch: true,
    resolution: CameraResolution.high,
    accentColor: Colors.blue,
    barColor: Color(0xFF1A1A2E),
    locale: ScannerLocale.en,
  ),
);
```

### Localization

Built-in locale support with optional per-label overrides:

```dart
// Use French locale
ScannerConfig(locale: ScannerLocale.fr)

// Use Arabic locale with a custom scan button label
ScannerConfig(
  locale: ScannerLocale.ar,
  scanLabel: 'Custom Scan',
)
```

**Supported locales:** `ScannerLocale.en`, `ScannerLocale.fr`, `ScannerLocale.ar`

### Handling the result

`SoftyScannerScreen.launch()` returns a `ScanResult`:

```dart
final result = await SoftyScannerScreen.launch(context);

if (result.isCancelled) {
  // User cancelled the scan
  return;
}

// Access scanned pages
final List<File> pages = result.scannedPages;
final int count = result.pageCount;

// Access generated PDF (available after PDF preview)
if (result.hasPdf) {
  final File pdf = result.pdfFile!;
}

// Access user-provided title
final String? title = result.title;
```

## Configuration Reference

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `initialMode` | `ScanMode` | `.multiple` | Starting capture mode |
| `allowModeSwitch` | `bool` | `true` | Allow toggling between single/multiple mode |
| `resolution` | `CameraResolution` | `.high` | Camera resolution preset (`low`, `medium`, `high`, `veryHigh`, `max`) |
| `accentColor` | `Color` | `#31A7DF` | Accent color for buttons and active elements |
| `barColor` | `Color` | `#1A1A2E` | Background color of top and bottom bars |
| `locale` | `ScannerLocale` | `.fr` | Locale for all UI labels |

All UI labels (20+) can be individually overridden. See `ScannerConfig` for the full list.

## Architecture

The package follows **Clean Architecture** with three layers:

```
lib/src/
  domain/       -- entities, repository interfaces, use cases
  data/         -- plugin-backed implementations
  presentation/ -- BLoC state management + UI widgets
```

**Dependency rule:** domain depends on nothing; data depends on domain; presentation depends on domain and data.

## License

MIT License. See [LICENSE](LICENSE) for details.
