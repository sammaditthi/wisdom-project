import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show HardwareKeyboard;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/constants.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/text_entry_theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../domain/entities/reader/document_slice.dart';
import '../../models/in_page_search_state.dart';
import '../../providers/tab_provider.dart'
    show activeSplitRatioProvider, updateActiveTabSplitRatioProvider;
import '../common/resizable_divider.dart';
import 'anchored_page_list.dart';
import 'entry_key_registry.dart';
import 'reader_entry_builder.dart';

/// Side-by-side Pali/Sinhala reader: one lazy list of pair rows, each
/// `Row(Pali cell, gap, Sinhala cell)`, so every row lines up its own pair.
///
/// One [SelectionArea] covers the whole list, so a drag can cross the anchor
/// row. A [_ColumnGate] on each cell keeps a selection inside the column the
/// press landed in.
class DualColumnPane extends ConsumerStatefulWidget {
  const DualColumnPane({
    super.key,
    required this.scrollController,
    required this.slice,
    required this.anchor,
    required this.searchState,
    required this.entryKeyRegistry,
    this.onWordTap,
    required this.onSelectionChanged,
    required this.contextMenuBuilder,
  });

  final ScrollController scrollController;

  /// The bounded unit to render — its pages, and where it starts and stops
  /// inside the first and last of them.
  final DocumentSlice slice;

  /// The row scroll offset 0 sits on; null is the unit's top.
  final (int, int)? anchor;

  final InPageSearchState searchState;

  /// Registry for entry-level GlobalKeys, one per pair row. Used for
  /// layout-switch scroll sync AND in-page-search scroll-to-match.
  final EntryKeyRegistry entryKeyRegistry;
  final void Function(String word)? onWordTap;
  final void Function(SelectedContent?) onSelectionChanged;
  final Widget Function(BuildContext, SelectableRegionState) contextMenuBuilder;

  @override
  ConsumerState<DualColumnPane> createState() => _DualColumnPaneState();
}

class _DualColumnPaneState extends ConsumerState<DualColumnPane> {
  /// The column of the last press, read by every cell's gate.
  final _ActiveColumn _activeColumn = _ActiveColumn();

