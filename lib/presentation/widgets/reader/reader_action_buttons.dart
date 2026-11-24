import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../models/reader_layout.dart';
import '../../providers/parallel_text_provider.dart';
import '../../providers/suttacentral_provider.dart'
    show activeSuttaCentralTranslatorProvider, activeSuttaCentralUrlProvider;
import '../../providers/tab_provider.dart'
    show activeReaderLayoutProvider, updateActiveTabLayoutProvider;
import '../common/dismissible_menu_anchor.dart';
import '../common/menu_row.dart';
import 'reader_link_actions.dart';

/// Where a step button goes, named by the sutta it steps to.
typedef ReaderStepTarget = ({String name, VoidCallback onTap});

/// Width of the ⋮ menu, fixed so it lines up with its button's right edge.
const double _endMenuWidth = 280;

/// Every reader action in one pill at the top-right. Layout and ⋮ open
/// menus.
class ReaderActionToolbar extends ConsumerWidget {
  final VoidCallback onSearchTap;

  /// Null at the corpus edge; the button is then left out.
  final ReaderStepTarget? previous;
  final ReaderStepTarget? next;

  /// Go to beginning, or null to leave it out: at the top of a unit it has
  /// nothing to do.
  final VoidCallback? onScrollToBeginning;

  /// False while the toolbar is hidden; an open menu then closes.
  final bool visible;

