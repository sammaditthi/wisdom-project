# Keyboard Shortcuts Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Every key in the design's table works on desktop (app and browser), and Settings gains a Keyboard shortcuts tab built from the same list.

**Architecture:** `keyboard_bindings.dart` becomes a list of `AppShortcut` entries (keys, intent, group, label). `AppShortcuts` turns it into the `Shortcuts` map for the current platform; the Settings tab turns it into rows. Each new behaviour is an `Intent` + `ContextAction` in the existing files. The reader and the search results panel are reached through provider-owned objects they borrow, never through provider state they write (the lesson in `in_page_search_focus_provider.dart`).

**Tech Stack:** Flutter `Shortcuts`/`Actions`/`PrioritizedIntents`, Riverpod 2 (`Provider`, `StateProvider`), flutter_test with `TargetPlatformVariant`.

**Spec:** `docs/todo/reader/keyboard-shortcuts-sheet.md`

## Global Constraints

- Work on branch `feat/keyboard-shortcuts`. Run `git switch`/`git branch` unsandboxed.
- No key combo is spelled anywhere in `lib/` outside `keyboard_bindings.dart` (spec rule 1).
- Platform comes from `defaultTargetPlatform`. No `kIsWeb` branch. ⌘ on macOS and iOS, Ctrl elsewhere; only that one is registered (spec rule 2).
- Desktop = `TargetPlatform.macOS`, `.windows`, `.linux`. New keys and the Settings tab exist only there; the existing five keys stay on every platform (spec rule 3).
- `const` wherever the value allows. Doc comments: a few lines, what and why only (CLAUDE.md).
- Every new label goes in both `app_en.arb` and `app_si.arb`, each with an `@key` description. Regenerate with `flutter gen-l10n`.
- The `flutter` CLI runs unsandboxed. Ask the user once before the first `flutter test` of the session (CLAUDE.md).
- Tests pin the platform with `variant: TargetPlatformVariant.only(TargetPlatform.macOS)` (or `.windows`/`.android`), never by editing globals by hand.
- Pali in tests is in Sinhala script (`බ්‍රහ්මජාල සුත්ත`).
- Don't delete commented-out code you come across.

## Review Focus

1. **AltGr while typing.** Ctrl+Alt+2 in a text box on Windows must reach the box (types ² on German layouts) and not change the layout. Test in Task 5.
2. **Arrows on a navigator row.** ↓ with focus on a tree row or a tab must move focus as today, not scroll the reader. Test in Task 6.
3. **Keys behind a dialog.** ⌥⌘] / ⌘B pressed with Settings open must do nothing to the reader underneath. Test in Task 4 and Task 5.
4. **Text-size drift and limits.** 0.9 + one step must be exactly 1.0; ⌘+ at 1.5 stays 1.5. Test in Task 4.
5. **Sutta keys at the edge and with ⇧.** ⌥⌘> at the last sutta does nothing; ⇧⌥⌘> works like ⌥⌘>. Test in Task 6.

---

### Task 1: One list, one modifier per platform

**Files:**
- Modify: `lib/presentation/keyboard/keyboard_bindings.dart` (replace `defaultBindings()`)
- Modify: `lib/presentation/keyboard/app_shortcuts.dart:40`
- Modify: `lib/core/localization/l10n/app_en.arb`, `app_si.arb`
- Create: `test/presentation/keyboard/keyboard_bindings_test.dart`
- Create: `test/presentation/keyboard/shortcut_test_host.dart`

**Interfaces:**
- Produces:
  ```dart
  enum ShortcutGroup { search, reader, layout, app } // tab order

  @immutable
  class ShortcutKeys { // == and hashCode on all four fields
    const ShortcutKeys(this.key, {this.primary = false, this.alt = false, this.shift = false});
    final LogicalKeyboardKey key;
    final bool primary, alt, shift; // primary: ⌘ on Apple, Ctrl elsewhere
    SingleActivator activatorFor(TargetPlatform platform);
  }

  @immutable
  class AppShortcut {
    const AppShortcut({required this.keys, required this.intent, this.alsoKeys = const [],
        this.group, this.label, this.desktopOnly = true}); // asserts label != null when group != null
    final ShortcutKeys keys;           // the combo the Settings tab shows
    final List<ShortcutKeys> alsoKeys; // bound too, never shown
    final Intent intent;
    final ShortcutGroup? group;        // null: bound but not listed
    final String Function(AppLocalizations l10n)? label;
    final bool desktopOnly;
  }

  bool isDesktopPlatform(TargetPlatform platform);
  bool usesCommandKey(TargetPlatform platform);           // macOS, iOS
  final List<AppShortcut> appShortcuts;                   // list order = row order
  List<AppShortcut> shortcutsFor(TargetPlatform platform); // drops desktopOnly off desktop
  Map<ShortcutActivator, Intent> shortcutMap(TargetPlatform platform);
  ```
