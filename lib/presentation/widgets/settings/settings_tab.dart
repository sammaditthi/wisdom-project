import 'package:flutter/material.dart';

import '../../../core/localization/l10n/app_localizations.dart';

/// The pages of the app Settings dialog, in sidebar order.
///
/// One enum drives the sidebar, the narrow-window tab bar and the page switch,
/// so adding a tab is an entry here plus a case in [SettingsDialog]'s page
/// switch — which won't compile until it exists.
enum SettingsTab {
  general(Icons.settings_outlined),
  anumodana(Icons.volunteer_activism_outlined);

  const SettingsTab(this.icon);

  final IconData icon;

  String label(AppLocalizations l10n) => switch (this) {
        SettingsTab.general => l10n.settingsGeneral,
        SettingsTab.anumodana => l10n.settingsAnumodana,
      };
}
