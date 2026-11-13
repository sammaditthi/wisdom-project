import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../providers/search_provider.dart';
import '../../providers/search_results_focus_provider.dart';
import '../../../domain/entities/search/recent_search.dart';
import 'search_link_button.dart';
import 'search_section_header.dart';
import 'search_traversal_policy.dart';

/// Simplified overlay that only shows recent searches
/// Displayed when search bar is focused with an empty query.
/// Shows the newest few; the last row holds "Show more", which opens the
/// rest in place, and "Clear all", under the ✕ column.
class RecentSearchOverlay extends ConsumerStatefulWidget {
  /// Callback when the overlay should be dismissed
  final VoidCallback onDismiss;

  /// Width of the dropdown
  final double width;

  const RecentSearchOverlay({
    super.key,
    required this.onDismiss,
    this.width = 350,
  });

  @override
  ConsumerState<RecentSearchOverlay> createState() =>
      _RecentSearchOverlayState();
}

class _RecentSearchOverlayState extends ConsumerState<RecentSearchOverlay> {
  /// Rows shown before "Show more".
  static const _collapsedCount = 5;

  // Row padding, pinned on each row (Material 3's defaults) so the last
  // row's links line up with the history icons and the ✕ icons.
  static const double _rowStartPadding = 16;
  static const double _rowEndPadding = 24;
  static const double _closeIconSize = 18;
  static const _closeDensity = VisualDensity.compact;

  /// The ✕ button: its icon plus IconButton's 8px a side. Density lowers
  /// only its 40px minimum (to 32), never the side padding.
  static const double _closeButtonSize = _closeIconSize + 2 * 8;

  /// Icons.close draws its cross 5/24 of its size inside its box.
  static const double _closeGlyphInset = _closeIconSize * 5 / 24;

  /// Local, so each open starts collapsed.
  bool _expanded = false;

  /// Distance from the card's end to the ✕ cross's end. Touch platforms pad
  /// the ✕ button out to a tap target, 48px less the same density, which
  /// moves the icon inwards.
  static double _closeIconEnd(BuildContext context) {
    final button =
        Theme.of(context).materialTapTargetSize == MaterialTapTargetSize.padded
            ? math.max(_closeButtonSize,
                kMinInteractiveDimension + _closeDensity.baseSizeAdjustment.dx)
            : _closeButtonSize;
    return _rowEndPadding + (button - _closeIconSize) / 2 + _closeGlyphInset;
  }

  /// Calculate max height based on screen size.
  ///
  /// Mobile: fill the available height (minus safe-area insets, the keyboard
  /// and a small gap for the search bar above). Tablet/desktop: also cap at
  /// 66% so the overlay doesn't dominate the viewport.
  double _calculateMaxHeight(BuildContext context) {
    // Safe-area insets (status bar, home indicator) and the keyboard — not a
    // responsive decision, so MediaQuery is still the right source here.
    final padding = MediaQuery.paddingOf(context);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight = ResponsiveUtils.screenHeight(context);

    final available =
        screenHeight - padding.top - padding.bottom - keyboard - 100;
    final maxHeight = ResponsiveUtils.isMobile(context)
        ? available
        : math.min(available, screenHeight * 0.66);
    // A negative max height would fail BoxConstraints' assert.
    return math.max(0, maxHeight);
  }

  @override
  Widget build(BuildContext context) {
    // Only the list, so unrelated search-state changes don't rebuild the rows.
    final recentSearches =
        ref.watch(searchStateProvider.select((s) => s.recentSearches));
    final theme = Theme.of(context);

    if (recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxHeight = _calculateMaxHeight(context);
    const borderRadius = BorderRadius.all(Radius.circular(12));

    return SizedBox(
      width: widget.width,
      child: Material(
        elevation: 8,
        borderRadius: borderRadius,
        color: theme.colorScheme.surface,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: ClipRRect(
            borderRadius: borderRadius,
            // A group, so Tab walks the card in the order it shows before
            // leaving it (keyboard-shortcuts-sheet.md, Go to results or
            // recent searches), with the panel's policy.
            child: FocusTraversalGroup(
              policy: searchTraversalPolicy(),
              child: SingleChildScrollView(
                child: Focus(
                  focusNode: ref.watch(recentSearchesFocusNodeProvider),
                  child: _buildRecentSearches(context, recentSearches),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearches(
    BuildContext context,
    List<RecentSearch> recentSearches,
  ) {
    final l10n = AppLocalizations.of(context);
    final canExpand = recentSearches.length > _collapsedCount;
    final visible =
        _expanded ? recentSearches : recentSearches.take(_collapsedCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchSectionHeader(label: l10n.recentSearches),
        // The rows ↓ / ↑ step through.
        Focus(
          focusNode: ref.watch(recentSearchRowsFocusNodeProvider),
          child: Column(
            children: [
              for (final search in visible) _buildRow(context, search),
            ],
          ),
        ),
        Padding(
          // List-wide links, so on the list's edges: under the history icons
          // (where the header starts) and under the ✕ icons. A result tile's
          // "Show more" sits under its text instead: it opens that text.
          padding: EdgeInsetsDirectional.only(
            start: _rowStartPadding - SearchLinkButton.padding,
            end: _closeIconEnd(context) - SearchLinkButton.padding,
            bottom: 4,
          ),
          child: Row(
            children: [
              // Gone once deleting leaves nothing to hide.
              if (canExpand)
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: SearchLinkButton(
                      onPressed: () => setState(() => _expanded = !_expanded),
                      icon: _expanded ? Icons.expand_less : Icons.expand_more,
                      label: _expanded ? l10n.showLess : l10n.showMore,
                    ),
                  ),
                )
              else
                const Spacer(),
              SearchLinkButton(
                label: l10n.clearAll,
                onPressed: () => ref
                    .read(searchStateProvider.notifier)
                    .clearRecentSearches(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, RecentSearch search) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    // Singlish searches are saved as their Sinhala
    // (saveRecentSearchAndDismiss), so the saved text is what we show.
    final queryText = search.queryText;

    return ListTile(
      key: ValueKey(queryText),
      dense: true,
      contentPadding: const EdgeInsetsDirectional.only(
          start: _rowStartPadding, end: _rowEndPadding),
      leading: Icon(
        Icons.history,
        size: 20,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        queryText,
        style: context.typography.listRowTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: _closeIconSize),
        color: theme.colorScheme.onSurfaceVariant,
        visualDensity: _closeDensity,
        tooltip: l10n.removeRecentSearch,
        onPressed: () {
          ref.read(searchStateProvider.notifier).removeRecentSearch(queryText);
        },
      ),
      onTap: () {
        // Read before dismissing: dismissing disposes this state and its ref.
        final notifier = ref.read(searchStateProvider.notifier);
        widget.onDismiss();
        notifier.selectRecentSearch(queryText);
      },
    );
  }
}
