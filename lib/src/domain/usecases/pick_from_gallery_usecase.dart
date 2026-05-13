import 'dart:io';

import '../repositories/gallery_repository.dart';

/// Picks one or more images from the device gallery.
class PickFromGalleryUseCase {
  final GalleryRepository _repository;

  const PickFromGalleryUseCase(this._repository);

  /// Pick a single image. Returns `null` if cancelled.
  Future<File?> pickSingle() => _repository.pickSingleImage();

  /// Pick multiple images. Returns empty list if cancelled.
  Future<List<File>> pickMultiple() => _repository.pickMultipleImages();

  /// Ensure a single file is in a compatible format (JPEG/PNG).
  Future<File> ensureCompatibleFormat(File file) =>
      _repository.ensureCompatibleFormat(file);

  /// Ensure a list of files are in a compatible format (JPEG/PNG).
  Future<List<File>> ensureCompatibleFormats(List<File> files) =>
      _repository.ensureCompatibleFormats(files);
}
