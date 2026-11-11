import 'package:flutter/services.dart';

import 'keyboard_bindings.dart';

/// The text on each key cap of [keys], for the Keyboard shortcuts tab.
///
/// Mac: Apple's symbols in Apple's order (⌃ ⌥ ⇧ ⌘; this app has no ⌃).
/// Elsewhere: Ctrl, Alt, Shift. [keyCap], when given, stands in for the
/// key's own label (the previous/next text keys' < and >).
List<String> keyCapLabels(
  ShortcutKeys keys,
  TargetPlatform platform, {
  String? keyCap,
}) {
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
    keyCap ?? _keyLabel(keys.key),
  ];
}

/// Every way to press [keys], as key caps. One, except Page Up / Page Down on
/// a Mac: laptops have no such keys, and fn plus an arrow sends them.
List<List<String>> keyCapWays(
  ShortcutKeys keys,
  TargetPlatform platform, {
  String? keyCap,
}) {
  final caps = keyCapLabels(keys, platform, keyCap: keyCap);
  final arrow = switch (keys.key) {
    LogicalKeyboardKey.pageUp => '↑',
    LogicalKeyboardKey.pageDown => '↓',
    _ => null,
  };
  if (arrow == null || !usesCommandKey(platform)) return [caps];
  return [
    caps,
    [...caps.take(caps.length - 1), 'fn', arrow],
  ];
}

String _keyLabel(LogicalKeyboardKey key) {
  if (key == LogicalKeyboardKey.equal) return '+';
  if (key == LogicalKeyboardKey.minus) return '−'; // − sign
  if (key == LogicalKeyboardKey.arrowUp) return '↑';
  if (key == LogicalKeyboardKey.arrowDown) return '↓';
  if (key == LogicalKeyboardKey.escape) return 'Esc';
  if (key == LogicalKeyboardKey.tab) return 'Tab';
  if (key == LogicalKeyboardKey.pageUp) return 'PgUp';
  if (key == LogicalKeyboardKey.pageDown) return 'PgDn';
  return key.keyLabel.toUpperCase();
}
