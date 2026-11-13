import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_wisdom_project/core/theme/theme_notifier.dart';
import 'package:the_wisdom_project/presentation/providers/app_section_provider.dart';
import 'package:the_wisdom_project/presentation/providers/navigator_visibility_provider.dart';
import 'package:the_wisdom_project/presentation/providers/overlay_stack_provider.dart';
import 'package:the_wisdom_project/presentation/widgets/settings/settings_dialog.dart';

import 'shortcut_test_host.dart';

/// Text size (⌘+ ⌘− ⌘0) and the navigator (⌘B)
/// (`docs/todo/reader/keyboard-shortcuts-sheet.md`).
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final mac = TargetPlatformVariant.only(TargetPlatform.macOS);

  testWidgets('⌘+ and ⌘⇧= step up by 0.1 without drift', (tester) async {
    final c = await pumpShortcutHost(tester, home: const Scaffold());
    await c.read(fontScaleProvider.notifier).setScale(0.9);

    await pressKeys(tester, LogicalKeyboardKey.equal, primary: true);
    expect(c.read(fontScaleProvider), 1.0);

    await pressKeys(tester, LogicalKeyboardKey.equal,
        primary: true, shift: true);
    expect(c.read(fontScaleProvider), 1.1);
  }, variant: mac);

  // A browser names ⇧= by the character it types, so it arrives as `add`.
  testWidgets('⌘⇧= from a browser, as +, steps up', (tester) async {
    final c = await pumpShortcutHost(tester, home: const Scaffold());
    await c.read(fontScaleProvider.notifier).setScale(0.9);

    await pressKeys(tester, LogicalKeyboardKey.add,
        primary: true, shift: true, physicalKey: PhysicalKeyboardKey.equal);
    expect(c.read(fontScaleProvider), 1.0);
  }, variant: mac);

  testWidgets('⌘+ stops at 1.5', (tester) async {
    final c = await pumpShortcutHost(tester, home: const Scaffold());
    await c.read(fontScaleProvider.notifier).setScale(1.45);

    await pressKeys(tester, LogicalKeyboardKey.equal, primary: true);
    expect(c.read(fontScaleProvider), 1.5);
    await pressKeys(tester, LogicalKeyboardKey.equal, primary: true);
    expect(c.read(fontScaleProvider), 1.5);
  }, variant: mac);

  testWidgets('⌘− steps down, ⌘0 resets', (tester) async {
    final c = await pumpShortcutHost(tester, home: const Scaffold());
    final notifier = c.read(fontScaleProvider.notifier);
    await notifier.setScale(1.0);

    await pressKeys(tester, LogicalKeyboardKey.minus, primary: true);
    expect(c.read(fontScaleProvider), 0.9);

    await pressKeys(tester, LogicalKeyboardKey.digit0, primary: true);
    expect(c.read(fontScaleProvider), notifier.platformDefault);
  }, variant: mac);

  testWidgets('⌘B toggles the navigator', (tester) async {
    final c = await pumpShortcutHost(tester, home: const Scaffold());
    expect(c.read(navigatorVisibleProvider), isTrue);

    await pressKeys(tester, LogicalKeyboardKey.keyB, primary: true);
    expect(c.read(navigatorVisibleProvider), isFalse);
    await pressKeys(tester, LogicalKeyboardKey.keyB, primary: true);
    expect(c.read(navigatorVisibleProvider), isTrue);
  }, variant: mac);

  testWidgets('⌘B does nothing outside the Reader or behind a dialog',
      (tester) async {
    final c = await pumpShortcutHost(tester, home: const Scaffold());

    c.read(selectedAppSectionProvider.notifier).state = AppSection.research;
    await pressKeys(tester, LogicalKeyboardKey.keyB, primary: true);
    expect(c.read(navigatorVisibleProvider), isTrue);

    c.read(selectedAppSectionProvider.notifier).state = AppSection.reader;
    c.read(overlayStackProvider.notifier).push(
          DismissibleOverlay(id: SettingsDialog.overlayId, dismiss: () {}),
        );
    await pressKeys(tester, LogicalKeyboardKey.keyB, primary: true);
    expect(c.read(navigatorVisibleProvider), isTrue);
  }, variant: mac);
}
