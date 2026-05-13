import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Handles image manipulation (rotation, crop) using the `image` package.
/// Heavy operations run on a background isolate via [compute].
class ImageEditDataSource {
  /// Rotate [file] by [quarterTurns] × 90° clockwise.
  /// Writes to a **new** file path to bypass Flutter's image cache.
  Future<File> rotate(File file, {int quarterTurns = 1}) async {
    final quarters = quarterTurns % 4;
    if (quarters == 0) return file;

    final bytes = await file.readAsBytes();
    final encoded = await compute(
      _rotateIsolate,
      _RotateParams(bytes, quarters * 90),
    );

    final newPath = _timestampedPath(file.path);
    final newFile = File(newPath);
    await newFile.writeAsBytes(encoded);

    if (await file.exists()) {
      await file.delete();
    }

    return newFile;
  }

  /// Write [croppedBytes] to a **new** file to bypass cache.
  Future<File> applyCrop(File file, Uint8List croppedBytes) async {
    final newPath = _timestampedPath(file.path);
    final newFile = File(newPath);
    await newFile.writeAsBytes(croppedBytes);

    if (await file.exists()) {
      await file.delete();
    }

    return newFile;
  }

  String _timestampedPath(String originalPath) {
    final dot = originalPath.lastIndexOf('.');
    final stamp = DateTime.now().microsecondsSinceEpoch;
    if (dot == -1) return '${originalPath}_$stamp';
    return '${originalPath.substring(0, dot)}_$stamp${originalPath.substring(dot)}';
  }
}

class _RotateParams {
  final Uint8List bytes;
  final int angle;
  const _RotateParams(this.bytes, this.angle);
}

/// Top-level function for [compute] — runs on a separate isolate.
Uint8List _rotateIsolate(_RotateParams params) {
  final decoded = img.decodeImage(params.bytes);
  if (decoded == null) throw Exception('Failed to decode image');
  final rotated = img.copyRotate(decoded, angle: params.angle);
  return Uint8List.fromList(img.encodeJpg(rotated, quality: 95));
}
