import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dictionary_badge_theme.dart';
import '../../../core/utils/pali_conjunct_transformer.dart';
import '../../../domain/entities/dictionary/dictionary_info.dart';
import '../../../domain/entities/search/search_result.dart';
import '../../providers/pali_letter_options_provider.dart';
import '../../providers/search_provider.dart';
import '../../utils/dictionary_meaning_spans.dart';
import '../dictionary/dpd_website_link.dart';
import 'result_badge.dart';
import 'search_link_button.dart';

/// A search result tile for dictionary definition results.
///
/// Shows the word, dictionary name and the first two lines of the meaning.
/// "Show more" below opens the full meaning in place, the way `GroupedFTSTile`
/// opens its hidden matches.
class DictionarySearchResultTile extends ConsumerWidget {
  /// The search result (must be of type definition)
  final SearchResult result;

  const DictionarySearchResultTile({
    super.key,
    required this.result,
  });

  static const _collapsedLines = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final typography = context.typography;
    final l10n = AppLocalizations.of(context);
    // Dictionary words are always Pali, but still gated by the switches so the
    // tile matches the rest of the app's rendering.
    final options = ref.watch(paliLetterOptionsProvider);
    // Only this entry's flag, as in GroupedFTSTile.
    final isExpanded = ref.watch(searchStateProvider
        .select((s) => s.expandedDefinitions.contains(result.id)));
    final dictInfo = DictionaryInfo.getById(result.editionId);
    final isDpd = result.editionId == 'DPD';
    // Badge colour from the theme's shared dictionary badge palette.
    final dictColor = context.dictionaryBadgeColors
        .colorFor(result.editionId, theme.colorScheme.primary);
    // Formatted like the dictionary sheet: its line breaks, bold and italics.
    final meaning = TextSpan(
      children: dictionaryMeaningSpans(result.matchedText, dropLinkText: isDpd),
    );

    return LayoutBuilder(builder: (context, constraints) {
      // The meaning's style and width inside the ListTile below, so "Show
      // more" appears only when two lines cut the meaning short.
      final meaningStyle = DefaultTextStyle.of(context)
          .style
          .merge(typography.resultMatchedText);
      final textStart = ResultBadge.textStart(context, true);
      final meaningWidth =
          constraints.maxWidth - textStart - ResultBadge.rowPadding;
      final canExpand = isExpanded ||
          _isCut(context, meaning, meaningStyle, math.max(0, meaningWidth));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: ResultBadge.rowPadding, vertical: 8),
            leading: ResultBadge(
              label: dictInfo?.abbreviation ?? result.editionId,
              backgroundColor: dictColor.withValues(alpha: 0.15),
              labelColor: dictColor,
            ),
            title: Text(
              result.title.withPaliLetters(options),
              style:
                  typography.resultTitle.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  result.subtitle, // Dictionary name
                  style: typography.resultSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text.rich(
                  meaning,
                  style: meaningStyle,
                  maxLines: isExpanded ? null : _collapsedLines,
                  overflow: isExpanded ? null : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // "Show more" / "Show less", and DPD's website link
          if (canExpand || isDpd)
            Padding(
              // Lines the first label up with the meaning, as in GroupedFTSTile.
              padding: EdgeInsets.only(
                left: textStart - SearchLinkButton.padding,
                bottom: 4,
              ),
              child: Wrap(
                spacing: 8,
                children: [
                  if (canExpand)
                    SearchLinkButton(
                      onPressed: () => ref
                          .read(searchStateProvider.notifier)
                          .toggleDefinitionExpansion(result.id),
                      icon: isExpanded ? Icons.expand_less : Icons.expand_more,
                      label: isExpanded ? l10n.showLess : l10n.showMore,
                    ),
                  if (isDpd) DpdWebsiteLink(html: result.matchedText),
                ],
              ),
            ),
        ],
      );
    });
  }

  /// Whether [_collapsedLines] lines at [maxWidth] cut [meaning] short.
  static bool _isCut(
    BuildContext context,
    InlineSpan meaning,
    TextStyle style,
    double maxWidth,
  ) {
    final painter = TextPainter(
      text: TextSpan(style: style, children: [meaning]),
      maxLines: _collapsedLines,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
    )..layout(maxWidth: maxWidth);
    final isCut = painter.didExceedMaxLines;
    painter.dispose();
    return isCut;
  }
}
