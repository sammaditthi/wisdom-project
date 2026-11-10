import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/presentation/widgets/settings/keyboard_shortcuts_page.dart';

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

  testWidgets('Windows shows Ctrl, not ⌘', (tester) async {
    await tester.pumpAppWithScaffold(const KeyboardShortcutsPage());

    expect(find.text('Ctrl'), findsWidgets);
    expect(find.text('⌘'), findsNothing);
    expect(find.text('Find in page'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
}
