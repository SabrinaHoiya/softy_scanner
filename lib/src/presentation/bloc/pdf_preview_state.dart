import 'dart:io';

import 'package:equatable/equatable.dart';

enum PdfPreviewStatus {
  initial,
  generating,
  ready,
  saving,
  saved,
  error,
}

/// Immutable state for the PDF preview BLoC.
class PdfPreviewState extends Equatable {
  final PdfPreviewStatus status;
  final List<File> images;
  final File? pdfFile;
  final File? savedFile;
  final String title;
  final String? errorMessage;
  final bool isReorderMode;
  final Set<int> selectedIndices;

  const PdfPreviewState({
    this.status = PdfPreviewStatus.initial,
    this.images = const [],
    this.pdfFile,
    this.savedFile,
    this.title = '',
    this.errorMessage,
    this.isReorderMode = false,
    this.selectedIndices = const {},
  });

  bool get isReady => status == PdfPreviewStatus.ready;
  bool get hasSelection => selectedIndices.isNotEmpty;
  bool get allSelected =>
      images.isNotEmpty && selectedIndices.length == images.length;

  PdfPreviewState copyWith({
    PdfPreviewStatus? status,
    List<File>? images,
    File? pdfFile,
    File? savedFile,
    String? title,
    String? errorMessage,
    bool? isReorderMode,
    Set<int>? selectedIndices,
  }) {
    return PdfPreviewState(
      status: status ?? this.status,
      images: images ?? this.images,
      pdfFile: pdfFile ?? this.pdfFile,
      savedFile: savedFile ?? this.savedFile,
      title: title ?? this.title,
      errorMessage: errorMessage,
      isReorderMode: isReorderMode ?? this.isReorderMode,
      selectedIndices: selectedIndices ?? this.selectedIndices,
    );
  }

  @override
  List<Object?> get props => [
        status,
        images,
        pdfFile,
        savedFile,
        title,
        errorMessage,
        isReorderMode,
        selectedIndices,
      ];
}
