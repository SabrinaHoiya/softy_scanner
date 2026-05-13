/// Defines whether the scanner captures a single page or multiple pages.
enum ScanMode {
  /// Capture a single document page — the scanner closes after one capture.
  unique,

  /// Capture multiple document pages before finishing.
  multiple,
}
