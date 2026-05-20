import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/entities/scanner_config.dart';

/// Bottom toolbar for the review screen:
/// Add | Rotation | Crop | Delete | [Effectuer]
class ReviewToolbar extends StatelessWidget {
  final ScannerConfig config;
  final bool actionsEnabled;
  final VoidCallback onAdd;
  final VoidCallback onRotate;
  final VoidCallback onCrop;
  final VoidCallback onDelete;
  final VoidCallback onConfirm;

  const ReviewToolbar({
    super.key,
    required this.config,
    required this.actionsEnabled,
    required this.onAdd,
    required this.onRotate,
    required this.onCrop,
    required this.onDelete,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: config.barColor,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 12,
        top: 12,
        left: 12,
        right: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ToolbarAction(
            iconWidget: SvgPicture.asset(
              'packages/softy_scanner/lib/src/assets/icons/ic_add.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            label: config.addLabel,
            onTap: onAdd,
            enabled: true,
          ),
          _ToolbarAction(
            icon: Icons.rotate_right,
            label: config.rotationLabel,
            onTap: onRotate,
            enabled: actionsEnabled,
          ),
          _ToolbarAction(
            icon: Icons.crop,
            label: config.cropLabel,
            onTap: onCrop,
            enabled: actionsEnabled,
          ),
          _ToolbarAction(
            iconWidget: SvgPicture.asset(
              'packages/softy_scanner/lib/src/assets/icons/ic_delete.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            label: config.deleteLabel,
            onTap: onDelete,
            enabled: actionsEnabled,
          ),
          // Effectuer button — highlighted
          GestureDetector(
            onTap: onConfirm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: config.accentColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                config.effectuerLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const _ToolbarAction({
    this.icon,
    this.iconWidget,
    required this.label,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? Colors.white : Colors.white38;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconWidget != null)
            ColorFiltered(
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              child: iconWidget!,
            )
          else
            Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
