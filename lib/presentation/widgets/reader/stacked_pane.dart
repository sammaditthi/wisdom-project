import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SelectedContent;
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/text_entry_theme.dart';
import '../../../domain/entities/content/entry_type.dart';
import '../../../domain/entities/reader/document_slice.dart';
import '../../models/in_page_search_state.dart';
import 'anchored_page_list.dart';
import 'entry_key_registry.dart';
import 'reader_entry_builder.dart';

/// A stacked reader pane that renders Pali and Sinhala entries vertically.
///
/// For each entry index, renders the Pali entry first (heavier weight)
/// followed by its Sinhala translation (regular weight), then moves to the
/// next index. This layout is ideal for smaller screens where side-by-side
/// is too cramped.
class StackedPane extends StatelessWidget {
  const StackedPane({
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

  /// Registry for entry-level GlobalKeys. Used for layout-switch scroll
  /// sync AND in-page-search scroll-to-match. The pair-level KeyedSubtree
  /// at the bottom of `_buildStackedEntries` carries the registry key for
  /// each `(absolutePageIndex, entryIndex)`.
  final EntryKeyRegistry entryKeyRegistry;

  /// Called when a word is tapped (for dictionary lookup).
  final void Function(String word)? onWordTap;

  final void Function(SelectedContent?) onSelectionChanged;
  final Widget Function(BuildContext, SelectableRegionState) contextMenuBuilder;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      onSelectionChanged: onSelectionChanged,
      contextMenuBuilder: contextMenuBuilder,
      // LayoutBuilder exposes the pane's own width so the reading column can
      // be capped and centered on wide screens (calmer margins), while
      // medium/small panes keep the standard uniform padding.
      child: LayoutBuilder(
        builder: (context, constraints) => AnchoredPageList(
          controller: scrollController,
          slice: slice,
          anchor: anchor,
          padding: context.textEntryTheme.readingPadding(constraints.maxWidth),
          rowCount: (page) => page.paliSection.entries.length,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          buildRows: _buildStackedEntries,
        ),
      ),
    );
  }

  /// Builds stacked Pali/Sinhala entry widgets for rows
  /// `[startEntry, endEntry)` of the page at slice-local [index].
  ///
  /// For each entry index, emits the Pali entry (heavier weight,
  /// dictionary-tappable) then the Sinhala entry (regular weight), with a
  /// small gap between them and a larger gap between pairs.
  List<Widget> _buildStackedEntries(
    BuildContext context,
    int index,
    int startEntry,
    int endEntry,
  ) {
    final page = slice.pages[index];
    final absolutePageIndex = slice.absolutePageStart + index;
    // The page's first row in this unit. The anchor can split a page, so
    // [startEntry] is not always it.
    final (pageStart, _) =
        slice.entriesOn(index, page.paliSection.entries.length);
    final widgets = <Widget>[];
    final currentMatch = searchState.currentMatch;
    final effectiveQuery = searchState.effectiveQuery;
    final hasQuery = searchState.hasActiveQuery;

    for (var i = 0; i < endEntry - startEntry; i++) {
      final entryIndex = i + startEntry;
      final paliEntry = page.paliSection.entries[entryIndex];
      final sinhalaEntry = entryIndex < page.sinhalaSection.entries.length
          ? page.sinhalaSection.entries[entryIndex]
          : null;

      // Check if either entry is the current search match
      final isPaliCurrentMatch = currentMatch != null &&
          currentMatch.pageIndex == absolutePageIndex &&
          currentMatch.entryIndex == entryIndex &&
          currentMatch.languageCode == 'pi';
      final isSinhalaCurrentMatch = currentMatch != null &&
          currentMatch.pageIndex == absolutePageIndex &&
          currentMatch.entryIndex == entryIndex &&
          currentMatch.languageCode == 'si';

      // Add extra space before title entries (heading/centered) to
      // visually separate them from preceding content on the same page
      final isTitle = paliEntry.entryType == EntryType.heading ||
          paliEntry.entryType == EntryType.centered;
      if (isTitle && entryIndex > pageStart) {
        widgets.add(const SizedBox(height: 12.0));
      }

      // Pali entry — heavier weight, dictionary lookup enabled. The weight
      // override keeps Pali two steps above the Sinhala body weight.
      final paliHasMatch = hasQuery &&
          searchState.hasMatchInEntry(absolutePageIndex, entryIndex, 'pi');
      final paliWidget = ReaderEntryBuilder.buildEntry(
        context,
        paliEntry,
        enableDictionaryLookup: true,
        inPageSearchQuery: paliHasMatch ? effectiveQuery : null,
        currentMatchIndexInEntry:
            isPaliCurrentMatch ? currentMatch.matchIndexInEntry : null,
        onWordTap: onWordTap,
        fontWeight: AppFonts.paliWeight,
      );

      // Build the entry pair children
      final pairChildren = <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: AppFonts.stackedPairGapPx),
          child: paliWidget,
        ),
      ];

      // Sinhala entry — regular weight, no dictionary lookup
      if (sinhalaEntry != null) {
        final sinhalaHasMatch = hasQuery &&
            searchState.hasMatchInEntry(absolutePageIndex, entryIndex, 'si');
        final sinhalaWidget = ReaderEntryBuilder.buildEntry(
          context,
          sinhalaEntry,
          enableDictionaryLookup: false,
          inPageSearchQuery: sinhalaHasMatch ? effectiveQuery : null,
          currentMatchIndexInEntry:
              isSinhalaCurrentMatch ? currentMatch.matchIndexInEntry : null,
          onWordTap: onWordTap,
        );

        pairChildren.add(
          Padding(
            padding:
                const EdgeInsets.only(bottom: AppFonts.stackedPairBottomGapPx),
            child: sinhalaWidget,
          ),
        );
      } else {
        // No Sinhala entry — take the pair's outer gap so the rhythm holds
        pairChildren[0] = Padding(
          padding:
              const EdgeInsets.only(bottom: AppFonts.stackedPairBottomGapPx),
          child: paliWidget,
        );
      }

      // Wrap the entry pair with a registry key for layout-switch scroll sync
      widgets.add(
        KeyedSubtree(
          key: entryKeyRegistry.keyFor(absolutePageIndex, entryIndex),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: pairChildren,
          ),
        ),
      );
    }

    return widgets;
  }
}
