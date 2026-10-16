import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/theme/app_typography.dart';
import '../../models/reader_layout.dart';
import '../../providers/overlay_stack_provider.dart';
import 'reader_actions.dart';

// The two presenters of the reader's actions (see `reader_actions.dart`):
// the toolbar at the top of a sutta, and the menu behind the FAB once scrolled.

/// Width of the menus that open from the right-hand end — the toolbar's Share
/// menu and the scrolled menu — fixed so they line up with their button's
/// right edge.
const double _endMenuWidth = 280;

/// How long the mouse rests on a submenu row before it opens. Flutter's
/// default opens at once, so a click straight after would close it again.
const Duration _submenuHoverDelay = Duration(milliseconds: 300);

/// Mode 1: every reader action in one pill, at top-right while the user is at
/// the start of the unit. Layout and Share open menus.
class ReaderActionToolbar extends ConsumerWidget {
  final VoidCallback onSearchTap;
  final ReaderStepTarget? previous;
  final ReaderStepTarget? next;

  /// False while the toolbar is faded out; an open menu then closes.
  final bool visible;

  const ReaderActionToolbar({
    super.key,
    required this.onSearchTap,
    this.previous,
    this.next,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final actions = buildReaderActions(
      context,
      ref,
      onSearch: onSearchTap,
      previous: previous,
      next: next,
    );

    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(24),
      color: colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, action) in actions.indexed) ...[
              if (i > 0 && action.group != actions[i - 1].group)
                Container(
                  width: 1,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: colorScheme.outlineVariant,
                ),
              switch (action) {
                ReaderLayoutChoice choice =>
                  _LayoutMenuButton(choice: choice, visible: visible),
                ReaderCommand command => _ActionIconButton(
                    icon: command.icon,
                    tooltip: command.tooltip ?? command.label,
                    onTap: command.onSelected,
                  ),
                ReaderActionMenu menu =>
                  _ActionMenuButton(menu: menu, visible: visible),
              },
            ],
          ],
        ),
      ),
    );
  }
}