- Produces (test helpers):
  ```dart
  Future<ProviderContainer> pumpShortcutHost(WidgetTester tester, {required Widget home, List<Override> overrides = const []});
  // ⌘ on macOS/iOS, Ctrl elsewhere, per defaultTargetPlatform
  Future<void> pressKeys(WidgetTester tester, LogicalKeyboardKey key, {bool primary = false, bool alt = false, bool shift = false});
  ```

- [ ] **Step 1: Write the failing tests**

```dart
testWidgets('macOS registers only ⌘', (tester) async {
  final activators = shortcutMap(defaultTargetPlatform).keys.cast<SingleActivator>();
  expect(activators.any((a) => a.control), isFalse);
  expect(activators.any((a) => a.trigger == LogicalKeyboardKey.keyF && a.meta && !a.shift), isTrue);
}, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

testWidgets('Windows registers only Ctrl', (tester) async {
  final activators = shortcutMap(defaultTargetPlatform).keys.cast<SingleActivator>();
  expect(activators.any((a) => a.meta), isFalse);
  expect(activators.any((a) => a.trigger == LogicalKeyboardKey.keyF && a.control && !a.shift), isTrue);
}, variant: TargetPlatformVariant.only(TargetPlatform.windows));

testWidgets('Android keeps only the existing five', (tester) async {
  expect(shortcutsFor(defaultTargetPlatform).map((s) => s.intent.runtimeType).toSet(), {
    DismissTopOverlayIntent, OpenInPageSearchIntent, OpenMainSearchIntent,
    CloseActiveTabIntent, SmartCopyIntent,
  });
}, variant: TargetPlatformVariant.only(TargetPlatform.android));

test('every listed entry has a label in English and Sinhala', () {
  for (final locale in const [Locale('en'), Locale('si')]) {
    final l10n = lookupAppLocalizations(locale);
    for (final s in appShortcuts.where((s) => s.group != null)) {
      expect(s.label!(l10n), isNotEmpty);
    }
  }
});
```

`pumpShortcutHost` builds `UncontrolledProviderScope(container: createTestContainer(overrides))` → `MaterialApp(navigatorKey: appNavigatorKey` (added in Task 3; leave the parameter out until then)`, localizationsDelegates, builder: (c, child) => AppShortcuts(child: child!), home: home)`.

- [ ] **Step 2: Run, expect FAIL** — `flutter test test/presentation/keyboard/keyboard_bindings_test.dart` fails on undefined `shortcutMap`.

- [ ] **Step 3: Implement the model and move the five existing keys into `appShortcuts`** with `desktopOnly: false`:

