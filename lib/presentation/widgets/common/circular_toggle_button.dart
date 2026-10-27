import 'package:flutter/material.dart';

/// A circular toggle button with active/inactive visual states.
/// Used for binary toggles like exact match and proximity in search/dictionary UIs.
class CircularToggleButton extends StatelessWidget {
  final bool isActive;
  final IconData icon;

  /// Stroke weight, for a Symbols glyph that reads heavier than the classic
  /// icons beside it. Null takes the font's own. No effect on classic.
  final double? weight;

  final String? tooltip;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry margin;

  const CircularToggleButton({
    super.key,
    required this.isActive,
    required this.icon,
    required this.onPressed,
    this.weight,
    this.tooltip,
    this.margin = const EdgeInsets.only(left: 4),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: margin,
      child: IconButton(
        icon: Icon(icon, weight: weight),
        // Announces on/off, as PillChip.refine does for the chip form of the
        // same control.
        isSelected: isActive,
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: isActive ? theme.colorScheme.primaryContainer : null,
          foregroundColor: isActive
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
