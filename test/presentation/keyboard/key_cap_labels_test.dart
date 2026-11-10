import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/presentation/keyboard/key_cap_labels.dart';
import 'package:the_wisdom_project/presentation/keyboard/keyboard_bindings.dart';

/// What the Keyboard shortcuts tab prints on each key cap: Apple's symbols
/// in Apple's order on a Mac, words elsewhere.
void main() {
  const closeTab =
      ShortcutKeys(LogicalKeyboardKey.keyW, primary: true, alt: true);

  test('Mac uses symbols in Apple order', () {
    const search =
        ShortcutKeys(LogicalKeyboardKey.keyF, primary: true, shift: true);
    expect(keyCapLabels(closeTab, TargetPlatform.macOS), ['⌥', '⌘', 'W']);
    expect(keyCapLabels(search, TargetPlatform.macOS), ['⇧', '⌘', 'F']);
  });

  test('Windows uses words', () {
    expect(
      keyCapLabels(closeTab, TargetPlatform.windows),
      ['Ctrl', 'Alt', 'W'],
    );
  });

  test('special keys', () {
    const pageUp = ShortcutKeys(LogicalKeyboardKey.pageUp);
    const previousSutta =
        ShortcutKeys(LogicalKeyboardKey.comma, primary: true, alt: true);
    const smaller = ShortcutKeys(LogicalKeyboardKey.minus, primary: true);
    expect(keyCapLabels(pageUp, TargetPlatform.macOS), ['fn', '↑']);
    expect(keyCapLabels(pageUp, TargetPlatform.windows), ['PgUp']);
    expect(
      keyCapLabels(previousSutta, TargetPlatform.macOS),
      ['⌥', '⌘', '<'],
    );
    // U+2212 MINUS SIGN, not the hyphen the key types.
    expect(keyCapLabels(smaller, TargetPlatform.windows), ['Ctrl', '−']);
  });
}
