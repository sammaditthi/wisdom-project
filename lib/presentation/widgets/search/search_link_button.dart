import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';

/// Muted text button, usually with a small trailing icon: "See all →",
/// "Show N more ⌄", "Show more ⌄", "dpdict.net ↗" and "Clear all". 40px tall,
/// so it is easy to tap.
class SearchLinkButton extends StatelessWidget {
  /// Space before the label. Callers subtract it to line the label up with
  /// the text above.
  static const double padding = 8;

  final String label;

  /// Null shows the label alone.
  final IconData? icon;
  final VoidCallback onPressed;

  const SearchLinkButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;

    return TextButton.icon(
      onPressed: onPressed,
      icon: icon == null ? null : Icon(icon, size: 16),
      iconAlignment: IconAlignment.end,
      // One line: where space runs short the label ends in "…", the icon stays.
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: TextButton.styleFrom(
        // A button ignores textStyle's colour; without this it paints primary.
        foregroundColor: context.typography.linkLabel.color,
        textStyle: context.typography.linkLabel,
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: padding),
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
