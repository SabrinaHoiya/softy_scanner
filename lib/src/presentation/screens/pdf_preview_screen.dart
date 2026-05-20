import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/datasources/pdf_data_source.dart';
import '../../data/repositories/pdf_repository_impl.dart';
import '../../domain/entities/scan_mode.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/entities/scanner_config.dart';
import '../../domain/usecases/generate_pdf_usecase.dart';
import '../../domain/usecases/save_pdf_usecase.dart';
import '../bloc/pdf_preview_bloc.dart';
import '../bloc/pdf_preview_event.dart';
import '../bloc/pdf_preview_state.dart';
import '../widgets/title_dialog.dart';
import 'scanner_screen.dart';

/// Screen that shows a preview of scanned pages with reorder, delete,
/// and save-as-PDF / save-as-image options.
class PdfPreviewScreen extends StatelessWidget {
  final List<File> images;
  final String title;
  final ScannerConfig config;

  const PdfPreviewScreen({
    super.key,
    required this.images,
    required this.title,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final dataSource = PdfDataSource();
    final repo = PdfRepositoryImpl(dataSource);

    return BlocProvider(
      create: (_) => PdfPreviewBloc(
        generatePdf: GeneratePdfUseCase(repo),
        savePdf: SavePdfUseCase(repo),
      )..add(PdfPreviewGenerate(images: images, title: title)),
      child: _PdfPreviewView(config: config),
    );
  }
}

class _PdfPreviewView extends StatefulWidget {
  final ScannerConfig config;

  const _PdfPreviewView({required this.config});

  @override
  State<_PdfPreviewView> createState() => _PdfPreviewViewState();
}

class _PdfPreviewViewState extends State<_PdfPreviewView> {
  final _scrollController = ScrollController();

