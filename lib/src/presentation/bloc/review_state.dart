import 'dart:io';

import 'package:equatable/equatable.dart';

/// Status of the review screen.
enum ReviewStatus {
  initial,
  ready,
  processing,
  titleDialog,
  confirmed,
}

/// Immutable state for the review BLoC.
class ReviewState extends Equatable {
  final ReviewStatus status;
  final List<File> pages;
  final int currentIndex;
  final String? title;

  /// Incremented after rotation/crop to force Image.file cache invalidation.
  final int imageVersion;

  /// Rotation per page in quarter-turns clockwise (0–3).
  final List<int> rotations;

  const ReviewState({
    this.status = ReviewStatus.initial,
    this.pages = const [],
    this.currentIndex = 0,
    this.title,
    this.imageVersion = 0,
    this.rotations = const [],
  });

  int get pageCount => pages.length;
  bool get hasPages => pages.isNotEmpty;
  bool get isProcessing => status == ReviewStatus.processing;

  /// Whether the viewer is showing the "add more pages" card
  /// (index is one past the last page).
  bool get isOnAddCard => currentIndex >= pages.length;

  /// The display index clamped to valid page range.
  int get displayIndex => currentIndex.clamp(0, pages.length);

  /// Total items in the viewer (pages + 1 add-card).
  int get totalItems => pages.length + 1;

  ReviewState copyWith({
    ReviewStatus? status,
    List<File>? pages,
    int? currentIndex,
    String? title,
    int? imageVersion,
    List<int>? rotations,
  }) {
    return ReviewState(
      status: status ?? this.status,
      pages: pages ?? this.pages,
      currentIndex: currentIndex ?? this.currentIndex,
      title: title ?? this.title,
      imageVersion: imageVersion ?? this.imageVersion,
      rotations: rotations ?? this.rotations,
    );
  }

  @override
  List<Object?> get props =>
      [status, pages, currentIndex, title, imageVersion, rotations];
}
