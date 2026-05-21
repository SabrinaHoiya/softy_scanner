## 0.0.2

* Removed title dialog step — documents now proceed directly to PDF preview with an auto-generated title
* Removed `title` field from `ScanResult`
* Removed `titleLabel` and `confirmLabel` from `ScannerConfig` and `ScannerLocale`
* Simplified review flow (confirm → process rotations → PDF preview in one step)

## 0.0.1

* Initial release
* Single-page and multi-page document capture
* Flash toggle support
* Gallery import via image picker
* Image cropping and rotation
* PDF generation from scanned pages
* Page reordering with drag-and-drop
* Batch select and delete pages
* Built-in localization (English, French, Arabic)
* Full UI customization (colors, labels, resolution)
* Clean Architecture with BLoC state management