  const ReaderActionToolbar({
    super.key,
    required this.onSearchTap,
    this.previous,
    this.next,
    this.onScrollToBeginning,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final targetNode = ref.watch(parallelTextNodeProvider);
    final isCommentary = ref.watch(isCommentaryProvider);
    final previous = this.previous;
    final next = this.next;
    final onScrollToBeginning = this.onScrollToBeginning;

    Widget step(ReaderStepTarget target, IconData icon) => _ToolbarButton.icon(
          icon,
          tooltip: l10n.goToSutta(target.name),
          onTap: target.onTap,
        );

    // This page, another sutta, outside the app, with a divider between two
    // groups. The middle group can be empty.
    final groups = <List<Widget>>[
      [
        _LayoutMenuButton(visible: visible),
        _ToolbarButton.icon(
          Symbols.document_search_sharp,
          // A page and a magnifier in 20px draws finer than the classic
          // icons beside it; 500 is what Symbols needs to sit among them.
          weight: 500,
          tooltip: l10n.findInPage,
          onTap: onSearchTap,
        ),
        // Last in its group: when a tap takes it away, the buttons to its
        // left slide over, so Find lands under the pointer, not Next.
        if (onScrollToBeginning != null)
          _ToolbarButton.icon(
            Icons.vertical_align_top,
            tooltip: l10n.scrollToBeginning,
            onTap: onScrollToBeginning,
          ),
      ],
      [
        // Commentary/Root text toggle — only when there is a parallel text
        if (targetNode != null)
          _ToolbarButton.icon(
            // The tree's icon for a text, in both directions.
            Symbols.description_sharp,
            weight: 500,
            tooltip: isCommentary ? l10n.rootText : l10n.commentary,
            onTap: () => ref.read(openParallelTextProvider)(
              isPortraitMode:
                  ResponsiveUtils.shouldDefaultToSingleColumn(context),
            ),
          ),
        if (previous != null) step(previous, Icons.skip_previous),
        if (next != null) step(next, Icons.skip_next),
      ],
      [_MoreMenuButton(visible: visible)],
    ].where((group) => group.isNotEmpty);

    return Material(
      // Enough shadow to lift the pill off the page.
      elevation: 3,
      borderRadius: BorderRadius.circular(24),
      color: colorScheme.surfaceContainer,
      // Go to beginning comes and goes while the toolbar shows: the pill
      // eases to its new width, its right end staying put.
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, group) in groups.indexed) ...[
                if (i > 0)
                  Container(
                    width: 1,
                    height: 24,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: colorScheme.outlineVariant,
                  ),
                ...group,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Layout ▾: the current layout's glyph, opening the four.
class _LayoutMenuButton extends ConsumerWidget {
  final bool visible;

  const _LayoutMenuButton({required this.visible});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // The toolbar icons' ink.
    final ink = Theme.of(context).colorScheme.onPrimaryContainer;
    final current = ref.watch(activeReaderLayoutProvider);

    return DismissibleMenuAnchor(
      overlayId: 'reader-layout-menu',
      visible: visible,
      menuChildren: [
        for (final layout in ReaderLayout.values)
          MenuRow(
            icon: _LayoutGlyph(layout: layout, color: ink),
            label: layout.label(l10n),
            selected: layout == current,
            onSelected: () => ref.read(updateActiveTabLayoutProvider)(layout),
          ),
      ],
      builder: (context, controller, focusNode) {
        final isOpen = controller.isOpen;
        return _ToolbarButton(
          tooltip: l10n.currentLayout(current.label(l10n)),
          onTap: controller.toggle,
          menuOpen: isOpen,
          focusNode: focusNode,
          padding: const EdgeInsetsDirectional.only(start: 12, end: 6),
          content: (color) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LayoutGlyph(layout: current, color: color),
              const SizedBox(width: 2),
              Icon(
                isOpen ? Icons.expand_less : Icons.expand_more,
                size: 16,
                color: color,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// More options (⋯ on Apple platforms, ⋮ elsewhere): Copy link, Copy path,
/// Open on SuttaCentral where the text has a counterpart there, and on the web
/// Open as HTML page. A generic menu, since most of its rows open the text
/// elsewhere rather than share it.
class _MoreMenuButton extends ConsumerWidget {
  final bool visible;

  const _MoreMenuButton({required this.visible});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // The toolbar icons' ink.
    final ink = Theme.of(context).colorScheme.onPrimaryContainer;
    final onSuttaCentral = ref.watch(activeSuttaCentralUrlProvider) != null;

    return DismissibleMenuAnchor(
      overlayId: 'reader-more-menu',
      visible: visible,
      endAlignedWidth: _endMenuWidth,
      menuChildren: [
        MenuRow(
          icon: Icon(Icons.content_copy, size: 20, color: ink),
          label: l10n.copyLink,
          onSelected: () => copyActiveTabLink(context, ref),
        ),
        MenuRow(
          icon: Icon(Icons.account_tree_outlined, size: 20, color: ink),
          label: l10n.copyPath,
          onSelected: () => copyActiveTabPath(context, ref),
        ),
        if (onSuttaCentral)
          MenuRow(
            icon: Icon(Icons.open_in_new, size: 20, color: ink),
            label: l10n.openOnSuttaCentral,
            note: ref.watch(activeSuttaCentralTranslatorProvider),
            onSelected: () => openOnSuttaCentral(context, ref),
          ),
        if (kIsWeb)
          MenuRow(
            icon: Icon(Icons.open_in_new, size: 20, color: ink),
            label: l10n.openAsHtmlPage,
            onSelected: () => openAsHtmlPage(context, ref),
          ),
      ],
      builder: (context, controller, focusNode) => _ToolbarButton.icon(
        Icons.adaptive.more,
        tooltip: l10n.moreOptions,
        onTap: controller.toggle,
        menuOpen: controller.isOpen,
        focusNode: focusNode,
      ),
    );
  }
}

/// A button inside the toolbar. No background of its own — the pill provides
/// the surface — except while its menu is open. The 44x44 minimum keeps the
/// touch target.
class _ToolbarButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onTap;

  /// What the button shows, drawn in the foreground colour it is given.
  final Widget Function(Color foreground) content;
  final EdgeInsetsGeometry padding;

  /// Whether its menu is open; null for a button without a menu.
  final bool? menuOpen;
  final FocusNode? focusNode;

  const _ToolbarButton({
    required this.tooltip,
    required this.onTap,
    required this.content,
    this.padding = EdgeInsets.zero,
    this.menuOpen,
    this.focusNode,
  });

  _ToolbarButton.icon(
    IconData icon, {
    required String tooltip,
    required VoidCallback onTap,
    bool? menuOpen,
    FocusNode? focusNode,
    double? weight,
  }) : this(
          tooltip: tooltip,
          onTap: onTap,
          menuOpen: menuOpen,
          focusNode: focusNode,
          content: (color) =>
              Icon(icon, size: 20, weight: weight, color: color),
        );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final highlighted = menuOpen ?? false;
    return Semantics(
      button: true,
      expanded: menuOpen,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color:
              highlighted ? colorScheme.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            focusNode: focusNode,
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              child: Padding(
                padding: padding,
                // Centred in the 44x44 minimum: icons centre themselves,
                // a letter (P, S) would otherwise sit at the top-left.
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  // onPrimaryContainer is the reader headings' colour in
                  // every theme: the strongest ink, so the icons stand out.
                  child: content(
                    highlighted
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Icons for the two-language layouts; the single-language ones show their
/// letter instead.
const _layoutIcons = {
  ReaderLayout.sideBySide: Icons.vertical_split,
  ReaderLayout.stacked: Icons.horizontal_split,
};

/// [layout]'s icon, or its letter (P, S) for a single-language layout.
class _LayoutGlyph extends StatelessWidget {
  final ReaderLayout layout;
  final Color color;

  const _LayoutGlyph({required this.layout, required this.color});

  @override
  Widget build(BuildContext context) {
    final icon = _layoutIcons[layout];
    if (icon != null) return Icon(icon, size: 20, color: color);
    return Text(
      layout.shortLabel,
      style: context.typography.layoutGlyph.copyWith(color: color),
    );
  }
}
