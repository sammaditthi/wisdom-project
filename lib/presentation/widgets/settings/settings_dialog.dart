import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../providers/overlay_stack_provider.dart';
import 'anumodana_page.dart';
import 'general_settings_page.dart';
import 'settings_row.dart' show settingsGutter;
import 'settings_tab.dart';

/// The app's Settings dialog, opened from the gear at the foot of the
/// navigation rail.
///
/// Holds what you set once and that applies everywhere. The settings you
/// change while reading live in the reader's own menu.
///
/// Two shapes, one set of pages:
/// - at [ResponsiveUtils.mobileBreakpoint] and above, a dialog with a sidebar;
/// - below it, a full-screen dialog with a tab bar. There is no phone entry
///   point yet (the bottom bar gets one separately), so this is what a desktop
///   window dragged narrow with the dialog open falls back to.
class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key, this.initialTab = SettingsTab.general});

  final SettingsTab initialTab;

  /// How wide and tall the dialog wants to be before the window clamps it.
  static const double _preferredWidth = 760;
  static const double _preferredHeight = 640;
  static const double _sidebarWidth = 232;

  /// Show the dialog.
  ///
  /// Registers on [overlayStackProvider] so the global ESC shortcut treats it
  /// as the topmost dismissible overlay — the same reason
  /// `RefineSearchDialog.show` does. The navigator is captured at show-time so
  /// the dismiss callback needs no BuildContext of its own, and the
  /// try/finally removes the entry however the dialog closed (ESC, barrier
  /// tap, system back, the close button).
  static Future<void> show(
    BuildContext context, {
    SettingsTab initial = SettingsTab.general,
  }) async {
    final overlayStack = ProviderScope.containerOf(context, listen: false)
        .read(overlayStackProvider.notifier);
    final navigator = Navigator.of(context, rootNavigator: true);
    overlayStack.push(DismissibleOverlay(
      id: 'settings-dialog',
      dismiss: () {
        if (navigator.canPop()) navigator.pop();
      },
    ));
    try {
      await showDialog<void>(
        context: context,
        builder: (context) => SettingsDialog(initialTab: initial),
      );
    } finally {
      overlayStack.remove('settings-dialog');
    }
  }

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog>
    with SingleTickerProviderStateMixin {
  /// Drives the narrow layout's tab bar, and is the selected tab in both
  /// layouts — so dragging the window across the breakpoint keeps your place.
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: SettingsTab.values.length,
      initialIndex: widget.initialTab.index,
      vsync: this,
    );
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  SettingsTab get _selected => SettingsTab.values[_tabs.index];

  void _select(SettingsTab tab) => _tabs.index = tab.index;

  void _close() => Navigator.of(context).pop();

  Widget _pageFor(SettingsTab tab) => switch (tab) {
        SettingsTab.general => const GeneralSettingsPage(),
        SettingsTab.anumodana => const AnumodanaPage(),
      };

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.isMobile(context) ? _fullScreen() : _withSidebar();
  }

  /// Tablet and desktop: sidebar on the left, page on the right.
  Widget _withSidebar() {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final screen = MediaQuery.sizeOf(context);
    // Clamped rather than fixed: between the breakpoint and ~860px the
    // preferred width plus the dialog's own inset does not fit. The insets
    // are Dialog's defaults, counted on both sides: 40 each horizontally,
    // 24 each vertically.
    final width = math.min(SettingsDialog._preferredWidth, screen.width - 80);
    final height =
        math.min(SettingsDialog._preferredHeight, screen.height - 48);

    return Dialog(
      backgroundColor: colors.surfaceContainerLowest,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: width,
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Sidebar(selected: _selected, onSelected: _select),
            Expanded(
              child: Column(
                children: [
                  _PageHeader(
                    title: _selected.label(l10n),
                    onClose: _close,
                  ),
                  Expanded(child: _pageFor(_selected)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Narrow windows: full screen, tabs across the top.
  Widget _fullScreen() {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Dialog.fullscreen(
      // Set on both: a Scaffold defaults to scaffoldBackgroundColor and an
      // AppBar to `surface`, so without this the narrow layout is the only
      // place the dialog is not `surfaceContainerLowest`.
      backgroundColor: colors.surfaceContainerLowest,
      child: Scaffold(
        backgroundColor: colors.surfaceContainerLowest,
        appBar: AppBar(
          backgroundColor: colors.surfaceContainerLowest,
          title: Text(l10n.settings),
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: l10n.close,
            onPressed: _close,
          ),
          bottom: TabBar(
            controller: _tabs,
            tabs: [
              for (final tab in SettingsTab.values)
                Tab(icon: Icon(tab.icon), text: tab.label(l10n)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabs,
          children: [
            for (final tab in SettingsTab.values) _pageFor(tab),
          ],
        ),
      ),
    );
  }
}

/// The dialog's left-hand tab list.
class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selected, required this.onSelected});

  final SettingsTab selected;
  final ValueChanged<SettingsTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    // A Material, not a coloured Container: ListTile paints its selected fill
    // and its ink on the nearest Material, so a ColoredBox in between would
    // hide both.
    return Material(
      color: colors.surfaceContainerLow,
      child: Container(
        width: SettingsDialog._sidebarWidth,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Text(
                l10n.settings,
                style: context.typography.menuSectionLabel,
              ),
            ),
            for (final tab in SettingsTab.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: ListTile(
                  leading: Icon(tab.icon, size: 20),
                  title: Text(
                    tab.label(l10n),
                    style: context.typography.resultTitle.copyWith(
                      fontWeight:
                          tab == selected ? FontWeight.w600 : FontWeight.w500,
                      color: tab == selected
                          ? colors.onSecondaryContainer
                          : colors.onSurface,
                    ),
                  ),
                  selected: tab == selected,
                  selectedColor: colors.onSecondaryContainer,
                  selectedTileColor: colors.secondaryContainer,
                  minTileHeight: 44,
                  horizontalTitleGap: 12,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: const StadiumBorder(),
                  onTap: () => onSelected(tab),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The page title and the close button, above whichever page is showing.
class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Left gutter matches the page's, so the title sits over its content.
      padding: const EdgeInsets.fromLTRB(settingsGutter, 14, 8, 2),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: context.typography.dialogTitle),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: AppLocalizations.of(context).close,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
