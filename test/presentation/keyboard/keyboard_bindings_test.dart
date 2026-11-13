import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/core/localization/l10n/app_localizations.dart';
import 'package:the_wisdom_project/presentation/keyboard/keyboard_bindings.dart';
import 'package:the_wisdom_project/presentation/keyboard/shortcut_intents.dart';

/// The one shortcut list (`docs/done/reader/keyboard-shortcuts-sheet.md`,
/// rules 1–3): one modifier per platform, desktop-only keys off desktop, and
/// a label for every row the Settings tab shows.
void main() {
  Iterable<SingleActivator> activators() =>
      shortcutMap(defaultTargetPlatform).keys.cast<SingleActivator>();

  testWidgets('macOS registers only ⌘', (tester) async {
    expect(activators().any((a) => a.control), isFalse);
    expect(
      activators().any(
          (a) => a.trigger == LogicalKeyboardKey.keyF && a.meta && !a.shift),
      isTrue,
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('Windows registers only Ctrl', (tester) async {
    expect(activators().any((a) => a.meta), isFalse);
    expect(
      activators().any(
          (a) => a.trigger == LogicalKeyboardKey.keyF && a.control && !a.shift),
      isTrue,
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('Android keeps only the existing five', (tester) async {
    expect(
      shortcutsFor(defaultTargetPlatform)
          .map((s) => s.intent.runtimeType)
          .toSet(),
      {
        DismissTopOverlayIntent,
        OpenInPageSearchIntent,
        OpenMainSearchIntent,
        CloseActiveTabIntent,
        SmartCopyIntent,
      },
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  test('every listed entry has a label in English and Sinhala', () {
    for (final locale in const [Locale('en'), Locale('si')]) {
      final l10n = lookupAppLocalizations(locale);
      for (final s in appShortcuts.where((s) => s.group != null)) {
        expect(s.label!(l10n), isNotEmpty);
      }
    }
  });
}
