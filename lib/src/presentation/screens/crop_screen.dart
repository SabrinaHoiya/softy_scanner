import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/scanner_config.dart';

/// Full-screen crop editor. Returns the cropped image bytes or `null` if cancelled.
class CropScreen extends StatefulWidget {
  final File imageFile;
  final ScannerConfig config;

  const CropScreen({
    super.key,
    required this.imageFile,
    required this.config,
  });

  /// Push the crop screen and return cropped bytes, or `null` if cancelled.
  static Future<Uint8List?> launch(
    BuildContext context, {
    required File imageFile,
    required ScannerConfig config,
  }) {
    return Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        builder: (_) => CropScreen(imageFile: imageFile, config: config),
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

  Future<void> _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    if (mounted) setState(() => _imageBytes = bytes);
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
                // Cancel
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                // Title
                Text(
                  config.cropLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Confirm
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
                  onPressed: _isCropping ? null : _onCrop,
                ),
              ],
            ),
          ),

          // ── Crop area ──────────────────────────────────────────────────
          Expanded(
            child: _imageBytes == null
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Crop(
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
                  ),
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
                      final isSelected = _selectedRatioIndex == i && !_isCircle;
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
                              color: isSelected ? Colors.white : Colors.white70,
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
                    // Circle toggle
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
                                color:
                                    _isCircle ? Colors.white : Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Reset
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
                            Icon(Icons.refresh, color: Colors.white70, size: 16),
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
