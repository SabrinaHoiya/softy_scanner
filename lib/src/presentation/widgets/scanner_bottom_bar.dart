import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/scan_mode.dart';
import '../../domain/entities/scanner_config.dart';
import 'capture_button.dart';
import 'scan_mode_toggle.dart';
import 'thumbnail_preview.dart';

/// The bottom section of the scanner: mode toggle, scan label, gallery,
/// capture button, and (in multiple mode) the thumbnail/continue area.
class ScannerBottomBar extends StatelessWidget {
  final ScannerConfig config;
  final ScanMode scanMode;
  final bool isCapturing;
  final List<File> capturedPages;
  final ValueChanged<ScanMode> onModeChanged;
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final VoidCallback onContinue;

  const ScannerBottomBar({
    super.key,
    required this.config,
    required this.scanMode,
    required this.isCapturing,
    required this.capturedPages,
    required this.onModeChanged,
    required this.onCapture,
    required this.onGallery,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: config.barColor,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 8,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mode toggle
          if (config.allowModeSwitch)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ScanModeToggle(
                currentMode: scanMode,
                config: config,
                onModeChanged: onModeChanged,
              ),
            ),

          // Scan label
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              config.scanLabel,
              style: TextStyle(
                color: config.accentColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Gallery — Capture — Thumbnail/Continue
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gallery button
              GestureDetector(
                onTap: onGallery,
                child: SizedBox(
                  width: 72,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_library_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        config.galleryLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Capture button
              CaptureButton(
                isCapturing: isCapturing,
                onPressed: onCapture,
              ),

              // Thumbnail / Continue (only in multiple mode with pages)
              SizedBox(
                width: 72,
                child:
                    scanMode == ScanMode.multiple && capturedPages.isNotEmpty
                        ? ThumbnailPreview(
                            pages: capturedPages,
                            config: config,
                            onContinue: onContinue,
                          )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
