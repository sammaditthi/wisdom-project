import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SelectedContent;
import '../../../core/theme/text_entry_theme.dart';
import '../../../domain/entities/bjt/bjt_page.dart';
import '../../../domain/entities/bjt/bjt_section.dart';
import '../../../domain/entities/reader/document_slice.dart';
import '../../models/in_page_search_state.dart';
import 'anchored_page_list.dart';
import 'entry_key_registry.dart';
import 'reader_entry_builder.dart';

/// A single-column reader pane for paliOnly or sinhalaOnly display modes.
///
/// Parameterized by [languageCode] and [enableDictionaryLookup] to handle
/// both Pali and Sinhala modes without duplication.
class SingleColumnPane extends StatelessWidget {
  const SingleColumnPane({
    super.key,
    required this.scrollController,
    required this.slice,
    required this.anchor,
    required this.searchState,
    required this.languageCode,
    required this.enableDictionaryLookup,
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

  /// 'pi' for Pali or 'si' for Sinhala.
  final String languageCode;
  final bool enableDictionaryLookup;

  /// Registry for entry-level GlobalKeys used to sync scroll position
  /// across layout switches AND to drive in-page-search scroll-to-match.
  final EntryKeyRegistry entryKeyRegistry;

  /// Called when a word is tapped (for dictionary lookup).
  final void Function(String word)? onWordTap;

  final void Function(SelectedContent?) onSelectionChanged;
  final Widget Function(BuildContext, SelectableRegionState) contextMenuBuilder;

  BJTSection _section(BJTPage page) =>
      languageCode == 'pi' ? page.paliSection : page.sinhalaSection;

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
          rowCount: (page) => _section(page).entries.length,
          buildRows: (context, index, start, end) =>
              ReaderEntryBuilder.buildEntries(
            context,
            _section(slice.pages[index]).entries.sublist(start, end),
            enableDictionaryLookup: enableDictionaryLookup,
            searchState: searchState,
            absolutePageIndex: slice.absolutePageStart + index,
            entryStartOffset: start,
            languageCode: languageCode,
            onWordTap: onWordTap,
            entryKeyRegistry: entryKeyRegistry,
          ),
        ),
      ),
    );
  }
}