| keys | intent | group | label (new ARB key unless noted) |
| --- | --- | --- | --- |
| `keyF, primary` | `OpenInPageSearchIntent` | search | `findInPage` (exists) |
| `keyF, primary, shift` | `OpenMainSearchIntent` | search | `searchHint` "Search" / "සොයන්න" (the search box's own word) |
| `keyW, primary, alt` | `CloseActiveTabIntent` | reader | `shortcutCloseTab` "Close tab" / "ටැබ් එක වසන්න" |
| `keyC, primary` | `SmartCopyIntent` | app | `shortcutCopy` "Copy" / "පිටපත් කරන්න" |
| `escape` | `DismissTopOverlayIntent` | app | `shortcutCloseOverlay` "Close menu, panel or dialog" / "මෙනුවක්, පැනලයක් හෝ සංවාද කොටුවක් වසන්න" |

Keep the existing comments' *why* (e.g. why not plain ⌘W) above each entry, shortened. `shortcutMap` maps each of `keys` and `alsoKeys` through `activatorFor`. `AppShortcuts` uses `shortcutMap(defaultTargetPlatform)`.

- [ ] **Step 4: Run, expect PASS.** Also run `test/presentation/screens/app_shell_test.dart` — still passes.

- [ ] **Step 5: Commit** — `refactor(keyboard): one shortcut list, one modifier per platform`

---

### Task 2: Keyboard shortcuts tab in Settings

**Files:**
- Modify: `lib/presentation/widgets/settings/settings_tab.dart`, `settings_dialog.dart` (TabController length, sidebar, tab bar, `_pageFor`)
- Create: `lib/presentation/widgets/settings/keyboard_shortcuts_page.dart`
- Create: `lib/presentation/keyboard/key_cap_labels.dart`
- Modify: ARB files
- Create: `test/presentation/keyboard/key_cap_labels_test.dart`, `test/presentation/widgets/settings/keyboard_shortcuts_page_test.dart`
- Modify: `test/presentation/widgets/settings/settings_dialog_test.dart`

**Interfaces:**
- Consumes: `appShortcuts`, `shortcutsFor`, `ShortcutGroup`, `ShortcutKeys` (Task 1).
- Produces:
  ```dart
  enum SettingsTab { general, shortcuts, anumodana; ...
    static List<SettingsTab> available(TargetPlatform platform); // no shortcuts off desktop
  }
  List<String> keyCapLabels(ShortcutKeys keys, TargetPlatform platform);
  class KeyboardShortcutsPage extends StatelessWidget { const KeyboardShortcutsPage({super.key}); }
  ```

- [ ] **Step 1: Write the failing tests**

```dart
// key_cap_labels_test.dart
test('Mac uses symbols in Apple order', () {
  const w = ShortcutKeys(LogicalKeyboardKey.keyW, primary: true, alt: true);
  const f = ShortcutKeys(LogicalKeyboardKey.keyF, primary: true, shift: true);
  expect(keyCapLabels(w, TargetPlatform.macOS), ['⌥', '⌘', 'W']);
  expect(keyCapLabels(f, TargetPlatform.macOS), ['⇧', '⌘', 'F']);
});
test('Windows uses words', () {
  const w = ShortcutKeys(LogicalKeyboardKey.keyW, primary: true, alt: true);
  expect(keyCapLabels(w, TargetPlatform.windows), ['Ctrl', 'Alt', 'W']);
});
test('special keys', () {
  const pgUp = ShortcutKeys(LogicalKeyboardKey.pageUp);
  const prev = ShortcutKeys(LogicalKeyboardKey.comma, primary: true, alt: true);
  const smaller = ShortcutKeys(LogicalKeyboardKey.minus, primary: true);
  expect(keyCapLabels(pgUp, TargetPlatform.macOS), ['fn', '↑']);
  expect(keyCapLabels(pgUp, TargetPlatform.windows), ['PgUp']);
  expect(keyCapLabels(prev, TargetPlatform.macOS, keyCap: '<'), ['⌥', '⌘', '<']);
  expect(keyCapLabels(smaller, TargetPlatform.windows), ['Ctrl', '−']); // U+2212
});

// keyboard_shortcuts_page_test.dart
testWidgets('Mac shows ⌘, not Ctrl', (tester) async {
  await tester.pumpApp(const KeyboardShortcutsPage());
  expect(find.text('⌘'), findsWidgets);
  expect(find.text('Ctrl'), findsNothing);
  expect(find.text('Find in page'), findsOneWidget);
}, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
testWidgets('Windows shows Ctrl, not ⌘', ...); // mirror, TargetPlatform.windows

// settings_dialog_test.dart — add
testWidgets('desktop has three tabs in order', (tester) async {
  // open the dialog; the sidebar reads General, Keyboard shortcuts, Anumodanā top to bottom
}, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
testWidgets('Android has no Keyboard shortcuts tab', (tester) async {
  // open the dialog; find.text('Keyboard shortcuts') findsNothing
}, variant: TargetPlatformVariant.only(TargetPlatform.android));
```

- [ ] **Step 2: Run, expect FAIL** on undefined `keyCapLabels` / `KeyboardShortcutsPage`.

- [ ] **Step 3: Implement.**
  - `keyCapLabels`: modifiers first. Mac: `alt` ⌥, `shift` ⇧, `primary` ⌘, in that order. Elsewhere: `primary` Ctrl, `alt` Alt, `shift` Shift. Then the key: letters upper-case, digits as is, `[` `]`, comma `,`, period `.` (the sutta-step entries show `<` `>` through `AppShortcut.keyCap`), equal `+`, minus `−` (U+2212), slash `/`, ↑ ↓, Esc, Tab; `pageUp`/`pageDown` are `PgUp`/`PgDn`, on a Mac `fn ↑`/`fn ↓` (most Mac keyboards have no Page Up); anything else `key.keyLabel`. After writing, dump the file's code points to check every symbol landed as itself.
  - `SettingsTab.shortcuts` (icon `Icons.keyboard_outlined`, label `settingsKeyboardShortcuts` "Keyboard shortcuts" / "යතුරුපුවරු කෙටිමං"). `available` keeps `shortcuts` only when `isDesktopPlatform`. The dialog uses `SettingsTab.available(defaultTargetPlatform)` for the TabController length, the sidebar, the tab bar and the index ↔ tab mapping; an `initial` not in the list falls back to General.
  - `KeyboardShortcutsPage`: `shortcutsFor(defaultTargetPlatform)` where `group != null`, one `SettingsSection` per `ShortcutGroup` (first gets `isFirst`), one `SettingsRow` per entry with `trailing:` key caps. Consecutive entries with the same label share one row, their key groups side by side with a wider gap. Section titles: `shortcutGroupSearch` "Search" / "සෙවීම", `shortcutGroupReader` "Reader" / "කියවීම", `shortcutGroupLayout` "Layout" / "පිරිසැලසුම", `shortcutGroupApp` "App" / "යෙදුම".
  - Key cap (private widget): min 28×28, horizontal padding 7, border 1 with a 2 px bottom edge, radius 6, 13 px w600, from `colorScheme` roles (`outlineVariant` border, `surface` fill) — the board's look (`RefTabs.dc.html`).
  - Sinhala strings in this plan are drafts for the user's copy review.

- [ ] **Step 4: Run, expect PASS** (the three test files).

- [ ] **Step 5: Commit** — `feat(settings): Keyboard shortcuts tab, built from the shortcut list`

---

### Task 3: Open Settings (⌘,) and this list (⌘/)

**Files:**
- Create: `lib/presentation/keyboard/app_navigator_key.dart`
- Modify: `lib/main.dart` (`MaterialApp(navigatorKey: appNavigatorKey, …)`)
- Modify: `lib/presentation/widgets/settings/settings_dialog.dart` (`static const overlayId = 'settings-dialog'`, used by `show`)
- Modify: `shortcut_intents.dart`, `shortcut_actions.dart`, `app_shortcuts.dart`, `keyboard_bindings.dart`, ARB files
- Modify: `test/presentation/keyboard/shortcut_test_host.dart` (pass `navigatorKey`)
- Create: `test/presentation/keyboard/settings_keys_test.dart`

**Interfaces:**
- Consumes: `SettingsTab.shortcuts`, `KeyboardShortcutsPage` (Task 2).
- Produces:
  ```dart
  final appNavigatorKey = GlobalKey<NavigatorState>();
  class OpenSettingsIntent extends Intent { const OpenSettingsIntent(this.tab); final SettingsTab tab; }
  class OpenSettingsAction extends ContextAction<OpenSettingsIntent> { OpenSettingsAction(this.ref); }
  ```

- [ ] **Step 1: Write the failing tests** (macOS variant; one Windows copy of the first)

```dart
testWidgets('⌘, opens Settings on General', (tester) async {
  await pumpShortcutHost(tester, home: const Scaffold());
  await pressKeys(tester, LogicalKeyboardKey.comma, primary: true);
  await tester.pumpAndSettle();
  expect(find.byType(SettingsDialog), findsOneWidget);
  expect(find.byType(GeneralSettingsPage), findsOneWidget);
});
testWidgets('⌘/ opens Settings on Keyboard shortcuts', ...); // find.byType(KeyboardShortcutsPage)
testWidgets('⌘/ with Settings open does nothing', (tester) async {
  // press ⌘, then ⌘/ → still one SettingsDialog, General still showing
});
```

- [ ] **Step 2: Run, expect FAIL.**

- [ ] **Step 3: Implement.** `isEnabled`: no entry with `SettingsDialog.overlayId` on `overlayStackProvider`, and `appNavigatorKey.currentState?.overlay` is not null. `invoke`: `unawaited(SettingsDialog.show(appNavigatorKey.currentState!.overlay!.context, initial: intent.tab))` — the overlay's context sits below the `Navigator`, which `AppShortcuts` does not. Entries, group app, desktop only: `comma, primary` → `OpenSettingsIntent(SettingsTab.general)`, label `settings` "Settings" / "සැකසුම්"; `slash, primary` → `OpenSettingsIntent(SettingsTab.shortcuts)`, label `settingsKeyboardShortcuts` "Keyboard shortcuts" / "යතුරුපුවරු කෙටිමං".

- [ ] **Step 4: Run, expect PASS**, plus `settings_dialog_test.dart`.

- [ ] **Step 5: Commit** — `feat(keyboard): Cmd/Ctrl+, opens Settings, Cmd/Ctrl+/ this list`

---

### Task 4: Text size (⌘+ ⌘− ⌘0) and the navigator (⌘B)

**Files:**
- Create: `lib/presentation/keyboard/shortcut_guards.dart`
- Modify: `lib/presentation/widgets/app/overlay_stack_sync.dart` (`static const inPageSearchOverlayId = 'in-page-search'`, used where the literal is)
- Modify: `shortcut_intents.dart`, `shortcut_actions.dart`, `app_shortcuts.dart`, `keyboard_bindings.dart`, ARB files
- Create: `test/presentation/keyboard/reading_keys_test.dart`

**Interfaces:**
- Produces:
  ```dart
  bool isTypingInTextBox(); // primary focus inside an EditableText
  bool readerKeysAllowed(WidgetRef ref); // Reader section, and nothing open but the find bar
  enum TextSizeChange { bigger, smaller, normal }
  class TextSizeIntent extends Intent { const TextSizeIntent(this.change); final TextSizeChange change; }
  class ToggleNavigatorIntent extends Intent { const ToggleNavigatorIntent(); }
  ```

- [ ] **Step 1: Write the failing tests** (macOS variant; `SharedPreferences.setMockInitialValues({})` in `setUp`)

```dart
testWidgets('⌘+ and ⌘⇧= step up by 0.1 without drift', (tester) async {
  final c = await pumpShortcutHost(tester, home: const Scaffold());
  await c.read(fontScaleProvider.notifier).setScale(0.9);
  await pressKeys(tester, LogicalKeyboardKey.equal, primary: true);
  expect(c.read(fontScaleProvider), 1.0); // exact
  await pressKeys(tester, LogicalKeyboardKey.equal, primary: true, shift: true);
  expect(c.read(fontScaleProvider), 1.1);
});
testWidgets('⌘+ stops at 1.5', ...);   // from 1.45 → 1.5, again → 1.5
testWidgets('⌘− steps down, ⌘0 resets', ...); // 1.0 → 0.9; ⌘0 → notifier.platformDefault
testWidgets('⌘B toggles the navigator', ...); // true → false → true
testWidgets('⌘B does nothing outside the Reader or behind a dialog', (tester) async {
  // selectedAppSectionProvider = AppSection.research → unchanged
  // back to reader, push DismissibleOverlay(id: SettingsDialog.overlayId, dismiss: () {}) → unchanged
});
```

- [ ] **Step 2: Run, expect FAIL.**

- [ ] **Step 3: Implement.**
  - `readerKeysAllowed`: `selectedAppSectionProvider == AppSection.reader` and every `overlayStackProvider` entry's id is `OverlayStackSync.inPageSearchOverlayId`.
  - `TextSizeAction` (always enabled): bigger/smaller → `setScale(((scale ± 0.1) * 20).round() / 20)`, the slider's own rounding; normal → `reset()`.
  - `ToggleNavigatorAction`: enabled when `readerKeysAllowed`; flips `navigatorVisibleProvider`.
  - Entries, group reader, desktop only: `equal, primary` (`alsoKeys`: `equal, primary, shift`; `numpadAdd, primary`) label `shortcutIncreaseFontSize` "Increase font size" / "අකුරු විශාල කරන්න"; `minus, primary` (`alsoKeys`: `numpadSubtract, primary`) label `shortcutDecreaseFontSize` "Decrease font size" / "අකුරු කුඩා කරන්න"; `digit0, primary` (`alsoKeys`: `numpad0, primary`) label `shortcutResetFontSize` "Reset font size" / "අකුරු ප්‍රමාණය යළි සකසන්න"; `keyB, primary` label `shortcutToggleNavigator` "Show/hide navigator" / "පටුන පෙන්වන්න/සඟවන්න". Order in the list: previous/next text (Task 6) will go first in this group, then navigator, text, scroll — insert so the final row order matches the spec's table.

- [ ] **Step 4: Run, expect PASS.**

- [ ] **Step 5: Commit** — `feat(keyboard): text size and navigator keys`

---

### Task 5: Reader tab keys (⌥⌘[ ], ⌥⌘1–4) and close-tab while typing

**Files:**
- Modify: `lib/presentation/models/reader_layout.dart` (add `String label(AppLocalizations l10n)`)
- Modify: `lib/presentation/widgets/reader/reader_action_buttons.dart` (`_layoutLabel` → `layout.label(l10n)`; delete the private copy)
- Modify: `shortcut_intents.dart`, `shortcut_actions.dart` (incl. `CloseActiveTabAction.isEnabled`), `app_shortcuts.dart`, `keyboard_bindings.dart`, ARB files
- Create: `test/presentation/keyboard/reader_tab_keys_test.dart`

**Interfaces:**
- Consumes: `isTypingInTextBox`, `readerKeysAllowed` (Task 4).
- Produces:
  ```dart
  class SwitchTabIntent extends Intent { const SwitchTabIntent(this.offset); final int offset; } // +1 / -1
  class SetLayoutIntent extends Intent { const SetLayoutIntent(this.layout); final ReaderLayout layout; }
  ```

- [ ] **Step 1: Write the failing tests.** Seed tabs with `tabsProvider.notifier.addTab(ReaderTab.fromNode(nodeKey: 'dn-1', paliName: 'බ්‍රහ්මජාල සුත්ත', sinhalaName: 'බ්‍රහ්මජාල සූත්‍රය'))` (and `dn-2`), then set `activeTabIndexProvider`. If `syncNavigatorToActiveTabProvider` needs the tree, override it with a no-op in the host.

```dart
testWidgets('⌥⌘] and ⌥⌘[ move between tabs and wrap', (tester) async {
  // two tabs, active 0: ⌥⌘] → 1, ⌥⌘] → 0, ⌥⌘[ → 1
}, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
testWidgets('one tab: ⌥⌘] does nothing', ...);
testWidgets('⌥⌘3 sets side by side and remembers it', (tester) async {
  // activeReaderLayoutProvider == ReaderLayout.sideBySide
  // lastReaderLayoutProvider == ReaderLayout.sideBySide
});
testWidgets('Ctrl+Alt+3 in a text box goes to the box', (tester) async {
  // home: Scaffold(body: TextField(autofocus: true)); layout unchanged
}, variant: TargetPlatformVariant.only(TargetPlatform.windows));
testWidgets('Ctrl+Alt+W in a text box keeps the tab', ...); // windows; tab count unchanged
testWidgets('⌥⌘] behind Settings does nothing', ...); // SettingsDialog.overlayId on the stack
```

- [ ] **Step 2: Run, expect FAIL.**

- [ ] **Step 3: Implement.**
  - `SwitchTabAction`: enabled when `readerKeysAllowed && !isTypingInTextBox()` and at least two tabs; invoke `switchTabProvider((active + offset) % length)`.
  - `SetLayoutAction`: enabled when `readerKeysAllowed && !isTypingInTextBox()` and `activeTabIndexProvider >= 0`; invoke `updateActiveTabLayoutProvider(intent.layout)`.
  - `CloseActiveTabAction.isEnabled`: add `&& !isTypingInTextBox()`.
  - Entries, desktop only: `bracketLeft, primary, alt` → `SwitchTabIntent(-1)`, label `shortcutPreviousTab` "Previous tab" / "පෙර ටැබ් එක"; `bracketRight, primary, alt` → `SwitchTabIntent(1)`, label `shortcutNextTab` "Next tab" / "ඊළඟ ටැබ් එක" — both group reader, before close-tab. Then for each `ReaderLayout.values[i]`: `digit(i+1), primary, alt` (`alsoKeys`: `numpad(i+1), primary, alt`) → `SetLayoutIntent(layout)`, group layout, label `(l10n) => layout.label(l10n)`.

- [ ] **Step 4: Run, expect PASS**, plus `test/presentation/widgets/reader/` (the toolbar's layout menu still reads the same labels).

- [ ] **Step 5: Commit** — `feat(keyboard): tab and layout keys; reader-tab keys leave text boxes alone`

---

### Task 6: Previous/next sutta (⌥⌘< >) and scrolling (↑ ↓ PgUp PgDn)

**Files:**
- Create: `lib/presentation/providers/reader_keyboard_bridge_provider.dart`
- Modify: `lib/presentation/widgets/reader/multi_pane_reader_widget.dart` (implement the handle, attach/detach, wrap the content in a `Focus`)
- Modify: `lib/presentation/keyboard/app_shortcuts.dart` (becomes a `ConsumerStatefulWidget` owning the idle `FocusNode` it gives its `Focus(autofocus: true)`)
- Modify: `shortcut_intents.dart`, `shortcut_actions.dart`, `keyboard_bindings.dart`, ARB files
- Create: `test/presentation/keyboard/reader_keys_test.dart`
- Modify: `test/presentation/widgets/multi_pane_reader_widget_test.dart`

**Interfaces:**
- Consumes: `isTypingInTextBox`, `readerKeysAllowed` (Task 4); `ReaderStep`, `neighbourLeafProvider` (existing).
- Produces:
  ```dart
  abstract interface class ReaderKeyboardHandle {
    bool canStep(ReaderStep step);   // a neighbouring sutta exists
    void step(ReaderStep step);      // calls _navigateToSutta, as ⏮ ⏭ do
    void scroll(AxisDirection direction, ScrollIncrementType type);
    bool get hasFocus;               // focus is inside the reader
  }
  class ReaderKeyboardBridge {
    ReaderKeyboardHandle? get handle;
    void attach(ReaderKeyboardHandle handle);
    void detach(ReaderKeyboardHandle handle); // only if it is the attached one
  }
  final readerKeyboardBridgeProvider = Provider<ReaderKeyboardBridge>((ref) => ReaderKeyboardBridge());
  class StepSuttaIntent extends Intent { const StepSuttaIntent(this.step); final ReaderStep step; }
  class ScrollReaderIntent extends Intent { const ScrollReaderIntent(this.direction, this.type); ... }
  ```

- [ ] **Step 1: Write the failing tests.** Action tests attach a `_FakeHandle` (records calls; `canStep`/`hasFocus` settable) to `readerKeyboardBridgeProvider`.

```dart
testWidgets('⌥⌘> and ⇧⌥⌘> step to the next sutta', (tester) async {
  // fake.steps == [ReaderStep.next, ReaderStep.next]
}, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
testWidgets('⌥⌘> at the last sutta does nothing', ...); // canStep false → steps empty
testWidgets('↓ with nothing focused scrolls a line, PgDn a page', (tester) async {
  // fake.scrolls == [(AxisDirection.down, ScrollIncrementType.line), (AxisDirection.down, ScrollIncrementType.page)]
});
testWidgets('↓ on a focused button outside the reader does not scroll', (tester) async {
  // home has a TextButton with autofocus; fake.hasFocus false → scrolls empty
});
testWidgets('↓ in a text box does not scroll', ...);

// multi_pane_reader_widget_test.dart
testWidgets('the reader attaches to the keyboard bridge while mounted', (tester) async {
  // after pump: container.read(readerKeyboardBridgeProvider).handle != null
  // after replacing the widget with SizedBox: handle == null
});
```

- [ ] **Step 2: Run, expect FAIL.**

- [ ] **Step 3: Implement.**
  - The reader's state attaches in `initState` (`ref.read(readerKeyboardBridgeProvider)`, kept in a field) and detaches in `dispose` through that field — no `ref` in `dispose`, no provider state written (see `in_page_search_focus_provider.dart`).
  - `canStep`/`step` read `neighbourLeafProvider((nodeKey, step))` for the active node key; `step` calls the existing `_navigateToSutta(leaf)`.
  - `scroll`: one line = 50 px, one page = 0.8 × viewport, `position.animateTo` clamped to the extents, 100 ms, `Curves.easeInOut` (Flutter's own `ScrollAction` numbers).
  - `hasFocus`: a `FocusNode(canRequestFocus: false, skipTraversal: true)` on a `Focus` around the reader content.
  - `StepSuttaAction`: enabled when `readerKeysAllowed && !isTypingInTextBox() && handle?.canStep(step) == true`.
  - `ScrollReaderAction(ref, idleFocus)`: enabled when `readerKeysAllowed && !isTypingInTextBox()`, a handle is attached, and `handle.hasFocus` or focus is idle (`primaryFocus` is null, a `FocusScopeNode`, or the idle node).
  - Entries, group reader, desktop only, after close-tab: `comma, primary, alt` (`alsoKeys`: same + `shift`) → `StepSuttaIntent(ReaderStep.previous)`, label `shortcutPreviousText` "Previous text" / "පෙර පෙළ"; `period, …` → next, label `shortcutNextText` "Next text" / "ඊළඟ පෙළ". Last in the group: `arrowUp` / `arrowDown` → line, both label `shortcutScroll` "Scroll" / "අනුචලනය" (one row); `pageUp` / `pageDown` → page, both label `shortcutScrollPage` "Scroll a page" / "පිටුවක් අනුචලනය".

- [ ] **Step 4: Run, expect PASS**, plus the whole `test/presentation/widgets/multi_pane_reader_widget_test.dart`.

- [ ] **Step 5: Commit** — `feat(keyboard): sutta step and scroll keys through the reader bridge`

---

### Task 7: Search box → results (↓, ↑) and Tab into the panel

**Files:**
- Create: `lib/presentation/providers/search_results_focus_provider.dart`
- Create: `lib/presentation/keyboard/search_result_stops.dart`
- Modify: `lib/presentation/widgets/search/search_results_panel.dart:43-80` (focus node + traversal order)
- Modify: `keyboard_bindings.dart` (`shortcutMap` merges shared keys), `app_shortcuts.dart` (register `PrioritizedIntents: PrioritizedAction()`), `shortcut_intents.dart`, `shortcut_actions.dart`, ARB files
- Create: `test/presentation/keyboard/search_results_keys_test.dart`

**Interfaces:**
- Consumes: `mainSearchFocusNodeProvider`, `searchStateProvider` (existing); `ScrollReaderIntent` (Task 6).
- Produces:
  ```dart
  final searchResultsFocusNodeProvider = Provider<FocusNode>(...); // owned, canRequestFocus: false, skipTraversal: true
  final searchPanelFocusNodeProvider = Provider<FocusNode>(...);   // same, around the whole panel
  List<FocusNode> searchResultStops(FocusNode within); // focusable descendants, ReadingOrderTraversalPolicy.sort
  enum SearchPanelStop { firstResult, firstControl }  // ↓, Tab
  class MoveIntoSearchResultsIntent extends Intent { const MoveIntoSearchResultsIntent(this.stop); final SearchPanelStop stop; }
  class BackToSearchBoxIntent extends Intent { const BackToSearchBoxIntent(); }
  class NextSearchResultIntent extends Intent { const NextSearchResultIntent(); }
  class PreviousSearchResultIntent extends Intent { const PreviousSearchResultIntent(); }
  ```

- [ ] **Step 1: Write the failing tests.** Host: a `TextField` whose node is set on `mainSearchFocusNodeProvider`, and a `Focus(focusNode: searchResultsFocusNodeProvider)` holding three `TextButton`s in a `Column`; search state from `FakeSearchStateNotifier` with the results panel visible.

```dart
testWidgets('↓ goes from the box to the first stop', ...); // macOS
testWidgets('↓ ↑ step through the stops; ↑ from the first returns to the box', ...);
testWidgets('↓ on the last stop stays there', ...);
testWidgets('panel hidden: ↓ leaves focus in the box', ...);
// On the real SearchResultsPanel (header, chips, tabs) with 20 title rows:
testWidgets('Tab goes from the box to match options; Shift+Tab comes back', ...);
testWidgets('Shift+Tab from the first result goes back to the tabs', ...);
testWidgets('scrolled list: Tab walks the panel in order to a row in view', ...);
test('↓ tries results first, then scrolling', () {
  final down = shortcutMap(TargetPlatform.macOS).entries.singleWhere((e) =>
      (e.key as SingleActivator).trigger == LogicalKeyboardKey.arrowDown &&
      !(e.key as SingleActivator).meta).value as PrioritizedIntents;
  expect(down.orderedIntents.map((i) => i.runtimeType),
      [MoveIntoSearchResultsIntent, NextSearchResultIntent, ScrollReaderIntent]);
});
```

The Tab tests use the real panel: the three-button host has no header, so Tab tests there pass either way. Mutation check 2026-11-13: each of these fails one of them: Tab to the first result, the old Shift+Tab, no group around the results, a focus callback that only scrolls down, a result taken as the first control, a plain outer policy. The scratch check before (2026-11-12) also tried 0 and 100 px; the test keeps 300, which shows both bugs.

- [ ] **Step 2: Run, expect FAIL.**

- [ ] **Step 3: Implement.**
  - `shortcutMap`: group by `ShortcutKeys` (not by `SingleActivator`, which has no `==`); one intent stays as is, several become `PrioritizedIntents(orderedIntents: …)` in list order.
  - `MoveIntoSearchResultsAction`: enabled when the main search node has focus and there is a target. `firstResult` also starts from focus on nothing with no route open, since picking a recent search lets go of the box.
    - `firstResult` targets the first arrow stop: the first of `searchResultStops` over the results, or with none over the recent-search rows.
    - `firstControl` targets the first Tab stop: the panel's first stop outside the results (a row scrolled up out of view sits above the header on screen, so it would sort first), or with no panel the first recent search.
    - Neither reads the search state: the panel is built only while it shows, and the recent searches only while it doesn't.
    - Focuses the stop with `FocusTraversalPolicy.defaultTraversalRequestFocusCallback`, `keepVisibleAtStart`, which scrolls back to it if it was scrolled away.
  - `BackToSearchBoxAction`: enabled when that same first Tab stop has the primary focus; focuses the main search node. Anywhere else Shift+Tab is Flutter's own.
  - `NextSearchResultAction`: enabled when the list under the box (the results, or the whole recent-searches card) has focus; steps through every result, or the recent-search rows only (a row's ✕ sits inside it and is skipped); next stop, or nothing on the last or on Show more / Clear all (still handled, so the reader can't scroll).
  - `PreviousSearchResultAction`: enabled when the list under the box has focus; previous stop, or the main search node from the first.
  - Recent searches: two nodes of the same kind in `RecentSearchOverlay`, as in the panel: `recentSearchesFocusNodeProvider` around the whole card, inside a `FocusTraversalGroup` with the panel's policy so Tab walks it in order, and `recentSearchRowsFocusNodeProvider` around just the rows, for the arrows. Closing the list (`SearchBar._hideOverlay`) unfocuses the card too: otherwise, as a focused row goes, Flutter hands focus back to the box and the list reopens.
  - Panel: `Focus(focusNode: …)` around `_ReferenceResultRow` and the results content, another around the whole panel. A `FocusTraversalGroup` around the panel, so Tab walks it as it shows (header, tabs, results) before leaving it, and one around the results, so they are one block placed where the list shows; without it, rows scrolled partly out of view sort in among the chips and tabs. Both use `searchTraversalPolicy()` (`widgets/search/search_traversal_policy.dart`, shared with the recent searches): `ReadingOrderTraversalPolicy` with a focus callback that scrolls the stop into view either way, as a browser does: Flutter's forward Tab only scrolls down, so Tab into a scrolled list would land on a row above it, out of sight.
  - Entries, desktop only, **before the scroll entries**: `arrowDown` → `MoveIntoSearchResultsIntent(firstResult)`, group search, label `shortcutGoToResults` "Go to results" / "ප්‍රතිඵල වෙත යන්න"; then unlisted `tab` → `MoveIntoSearchResultsIntent(firstControl)`, `tab, shift` → `BackToSearchBoxIntent`, `arrowDown` → `NextSearchResultIntent`, `arrowUp` → `PreviousSearchResultIntent`.

- [ ] **Step 4: Run, expect PASS**, plus `test/presentation/widgets/search_results_panel_test.dart` and `test/presentation/widgets/search/`.

- [ ] **Step 5: Commit** — `feat(search): arrow and Tab keys from the search box into the results`

---

### Task 8: Check on real platforms, then the docs

**Files:**
- Maybe modify: `macos/Runner/Base.lproj/MainMenu.xib` (only if ⌘, is swallowed)
- Modify: `docs/todo/reader/keyboard-shortcuts-sheet.md`, `docs/todo/settings/app-settings-dialog.md` (Decision 7, *Later* bullet), `test/presentation/screens/app_shell_test.dart:163` (the reason string), `CHANGELOG.md`

- [ ] **Step 1: Full test run** — `flutter test` (ask first), then `flutter test integration_test/search_mode_test.dart -d macos` (`caffeinate -d`; re-run alone before blaming the diff). Expected: all pass.
- [ ] **Step 2: macOS app** — `flutter run -d macos`; press every key in the spec's table. ⌘, must open Settings; if the menu's dead "Preferences…" item swallows it, remove that item's `keyEquivalent=","` and re-check.
- [ ] **Step 3: Browsers** — `flutter run -d chrome`, then Safari and Firefox on macOS: every key reaches the page; ⌘+ / ⌘− / ⌘0 change the text, not the zoom. **If Safari keeps ⌘, for itself, stop and ask the user.** Windows Chrome/Edge and the Windows app: ask the user to run the same pass (no Windows machine here).
- [ ] **Step 4: Sinhala layout** — switch macOS to a Sinhala layout; ⌥⌘[ ] < > / , and ⌥⌘1–4 still work in the app and in Chrome.
- [ ] **Step 5: Docs.** Spec: status line "Built 2026-MM-DD on `feat/keyboard-shortcuts`", tick *Check while building* with what each check found. Settings plan: Decision 7 closed by ⌘,; *Later* bullet points at the spec. `app_shell_test.dart:163` reason → `'Cmd/Ctrl+, opens Settings without the rail'`. `CHANGELOG.md`: under `## Unreleased` (add the heading if missing), `### New` — "Keyboard shortcuts on desktop, listed in Settings", per `docs/general/how-to-release.md`.
- [ ] **Step 6: Sinhala copy review** — show the user every new `app_si.arb` string in one table; apply their changes.
- [ ] **Step 7: Commit** — `docs(keyboard): shortcut checks, changelog note`
