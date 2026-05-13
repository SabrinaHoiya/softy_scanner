import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/image_edit_data_source.dart';
import '../../data/repositories/image_edit_repository_impl.dart';
import '../../domain/entities/scan_mode.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/entities/scanner_config.dart';
import '../../domain/usecases/crop_image_usecase.dart';
import '../../domain/usecases/rotate_image_usecase.dart';
import '../bloc/review_bloc.dart';
import '../bloc/review_event.dart';
import '../bloc/review_state.dart';
import '../widgets/add_pages_card.dart';
import '../widgets/page_indicator.dart';
import '../widgets/review_toolbar.dart';
import '../widgets/review_top_bar.dart';
import '../widgets/title_dialog.dart';
import 'crop_screen.dart';
import 'pdf_preview_screen.dart';
import 'scanner_screen.dart';

/// Review screen shown after capturing pages.
class ReviewScreen extends StatelessWidget {
  final List<File> initialPages;
  final ScannerConfig config;

  const ReviewScreen({
    super.key,
    required this.initialPages,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final dataSource = ImageEditDataSource();
    final repo = ImageEditRepositoryImpl(dataSource);

    return BlocProvider(
      create: (_) => ReviewBloc(
        rotateImage: RotateImageUseCase(repo),
        cropImage: CropImageUseCase(repo),
      )..add(ReviewInitialized(initialPages)),
      child: _ReviewView(config: config),
    );
  }
}

class _ReviewView extends StatefulWidget {
  final ScannerConfig config;

  const _ReviewView({required this.config});

  @override
  State<_ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends State<_ReviewView> {
  late PageController _pageController;
  int _lastKnownIndex = 0;

  ScannerConfig get config => widget.config;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _defaultTitle() {
    final now = DateTime.now();
    final formatted = '${now.day.toString().padLeft(2, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.year}';
    return '${config.defaultTitlePrefix} $formatted';
  }

  /// Sync the PageController when the BLoC index changes externally
  /// (e.g. after delete, add pages, rotation).
  void _syncPageController(ReviewState state) {
    final target = state.displayIndex;
    if (target != _lastKnownIndex && _pageController.hasClients) {
      _pageController.jumpToPage(target);
    }
    _lastKnownIndex = target;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewBloc, ReviewState>(
      listenWhen: (prev, curr) =>
          curr.status == ReviewStatus.confirmed ||
          prev.currentIndex != curr.currentIndex ||
          prev.imageVersion != curr.imageVersion ||
          prev.pages.length != curr.pages.length,
      listener: (context, state) {
        if (state.status == ReviewStatus.confirmed) {
          _navigateToPdfPreview(context, state);
          return;
        }
        // All pages deleted — go back to the scanner.
        if (!state.hasPages && state.status == ReviewStatus.ready) {
          Navigator.of(context).pop();
          return;
        }
        _syncPageController(state);
      },
      builder: (context, state) {
        if (state.status == ReviewStatus.initial) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
                child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        return Scaffold(
          backgroundColor: config.barColor,
          body: Column(
            children: [
              // Top bar
              ReviewTopBar(
                config: config,
                title: _defaultTitle(),
                onBack: () => Navigator.of(context).pop(),
              ),

              // Page viewer with swipe
              Expanded(child: _buildPageView(context, state)),

              // Page indicator
              PageIndicator(
                currentIndex:
                    state.displayIndex.clamp(0, state.pageCount - 1),
                totalPages: state.pageCount,
                onPrevious: state.displayIndex > 0
                    ? () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
                onNext: state.displayIndex < state.pageCount
                    ? () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
              ),

              // Bottom toolbar
              ReviewToolbar(
                config: config,
                actionsEnabled:
                    !state.isOnAddCard && state.hasPages && !state.isProcessing,
                onAdd: () => _addMorePages(context),
                onRotate: () => context
                    .read<ReviewBloc>()
                    .add(const ReviewPageRotated()),
                onCrop: () => _openCropScreen(context, state),
                onDelete: () => context
                    .read<ReviewBloc>()
                    .add(const ReviewPageDeleted()),
                onConfirm: () => _showTitleDialog(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageView(BuildContext context, ReviewState state) {
    // Total items = captured pages + 1 "add more" card at the end.
    final itemCount = state.pageCount + 1;

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: itemCount,
          onPageChanged: (index) {
            _lastKnownIndex = index;
            context.read<ReviewBloc>().add(ReviewPageChanged(index));
          },
          physics: state.isProcessing
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            // Last item is always the "add more pages" card.
            if (index >= state.pageCount) {
              return AddPagesCard(
                config: config,
                onTap: () => _addMorePages(context),
              );
            }

            final quarters = index < state.rotations.length
                ? state.rotations[index]
                : 0;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: RotatedBox(
                quarterTurns: quarters,
                child: Image.file(
                  state.pages[index],
                  key: ValueKey(
                      '${state.pages[index].path}-${state.imageVersion}'),
                  fit: BoxFit.contain,
                  cacheWidth: null,
                ),
              ),
            );
          },
        ),

        // Processing overlay
        if (state.isProcessing)
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
      ],
    );
  }

  Future<void> _addMorePages(BuildContext context) async {
    // Always open scanner in unique mode — capture one page at a time,
    // it gets added to the existing list.
    final addConfig = ScannerConfig(
      initialMode: ScanMode.unique,
      allowModeSwitch: false,
      resolution: config.resolution,
      accentColor: config.accentColor,
      barColor: config.barColor,
      scanLabel: config.scanLabel,
      cancelLabel: config.cancelLabel,
      galleryLabel: config.galleryLabel,
    );
    final result = await SoftyScannerScreen.launch(
      context,
      config: addConfig,
      quickCapture: true,
    );
    if (!result.isCancelled && result.hasPages && context.mounted) {
      context.read<ReviewBloc>().add(ReviewPagesAdded(result.scannedPages));
    }
  }

  Future<void> _openCropScreen(BuildContext context, ReviewState state) async {
    if (state.isOnAddCard || !state.hasPages) return;

    final quarterTurns = state.currentIndex < state.rotations.length
        ? state.rotations[state.currentIndex]
        : 0;
    final croppedBytes = await CropScreen.launch(
      context,
      imageFile: state.pages[state.currentIndex],
      config: config,
      quarterTurns: quarterTurns,
    );

    if (croppedBytes != null && context.mounted) {
      context.read<ReviewBloc>().add(ReviewPageCropped(croppedBytes));
    }
  }

  Future<void> _showTitleDialog(BuildContext context) async {
    final title = await TitleDialog.show(
      context,
      config: config,
      initialTitle: _defaultTitle(),
    );
    if (title != null && context.mounted) {
      context.read<ReviewBloc>().add(ReviewTitleConfirmed(title));
    }
  }

  Future<void> _navigateToPdfPreview(
    BuildContext context,
    ReviewState state,
  ) async {
    final result = await Navigator.of(context).push<ScanResult>(
      MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(
          images: state.pages,
          title: state.title ?? _defaultTitle(),
          config: config,
        ),
      ),
    );

    if (result != null && result.hasPdf && context.mounted) {
      // Final result with PDF — pop back to the host app.
      Navigator.of(context).pop(result);
    } else if (result != null && result.hasPages && context.mounted) {
      // "Modifier" was tapped — re-initialize review with updated images.
      context
          .read<ReviewBloc>()
          .add(ReviewInitialized(result.scannedPages));
    } else if (context.mounted) {
      // PDF preview was dismissed (e.g. all images deleted) — go back
      // to the scanner screen.
      Navigator.of(context).pop();
    }
  }
}
