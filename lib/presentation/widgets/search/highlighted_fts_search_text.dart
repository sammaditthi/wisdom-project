import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisdom_shared/wisdom_shared.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/search_match_finder.dart';
import '../../../core/utils/text_utils.dart';
import '../../providers/pali_letter_options_provider.dart';

/// Displays text with search query matches highlighted.
///
/// Supports three modes:
/// - **Exact phrase**: Entire query as single match
/// - **Phrase with prefix**: Adjacent words with prefix matching
/// - **Separate words**: Each word highlighted independently
class HighlightedFtsSearchText extends ConsumerWidget {
  /// The text content to display and highlight matches within.
  ///
  /// Must already be marker-free — pass `SearchResult.plainMatchedText`, as
  /// the reader passes `Entry.plainText`. Markers left in would split words
  /// the FTS index holds whole, and the hit could not be located.
  final String matchedText;

  /// Pre-computed effective query (sanitized + Singlish converted).
  final String effectiveQuery;

  /// Phrase mode: words must appear adjacent. Otherwise within proximity.
  final bool isPhraseSearch;

  /// Exact mode: exact token match. Otherwise prefix matching.
  final bool isExactMatch;

  /// Language of the matched text ('pali' or 'sinhala').
  /// When 'pali', conjunct consonant transformation is applied for display.
  final String language;

  /// Maximum display lines. Defaults to 3.
  final int maxLines;

  const HighlightedFtsSearchText({
    super.key,
    required this.matchedText,
    required this.effectiveQuery,
    required this.isPhraseSearch,
    required this.isExactMatch,
    required this.language,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // The Pali-letter switches; only used on the Pali branch. Watching here
    // rebuilds the snippet live when a switch flips.
    final options = ref.watch(paliLetterOptionsProvider);
    return _buildHighlightedText(context, matchedText, theme, options);
  }

  /// Main entry point for building highlighted text.
  Widget _buildHighlightedText(
    BuildContext context,
    String plainText,
    ThemeData theme,
    PaliLetterOptions options,
  ) {
    final baseStyle = context.typography.resultMatchedText;

    // One finder for both jobs: where to centre the snippet, and what to
    // highlight once it is cut. Using it for both is what keeps the two in
    // agreement — they used to be separate implementations that had already
    // drifted to different proximity windows.
    final finder = SearchMatchFinder(
      queryText: effectiveQuery,
      isPhraseSearch: isPhraseSearch,
      isExactMatch: isExactMatch,
    );

    final snippet = _createSnippet(plainText, finder);

    final highlightStyle = TextStyle(
      backgroundColor: theme.colorScheme.tertiaryContainer,
      color: theme.colorScheme.onPrimaryContainer,
    );

    final rawRanges = finder.findMatchRanges(snippet);

    // For Pali text, apply conjunct transformation and remap highlight ranges
    final String displaySnippet;
    final List<({int start, int end})> displayRanges;
    if (language == 'pali') {
      (displaySnippet, displayRanges) =
          applyConjunctsWithRangeMapping(snippet, rawRanges, options);
    } else {
      displaySnippet = snippet;
      displayRanges = rawRanges;
    }

    // Build spans from ranges
    final spans =
        _buildSpansFromRanges(displaySnippet, displayRanges, highlightStyle);

    return RichText(
      text: TextSpan(style: baseStyle, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  // ===========================================================================
  // SNIPPET CREATION
  // ===========================================================================

  /// Extracts a window of [text] centred on the first match [finder] reports.
  ///
  /// Both ends snap to grapheme cluster boundaries, so a Sinhala combining
  /// character (virama, vowel sign) is never split at the "..." edges.
  ///
  /// With no match it falls back to the head of the entry. That happens when
  /// the index joined a word across a character the text keeps, such as the
  /// Pali elision `’` in `තීණි’මානි` — see
  /// docs/todo/search/word-joining-characters-in-the-fts-index.md.
  String _createSnippet(
    String text,
    SearchMatchFinder finder, {
    int contextBefore = 50,
    int contextAfter = 100,
  }) {
    final centre = _centreOn(text, finder);

    final rawStart = (centre.start - contextBefore).clamp(0, text.length);
    final rawEnd = (centre.end + contextAfter).clamp(0, text.length);
    final snippetStart = snapToGraphemeBoundary(text, rawStart);
    final snippetEnd = snapToGraphemeBoundary(text, rawEnd, forward: true);

    var snippet = text.substring(snippetStart, snippetEnd);
    if (snippetStart > 0) snippet = '...$snippet';
    if (snippetEnd < text.length) snippet = '$snippet...';

    return snippet;
  }

  /// Which match the snippet opens on, in [text] coordinates.
  ///
  /// Separate-words mode highlights every occurrence of every word, and the
  /// earliest one can sit far from the cluster that actually made the record
  /// match. So that mode gets a proximity pass first — same finder, wider
  /// window — and only falls back to the earliest single match when the words
  /// never come close together.
  ({int start, int end}) _centreOn(String text, SearchMatchFinder finder) {
    if (!isPhraseSearch && splitQueryWords(effectiveQuery).length >= 2) {
      final clustered = SearchMatchFinder(
        queryText: effectiveQuery,
        isPhraseSearch: true,
        isExactMatch: false,
        maxGap: _separateWordsGap,
      ).findMatchRanges(text);
      if (clustered.isNotEmpty) return clustered.first;
    }

    // Ranges come back earliest first, so this is the first highlight too.
    final matches = finder.findMatchRanges(text);
    return matches.isEmpty ? (start: 0, end: 0) : matches.first;
  }

  /// How far apart separate words may sit and still be read as one hit, for
  /// snippet centring only. Wider than the phrase-mode window the finder
  /// defaults to, and independent of the proximity the FTS query used.
  static const int _separateWordsGap = 100;

  // ===========================================================================
  // UTILITIES
  // ===========================================================================

  /// Builds TextSpans from highlight ranges.
  List<TextSpan> _buildSpansFromRanges(
    String text,
    List<({int start, int end})> ranges,
    TextStyle highlightStyle,
  ) {
    if (ranges.isEmpty) return [TextSpan(text: text)];

    final spans = <TextSpan>[];
    int pos = 0;

    for (final range in ranges) {
      if (range.start > pos) {
        spans.add(TextSpan(text: text.substring(pos, range.start)));
      }
      spans.add(TextSpan(
        text: text.substring(range.start, range.end),
        style: highlightStyle,
      ));
      pos = range.end;
    }

    if (pos < text.length) {
      spans.add(TextSpan(text: text.substring(pos)));
    }
    return spans;
  }
}
