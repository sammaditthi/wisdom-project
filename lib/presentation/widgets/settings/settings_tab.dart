import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/constants/feature_flags.dart';
import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/utils/platform_utils.dart';

/// The pages of the app Settings dialog, in sidebar order.
///
/// One enum drives the sidebar, the narrow-window tab bar and the page switch,
/// so adding a tab is an entry here plus a case in [SettingsDialog]'s page
/// switch — which won't compile until it exists.
enum SettingsTab {
  general(Icons.settings_outlined),
  // Sun and moon, not a clock: the tab's "Time" is kāla.
  vinayaTimes(Symbols.routine_sharp),
  shortcuts(Icons.keyboard_outlined),
  anumodana(Symbols.folded_hands_sharp);

  const SettingsTab(this.icon);

  final IconData icon;

  String label(AppLocalizations l10n) => switch (this) {
    SettingsTab.general => l10n.settingsGeneral,
    SettingsTab.vinayaTimes => l10n.settingsVinayaTimes,
    SettingsTab.shortcuts => l10n.settingsKeyboardShortcuts,
    SettingsTab.anumodana => l10n.settingsAnumodana,
  };

  /// The tabs [platform] shows: Keyboard shortcuts only on desktop, and
  /// the Time tab only with Home, whose Today card it sets up.
  static List<SettingsTab> available(TargetPlatform platform) => [
    for (final tab in values)
      if (switch (tab) {
        shortcuts => isDesktopPlatform(platform),
        vinayaTimes => kEnableHome,
        general || anumodana => true,
      })
        tab,
  ];
}
