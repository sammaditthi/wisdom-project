import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/presentation/widgets/settings/keyboard_shortcuts_page.dart';
import 'package:the_wisdom_project/presentation/widgets/settings/settings_row.dart';

import '../../../helpers/pump_app.dart';

/// The Keyboard shortcuts tab shows the keys of the platform it runs on
/// (`docs/todo/reader/keyboard-shortcuts-sheet.md`, rule 2).
void main() {
  testWidgets('Mac shows ⌘, not Ctrl', (tester) async {
    await tester.pumpAppWithScaffold(const KeyboardShortcutsPage());

    expect(find.text('⌘'), findsWidgets);
    expect(find.text('Ctrl'), findsNothing);
    expect(find.text('Find in page'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  // The , and . keys show as < and > only where they step through suttas.
  testWidgets('Open Settings shows a comma; the sutta keys show < and >',
      (tester) async {
    // Tall enough that the list builds every row.
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpAppWithScaffold(const KeyboardShortcutsPage());

    List<String> capsOf(String label) => tester
        .widgetList<Text>(find.descendant(
          of: find.widgetWithText(SettingsRow, label),
          matching: find.byType(Text),
        ))
        .map((t) => t.data!)
        .where((text) => text != label)
        .toList();

    expect(capsOf('Open Settings'), ['⌘', ',']);
    expect(capsOf('Previous sutta'), ['⌥', '⌘', '<']);
    expect(capsOf('Next sutta'), ['⌥', '⌘', '>']);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('Windows shows Ctrl, not ⌘', (tester) async {
    await tester.pumpAppWithScaffold(const KeyboardShortcutsPage());

    expect(find.text('Ctrl'), findsWidgets);
    expect(find.text('⌘'), findsNothing);
    expect(find.text('Find in page'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
}
