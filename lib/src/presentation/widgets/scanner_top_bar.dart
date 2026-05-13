import 'package:flutter/material.dart';

import '../../domain/entities/scanner_config.dart';

/// Dark top bar with Cancel button and flash toggle.
class ScannerTopBar extends StatelessWidget {
  final ScannerConfig config;
  final bool isFlashOn;
  final VoidCallback onCancel;
  final VoidCallback onToggleFlash;

  const ScannerTopBar({
    super.key,
    required this.config,
    required this.isFlashOn,
    required this.onCancel,
    required this.onToggleFlash,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: config.barColor,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
      ),
      height: MediaQuery.of(context).padding.top + 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onCancel,
            child: Text(
              config.cancelLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: onToggleFlash,
            child: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}
