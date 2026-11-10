import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../core/localization/l10n/app_localizations.dart';
import '../models/reader_layout.dart';
import '../providers/reader_unit_provider.dart' show ReaderStep;
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
  // Same label: ↓ and Tab share one row. Before the scroll keys, so in the
  // search box ↓ means "to the results", not "scroll".
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.arrowDown),
    intent: const MoveIntoSearchResultsIntent(),
    group: ShortcutGroup.search,
    label: (l10n) => l10n.shortcutSearchToResults,
  ),
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.tab),
    intent: const MoveIntoSearchResultsIntent(),
    group: ShortcutGroup.search,
    label: (l10n) => l10n.shortcutSearchToResults,
  ),
  // Moves inside the results; not listed.
  const AppShortcut(
    keys: ShortcutKeys(LogicalKeyboardKey.arrowDown),
    intent: NextSearchResultIntent(),
  ),
  const AppShortcut(
    keys: ShortcutKeys(LogicalKeyboardKey.arrowUp),
    intent: PreviousSearchResultIntent(),
  ),
  const AppShortcut(
    keys: ShortcutKeys(LogicalKeyboardKey.tab, shift: true),
    intent: PreviousSearchResultIntent(),
  ),

  // ─── Reader tabs ───────────────────────────────────────────────────────
  // ⌥⌘ acts on the reader tab. Not ⌥⌘← →: Chrome keeps those for its own
  // tabs and the page never sees them. ⇧⌘[ ] is the browser's tab switch.
  AppShortcut(
    keys: const ShortcutKeys(
      LogicalKeyboardKey.bracketRight,
      primary: true,
      alt: true,
    ),
    intent: const SwitchTabIntent(1),
    group: ShortcutGroup.readerTabs,
    label: (l10n) => l10n.shortcutNextTab,
  ),
  AppShortcut(
    keys: const ShortcutKeys(
      LogicalKeyboardKey.bracketLeft,
      primary: true,
      alt: true,
    ),
    intent: const SwitchTabIntent(-1),
    group: ShortcutGroup.readerTabs,
    label: (l10n) => l10n.shortcutPreviousTab,
  ),
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

  // ─── Layout ────────────────────────────────────────────────────────────
  // ⌥⌘1–4 in the toolbar's left-to-right order. Not ⌘1–4: the browser's
  // "go to tab 1–4".
  for (final (i, layout) in ReaderLayout.values.indexed)
    AppShortcut(
      keys: ShortcutKeys(_digits[i], primary: true, alt: true),
      intent: SetLayoutIntent(layout),
      group: ShortcutGroup.layout,
      label: layout.label,
    ),

  // ─── Reading ───────────────────────────────────────────────────────────
  // The , and . keys, marked < and >: they point the way the toolbar's ⏮ ⏭
  // do, and answer with or without ⇧. Not ⌥⌘← →, which Chrome keeps.
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.comma, primary: true, alt: true),
    alsoKeys: const [
      ShortcutKeys(
        LogicalKeyboardKey.comma,
        primary: true,
        alt: true,
        shift: true,
      ),
    ],
    intent: const StepSuttaIntent(ReaderStep.previous),
    group: ShortcutGroup.reading,
    label: (l10n) => l10n.shortcutPreviousSutta,
  ),
  AppShortcut(
    keys:
        const ShortcutKeys(LogicalKeyboardKey.period, primary: true, alt: true),
    alsoKeys: const [
      ShortcutKeys(
        LogicalKeyboardKey.period,
        primary: true,
        alt: true,
        shift: true,
      ),
    ],
    intent: const StepSuttaIntent(ReaderStep.next),
    group: ShortcutGroup.reading,
    label: (l10n) => l10n.shortcutNextSutta,
  ),
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
  // Same label: ↑ and ↓ share one row in the Settings tab.
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.arrowUp),
    intent: const ScrollReaderIntent(AxisDirection.up, ScrollIncrementType.line),
    group: ShortcutGroup.reading,
    label: (l10n) => l10n.shortcutScroll,
  ),
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.arrowDown),
    intent:
        const ScrollReaderIntent(AxisDirection.down, ScrollIncrementType.line),
    group: ShortcutGroup.reading,
    label: (l10n) => l10n.shortcutScroll,
  ),
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.pageUp),
    intent: const ScrollReaderIntent(AxisDirection.up, ScrollIncrementType.page),
    group: ShortcutGroup.reading,
    label: (l10n) => l10n.shortcutScrollPage,
  ),
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.pageDown),
    intent:
        const ScrollReaderIntent(AxisDirection.down, ScrollIncrementType.page),
    group: ShortcutGroup.reading,
    label: (l10n) => l10n.shortcutScrollPage,
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

const _digits = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
];

/// The shortcuts registered on [platform].
List<AppShortcut> shortcutsFor(TargetPlatform platform) {
  final desktop = isDesktopPlatform(platform);
  return [
    for (final s in appShortcuts)
      if (desktop || !s.desktopOnly) s,
  ];
}

/// The `Shortcuts` map for [platform]. A key bound by several entries tries
/// them in list order: the first one enabled acts.
///
/// Grouped by [ShortcutKeys], since `SingleActivator` has no `==`: two equal
/// activators would be two map keys, and only the first would ever fire.
Map<ShortcutActivator, Intent> shortcutMap(TargetPlatform platform) {
  final intentsByKeys = <ShortcutKeys, List<Intent>>{};
  for (final s in shortcutsFor(platform)) {
    for (final keys in [s.keys, ...s.alsoKeys]) {
      (intentsByKeys[keys] ??= []).add(s.intent);
    }
  }
  return <ShortcutActivator, Intent>{
    for (final MapEntry(key: keys, value: intents) in intentsByKeys.entries)
      keys.activatorFor(platform): intents.length == 1
          ? intents.single
          : PrioritizedIntents(orderedIntents: intents),
  };
}
