import 'dart:io';

/// Abstract contract for picking images from the device gallery.
abstract class GalleryRepository {
  /// Pick a single image from the gallery.
  /// Returns `null` if the user cancelled.
  Future<File?> pickSingleImage();

  /// Pick multiple images from the gallery.
  /// Returns an empty list if the user cancelled.
  Future<List<File>> pickMultipleImages();

  /// Ensure a single file is in a compatible format (JPEG/PNG).
  Future<File> ensureCompatibleFormat(File file);

  /// Ensure a list of files are in a compatible format (JPEG/PNG).
  Future<List<File>> ensureCompatibleFormats(List<File> files);
}
