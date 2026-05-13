import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Base class for all review screen events.
sealed class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize the review screen with captured pages.
class ReviewInitialized extends ReviewEvent {
  final List<File> pages;

  const ReviewInitialized(this.pages);

  @override
  List<Object?> get props => [pages];
}

/// Navigate to a specific page index.
class ReviewPageChanged extends ReviewEvent {
  final int index;

  const ReviewPageChanged(this.index);

  @override
  List<Object?> get props => [index];
}

/// Rotate the current page 90° clockwise.
class ReviewPageRotated extends ReviewEvent {
  const ReviewPageRotated();
}

/// Apply cropped bytes to the current page.
class ReviewPageCropped extends ReviewEvent {
  final Uint8List croppedBytes;

  const ReviewPageCropped(this.croppedBytes);

  @override
  List<Object?> get props => [croppedBytes];
}

/// Delete the current page.
class ReviewPageDeleted extends ReviewEvent {
  const ReviewPageDeleted();
}

/// New pages added from the scanner (user tapped "add more pages").
class ReviewPagesAdded extends ReviewEvent {
  final List<File> newPages;

  const ReviewPagesAdded(this.newPages);

  @override
  List<Object?> get props => [newPages];
}

/// User tapped "Effectuer" — show the title dialog.
class ReviewConfirmRequested extends ReviewEvent {
  const ReviewConfirmRequested();
}

/// User confirmed the title in the dialog.
class ReviewTitleConfirmed extends ReviewEvent {
  final String title;

  const ReviewTitleConfirmed(this.title);

  @override
  List<Object?> get props => [title];
}
