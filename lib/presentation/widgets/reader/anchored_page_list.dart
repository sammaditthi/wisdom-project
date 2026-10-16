import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../domain/entities/bjt/bjt_page.dart';
import '../../../domain/entities/reader/document_slice.dart';
import 'reader_entry_builder.dart';

/// Builds the rows `[start, end)` of the page at slice-local [page].
typedef PageRowsBuilder = List<Widget> Function(
  BuildContext context,
  int page,
  int start,
  int end,
);

/// A unit's pages in one lazy scroll view whose offset 0 sits on [anchor].
///
/// The pages above the anchor live in a sliver before
/// [CustomScrollView.center], which grows upward: they are built only when
/// the reader scrolls up, and nothing that changes height up there moves the
/// screen. Every reader layout renders through this.
class AnchoredPageList extends StatelessWidget {
  const AnchoredPageList({
    super.key,
    required this.controller,
    required this.slice,
    required this.anchor,
    required this.padding,
    required this.rowCount,
    required this.buildRows,
    this.buildPageNumber = ReaderEntryBuilder.buildPageNumber,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final ScrollController controller;
  final DocumentSlice slice;

  /// The anchor row as an absolute `(page, entry)`; null is the unit's top.
  final (int, int)? anchor;

  final EdgeInsets padding;

  /// How many rows [page] has in what this pane draws.
  final int Function(BJTPage page) rowCount;

  final PageRowsBuilder buildRows;
  final Widget Function(BuildContext context, int pageNumber) buildPageNumber;
  final CrossAxisAlignment crossAxisAlignment;

  static const _centerKey = ValueKey('anchored-page-list-center');

  static const _spacer =
      SizedBox(height: PaneWidthConstants.readerActionButtonGroupHeight);

  @override
  Widget build(BuildContext context) {
    final pageCount = slice.pages.length;
    final split = _localAnchor();

    if (split == null) {
      return CustomScrollView(
        controller: controller,
        center: _centerKey,
        slivers: [
          SliverPadding(
            key: _centerKey,
            padding: padding,
            sliver: SliverList.builder(
              itemCount: pageCount + 1,
              itemBuilder: (context, i) =>
                  i == 0 ? _spacer : _page(context, i - 1),
            ),
          ),
        ],
      );
    }

    final (ap, ae) = split;
    return CustomScrollView(
      controller: controller,
      center: _centerKey,
      slivers: [
        // Grows upward from the anchor: index 0 is nearest it.
        SliverPadding(
          padding: padding.copyWith(bottom: 0),
          sliver: SliverList.builder(
            itemCount: ap + 2,
            itemBuilder: (context, i) {
              if (i == ap + 1) return _spacer;
              // The anchor page's rows before the anchor, with no page gap.
              if (i == 0) return _page(context, ap, end: ae, gap: false);
              return _page(context, ap - i);
            },
          ),
        ),
        SliverPadding(
          key: _centerKey,
          padding: padding.copyWith(top: 0),
          sliver: SliverList.builder(
            itemCount: pageCount - ap,
            // The anchor row onward, with no page number.
            itemBuilder: (context, i) => i == 0
                ? _page(context, ap, start: ae, label: false)
                : _page(context, ap + i),
          ),
        ),
      ],
    );
  }

  /// The anchor as `(slice-local page, entry)`, or null when the whole unit
  /// goes below it: no anchor, one outside the slice (a stale `?e=` link) or
  /// one on the unit's first row.
  (int, int)? _localAnchor() {
    final anchor = this.anchor;
    if (anchor == null) return null;
    final page = anchor.$1 - slice.absolutePageStart;
    if (page < 0 || page >= slice.pages.length) return null;
    final (start, end) = slice.entriesOn(page, rowCount(slice.pages[page]));
    // A row this pane doesn't draw (Sinhala can run shorter than Pali)
    // anchors at the nearest edge of what it does.
    final entry = anchor.$2.clamp(start, end);
    if (page == 0 && entry == start) return null;
    if (page == slice.pages.length - 1 && entry == end) return null;
    return (page, entry);
  }

  /// One page, or its part from [start] / up to [end].
  Widget _page(
    BuildContext context,
    int index, {
    int? start,
    int? end,
    bool label = true,
    bool gap = true,
  }) {
    final page = slice.pages[index];
    // The unit may begin and end mid-page, so both ends are trimmed.
    final (first, last) = slice.entriesOn(index, rowCount(page));
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (label) ...[
          buildPageNumber(context, page.pageNumber),
          const SizedBox(height: AppFonts.pageNumberGapPx),
        ],
        ...buildRows(context, index, start ?? first, end ?? last),
        if (gap) const SizedBox(height: AppFonts.pageGapPx),
      ],
    );
  }
}