  @override
  Widget build(BuildContext context) {
    final isTabletOrDesktop = ResponsiveUtils.isTabletOrDesktop(context);
    final dividerWidth =
        isTabletOrDesktop ? PaneWidthConstants.dividerWidth : 24.0;

    return Stack(
      children: [
        SelectionArea(
          onSelectionChanged: widget.onSelectionChanged,
          contextMenuBuilder: widget.contextMenuBuilder,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Past the paired measure the leftover becomes equal margins
              // instead of more column.
              final padding = context.textEntryTheme
                  .readingPadding(constraints.maxWidth, columns: 2);
              final availableWidth =
                  constraints.maxWidth - padding.horizontal - dividerWidth;
              final columns = _Columns(availableWidth, dividerWidth);

              return Listener(
                // Runs before the selection sees the press. A shift-click
                // keeps the column, so it extends the selection already there.
                onPointerDown: (event) {
                  if (HardwareKeyboard.instance.isShiftPressed) return;
                  final ratio = ref.read(activeSplitRatioProvider);
                  final seam =
                      padding.left + availableWidth * ratio + dividerWidth / 2;
                  _activeColumn.value = event.localPosition.dx < seam ? 0 : 1;
                },
                child: AnchoredPageList(
                  controller: widget.scrollController,
                  slice: widget.slice,
                  anchor: widget.anchor,
                  padding: padding,
                  rowCount: (page) => page.paliSection.entries.length,
                  buildPageNumber: (context, number) => columns.row(
                    ReaderEntryBuilder.buildPageNumber(context, number),
                    ReaderEntryBuilder.buildPageNumber(context, number),
                  ),
                  buildRows: (context, index, start, end) =>
                      _buildRows(context, index, start, end, columns),
                ),
              );
            },
          ),
        ),
        if (isTabletOrDesktop)
          // Watches splitRatio in its own Consumer — a tiny widget, cheap to
          // rebuild on drag.
          Consumer(
            builder: (context, ref, _) {
              final splitRatio = ref.watch(activeSplitRatioProvider);
              return _buildDividerOverlay(context, ref, splitRatio);
            },
          ),
      ],
    );
  }

  List<Widget> _buildRows(
    BuildContext context,
    int index,
    int start,
    int end,
    _Columns columns,
  ) {
    final slice = widget.slice;
    final page = slice.pages[index];
    final absolutePageIndex = slice.absolutePageStart + index;
    final searchState = widget.searchState;
    final currentMatch = searchState.currentMatch;
    final effectiveQuery = searchState.effectiveQuery;
    final hasQuery = searchState.hasActiveQuery;

    // One cell's entry, with its in-page search highlight.
    Widget entry(int entryIndex, String language) {
      final isPali = language == 'pi';
      final section = isPali ? page.paliSection : page.sinhalaSection;
      final isCurrentMatch = currentMatch != null &&
          currentMatch.pageIndex == absolutePageIndex &&
          currentMatch.entryIndex == entryIndex &&
          currentMatch.languageCode == language;
      return ReaderEntryBuilder.buildEntry(
        context,
        section.entries[entryIndex],
        enableDictionaryLookup: isPali,
        inPageSearchQuery: hasQuery &&
                searchState.hasMatchInEntry(
                    absolutePageIndex, entryIndex, language)
            ? effectiveQuery
            : null,
        currentMatchIndexInEntry:
            isCurrentMatch ? currentMatch.matchIndexInEntry : null,
        onWordTap: widget.onWordTap,
      );
    }

    return [
      for (var entryIndex = start; entryIndex < end; entryIndex++)
        KeyedSubtree(
          key: widget.entryKeyRegistry.keyFor(absolutePageIndex, entryIndex),
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppFonts.entryGapPx),
            child: columns.row(
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: _GatedCell(
                  column: 0,
                  active: _activeColumn,
                  child: entry(entryIndex, 'pi'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: entryIndex < page.sinhalaSection.entries.length
                    ? _GatedCell(
                        column: 1,
                        active: _activeColumn,
                        child: entry(entryIndex, 'si'),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
    ];
  }

  Widget _buildDividerOverlay(
      BuildContext context, WidgetRef ref, double splitRatio) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The same padding the content is laid out with — this overlay floats
          // free of it, so once the margins start widening a literal 24 would
          // leave the handle sitting well left of the seam it drags.
          final padding = context.textEntryTheme
              .readingPadding(constraints.maxWidth, columns: 2);
          // Must be the *same* width the rows divide: the divider is each
          // row's middle child, not part of either column, so the ratio is
          // against what is left after it.
          final availableWidth = constraints.maxWidth -
              padding.horizontal -
              PaneWidthConstants.dividerWidth;
          // The gap's own left edge, which is where the handle starts.
          // `ResizableDivider` sizes itself from the same constant, so landing
          // its left edge on the gap's left edge fills the gap exactly. Only
          // reached when `isTabletOrDesktop`, the same branch where the rows'
          // gap is this constant rather than the 24 a phone uses.
          final dividerLeft = padding.left + (availableWidth * splitRatio);

          return Padding(
            padding: EdgeInsets.only(left: dividerLeft),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ResizableDivider(
                hideWhenIdle: true,
                onDragUpdate: (delta) {
                  // Against the width the ratio is a fraction of, so the seam
                  // keeps up with the pointer instead of trailing it by the
                  // divider's share.
                  final ratioChange = delta / availableWidth;
                  final currentRatio = ref.read(activeSplitRatioProvider);
                  ref.read(updateActiveTabSplitRatioProvider)(
                      currentRatio + ratioChange);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The two column widths a pair row splits its width into.
class _Columns {
  const _Columns(this.availableWidth, this.dividerWidth);

  final double availableWidth;
  final double dividerWidth;

  /// A row of [left] and [right] at the split ratio. Each row watches the
  /// ratio itself, so a divider drag re-lays only the built rows and never
  /// rebuilds the cells.
  Widget row(Widget left, Widget right) => Consumer(
        builder: (context, ref, _) {
          final ratio = ref.watch(activeSplitRatioProvider);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: availableWidth * ratio, child: left),
              SizedBox(width: dividerWidth),
              SizedBox(width: availableWidth * (1 - ratio), child: right),
            ],
          );
        },
      );
}

/// Which column the last press landed in: 0 Pali, 1 Sinhala, null none yet.
class _ActiveColumn {
  int? value;
}

/// One cell of a pair row, with a [_ColumnGate] it owns.
class _GatedCell extends StatefulWidget {
  const _GatedCell({
    required this.column,
    required this.active,
    required this.child,
  });

  final int column;
  final _ActiveColumn active;
  final Widget child;

  @override
  State<_GatedCell> createState() => _GatedCellState();
}

class _GatedCellState extends State<_GatedCell> {
  late final _ColumnGate _gate = _ColumnGate(widget.column, widget.active);

  @override
  void didUpdateWidget(_GatedCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _gate
      ..column = widget.column
      ..active = widget.active;
  }

  @override
  void dispose() {
    _gate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      SelectionContainer(delegate: _gate, child: widget.child);
}

/// Keeps a selection in one column.
///
/// In the active column, events pass through. In the other column the cell
/// holds no selection and only says where the pointer lies, so the scroll
/// view's selection walks past it. A gate per cell rather than an ordering:
/// the scroll view puts its own selection container between the
/// [SelectionArea] and the rows, so nothing above it ever sees the cells.
class _ColumnGate extends StaticSelectionContainerDelegate {
  _ColumnGate(this.column, this.active);

  int column;
  _ActiveColumn active;

  Rect get _rect => MatrixUtils.transformRect(
      getTransformTo(null), Offset.zero & containerSize);

  @override
  SelectionResult dispatchSelectionEvent(SelectionEvent event) {
    final owner = active.value;
    if (event is ClearSelectionEvent || owner == null || owner == column) {
      return super.dispatchSelectionEvent(event);
    }
    if (event is SelectAllSelectionEvent) {
      // An empty selection at the top-left: after select-all the scroll
      // view's selection container expects its first and last child to hold
      // one (an assert in debug, a null error in release).
      final start = _rect.topLeft;
      super.dispatchSelectionEvent(const ClearSelectionEvent());
      super.dispatchSelectionEvent(
          SelectionEdgeUpdateEvent.forStart(globalPosition: start));
      super.dispatchSelectionEvent(
          SelectionEdgeUpdateEvent.forEnd(globalPosition: start));
      return SelectionResult.none;
    }
    if (value.hasSelection) {
      super.dispatchSelectionEvent(const ClearSelectionEvent());
    }
    return switch (event) {
      SelectionEdgeUpdateEvent(:final globalPosition) => hasSize
          ? SelectionUtils.getResultBasedOnRect(_rect, globalPosition)
          : SelectionResult.next,
      GranularlyExtendSelectionEvent(:final forward) =>
        forward ? SelectionResult.next : SelectionResult.previous,
      DirectionallyExtendSelectionEvent(:final direction) =>
        switch (direction) {
          SelectionExtendDirection.forward ||
          SelectionExtendDirection.nextLine =>
            SelectionResult.next,
          SelectionExtendDirection.backward ||
          SelectionExtendDirection.previousLine =>
            SelectionResult.previous,
        },
      _ => SelectionResult.none,
    };
  }
}
