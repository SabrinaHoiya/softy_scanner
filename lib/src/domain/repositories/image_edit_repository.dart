import 'dart:io';
import 'dart:typed_data';

/// Abstract contract for image editing operations (rotation, crop).
abstract class ImageEditRepository {
  /// Rotate the image by [quarterTurns] × 90° clockwise and return the new file.
  Future<File> rotate(File file, {int quarterTurns = 1});

  /// Crop the image with the given [croppedBytes] and write it back.
  Future<File> applyCrop(File file, Uint8List croppedBytes);
}
