import 'package:flutter/material.dart';

import '../../domain/entities/scan_mode.dart';
import '../../domain/entities/scanner_config.dart';

/// A pill-shaped toggle that switches between Unique and Multiple modes.
class ScanModeToggle extends StatelessWidget {
  final ScanMode currentMode;
  final ScannerConfig config;
  final ValueChanged<ScanMode> onModeChanged;

  const ScanModeToggle({
    super.key,
    required this.currentMode,
    required this.config,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(ScanMode.unique, config.uniqueLabel),
          _buildOption(ScanMode.multiple, config.multipleLabel),
        ],
      ),
    );
  }

  Widget _buildOption(ScanMode mode, String label) {
    final isSelected = currentMode == mode;
    return GestureDetector(
      onTap: () => onModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
