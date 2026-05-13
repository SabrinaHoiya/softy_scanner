import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/scanner_config.dart';

/// Shows a small thumbnail of the last captured page with a count badge
/// and a "Continue >" label. Visible only in multiple mode when pages exist.
/// Animates with a bounce when new pages are added.
class ThumbnailPreview extends StatefulWidget {
  final List<File> pages;
  final ScannerConfig config;
  final VoidCallback onContinue;

  const ThumbnailPreview({
    super.key,
    required this.pages,
    required this.config,
    required this.onContinue,
  });

  @override
  State<ThumbnailPreview> createState() => _ThumbnailPreviewState();
}

class _ThumbnailPreviewState extends State<ThumbnailPreview>
    with TickerProviderStateMixin {
  late AnimationController _thumbnailController;
  late AnimationController _badgeController;
  late Animation<double> _thumbnailScale;
  late Animation<double> _badgeScale;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _previousCount = widget.pages.length;

    _thumbnailController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _thumbnailScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _thumbnailController,
      curve: Curves.easeOut,
    ));

    _badgeScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 0.85), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(
      parent: _badgeController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(covariant ThumbnailPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pages.length > _previousCount) {
      _thumbnailController.forward(from: 0);
      _badgeController.forward(from: 0);
    }
    _previousCount = widget.pages.length;
  }

  @override
  void dispose() {
    _thumbnailController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pages.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: widget.onContinue,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _thumbnailController,
            builder: (context, child) => Transform.scale(
              scale: _thumbnailScale.value,
              child: child,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    widget.pages.last,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: AnimatedBuilder(
                    animation: _badgeController,
                    builder: (context, child) => Transform.scale(
                      scale: _badgeScale.value,
                      child: child,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: widget.config.accentColor,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        '${widget.pages.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  widget.config.continueLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white, size: 14),
            ],
          ),
        ],
      ),
    );
  }
}
