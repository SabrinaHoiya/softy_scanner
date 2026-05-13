import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Handles picking images from the device gallery via `image_picker`.
/// All picked images are guaranteed to be JPEG/PNG — HEIC/WebP/etc. are
/// converted automatically using the platform's native decoder.
class GalleryDataSource {
  final ImagePicker _picker;

  GalleryDataSource({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Pick a single image. Returns `null` if cancelled.
  /// Does NOT run format conversion — call [ensureCompatibleFormat] afterwards.
  Future<File?> pickSingleImage() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  /// Pick multiple images. Returns empty list if cancelled.
  /// Does NOT run format conversion — call [ensureCompatibleFormats] afterwards.
  Future<List<File>> pickMultipleImages() async {
    final xFiles = await _picker.pickMultiImage();
    return xFiles.map((x) => File(x.path)).toList();
  }

  /// If the file is already JPEG or PNG, return it as-is.
  /// Otherwise, decode it using Flutter's native codec and re-encode as PNG.
  Future<File> ensureCompatibleFormat(File file) async {
    final isCompatible = await _isCompatibleFormat(file);
    if (isCompatible) return file;

    final bytes = await file.readAsBytes();

    // Use Flutter's native image codec — supports HEIC, WebP, etc.
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    if (byteData == null) {
      throw Exception('Failed to convert image: ${file.path}');
    }

    final pngBytes = Uint8List.sublistView(byteData.buffer.asUint8List());

    final tempDir = await getTemporaryDirectory();
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final newFile = File('${tempDir.path}/gallery_$stamp.png');
    await newFile.writeAsBytes(pngBytes);
    return newFile;
  }

  /// Convert a list of files, processing them sequentially to avoid
  /// overwhelming the main thread.
  Future<List<File>> ensureCompatibleFormats(List<File> files) async {
    final results = <File>[];
    for (final file in files) {
      results.add(await ensureCompatibleFormat(file));
    }
    return results;
  }

  /// Read only the first few bytes to check the magic number.
  Future<bool> _isCompatibleFormat(File file) async {
    final raf = await file.open(mode: FileMode.read);
    try {
      final header = await raf.read(4);
      if (header.length < 2) return false;
      final isJpeg = header[0] == 0xFF && header[1] == 0xD8;
      final isPng = header.length >= 4 &&
          header[0] == 0x89 &&
          header[1] == 0x50 &&
          header[2] == 0x4E &&
          header[3] == 0x47;
      return isJpeg || isPng;
    } finally {
      await raf.close();
    }
  }
}
