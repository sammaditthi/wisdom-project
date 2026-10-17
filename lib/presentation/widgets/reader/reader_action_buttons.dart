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
          Icons.search,
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
    final current = ref.watch(activeReaderLayoutProvider);

    return DismissibleMenuAnchor(
      overlayId: 'reader-layout-menu',
      visible: visible,
      menuChildren: [
        for (final layout in ReaderLayout.values)
          _LayoutMenuItem(
            layout: layout,
            isSelected: layout == current,
            onSelected: () => ref.read(updateActiveTabLayoutProvider)(layout),
          ),
      ],
      builder: (context, controller, focusNode) {
        final isOpen = controller.isOpen;
        return _ToolbarButton(
          tooltip: l10n.currentLayout(_layoutLabel(context, current)),
          onTap: controller.toggle,
          highlighted: isOpen,
          expanded: isOpen,
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

    return DismissibleMenuAnchor(
      overlayId: 'reader-share-menu',
      visible: visible,
      endAlignedWidth: _endMenuWidth,
      menuChildren: [
        _MenuRow(
          icon: Icons.content_copy,
          label: l10n.copyLink,
          onSelected: () => copyActiveTabLink(context, ref),
        ),
        if (kIsWeb)
          _MenuRow(
            icon: Icons.open_in_new,
            label: l10n.openAsWebPage,
            onSelected: () => openAsWebPage(context, ref),
          ),
      ],
      builder: (context, controller, focusNode) => _ToolbarButton.icon(
        Icons.adaptive.share,
        tooltip: l10n.share,
        onTap: controller.toggle,
        highlighted: controller.isOpen,
        expanded: controller.isOpen,
        focusNode: focusNode,
      ),
    );
  }
}

/// One layout in the Layout ▾ menu, with a check on the current one.
class _LayoutMenuItem extends StatelessWidget {
  final ReaderLayout layout;
  final bool isSelected;
  final VoidCallback onSelected;

  const _LayoutMenuItem({
    required this.layout,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rowStyle = context.typography.listRowTitle;

    return MenuItemButton(
      onPressed: onSelected,
      style: MenuItemButton.styleFrom(
        backgroundColor:
            isSelected ? AppMenuTheme.selectedRowColor(colorScheme) : null,
      ),
      leadingIcon: _MenuIcon(
        child: _LayoutGlyph(layout: layout, color: colorScheme.primary),
      ),
      trailingIcon: isSelected
          ? Icon(Icons.check, size: 18, color: colorScheme.primary)
          : null,
      // Read out as one choice of four, like a radio group.
      child: Semantics(
        checked: isSelected,
        inMutuallyExclusiveGroup: true,
        child: Text(
          _layoutLabel(context, layout),
          style: isSelected
              ? rowStyle.copyWith(fontWeight: FontWeight.w600)
              : rowStyle,
        ),
      ),
    );
  }
}

/// A menu row: icon and a one-line label.
class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onSelected;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MenuItemButton(
      onPressed: onSelected,
      leadingIcon: _MenuIcon(
        child: Icon(icon, size: 20, color: colorScheme.primary),
      ),
      child: Text(
        label,
        style: context.typography.listRowTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Lines up menu-row glyphs of different widths (icons, "P", "S").
class _MenuIcon extends StatelessWidget {
  final Widget child;

  const _MenuIcon({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 24, child: Center(child: child));
  }
}

/// A button inside the toolbar. No background of its own — the pill provides
/// the surface — except [highlighted] while its menu is open. The 44x44
/// minimum keeps the touch target.
class _ToolbarButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onTap;

  /// What the button shows, drawn in the foreground colour it is given.
  final Widget Function(Color foreground) content;
  final EdgeInsetsGeometry padding;
  final bool highlighted;

  /// Whether its menu is open; null for a button without a menu.
  final bool? expanded;
  final FocusNode? focusNode;

  const _ToolbarButton({
    required this.tooltip,
    required this.onTap,
    required this.content,
    this.padding = EdgeInsets.zero,
    this.highlighted = false,
    this.expanded,
    this.focusNode,
  });

  _ToolbarButton.icon(
    IconData icon, {
    required String tooltip,
    required VoidCallback onTap,
    bool highlighted = false,
    bool? expanded,
    FocusNode? focusNode,
  }) : this(
          tooltip: tooltip,
          onTap: onTap,
          highlighted: highlighted,
          expanded: expanded,
          focusNode: focusNode,
          content: (color) => Icon(icon, size: 20, color: color),
        );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      expanded: expanded,
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
      style: context.typography.segmentedButtonLabel.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
        // Fixed like the 20px icons it sits among, which
        // don't follow the font-size setting either.
        fontSize: 14,
      ),
    );
  }
}
