import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart' as share;

import '../../domain/usecases/generate_pdf_usecase.dart';
import '../../domain/usecases/save_pdf_usecase.dart';
import 'pdf_preview_event.dart';
import 'pdf_preview_state.dart';

/// BLoC for the PDF preview screen.
class PdfPreviewBloc extends Bloc<PdfPreviewEvent, PdfPreviewState> {
  final GeneratePdfUseCase _generatePdf;
  final SavePdfUseCase _savePdf;

  PdfPreviewBloc({
    required GeneratePdfUseCase generatePdf,
    required SavePdfUseCase savePdf,
  })  : _generatePdf = generatePdf,
        _savePdf = savePdf,
        super(const PdfPreviewState()) {
    on<PdfPreviewGenerate>(_onGenerate);
    on<PdfPreviewToggleReorder>(_onToggleReorder);
    on<PdfPreviewReorder>(_onReorder);
    on<PdfPreviewApplyOrder>(_onApplyOrder);
    on<PdfPreviewToggleSelection>(_onToggleSelection);
    on<PdfPreviewSelectAll>(_onSelectAll);
    on<PdfPreviewDeleteSelected>(_onDeleteSelected);
    on<PdfPreviewAddPages>(_onAddPages);
    on<PdfPreviewSavePdf>(_onSavePdf);
    on<PdfPreviewSaveImages>(_onSaveImages);
    on<PdfPreviewShare>(_onShare);
  }

  Future<void> _onGenerate(
    PdfPreviewGenerate event,
    Emitter<PdfPreviewState> emit,
  ) async {
    emit(state.copyWith(
      status: PdfPreviewStatus.generating,
      images: event.images,
      title: event.title,
    ));

    try {
      final pdfFile = await _generatePdf(
        imageFiles: event.images,
        title: event.title,
      );
      emit(state.copyWith(
        status: PdfPreviewStatus.ready,
        pdfFile: pdfFile,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PdfPreviewStatus.error,
        errorMessage: 'Failed to generate PDF: $e',
      ));
    }
  }

  void _onToggleReorder(
    PdfPreviewToggleReorder event,
    Emitter<PdfPreviewState> emit,
  ) {
    emit(state.copyWith(
      isReorderMode: !state.isReorderMode,
      selectedIndices: const {},
    ));
  }

  void _onReorder(
    PdfPreviewReorder event,
    Emitter<PdfPreviewState> emit,
  ) {
    final images = List<File>.of(state.images);
    var newIndex = event.newIndex;
    if (newIndex > event.oldIndex) newIndex--;
    final item = images.removeAt(event.oldIndex);
    images.insert(newIndex, item);
    emit(state.copyWith(images: images, selectedIndices: const {}));
  }

  void _onApplyOrder(
    PdfPreviewApplyOrder event,
    Emitter<PdfPreviewState> emit,
  ) {
    emit(state.copyWith(images: event.reorderedImages, selectedIndices: const {}));
  }

  void _onToggleSelection(
    PdfPreviewToggleSelection event,
    Emitter<PdfPreviewState> emit,
  ) {
    final selected = Set<int>.of(state.selectedIndices);
    if (selected.contains(event.index)) {
      selected.remove(event.index);
    } else {
      selected.add(event.index);
    }
    emit(state.copyWith(selectedIndices: selected));
  }

  void _onSelectAll(
    PdfPreviewSelectAll event,
    Emitter<PdfPreviewState> emit,
  ) {
    if (state.allSelected) {
      emit(state.copyWith(selectedIndices: const {}));
    } else {
      emit(state.copyWith(
        selectedIndices: Set.from(List.generate(state.images.length, (i) => i)),
      ));
    }
  }

  void _onDeleteSelected(
    PdfPreviewDeleteSelected event,
    Emitter<PdfPreviewState> emit,
  ) {
    if (!state.hasSelection) return;
    final images = <File>[];
    for (var i = 0; i < state.images.length; i++) {
      if (!state.selectedIndices.contains(i)) {
        images.add(state.images[i]);
      }
    }
    emit(state.copyWith(images: images, selectedIndices: const {}));
  }

  void _onAddPages(
    PdfPreviewAddPages event,
    Emitter<PdfPreviewState> emit,
  ) {
    final images = List<File>.of(state.images)..addAll(event.newPages);
    emit(state.copyWith(images: images));
  }

  Future<void> _onSavePdf(
    PdfPreviewSavePdf event,
    Emitter<PdfPreviewState> emit,
  ) async {
    emit(state.copyWith(status: PdfPreviewStatus.saving));

    try {
      // Regenerate PDF with potentially reordered images.
      final pdfFile = await _generatePdf(
        imageFiles: state.images,
        title: state.title,
      );
      final saved = await _savePdf(pdfFile: pdfFile, fileName: state.title);
      emit(state.copyWith(
        status: PdfPreviewStatus.saved,
        pdfFile: pdfFile,
        savedFile: saved,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PdfPreviewStatus.ready,
        errorMessage: 'Failed to save PDF: $e',
      ));
    }
  }

  Future<void> _onSaveImages(
    PdfPreviewSaveImages event,
    Emitter<PdfPreviewState> emit,
  ) async {
    emit(state.copyWith(status: PdfPreviewStatus.saving));
    try {
      emit(state.copyWith(status: PdfPreviewStatus.saved));
    } catch (e) {
      emit(state.copyWith(
        status: PdfPreviewStatus.ready,
        errorMessage: 'Failed to save images: $e',
      ));
    }
  }

  Future<void> _onShare(
    PdfPreviewShare event,
    Emitter<PdfPreviewState> emit,
  ) async {
    if (state.pdfFile == null) return;
    await share.Share.shareXFiles(
      [share.XFile(state.pdfFile!.path)],
      subject: state.title,
    );
  }
}
