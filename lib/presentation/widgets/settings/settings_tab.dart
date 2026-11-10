import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../keyboard/keyboard_bindings.dart';

/// The pages of the app Settings dialog, in sidebar order.
///
/// One enum drives the sidebar, the narrow-window tab bar and the page switch,
/// so adding a tab is an entry here plus a case in [SettingsDialog]'s page
/// switch — which won't compile until it exists.
enum SettingsTab {
  general(Icons.settings_outlined),
  shortcuts(Icons.keyboard_outlined),
  anumodana(Symbols.folded_hands_sharp);

  const SettingsTab(this.icon);

  final IconData icon;

  String label(AppLocalizations l10n) => switch (this) {
        SettingsTab.general => l10n.settingsGeneral,
        SettingsTab.shortcuts => l10n.settingsKeyboardShortcuts,
        SettingsTab.anumodana => l10n.settingsAnumodana,
      };

  /// The tabs [platform] shows: Keyboard shortcuts only on desktop.
  static List<SettingsTab> available(TargetPlatform platform) => [
        for (final tab in values)
          if (tab != shortcuts || isDesktopPlatform(platform)) tab,
      ];
}
