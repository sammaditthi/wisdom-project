/// The shape every [SegmentedButton] shares, added with the Settings dialog.
///
/// It is set on all three themes, so the one thing worth pinning is that none
/// of them was missed — a theme without it falls back to Material 3's stadium
/// and the app has two different segmented looks depending on the theme.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/core/theme/app_theme.dart';

void main() {
  /// The radius the theme asks for, or null when the theme sets no shape.
  double? radiusOf(ThemeData theme) {
    final shape = theme.segmentedButtonTheme.style?.shape?.resolve({});
    if (shape is! RoundedRectangleBorder) return null;
    return (shape.borderRadius as BorderRadius).topLeft.x;
  }

  test('all three themes give segmented buttons the same soft rectangle', () {
    final themes = {
      'light': AppTheme.light(),
      'dark': AppTheme.dark(),
      'warm': AppTheme.warm(),
    };

    for (final entry in themes.entries) {
      expect(radiusOf(entry.value), 8,
          reason: '${entry.key} does not carry the shared shape');
    }
  });

  test('a button that passes its own shape still wins', () {
    // What the search Refine dialog's language toggle relies on: it keeps the
    // pill it shares with the filter chips beside it. The theme is a default,
    // not an override — Flutter resolves the widget's own style first.
    const own = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(100)),
    );
    final merged = const ButtonStyle(
      shape: WidgetStatePropertyAll(own),
    ).merge(AppTheme.light().segmentedButtonTheme.style);

    expect(merged.shape?.resolve({}), own);
  });
}
