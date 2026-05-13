import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/scanner_config.dart';

/// Full-screen crop editor. Returns the cropped image bytes or `null` if cancelled.
class CropScreen extends StatefulWidget {
  final File imageFile;
  final ScannerConfig config;

  /// Virtual rotation (0–3 quarter-turns clockwise) to bake into the image
  /// before cropping.
  final int quarterTurns;

  const CropScreen({
    super.key,
    required this.imageFile,
    required this.config,
    this.quarterTurns = 0,
  });

  /// Push the crop screen and return cropped bytes, or `null` if cancelled.
  static Future<Uint8List?> launch(
    BuildContext context, {
    required File imageFile,
    required ScannerConfig config,
    int quarterTurns = 0,
  }) {
    return Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        builder: (_) => CropScreen(
          imageFile: imageFile,
          config: config,
          quarterTurns: quarterTurns,
        ),
      ),
    );
  }

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  final _cropController = CropController();
  Uint8List? _imageBytes;
  bool _isCropping = false;
  bool _isCircle = false;
  bool _loadFailed = false;
  double? _aspectRatio;
  int _resetKey = 0;

  static const _aspectRatios = <_AspectOption>[
    _AspectOption('Free', null),
    _AspectOption('1:1', 1.0),
    _AspectOption('4:3', 4.0 / 3.0),
    _AspectOption('3:4', 3.0 / 4.0),
    _AspectOption('16:9', 16.0 / 9.0),
    _AspectOption('A4', 210.0 / 297.0),
  ];

  int _selectedRatioIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  /// Load, normalize to PNG, and apply pending rotation so the Crop widget
  /// always receives a clean, displayable image.
  Future<void> _loadImage() async {
    try {
      final rawBytes = await widget.imageFile.readAsBytes();

      // Decode using Flutter's native codec — handles JPEG, PNG, HEIC, WebP.
      final codec = await ui.instantiateImageCodec(rawBytes);
      final frame = await codec.getNextFrame();
      var image = frame.image;

      // Apply virtual rotation if needed.
      final quarters = widget.quarterTurns % 4;
      if (quarters != 0) {
        image = await _rotateImage(image, quarters);
      }

      // Re-encode as PNG — universally supported by the Crop widget.
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      if (byteData == null) {
        if (mounted) setState(() => _loadFailed = true);
        return;
      }

      final pngBytes = Uint8List.sublistView(byteData.buffer.asUint8List());
      if (mounted) setState(() => _imageBytes = pngBytes);
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    }
  }

  /// Rotate a [ui.Image] by [quarters] × 90° clockwise using a canvas.
  Future<ui.Image> _rotateImage(ui.Image source, int quarters) async {
    final angle = quarters * math.pi / 2;
    final isOddQuarter = quarters % 2 != 0;
    final w = isOddQuarter ? source.height : source.width;
    final h = isOddQuarter ? source.width : source.height;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.translate(w / 2, h / 2);
    canvas.rotate(angle);
    canvas.translate(-source.width / 2, -source.height / 2);
    canvas.drawImage(source, Offset.zero, Paint());

    final picture = recorder.endRecording();
    final rotated = await picture.toImage(w, h);
    source.dispose();
    return rotated;
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // ── Top bar ────────────────────────────────────────────────────
          Container(
            color: config.barColor,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 4,
              right: 4,
            ),
            height: MediaQuery.of(context).padding.top + 56,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                Text(
                  config.cropLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: _isCropping
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(Icons.check, color: config.accentColor),
                  onPressed:
                      _isCropping || _imageBytes == null ? null : _onCrop,
                ),
              ],
            ),
          ),

          // ── Crop area ──────────────────────────────────────────────────
          Expanded(
            child: _buildCropArea(config),
          ),

          // ── Bottom controls ────────────────────────────────────────────
          Container(
            color: config.barColor,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 12,
              top: 8,
              left: 8,
              right: 8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Aspect ratio chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _aspectRatios.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final option = _aspectRatios[i];
                      final isSelected =
                          _selectedRatioIndex == i && !_isCircle;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedRatioIndex = i;
                          _aspectRatio = option.ratio;
                          _isCircle = false;
                          _resetKey++;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? config.accentColor
                                : Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            option.label,
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Circle toggle + Reset
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() {
                        _isCircle = !_isCircle;
                        if (_isCircle) _aspectRatio = 1.0;
                        _resetKey++;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isCircle
                              ? config.accentColor
                              : Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle_outlined,
                              color:
                                  _isCircle ? Colors.white : Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Circle',
                              style: TextStyle(
                                color: _isCircle
                                    ? Colors.white
                                    : Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => setState(() {
                        _selectedRatioIndex = 0;
                        _aspectRatio = null;
                        _isCircle = false;
                        _resetKey++;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh,
                                color: Colors.white70, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Reset',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropArea(ScannerConfig config) {
    if (_loadFailed) {
      return const Center(
        child: Text(
          'Unable to load image',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    if (_imageBytes == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Crop(
      key: ValueKey('crop-$_resetKey-$_selectedRatioIndex-$_isCircle'),
      image: _imageBytes!,
      controller: _cropController,
      onCropped: (croppedImage) {
        Navigator.pop(context, croppedImage);
      },
      aspectRatio: _aspectRatio,
      withCircleUi: _isCircle,
      baseColor: Colors.black,
      maskColor: Colors.black.withValues(alpha: 0.6),
      cornerDotBuilder: (size, edgeAlignment) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: config.accentColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
      ),
      interactive: true,
    );
  }

  void _onCrop() {
    setState(() => _isCropping = true);
    _cropController.crop();
  }
}

class _AspectOption {
  final String label;
  final double? ratio;
  const _AspectOption(this.label, this.ratio);
}
