import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/theme/app_menu_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../models/reader_layout.dart';
import '../../providers/parallel_text_provider.dart';
import '../../providers/tab_provider.dart'
    show activeReaderLayoutProvider, updateActiveTabLayoutProvider;
import '../common/dismissible_menu_anchor.dart';
import 'reader_link_actions.dart';

/// Where a step button goes, named by the sutta it steps to.
typedef ReaderStepTarget = ({String name, VoidCallback onTap});

/// Width of the Share menu, fixed so it lines up with its button's right
/// edge.
const double _endMenuWidth = 280;

/// Every reader action in one pill at the top-right. Layout and Share open
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
          Symbols.find_in_page_sharp,
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
      [_ShareMenuButton(visible: visible)],
    ].where((group) => group.isNotEmpty);

    return Material(
      elevation: 1,
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
    final primary = Theme.of(context).colorScheme.primary;
    final current = ref.watch(activeReaderLayoutProvider);

    return DismissibleMenuAnchor(
      overlayId: 'reader-layout-menu',
      visible: visible,
      menuChildren: [
        for (final layout in ReaderLayout.values)
          _MenuRow(
            icon: _LayoutGlyph(layout: layout, color: primary),
            label: _layoutLabel(context, layout),
            selected: layout == current,
            onSelected: () => ref.read(updateActiveTabLayoutProvider)(layout),
          ),
      ],
      builder: (context, controller, focusNode) {
        final isOpen = controller.isOpen;
        return _ToolbarButton(
          tooltip: l10n.currentLayout(_layoutLabel(context, current)),
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

/// Share ▾: Copy link and, on the web, Open as web page.
class _ShareMenuButton extends ConsumerWidget {
  final bool visible;

  const _ShareMenuButton({required this.visible});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return DismissibleMenuAnchor(
      overlayId: 'reader-share-menu',
      visible: visible,
      endAlignedWidth: _endMenuWidth,
      menuChildren: [
        _MenuRow(
          icon: Icon(Icons.content_copy, size: 20, color: primary),
          label: l10n.copyLink,
          onSelected: () => copyActiveTabLink(context, ref),
        ),
        if (kIsWeb)
          _MenuRow(
            icon: Icon(Icons.open_in_new, size: 20, color: primary),
            label: l10n.openAsWebPage,
            onSelected: () => openAsWebPage(context, ref),
          ),
      ],
      builder: (context, controller, focusNode) => _ToolbarButton.icon(
        Icons.adaptive.share,
        tooltip: l10n.share,
        onTap: controller.toggle,
        menuOpen: controller.isOpen,
        focusNode: focusNode,
      ),
    );
  }
}

/// A menu row: a glyph and a one-line label. With [selected] set, the row is
/// one choice of a set, checked when true.
class _MenuRow extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onSelected;
  final bool? selected;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onSelected,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rowStyle = context.typography.listRowTitle;
    final isSelected = selected ?? false;

    return MenuItemButton(
      onPressed: onSelected,
      style: isSelected
          ? MenuItemButton.styleFrom(
              backgroundColor: AppMenuTheme.selectedRowColor(colorScheme),
            )
          : null,
      // Lines up glyphs of different widths (icons, "P", "S").
      leadingIcon: SizedBox(width: 24, child: Center(child: icon)),
      trailingIcon: isSelected
          ? Icon(Icons.check, size: 18, color: colorScheme.primary)
          : null,
      // A choice is read out like a radio button.
      child: Semantics(
        checked: selected,
        inMutuallyExclusiveGroup: selected == null ? null : true,
        child: Text(
          label,
          style: isSelected
              ? rowStyle.copyWith(fontWeight: FontWeight.w600)
              : rowStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
                  child: content(
                    highlighted
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.primary,
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

/// The localized name of [layout].
String _layoutLabel(BuildContext context, ReaderLayout layout) {
  final l10n = AppLocalizations.of(context);
  return switch (layout) {
    ReaderLayout.paliOnly => l10n.layoutPaliOnly,
    ReaderLayout.sideBySide => l10n.layoutSideBySide,
    ReaderLayout.stacked => l10n.layoutStacked,
    ReaderLayout.sinhalaOnly => l10n.layoutSinhalaOnly,
  };
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
