import 'package:flutter/material.dart';

/// Shows "< 1 of 3 >" navigation arrows with the current page position.
class PageIndicator extends StatelessWidget {
  /// Zero-based index of the current page.
  final int currentIndex;

  /// Total number of pages (e.g. 3 for pages 1–3).
  final int totalPages;

  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const PageIndicator({
    super.key,
    required this.currentIndex,
    required this.totalPages,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex < totalPages - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ArrowButton(
            icon: Icons.arrow_back_ios_new,
            enabled: hasPrev,
            onTap: hasPrev ? onPrevious : null,
          ),
          const SizedBox(width: 16),
          Text(
            '${currentIndex + 1} of $totalPages',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(width: 16),
          _ArrowButton(
            icon: Icons.arrow_forward_ios,
            enabled: hasNext,
            onTap: hasNext ? onNext : null,
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _ArrowButton({
    required this.icon,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: enabled ? 0.15 : 0.06),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? Colors.white : Colors.white24,
        ),
      ),
    );
  }
}
