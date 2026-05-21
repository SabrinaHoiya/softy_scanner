import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/crop_image_usecase.dart';
import '../../domain/usecases/rotate_image_usecase.dart';
import 'review_event.dart';
import 'review_state.dart';

/// BLoC that manages the review / edit screen after scanning.
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final RotateImageUseCase _rotateImage;
  final CropImageUseCase _cropImage;

  ReviewBloc({
    required RotateImageUseCase rotateImage,
    required CropImageUseCase cropImage,
  })  : _rotateImage = rotateImage,
        _cropImage = cropImage,
        super(const ReviewState()) {
    on<ReviewInitialized>(_onInitialized);
    on<ReviewPageChanged>(_onPageChanged);
    on<ReviewPageRotated>(_onPageRotated);
    on<ReviewPageCropped>(_onPageCropped);
    on<ReviewPageDeleted>(_onPageDeleted);
    on<ReviewPagesAdded>(_onPagesAdded);
    on<ReviewConfirmRequested>(_onConfirmRequested);
  }

  void _onInitialized(ReviewInitialized event, Emitter<ReviewState> emit) {
    emit(state.copyWith(
      status: ReviewStatus.ready,
      pages: List.of(event.pages),
      currentIndex: 0,
      rotations: List.filled(event.pages.length, 0),
    ));
  }

  void _onPageChanged(ReviewPageChanged event, Emitter<ReviewState> emit) {
    emit(state.copyWith(currentIndex: event.index));
  }

  void _onPageRotated(
    ReviewPageRotated event,
    Emitter<ReviewState> emit,
  ) {
    if (state.isOnAddCard || !state.hasPages) return;

    final index = state.currentIndex;
    final updatedRotations = List<int>.of(state.rotations);
    updatedRotations[index] = (updatedRotations[index] + 1) % 4;
    emit(state.copyWith(rotations: updatedRotations));
  }

  Future<void> _onPageCropped(
    ReviewPageCropped event,
    Emitter<ReviewState> emit,
  ) async {
    if (state.isOnAddCard || !state.hasPages) return;

    final index = state.currentIndex;
    final file = state.pages[index];

    emit(state.copyWith(status: ReviewStatus.processing));

    try {
      final cropped = await _cropImage(file, event.croppedBytes);

      imageCache.clear();
      imageCache.clearLiveImages();

      final updatedPages = List<File>.of(state.pages);
      updatedPages[index] = cropped;
      emit(state.copyWith(
        status: ReviewStatus.ready,
        pages: updatedPages,
        imageVersion: state.imageVersion + 1,
      ));
    } catch (_) {
      emit(state.copyWith(status: ReviewStatus.ready));
    }
  }

  void _onPageDeleted(ReviewPageDeleted event, Emitter<ReviewState> emit) {
    if (state.isOnAddCard || !state.hasPages) return;

    final updatedPages = List<File>.of(state.pages)
      ..removeAt(state.currentIndex);
    final updatedRotations = List<int>.of(state.rotations)
      ..removeAt(state.currentIndex);
    final newIndex = state.currentIndex >= updatedPages.length
        ? (updatedPages.isEmpty ? 0 : updatedPages.length - 1)
        : state.currentIndex;
    emit(state.copyWith(
      pages: updatedPages,
      rotations: updatedRotations,
      currentIndex: newIndex,
    ));
  }

  void _onPagesAdded(ReviewPagesAdded event, Emitter<ReviewState> emit) {
    final updatedPages = List<File>.of(state.pages)..addAll(event.newPages);
    final updatedRotations = List<int>.of(state.rotations)
      ..addAll(List.filled(event.newPages.length, 0));
    emit(state.copyWith(
      pages: updatedPages,
      rotations: updatedRotations,
      currentIndex: state.pages.length,
    ));
  }

  Future<void> _onConfirmRequested(
    ReviewConfirmRequested event,
    Emitter<ReviewState> emit,
  ) async {
    emit(state.copyWith(status: ReviewStatus.processing));

    try {
      // Apply any pending rotations to the actual files.
      final pages = List<File>.of(state.pages);
      for (var i = 0; i < pages.length; i++) {
        final quarters = state.rotations[i] % 4;
        if (quarters == 0) continue;
        final rotated =
            await _rotateImage.call(pages[i], quarterTurns: quarters);
        pages[i] = rotated;
      }

      emit(state.copyWith(
        status: ReviewStatus.confirmed,
        pages: pages,
        rotations: List.filled(pages.length, 0),
      ));
    } catch (_) {
      emit(state.copyWith(status: ReviewStatus.ready));
    }
  }
}