  ScannerConfig get config => widget.config;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PdfPreviewBloc, PdfPreviewState>(
      listenWhen: (prev, curr) =>
          curr.status == PdfPreviewStatus.saved ||
          (curr.errorMessage != null &&
              curr.errorMessage != prev.errorMessage) ||
          prev.images.length != curr.images.length,
      listener: (context, state) {
        if (state.status == PdfPreviewStatus.saved) {
          Navigator.of(context).pop(
            ScanResult(
              scannedPages: state.images,
              title: state.title,
              pdfFile: state.pdfFile,
            ),
          );
          return;
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
        if (state.images.isEmpty && state.status == PdfPreviewStatus.ready) {
          Navigator.of(context).pop();
          return;
        }
        // Scroll to bottom when a new page is added.
        if (!state.isReorderMode && _scrollController.hasClients) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: Column(
            children: [
              _buildTopBar(context, state),
              if (state.isReorderMode)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: config.accentColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          config.reorderInstructionLabel,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(child: _buildContent(context, state)),
              _buildBottomBar(context, state),
            ],
          ),
        );
      },
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context, PdfPreviewState state) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 4,
        right: 8,
      ),
      height: MediaQuery.of(context).padding.top + 56,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              if (state.isReorderMode) {
                context
                    .read<PdfPreviewBloc>()
                    .add(const PdfPreviewToggleReorder());
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final newTitle = await TitleDialog.show(
                  context,
                  config: config,
                  initialTitle: state.title,
                );
                if (newTitle != null && context.mounted) {
                  context
                      .read<PdfPreviewBloc>()
                      .add(PdfPreviewRenameTitle(newTitle));
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      state.title,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  SvgPicture.asset(
                    'packages/softy_scanner/lib/src/assets/icons/ic_edit.svg',
                          width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF4C5063),
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (state.isReorderMode)
            GestureDetector(
              onTap: () => context
                  .read<PdfPreviewBloc>()
                  .add(const PdfPreviewSelectAll()),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  config.selectAllLabel,
                  style: TextStyle(
                    color: config.accentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else if (state.isReady)
            GestureDetector(
              onTap: () => context
                  .read<PdfPreviewBloc>()
                  .add(const PdfPreviewToggleReorder()),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCFCFF),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: const Color(0xFFE8EAF5)),
                ),
                child: Text(
                  config.reorderPagesLabel,
                  style: const TextStyle(
                    color: Color(0xFF4C5063),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Content ────────────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context, PdfPreviewState state) {
    if (state.status == PdfPreviewStatus.generating ||
        state.status == PdfPreviewStatus.initial ||
        state.status == PdfPreviewStatus.saving) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == PdfPreviewStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.errorMessage ?? 'An error occurred',
            style: const TextStyle(color: Colors.red, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.isReorderMode) {
      return _ReorderGrid(config: config, state: state);
    }

    return _buildNormalList(context, state);
  }

  // ── Normal Mode: scrollable page list + add card ───────────────────────

  Widget _buildNormalList(BuildContext context, PdfPreviewState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.images.length + 1,
      itemBuilder: (_, index) {
        if (index >= state.images.length) {
          return _buildAddCard(context);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                state.images[index],
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _addMorePages(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFCFF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE8EAF5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'packages/softy_scanner/lib/src/assets/icons/ic_add.svg',
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(
                Color(0xFF4C5063),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              config.addPagesLabel,
              style: const TextStyle(
                color: Color(0xFF4C5063),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Bar ─────────────────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context, PdfPreviewState state) {
    final isEnabled = state.isReady && state.images.isNotEmpty;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 14,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          _ToolbarAction(
            iconWidget: SvgPicture.asset(
              'packages/softy_scanner/lib/src/assets/icons/ic_add.svg',
              width: 24,
              height: 24,
            ),
            label: config.addPagesLabel,
            onTap: () => _addMorePages(context),
          ),
          const SizedBox(width: 16),
          if (state.isReorderMode)
            _ToolbarAction(
              iconWidget: SvgPicture.asset(
                'packages/softy_scanner/lib/src/assets/icons/ic_delete.svg',
                  width: 24,
                height: 24,
              ),
              label: config.removeLabel,
              onTap: state.hasSelection
                  ? () => context
                      .read<PdfPreviewBloc>()
                      .add(const PdfPreviewDeleteSelected())
                  : null,
            )
          else
            _ToolbarAction(
              iconWidget: SvgPicture.asset(
                'packages/softy_scanner/lib/src/assets/icons/ic_edit.svg',
                  width: 24,
                height: 24,
              ),
              label: config.modifyLabel,
              onTap: () {
                Navigator.of(context).pop(
                  ScanResult(scannedPages: state.images, title: state.title),
                );
              },
            ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: isEnabled
                  ? () => context
                      .read<PdfPreviewBloc>()
                      .add(const PdfPreviewSavePdf())
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: config.accentColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    config.accentColor.withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: Text(
                config.saveAndSendLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  Future<void> _addMorePages(BuildContext context) async {
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
      context
          .read<PdfPreviewBloc>()
          .add(PdfPreviewAddPages(result.scannedPages));
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Reorder Grid — 2-column drag-and-drop grid with animated reordering
// ═══════════════════════════════════════════════════════════════════════════════

class _ReorderGrid extends StatefulWidget {
  final ScannerConfig config;
  final PdfPreviewState state;

  const _ReorderGrid({required this.config, required this.state});

  @override
  State<_ReorderGrid> createState() => _ReorderGridState();
}

class _ReorderGridState extends State<_ReorderGrid> {
  final _scrollController = ScrollController();
  final _gridKey = GlobalKey();

  /// Maps visual grid position → original image index.
  late List<int> _currentOrder;

  /// The original index of the item being dragged, or null.
  int? _dragIndex;

  Timer? _autoScrollTimer;

  static const _spacing = 16.0;
  static const _padding = 16.0;
  static const _animDuration = Duration(milliseconds: 200);
  static const _animCurve = Curves.easeInOut;
  static const _autoScrollZone = 60.0;
  static const _autoScrollSpeed = 6.0;

  double _itemWidth(BuildContext context) =>
      (MediaQuery.of(context).size.width - _padding * 2 - _spacing) / 2;

  Offset _gridPositionFor(int gridIndex, double itemW, double itemH) {
    final col = gridIndex % 2;
    final row = gridIndex ~/ 2;
    return Offset(
      _padding + col * (itemW + _spacing),
      _padding + row * (itemH + _spacing),
    );
  }

  double _gridHeight(double itemH) {
    final rows = (_currentOrder.length + 1) ~/ 2;
    return _padding * 2 + rows * itemH + (rows - 1) * _spacing;
  }

  @override
  void initState() {
    super.initState();
    _resetOrder();
  }

  @override
  void didUpdateWidget(covariant _ReorderGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset local order when BLoC images change (after commit, delete, or add).
    // Skip during active drag so tentative order is preserved.
    if (_dragIndex == null &&
        !_sameImageList(widget.state.images, oldWidget.state.images)) {
      _resetOrder();
    }
  }

  /// Reference-based list comparison (fast — avoids deep equality).
  bool _sameImageList(List<File> a, List<File> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!identical(a[i], b[i])) return false;
    }
    return true;
  }

  void _resetOrder() {
    _currentOrder = List.generate(widget.state.images.length, (i) => i);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  /// Move the dragged item in [_currentOrder] to [targetGridPos].
  void _tentativeReorder(int draggedOriginalIdx, int targetGridPos) {
    final fromGridPos = _currentOrder.indexOf(draggedOriginalIdx);
    if (fromGridPos == targetGridPos) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentOrder.removeAt(fromGridPos);
      _currentOrder.insert(targetGridPos, draggedOriginalIdx);
    });
  }

  /// Commit the current order to the BLoC.
  void _commitReorder() {
    final reordered =
        _currentOrder.map((i) => widget.state.images[i]).toList();
    context.read<PdfPreviewBloc>().add(PdfPreviewApplyOrder(reordered));
  }

  /// Start auto-scrolling if the pointer is near the top or bottom edge.
  void _handleAutoScroll(double pointerY, double viewportHeight) {
    if (pointerY < _autoScrollZone) {
      _startAutoScroll(-_autoScrollSpeed);
    } else if (pointerY > viewportHeight - _autoScrollZone) {
      _startAutoScroll(_autoScrollSpeed);
    } else {
      _stopAutoScroll();
    }
  }

  void _startAutoScroll(double delta) {
    if (_autoScrollTimer != null) return;
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_scrollController.hasClients) return;
      final pos = _scrollController.position;
      final newOffset =
          (_scrollController.offset + delta).clamp(0.0, pos.maxScrollExtent);
      _scrollController.jumpTo(newOffset);
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.state.images;
    final selected = widget.state.selectedIndices;
    final accent = widget.config.accentColor;
    final itemW = _itemWidth(context);
    final itemH = itemW / 0.65;
    final totalHeight = _gridHeight(itemH);

    return Listener(
      onPointerMove: (event) {
        if (_dragIndex == null) return;
        final gridBox =
            _gridKey.currentContext?.findRenderObject() as RenderBox?;
        if (gridBox == null) return;

        // Auto-scroll based on pointer position relative to viewport.
        final scrollView = context.findRenderObject() as RenderBox?;
        if (scrollView != null) {
          final localY =
              scrollView.globalToLocal(event.position).dy;
          _handleAutoScroll(localY, scrollView.size.height);
        }
      },
      onPointerUp: (_) => _stopAutoScroll(),
      onPointerCancel: (_) => _stopAutoScroll(),
      child: SingleChildScrollView(
        key: _gridKey,
        controller: _scrollController,
        child: SizedBox(
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (int originalIdx = 0;
                  originalIdx < images.length;
                  originalIdx++)
                _buildGridItem(
                  originalIdx: originalIdx,
                  images: images,
                  selected: selected,
                  accent: accent,
                  itemW: itemW,
                  itemH: itemH,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem({
    required int originalIdx,
    required List<File> images,
    required Set<int> selected,
    required Color accent,
    required double itemW,
    required double itemH,
  }) {
    final gridPos = _currentOrder.indexOf(originalIdx);
    final pos = _gridPositionFor(gridPos, itemW, itemH);
    final isDragging = _dragIndex == originalIdx;
    final isSelected = selected.contains(originalIdx);

    return AnimatedPositioned(
      key: ValueKey(originalIdx),
      duration: isDragging ? Duration.zero : _animDuration,
      curve: _animCurve,
      left: pos.dx,
      top: pos.dy,
      width: itemW,
      height: itemH,
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) {
          if (details.data != originalIdx) {
            _tentativeReorder(details.data, gridPos);
          }
          return details.data != originalIdx;
        },
        onAcceptWithDetails: (_) {},
        builder: (context, candidateData, rejectedData) {
          return LongPressDraggable<int>(
            data: originalIdx,
            delay: const Duration(milliseconds: 150),
            hapticFeedbackOnStart: true,
            onDragStarted: () => setState(() => _dragIndex = originalIdx),
            onDraggableCanceled: (_, __) {
              _stopAutoScroll();
            },
            onDragEnd: (_) {
              _stopAutoScroll();
              _commitReorder();
              setState(() => _dragIndex = null);
            },
            feedback: Transform.rotate(
              angle: 0.04,
              child: Material(
                color: Colors.transparent,
                elevation: 16,
                borderRadius: BorderRadius.circular(10),
                shadowColor: Colors.black38,
                child: SizedBox(
                  width: itemW,
                  height: itemH - 30,
                  child: _buildThumbnail(
                    images[originalIdx],
                    isSelected: isSelected,
                    accent: accent,
                  ),
                ),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _buildThumbnailWithLabel(
                images[originalIdx],
                originalIdx,
                isSelected: isSelected,
                accent: accent,
              ),
            ),
            child: GestureDetector(
              onTap: () => context
                  .read<PdfPreviewBloc>()
                  .add(PdfPreviewToggleSelection(originalIdx)),
              child: _buildThumbnailWithLabel(
                images[originalIdx],
                originalIdx,
                isSelected: isSelected,
                accent: accent,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumbnailWithLabel(
    File image,
    int originalIndex, {
    required bool isSelected,
    required Color accent,
  }) {
    return Column(
      children: [
        Expanded(
          child:
              _buildThumbnail(image, isSelected: isSelected, accent: accent),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            (originalIndex + 1).toString().padLeft(2, '0'),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail(
    File image, {
    required bool isSelected,
    required Color accent,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? accent : Colors.grey.shade300,
          width: isSelected ? 2.5 : 1,
        ),
        color: Colors.white,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isSelected ? 7.5 : 9),
              child: Image.file(image, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? accent : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? accent : Colors.grey.shade400,
                  width: isSelected ? 0 : 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════

class _ToolbarAction extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final VoidCallback? onTap;

  const _ToolbarAction({
    required this.iconWidget,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = onTap != null ? Colors.black87 : Colors.black26;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              child: iconWidget,
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
