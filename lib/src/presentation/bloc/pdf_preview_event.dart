import 'dart:io';

import 'package:equatable/equatable.dart';

/// Base class for PDF preview events.
sealed class PdfPreviewEvent extends Equatable {
  const PdfPreviewEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize with images and title.
class PdfPreviewGenerate extends PdfPreviewEvent {
  final List<File> images;
  final String title;

  const PdfPreviewGenerate({required this.images, required this.title});

  @override
  List<Object?> get props => [images, title];
}

/// Toggle between normal and reorder mode.
class PdfPreviewToggleReorder extends PdfPreviewEvent {
  const PdfPreviewToggleReorder();
}

/// Reorder a page from [oldIndex] to [newIndex].
class PdfPreviewReorder extends PdfPreviewEvent {
  final int oldIndex;
  final int newIndex;

  const PdfPreviewReorder({required this.oldIndex, required this.newIndex});

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

/// Apply a complete reorder given the final image list.
class PdfPreviewApplyOrder extends PdfPreviewEvent {
  final List<File> reorderedImages;

  const PdfPreviewApplyOrder(this.reorderedImages);

  @override
  List<Object?> get props => [reorderedImages];
}

/// Toggle selection of a page at [index].
class PdfPreviewToggleSelection extends PdfPreviewEvent {
  final int index;

  const PdfPreviewToggleSelection(this.index);

  @override
  List<Object?> get props => [index];
}

/// Select all pages.
class PdfPreviewSelectAll extends PdfPreviewEvent {
  const PdfPreviewSelectAll();
}

/// Delete all selected pages.
class PdfPreviewDeleteSelected extends PdfPreviewEvent {
  const PdfPreviewDeleteSelected();
}

/// Add more pages from scanner.
class PdfPreviewAddPages extends PdfPreviewEvent {
  final List<File> newPages;

  const PdfPreviewAddPages(this.newPages);

  @override
  List<Object?> get props => [newPages];
}

/// Save as PDF.
class PdfPreviewSavePdf extends PdfPreviewEvent {
  const PdfPreviewSavePdf();
}

/// Save original images.
class PdfPreviewSaveImages extends PdfPreviewEvent {
  const PdfPreviewSaveImages();
}

/// Share the PDF file.
class PdfPreviewShare extends PdfPreviewEvent {
  const PdfPreviewShare();
}
