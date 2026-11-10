import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../core/localization/l10n/app_localizations.dart';
import '../widgets/settings/settings_tab.dart';
import 'shortcut_intents.dart';

/// The single list of the app's keyboard shortcuts.
///
/// `AppShortcuts` builds its key map from it and the Settings tab builds its
/// rows from it, so no key combo is spelled anywhere else. How the keys were
/// chosen: `docs/todo/reader/keyboard-shortcuts-sheet.md`.

/// Sections of the Settings tab, in the order they show.
enum ShortcutGroup { search, readerTabs, layout, reading, everywhere }

/// A key and its modifiers. [primary] is ⌘ on Apple platforms, Ctrl
/// elsewhere, so a shortcut is written once for every platform.
@immutable
class ShortcutKeys {
  const ShortcutKeys(
    this.key, {
    this.primary = false,
    this.alt = false,
    this.shift = false,
  });

  final LogicalKeyboardKey key;
  final bool primary;
  final bool alt;
  final bool shift;

  /// The activator for [platform]: only its own primary modifier.
  SingleActivator activatorFor(TargetPlatform platform) {
    final command = usesCommandKey(platform);
    return SingleActivator(
      key,
      control: primary && !command,
      meta: primary && command,
      alt: alt,
      shift: shift,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ShortcutKeys &&
      other.key == key &&
      other.primary == primary &&
      other.alt == alt &&
      other.shift == shift;

  @override
  int get hashCode => Object.hash(key, primary, alt, shift);
}

/// One shortcut: one row in the Settings tab.
@immutable
class AppShortcut {
  const AppShortcut({
    required this.keys,
    required this.intent,
    this.alsoKeys = const [],
    this.group,
    this.label,
    this.desktopOnly = true,
  }) : assert(group == null || label != null);

  /// The combo the Settings tab shows.
  final ShortcutKeys keys;

  /// Also bound, never shown (e.g. the keypad's +).
  final List<ShortcutKeys> alsoKeys;

  final Intent intent;

  /// Null: bound but not listed.
  final ShortcutGroup? group;

  final String Function(AppLocalizations l10n)? label;

  /// Off desktop the shortcut is not registered.
  final bool desktopOnly;
}

/// macOS, Windows and Linux — as an app or in a browser. Flutter web reports
/// an iPad as iOS, so phones and tablets are never desktop.
bool isDesktopPlatform(TargetPlatform platform) => switch (platform) {
      TargetPlatform.macOS || TargetPlatform.windows || TargetPlatform.linux =>
        true,
      _ => false,
    };

/// Apple platforms use ⌘ where the others use Ctrl.
bool usesCommandKey(TargetPlatform platform) =>
    platform == TargetPlatform.macOS || platform == TargetPlatform.iOS;

/// Every shortcut, in Settings-tab order within each group.
final List<AppShortcut> appShortcuts = [
  // ─── Search ────────────────────────────────────────────────────────────
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.keyF, primary: true),
    intent: const OpenInPageSearchIntent(),
    group: ShortcutGroup.search,
    label: (l10n) => l10n.findInPage,
    desktopOnly: false,
  ),
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.keyF, primary: true, shift: true),
    intent: const OpenMainSearchIntent(),
    group: ShortcutGroup.search,
    label: (l10n) => l10n.shortcutSearchTipitaka,
    desktopOnly: false,
  ),

  // ─── Reader tabs ───────────────────────────────────────────────────────
  // Not plain ⌘W: browsers keep it (close their tab) and the page never sees
  // the keydown. ⇧⌘W closes the browser window. Adding ⌥ is the closest
  // combo free on every platform.
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.keyW, primary: true, alt: true),
    intent: const CloseActiveTabIntent(),
    group: ShortcutGroup.readerTabs,
    label: (l10n) => l10n.shortcutCloseTab,
    desktopOnly: false,
  ),

  // ─── Reading ───────────────────────────────────────────────────────────
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.keyB, primary: true),
    intent: const ToggleNavigatorIntent(),
    group: ShortcutGroup.reading,
    label: (l10n) => l10n.shortcutToggleNavigator,
  ),
  // The browser's own zoom keys: same meaning, so the reader takes them.
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.equal, primary: true),
    alsoKeys: const [
      ShortcutKeys(LogicalKeyboardKey.equal, primary: true, shift: true),
      ShortcutKeys(LogicalKeyboardKey.numpadAdd, primary: true),
    ],
    intent: const TextSizeIntent(TextSizeChange.bigger),
    group: ShortcutGroup.reading,
    label: (l10n) => l10n.shortcutTextBigger,
  ),
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.minus, primary: true),
    alsoKeys: const [
      ShortcutKeys(LogicalKeyboardKey.numpadSubtract, primary: true),
    ],
    intent: const TextSizeIntent(TextSizeChange.smaller),
    group: ShortcutGroup.reading,
    label: (l10n) => l10n.shortcutTextSmaller,
  ),
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.digit0, primary: true),
    alsoKeys: const [ShortcutKeys(LogicalKeyboardKey.numpad0, primary: true)],
    intent: const TextSizeIntent(TextSizeChange.normal),
    group: ShortcutGroup.reading,
    label: (l10n) => l10n.shortcutTextNormal,
  ),

  // ─── Everywhere ────────────────────────────────────────────────────────
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.comma, primary: true),
    intent: const OpenSettingsIntent(SettingsTab.general),
    group: ShortcutGroup.everywhere,
    label: (l10n) => l10n.shortcutOpenSettings,
  ),
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.slash, primary: true),
    intent: const OpenSettingsIntent(SettingsTab.shortcuts),
    group: ShortcutGroup.everywhere,
    label: (l10n) => l10n.shortcutOpenShortcutList,
  ),
  // The action defers to the focused widget's own copy first, then falls
  // back to the last reader selection — which rescues ⌘C on web.
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.keyC, primary: true),
    intent: const SmartCopyIntent(),
    group: ShortcutGroup.everywhere,
    label: (l10n) => l10n.shortcutCopy,
    desktopOnly: false,
  ),
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.escape),
    intent: const DismissTopOverlayIntent(),
    group: ShortcutGroup.everywhere,
    label: (l10n) => l10n.shortcutCloseOverlay,
    desktopOnly: false,
  ),
];

/// The shortcuts registered on [platform].
List<AppShortcut> shortcutsFor(TargetPlatform platform) {
  final desktop = isDesktopPlatform(platform);
  return [
    for (final s in appShortcuts)
      if (desktop || !s.desktopOnly) s,
  ];
}

/// The `Shortcuts` map for [platform].
Map<ShortcutActivator, Intent> shortcutMap(TargetPlatform platform) {
  return <ShortcutActivator, Intent>{
    for (final s in shortcutsFor(platform))
      for (final keys in [s.keys, ...s.alsoKeys])
        keys.activatorFor(platform): s.intent,
  };
}
