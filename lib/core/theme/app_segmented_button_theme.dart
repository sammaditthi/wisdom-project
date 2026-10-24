import 'package:flutter/material.dart';

/// The shape every [SegmentedButton] shares: a soft rectangle instead of
/// Material 3's stadium.
abstract final class AppSegmentedButtonTheme {
  /// Set as `ThemeData.segmentedButtonTheme`.
  ///
  /// `shape` is the whole bar's outline; the segments inside are clipped to
  /// it, so this one value rounds the ends and nothing else. A button that
  /// passes its own `shape` still wins — the search Refine dialog's language
  /// toggle keeps the pill it shares with the filter chips beside it.
  static const SegmentedButtonThemeData standard = SegmentedButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
  );
}
