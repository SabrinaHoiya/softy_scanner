import 'package:flutter/material.dart';

import '../../domain/entities/scanner_config.dart';

/// Top bar for the review screen with back arrow.
class ReviewTopBar extends StatelessWidget {
  final ScannerConfig config;
  final VoidCallback onBack;

  const ReviewTopBar({
    super.key,
    required this.config,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: config.barColor,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 8,
        right: 16,
      ),
      height: MediaQuery.of(context).padding.top + 56,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBack,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
