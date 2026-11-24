import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_menu_theme.dart';
import '../../../core/theme/app_typography.dart';

/// A menu row: a glyph and a one-line label, with an optional [note] under it
/// in small grey text. With [selected] set, the row is one choice of a set,
/// tinted, bold and ticked when true.
class MenuRow extends StatelessWidget {
  final Widget icon;
  final String label;
  final String? note;
  final VoidCallback onSelected;
  final bool? selected;

  const MenuRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onSelected,
    this.note,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final typography = context.typography;
    final rowStyle = typography.listRowTitle;
    final isSelected = selected ?? false;

    return MenuItemButton(
      onPressed: onSelected,
      style: isSelected
          ? MenuItemButton.styleFrom(
              backgroundColor: AppMenuTheme.selectedRowColor(colorScheme),
            )
          : null,
      // Lines up glyphs of different widths (icons, letters).
      leadingIcon: SizedBox(width: 24, child: Center(child: icon)),
      trailingIcon: isSelected
          ? Icon(Icons.check, size: 18, color: colorScheme.onPrimaryContainer)
          : null,
      // A choice is read out like a radio button.
      child: Semantics(
        checked: selected,
        inMutuallyExclusiveGroup: selected == null ? null : true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: isSelected
                  ? rowStyle.copyWith(fontWeight: FontWeight.w600)
                  : rowStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (note != null)
              Text(
                note!,
                // The menu's grey hint style at the app's smallest size.
                style: typography.menuSectionLabel.copyWith(
                  fontSize: typography.countBadge.fontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
