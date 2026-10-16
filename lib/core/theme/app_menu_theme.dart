import 'package:flutter/material.dart';

/// The look every dropdown menu shares (`MenuAnchor` and its submenus): the
/// search match options and the reader's toolbar menus.
abstract final class AppMenuTheme {
  /// Height a divider between two groups of menu rows takes.
  static const double dividerHeight = 13;

  /// Set as `ThemeData.menuTheme`, so a menu needs no style of its own.
  static MenuThemeData of(ColorScheme colors) => MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(colors.surface),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 8),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colors.outline),
            ),
          ),
        ),
      );

  /// Background of the row that holds the current choice.
  static Color selectedRowColor(ColorScheme colors) =>
      colors.surfaceContainerLow;
}