/// Mode 2: a FAB at bottom-right, shown once the user has scrolled past one
/// viewport. It opens one menu with the toolbar's groups, plus Go to beginning.
class ReaderActionMenuFab extends ConsumerWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onScrollTap;
  final ReaderStepTarget? previous;
  final ReaderStepTarget? next;

  /// False while the FAB is faded out; an open menu then closes.
  final bool visible;

  const ReaderActionMenuFab({
    super.key,
    required this.onSearchTap,
    required this.onScrollTap,
    this.previous,
    this.next,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final actions = buildReaderActions(
      context,
      ref,
      onSearch: onSearchTap,
      previous: previous,
      next: next,
      onScrollToBeginning: onScrollTap,
    );

    return _ReaderMenuAnchor(
      overlayId: 'reader-actions-menu',
      visible: visible,
      endAligned: true,
      gap: 12,
      menuChildren: [
        for (final (i, action) in actions.indexed) ...[
          if (i > 0 && action.group != actions[i - 1].group)
            const Divider(height: 9),
          switch (action) {
            ReaderLayoutChoice choice => _LayoutSubmenu(choice: choice),
            ReaderCommand command => _CommandMenuItem(command: command),
            ReaderActionMenu menu => SubmenuButton(
                hoverOpenDelay: _submenuHoverDelay,
                leadingIcon: _MenuIcon(
                  child: Icon(menu.icon, size: 20, color: colorScheme.primary),
                ),
                menuChildren: [
                  for (final item in menu.items)
                    _CommandMenuItem(command: item),
                ],
                child: _MenuLabel(menu.label),
              ),
          },
        ],
      ],
      builder: (context, controller, focusNode) {
        final isOpen = controller.isOpen;
        return Material(
          elevation: isOpen ? 4 : 2,
          borderRadius: BorderRadius.circular(16),
          color: colorScheme.surfaceContainer,
          child: InkWell(
            focusNode: focusNode,
            borderRadius: BorderRadius.circular(16),
            onTap: () => isOpen ? controller.close() : controller.open(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: AnimatedRotation(
                turns: isOpen ? 0.25 : 0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: Icon(
                  isOpen ? Icons.close : Icons.more_vert,
                  size: 24,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A [MenuAnchor] for the reader's actions. ESC closes it before anything
/// under it, and it closes when its presenter fades out.
///
/// [endAligned] lines the menu's right edge up with the button's, at
/// [_endMenuWidth]; otherwise the menu starts at the button's left edge.
/// The menu opens below the button, or above it where there is no room below.
class _ReaderMenuAnchor extends ConsumerStatefulWidget {
  final String overlayId;
  final bool visible;
  final bool endAligned;
  final double gap;
  final List<Widget> menuChildren;
  final Widget Function(
    BuildContext context,
    MenuController controller,
    FocusNode focusNode,
  ) builder;

  const _ReaderMenuAnchor({
    required this.overlayId,
    required this.visible,
    required this.menuChildren,
    required this.builder,
    this.endAligned = false,
    this.gap = 4,
  });

  @override
  ConsumerState<_ReaderMenuAnchor> createState() => _ReaderMenuAnchorState();
}

class _ReaderMenuAnchorState extends ConsumerState<_ReaderMenuAnchor> {
  final _controller = MenuController();
  // Lets the arrow keys move from the button into the menu.
  final _buttonFocusNode = FocusNode(debugLabel: 'ReaderMenuAnchor');

  // Captured in initState: dispose() can't use `ref`.
  late final OverlayStackNotifier _overlayStack;

  @override
  void initState() {
    super.initState();
    _overlayStack = ref.read(overlayStackProvider.notifier);
  }

  @override
  void didUpdateWidget(_ReaderMenuAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Closing updates the overlay stack, which can't change mid-build.
    if (oldWidget.visible && !widget.visible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.close();
      });
    }
  }

  @override
  void dispose() {
    // A menu closed because its button went away doesn't call onClose, and
    // Riverpod forbids changing a provider while the tree is torn down.
    final stack = _overlayStack;
    final id = widget.overlayId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (stack.mounted) stack.remove(id);
    });
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _controller,
      childFocusNode: _buttonFocusNode,
      alignmentOffset: widget.endAligned
          ? Offset(-_endMenuWidth, widget.gap)
          : Offset(0, widget.gap),
      style: widget.endAligned
          ? const MenuStyle(alignment: AlignmentDirectional.bottomEnd)
          : null,
      onOpen: () => _overlayStack.push(
        DismissibleOverlay(id: widget.overlayId, dismiss: _controller.close),
      ),
      onClose: () => _overlayStack.remove(widget.overlayId),
      // A sized box, not MenuStyle's sizes: compact density (desktop, web)
      // shrinks a menu's minimum width, which would undo the alignment.
      menuChildren: widget.endAligned
          ? [
              SizedBox(
                width: _endMenuWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widget.menuChildren,
                ),
              ),
            ]
          : widget.menuChildren,
      builder: (context, controller, _) =>
          widget.builder(context, controller, _buttonFocusNode),
    );
  }
}

/// The toolbar's Layout ▾: the current layout's glyph, opening the four.
class _LayoutMenuButton extends StatelessWidget {
  final ReaderLayoutChoice choice;
  final bool visible;

  const _LayoutMenuButton({required this.choice, required this.visible});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return _ReaderMenuAnchor(
      overlayId: 'reader-layout-menu',
      visible: visible,
      menuChildren: [
        for (final layout in ReaderLayout.values)
          _LayoutMenuItem(layout: layout, choice: choice),
      ],
      builder: (context, controller, focusNode) {
        final isOpen = controller.isOpen;
        final color =
            isOpen ? colorScheme.onSecondaryContainer : colorScheme.primary;
        return Tooltip(
          message: l10n.layout,
          child: Material(
            color: isOpen ? colorScheme.secondaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              focusNode: focusNode,
              borderRadius: BorderRadius.circular(22),
              onTap: () => isOpen ? controller.close() : controller.open(),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12, end: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LayoutGlyph(layout: choice.current, color: color),
                      const SizedBox(width: 2),
                      Icon(
                        isOpen ? Icons.expand_less : Icons.expand_more,
                        size: 16,
                        color: color,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The toolbar's button for an [ReaderActionMenu] (Share): its icon, opening
/// its items.
class _ActionMenuButton extends StatelessWidget {
  final ReaderActionMenu menu;
  final bool visible;

  const _ActionMenuButton({required this.menu, required this.visible});

  @override
  Widget build(BuildContext context) {
    return _ReaderMenuAnchor(
      overlayId: 'reader-share-menu',
      visible: visible,
      endAligned: true,
      menuChildren: [
        for (final item in menu.items) _CommandMenuItem(command: item),
      ],
      builder: (context, controller, focusNode) => _ActionIconButton(
        icon: menu.icon,
        tooltip: menu.label,
        highlighted: controller.isOpen,
        focusNode: focusNode,
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

/// The scrolled menu's Layout ›, naming the current layout.
class _LayoutSubmenu extends StatelessWidget {
  final ReaderLayoutChoice choice;

  const _LayoutSubmenu({required this.choice});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final typography = context.typography;
    return SubmenuButton(
      hoverOpenDelay: _submenuHoverDelay,
      leadingIcon: _MenuIcon(
        child: _LayoutGlyph(layout: choice.current, color: colorScheme.primary),
      ),
      menuChildren: [
        for (final layout in ReaderLayout.values)
          _LayoutMenuItem(layout: layout, choice: choice),
      ],
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context).layout,
              style: typography.listRowTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _layoutLabel(context, choice.current),
            style: typography.menuSectionLabel,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

/// One layout in a layout menu, with a check on the current one.
class _LayoutMenuItem extends StatelessWidget {
  final ReaderLayout layout;
  final ReaderLayoutChoice choice;

  const _LayoutMenuItem({required this.layout, required this.choice});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rowStyle = context.typography.listRowTitle;
    final isSelected = layout == choice.current;

    return MenuItemButton(
      onPressed: () => choice.onChanged(layout),
      style: MenuItemButton.styleFrom(
        backgroundColor:
            isSelected ? colorScheme.surfaceContainerHighest : null,
      ),
      leadingIcon: _MenuIcon(
        child: _LayoutGlyph(layout: layout, color: colorScheme.primary),
      ),
      trailingIcon: isSelected
          ? Icon(Icons.check, size: 18, color: colorScheme.primary)
          : null,
      child: Semantics(
        selected: isSelected,
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

/// A [ReaderCommand] as a menu row, with its caption above the label if any.
class _CommandMenuItem extends StatelessWidget {
  final ReaderCommand command;

  const _CommandMenuItem({required this.command});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final caption = command.caption;

    return MenuItemButton(
      onPressed: command.onSelected,
      leadingIcon: _MenuIcon(
        child: Icon(command.icon, size: 20, color: colorScheme.primary),
      ),
      child: caption == null
          ? _MenuLabel(command.label)
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(caption, style: context.typography.menuSectionLabel),
                _MenuLabel(command.label),
              ],
            ),
    );
  }
}

/// A menu row's text, on one line.
class _MenuLabel extends StatelessWidget {
  final String text;

  const _MenuLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.typography.listRowTitle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
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

/// Icon button inside the toolbar. No background of its own — the pill
/// provides the surface — except [highlighted] while its menu is open.
/// ConstrainedBox keeps the 44x44 minimum touch target.
class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool highlighted;
  final FocusNode? focusNode;

  const _ActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.highlighted = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
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
            constraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            child: Icon(
              icon,
              size: 20,
              color: highlighted
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.primary,
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
        fontSize: 14,
      ),
    );
  }
}
