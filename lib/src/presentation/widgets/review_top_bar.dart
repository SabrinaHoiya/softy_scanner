import 'package:flutter/material.dart';

import '../../domain/entities/scanner_config.dart';

/// Top bar for the review screen with back arrow and scan title.
class ReviewTopBar extends StatelessWidget {
  final ScannerConfig config;
  final String title;
  final VoidCallback onBack;

  const ReviewTopBar({
    super.key,
    required this.config,
    required this.title,
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
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Spacer to balance the back button width.
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
