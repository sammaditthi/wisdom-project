import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wisdom_shared/wisdom_shared.dart';
import 'search_result_type.dart';

part 'search_result.freezed.dart';

/// Represents a single search result
@freezed
class SearchResult with _$SearchResult {
  const SearchResult._();

  const factory SearchResult({
    /// Unique identifier for this result
    required String id,

    /// Edition this result came from (e.g., 'bjt', 'sc')
    required String editionId,

    /// Category this result belongs to (title, content, or definition)
    required SearchResultType resultType,

    /// Title of the sutta/document
    required String title,

    /// Subtitle showing the navigation path (e.g., "Dīgha Nikāya > Sīlakkhandhavagga")
    required String subtitle,

    /// The actual text that matched the search query
    required String matchedText,

    /// Text before the match (for context preview)
    @Default('') String contextBefore,

    /// Text after the match (for context preview)
    @Default('') String contextAfter,

    /// File ID for navigation (e.g., "dn-1")
    required String contentFileId,

    /// Page index where the match is located
    required int pageIndex,

    /// Entry index within the page
    required int entryIndex,

    /// Reference to the tree node
    required String nodeKey,

    /// Language of the matched text
    required String language,

    /// Relevance score for ranking (optional)
    double? relevanceScore,
  }) = _SearchResult;

  /// Cached storage for [plainMatchedText], keyed by instance identity so it
  /// works with Freezed's const constructor. Same shape as
  /// `Entry.markedRanges`.
  static final Expando<String> _plainMatchedTextCache =
      Expando('plainMatchedText');

  /// [matchedText] with the formatting markers removed — what a snippet shows.
  ///
  /// The FTS index was built on marker-free text, so a word the markers split
  /// (`**ඡන්දරාගවෙමත්තතා**ති`) is one token there and two in [matchedText].
  /// Matching a hit against the raw string cannot locate it; match against
  /// this instead. Mirrors `Entry.plainText`, and is cached because the search
  /// tile reads it from `build()`.
  ///
  /// [matchedText] itself stays raw: the snippet goldens in
  /// `integration_test/search_flow_integration_test.dart` pin it byte-for-byte
  /// to prove the `bjt_content` pipeline loses nothing, markers included.
  String get plainMatchedText =>
      _plainMatchedTextCache[this] ??= ContentMarkers.stripMarkers(matchedText);
}
