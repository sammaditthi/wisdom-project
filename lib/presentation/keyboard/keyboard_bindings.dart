import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../core/localization/l10n/app_localizations.dart';
import '../../core/utils/platform_utils.dart';
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
enum ShortcutGroup { search, reader, layout, app }

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
    this.keyCap,
    this.desktopOnly = true,
  }) : assert(group == null || label != null);

  /// The combo the Settings tab shows.
  final ShortcutKeys keys;

  /// What the Settings tab prints for the key, when not the key's own label.
  final String? keyCap;

  /// Also bound, never shown (e.g. the keypad's +).
  final List<ShortcutKeys> alsoKeys;

  final Intent intent;

  /// Null: bound but not listed.
  final ShortcutGroup? group;

  final String Function(AppLocalizations l10n)? label;

  /// Off desktop the shortcut is not registered.
  final bool desktopOnly;
}

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
    keys:
        const ShortcutKeys(LogicalKeyboardKey.keyF, primary: true, shift: true),
    intent: const OpenMainSearchIntent(),
    group: ShortcutGroup.search,
    // The search box's own word: it searches the commentaries too.
    label: (l10n) => l10n.searchHint,
    desktopOnly: false,
  ),
  // Before the scroll keys, so in the search box ↓ means "to the results"
  // (or the recent searches, while the box is empty), not "scroll".
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.arrowDown),
    intent: const MoveIntoSearchResultsIntent(SearchPanelStop.firstResult),
    group: ShortcutGroup.search,
    label: (l10n) => l10n.shortcutGoToResults,
  ),
  // Tab works as Tab, so it isn't listed. The panel and the recent searches
  // are drawn over the reader, so plain Tab from the box would go on to the
  // app bar and the reader behind; these take it into their first stop and
  // back.
  const AppShortcut(
    keys: ShortcutKeys(LogicalKeyboardKey.tab),
    intent: MoveIntoSearchResultsIntent(SearchPanelStop.firstControl),
  ),
  const AppShortcut(
    keys: ShortcutKeys(LogicalKeyboardKey.tab, shift: true),
    intent: BackToSearchBoxIntent(),
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

  // ─── Reader ────────────────────────────────────────────────────────────
  // Previous before next, as the toolbar's ⏮ ⏭ and the keys [ ] and < >.
  // ⌥⌘ acts on the reader tab. Not ⌥⌘← →: Chrome keeps those for its own
  // tabs and the page never sees them. ⇧⌘[ ] is the browser's tab switch.
  AppShortcut(
    keys: const ShortcutKeys(
      LogicalKeyboardKey.bracketLeft,
      primary: true,
      alt: true,
    ),
    intent: const SwitchTabIntent(-1),
    group: ShortcutGroup.reader,
    label: (l10n) => l10n.shortcutPreviousTab,
  ),
  AppShortcut(
    keys: const ShortcutKeys(
      LogicalKeyboardKey.bracketRight,
      primary: true,
      alt: true,
    ),
    intent: const SwitchTabIntent(1),
    group: ShortcutGroup.reader,
    label: (l10n) => l10n.shortcutNextTab,
  ),
  // Not plain ⌘W: browsers keep it (close their tab) and the page never sees
  // the keydown. ⇧⌘W closes the browser window. Adding ⌥ is the closest
  // combo free on every platform.
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.keyW, primary: true, alt: true),
    intent: const CloseActiveTabIntent(),
    group: ShortcutGroup.reader,
    label: (l10n) => l10n.shortcutCloseTab,
    desktopOnly: false,
  ),
  // The , and . keys, marked < and >: they point the way the toolbar's ⏮ ⏭
  // do, and answer with or without ⇧. Not ⌥⌘← →, which Chrome keeps.
  // With ⇧ a browser can name the key by its typed character, < or >.
  AppShortcut(
    keys:
        const ShortcutKeys(LogicalKeyboardKey.comma, primary: true, alt: true),
    alsoKeys: const [
      ShortcutKeys(
        LogicalKeyboardKey.comma,
        primary: true,
        alt: true,
        shift: true,
      ),
      ShortcutKeys(
        LogicalKeyboardKey.less,
        primary: true,
        alt: true,
        shift: true,
      ),
    ],
    intent: const StepSuttaIntent(ReaderStep.previous),
    group: ShortcutGroup.reader,
    label: (l10n) => l10n.shortcutPreviousText,
    keyCap: '<',
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
      ShortcutKeys(
        LogicalKeyboardKey.greater,
        primary: true,
        alt: true,
        shift: true,
      ),
    ],
    intent: const StepSuttaIntent(ReaderStep.next),
    group: ShortcutGroup.reader,
    label: (l10n) => l10n.shortcutNextText,
    keyCap: '>',
  ),
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.keyB, primary: true),
    intent: const ToggleNavigatorIntent(),
    group: ShortcutGroup.reader,
    label: (l10n) => l10n.shortcutToggleNavigator,
  ),
  // The browser's own zoom keys: same meaning, so the reader takes them.
  // ⇧= is `equal` on desktop and `add` in a browser, which names the key by
  // its typed character.
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.equal, primary: true),
    alsoKeys: const [
      ShortcutKeys(LogicalKeyboardKey.equal, primary: true, shift: true),
      ShortcutKeys(LogicalKeyboardKey.add, primary: true, shift: true),
      ShortcutKeys(LogicalKeyboardKey.numpadAdd, primary: true),
    ],
    intent: const TextSizeIntent(TextSizeChange.bigger),
    group: ShortcutGroup.reader,
    label: (l10n) => l10n.shortcutIncreaseFontSize,
  ),
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.minus, primary: true),
    alsoKeys: const [
      ShortcutKeys(LogicalKeyboardKey.numpadSubtract, primary: true),
    ],
    intent: const TextSizeIntent(TextSizeChange.smaller),
    group: ShortcutGroup.reader,
    label: (l10n) => l10n.shortcutDecreaseFontSize,
  ),
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.digit0, primary: true),
    alsoKeys: const [ShortcutKeys(LogicalKeyboardKey.numpad0, primary: true)],
    intent: const TextSizeIntent(TextSizeChange.normal),
    group: ShortcutGroup.reader,
    label: (l10n) => l10n.shortcutResetFontSize,
  ),
  // Same label: ↑ and ↓ share one row in the Settings tab, as do PgUp PgDn.
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.arrowUp),
    intent:
        const ScrollReaderIntent(AxisDirection.up, ScrollIncrementType.line),
    group: ShortcutGroup.reader,
    label: (l10n) => l10n.shortcutScroll,
  ),
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.arrowDown),
    intent:
        const ScrollReaderIntent(AxisDirection.down, ScrollIncrementType.line),
    group: ShortcutGroup.reader,
    label: (l10n) => l10n.shortcutScroll,
  ),
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.pageUp),
    intent:
        const ScrollReaderIntent(AxisDirection.up, ScrollIncrementType.page),
    group: ShortcutGroup.reader,
    label: (l10n) => l10n.shortcutScrollPage,
  ),
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.pageDown),
    intent:
        const ScrollReaderIntent(AxisDirection.down, ScrollIncrementType.page),
    group: ShortcutGroup.reader,
    label: (l10n) => l10n.shortcutScrollPage,
  ),

  // ─── Layout ────────────────────────────────────────────────────────────
  // ⌥⌘1–4 in the toolbar's left-to-right order, top row or keypad. Not
  // ⌘1–4: the browser's "go to tab 1–4".
  for (final (i, layout) in ReaderLayout.values.indexed)
    AppShortcut(
      keys: ShortcutKeys(_digits[i], primary: true, alt: true),
      alsoKeys: [ShortcutKeys(_keypadDigits[i], primary: true, alt: true)],
      intent: SetLayoutIntent(layout),
      group: ShortcutGroup.layout,
      label: layout.label,
    ),

  // ─── App ───────────────────────────────────────────────────────────────
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.comma, primary: true),
    intent: const OpenSettingsIntent(SettingsTab.general),
    group: ShortcutGroup.app,
    label: (l10n) => l10n.settings,
  ),
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.slash, primary: true),
    intent: const OpenSettingsIntent(SettingsTab.shortcuts),
    group: ShortcutGroup.app,
    label: (l10n) => l10n.settingsKeyboardShortcuts,
  ),
  // The action defers to the focused widget's own copy first, then falls
  // back to the last reader selection — which rescues ⌘C on web.
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.keyC, primary: true),
    intent: const SmartCopyIntent(),
    group: ShortcutGroup.app,
    label: (l10n) => l10n.shortcutCopy,
    desktopOnly: false,
  ),
  AppShortcut(
    keys: const ShortcutKeys(LogicalKeyboardKey.escape),
    intent: const DismissTopOverlayIntent(),
    group: ShortcutGroup.app,
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

const _keypadDigits = [
  LogicalKeyboardKey.numpad1,
  LogicalKeyboardKey.numpad2,
  LogicalKeyboardKey.numpad3,
  LogicalKeyboardKey.numpad4,
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
