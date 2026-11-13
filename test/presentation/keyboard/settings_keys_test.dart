import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/presentation/widgets/settings/general_settings_page.dart';
import 'package:the_wisdom_project/presentation/widgets/settings/keyboard_shortcuts_page.dart';
import 'package:the_wisdom_project/presentation/widgets/settings/settings_dialog.dart';

import '../../helpers/test_view.dart';
import 'shortcut_test_host.dart';

/// ⌘, opens Settings and ⌘/ opens it on the shortcut list, from anywhere
/// (`docs/done/reader/keyboard-shortcuts-sheet.md`).
void main() {
  Future<void> pumpHost(WidgetTester tester) async {
    tester.useWindow(const Size(1024, 800));
    await pumpShortcutHost(tester, home: const Scaffold());
  }

  testWidgets('⌘, opens Settings on General', (tester) async {
    await pumpHost(tester);

    await pressKeys(tester, LogicalKeyboardKey.comma, primary: true);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsDialog), findsOneWidget);
    expect(find.byType(GeneralSettingsPage), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('⌘/ opens Settings on Keyboard shortcuts', (tester) async {
    await pumpHost(tester);

    await pressKeys(tester, LogicalKeyboardKey.slash, primary: true);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsDialog), findsOneWidget);
    expect(find.byType(KeyboardShortcutsPage), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('⌘/ with Settings open does nothing', (tester) async {
    await pumpHost(tester);

    await pressKeys(tester, LogicalKeyboardKey.comma, primary: true);
    await tester.pumpAndSettle();
    await pressKeys(tester, LogicalKeyboardKey.slash, primary: true);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsDialog), findsOneWidget);
    expect(find.byType(GeneralSettingsPage), findsOneWidget);
    expect(find.byType(KeyboardShortcutsPage), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('Ctrl+, opens Settings on Windows', (tester) async {
    await pumpHost(tester);

    await pressKeys(tester, LogicalKeyboardKey.comma, primary: true);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsDialog), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
}
