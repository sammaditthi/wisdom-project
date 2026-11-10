import 'package:flutter/services.dart';

import 'keyboard_bindings.dart';

/// The text on each key cap of [keys], for the Keyboard shortcuts tab.
///
/// Mac: Apple's symbols in Apple's order (⌃ ⌥ ⇧ ⌘; this app has no ⌃).
/// Elsewhere: Ctrl, Alt, Shift. The comma and period keys show as < and >,
/// the direction they step in.
List<String> keyCapLabels(ShortcutKeys keys, TargetPlatform platform) {
  final mac = usesCommandKey(platform);
  return [
    if (mac) ...[
      if (keys.alt) '⌥',
      if (keys.shift) '⇧',
      if (keys.primary) '⌘',
    ] else ...[
      if (keys.primary) 'Ctrl',
      if (keys.alt) 'Alt',
      if (keys.shift) 'Shift',
    ],
    ..._keyLabels(keys.key, mac: mac),
  ];
}

List<String> _keyLabels(LogicalKeyboardKey key, {required bool mac}) {
  if (key == LogicalKeyboardKey.comma) return const ['<'];
  if (key == LogicalKeyboardKey.period) return const ['>'];
  if (key == LogicalKeyboardKey.equal) return const ['+'];
  if (key == LogicalKeyboardKey.minus) return const ['−']; // − sign
  if (key == LogicalKeyboardKey.arrowUp) return const ['↑'];
  if (key == LogicalKeyboardKey.arrowDown) return const ['↓'];
  if (key == LogicalKeyboardKey.escape) return const ['Esc'];
  if (key == LogicalKeyboardKey.tab) return const ['Tab'];
  // Mac laptops have no Page Up / Page Down; fn plus an arrow sends them.
  if (key == LogicalKeyboardKey.pageUp) {
    return mac ? const ['fn', '↑'] : const ['PgUp'];
  }
  if (key == LogicalKeyboardKey.pageDown) {
    return mac ? const ['fn', '↓'] : const ['PgDn'];
  }
  return [key.keyLabel.toUpperCase()];
}
