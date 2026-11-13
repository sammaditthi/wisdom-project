import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/presentation/models/reader_layout.dart';
import 'package:the_wisdom_project/presentation/models/reader_tab.dart';
import 'package:the_wisdom_project/presentation/providers/last_reader_layout_provider.dart';
import 'package:the_wisdom_project/presentation/providers/navigator_sync_provider.dart';
import 'package:the_wisdom_project/presentation/providers/overlay_stack_provider.dart';
import 'package:the_wisdom_project/presentation/providers/tab_provider.dart';
import 'package:the_wisdom_project/presentation/widgets/app/overlay_stack_sync.dart';
import 'package:the_wisdom_project/presentation/widgets/settings/settings_dialog.dart';

import 'shortcut_test_host.dart';

/// Reader-tab keys: ⌥⌘[ ] between tabs, ⌥⌘1–4 for the layout, and none of
/// them — close-tab included — while typing, where Ctrl+Alt is AltGr
/// (`docs/done/reader/keyboard-shortcuts-sheet.md`, rules 4 and 5).
void main() {
  final mac = TargetPlatformVariant.only(TargetPlatform.macOS);
  final windows = TargetPlatformVariant.only(TargetPlatform.windows);

  /// Pumps [home] with [count] tabs open and the first one active. The
  /// navigator sync needs the whole text tree, which these tests don't load.
  Future<ProviderContainer> pumpWithTabs(
    WidgetTester tester, {
    int count = 2,
    Widget home = const Scaffold(),
  }) async {
    final c = await pumpShortcutHost(
      tester,
      home: home,
      overrides: [syncNavigatorToActiveTabProvider.overrideWithValue(() {})],
    );
    const suttas = [
      ('dn-1', 'බ්‍රහ්මජාල සුත්ත', 'බ්‍රහ්මජාල සූත්‍රය'),
      ('dn-2', 'සාමඤ්ඤඵල සුත්ත', 'සාමඤ්ඤඵල සූත්‍රය'),
    ];
    for (final (key, pali, sinhala) in suttas.take(count)) {
      c.read(tabsProvider.notifier).addTab(ReaderTab.fromNode(
            nodeKey: key,
            paliName: pali,
            sinhalaName: sinhala,
          ));
    }
    c.read(activeTabIndexProvider.notifier).state = 0;
    await tester.pump();
    return c;
  }

  /// Lets the tabs' debounced save (500 ms) run before the test ends, which
  /// fails on a pending timer.
  Future<void> flushTabSaves(WidgetTester tester) =>
      tester.pump(const Duration(seconds: 1));

  testWidgets('⌥⌘] and ⌥⌘[ move between tabs and wrap', (tester) async {
    final c = await pumpWithTabs(tester);

    await pressKeys(tester, LogicalKeyboardKey.bracketRight,
        primary: true, alt: true);
    expect(c.read(activeTabIndexProvider), 1);
    await pressKeys(tester, LogicalKeyboardKey.bracketRight,
        primary: true, alt: true);
    expect(c.read(activeTabIndexProvider), 0);
    await pressKeys(tester, LogicalKeyboardKey.bracketLeft,
        primary: true, alt: true);
    expect(c.read(activeTabIndexProvider), 1);
    await flushTabSaves(tester);
  }, variant: mac);

  testWidgets('one tab: ⌥⌘] does nothing', (tester) async {
    final c = await pumpWithTabs(tester, count: 1);

    await pressKeys(tester, LogicalKeyboardKey.bracketRight,
        primary: true, alt: true);
    expect(c.read(activeTabIndexProvider), 0);
    await flushTabSaves(tester);
  }, variant: mac);

  testWidgets('⌥⌘3 sets side by side and remembers it', (tester) async {
    final c = await pumpWithTabs(tester);

    await pressKeys(tester, LogicalKeyboardKey.digit3,
        primary: true, alt: true);
    expect(c.read(activeReaderLayoutProvider), ReaderLayout.sideBySide);
    expect(c.read(lastReaderLayoutProvider), ReaderLayout.sideBySide);
    await flushTabSaves(tester);
  }, variant: mac);

  testWidgets('the keypad 3 works as the top-row 3', (tester) async {
    final c = await pumpWithTabs(tester);

    await pressKeys(tester, LogicalKeyboardKey.numpad3,
        primary: true, alt: true);
    expect(c.read(activeReaderLayoutProvider), ReaderLayout.sideBySide);
    await flushTabSaves(tester);
  }, variant: mac);

  testWidgets('Ctrl+Alt+3 in a text box goes to the box', (tester) async {
    final c = await pumpWithTabs(
      tester,
      home: const Scaffold(body: TextField(autofocus: true)),
    );
    await tester.pump();

    await pressKeys(tester, LogicalKeyboardKey.digit3,
        primary: true, alt: true);
    expect(c.read(activeReaderLayoutProvider), ReaderLayout.paliOnly);
    await flushTabSaves(tester);
  }, variant: windows);

  testWidgets('Ctrl+Alt+W in a text box keeps the tab', (tester) async {
    final c = await pumpWithTabs(
      tester,
      home: const Scaffold(body: TextField(autofocus: true)),
    );
    await tester.pump();

    await pressKeys(tester, LogicalKeyboardKey.keyW, primary: true, alt: true);
    expect(c.read(tabsProvider), hasLength(2));
    await flushTabSaves(tester);
  }, variant: windows);

  testWidgets('⌥⌘] still works with the dictionary sheet open', (tester) async {
    // Clicking a word opens the sheet; the reader keys must not go dead.
    final c = await pumpWithTabs(tester);
    c.read(overlayStackProvider.notifier).push(
          DismissibleOverlay(
            id: OverlayStackSync.dictionaryOverlayId,
            dismiss: () {},
          ),
        );

    await pressKeys(tester, LogicalKeyboardKey.bracketRight,
        primary: true, alt: true);
    expect(c.read(activeTabIndexProvider), 1);
    await flushTabSaves(tester);
  }, variant: mac);

  testWidgets('⌥⌘] behind Settings does nothing', (tester) async {
    final c = await pumpWithTabs(tester);
    c.read(overlayStackProvider.notifier).push(
          DismissibleOverlay(id: SettingsDialog.overlayId, dismiss: () {}),
        );

    await pressKeys(tester, LogicalKeyboardKey.bracketRight,
        primary: true, alt: true);
    expect(c.read(activeTabIndexProvider), 0);
    await flushTabSaves(tester);
  }, variant: mac);

  testWidgets('⌥⌘W behind Settings keeps the tab', (tester) async {
    final c = await pumpWithTabs(tester);
    c.read(overlayStackProvider.notifier).push(
          DismissibleOverlay(id: SettingsDialog.overlayId, dismiss: () {}),
        );

    await pressKeys(tester, LogicalKeyboardKey.keyW, primary: true, alt: true);
    expect(c.read(tabsProvider), hasLength(2));
    await flushTabSaves(tester);
  }, variant: mac);
}
