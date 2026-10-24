import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';

/// Horizontal gutter every Settings page uses, so headers, rows and dividers
/// line up on one edge.
const double settingsGutter = 24.0;

/// A titled group of [SettingsRow]s.
///
/// The gap above the title is the group separator — the first group on a page
/// passes [isFirst] so it doesn't start with a hole under the dialog header.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    this.hint,
    this.isFirst = false,
    required this.children,
  });

  final String title;
  final String? hint;
  final bool isFirst;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(top: isFirst ? 8 : 28, bottom: 4),
          child: Text(
            title,
            // A section header and a row label are the same size; only the
            // weight separates them. Not `sectionHeader`, which is the
            // uppercase letter-spaced style the search panel uses.
            style: typography.resultTitle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (hint != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(hint!, style: typography.menuSectionLabel),
          ),
        ...children,
      ],
    );
  }
}

/// One setting: a label, an optional hint below it, an optional leading tile
/// and a trailing control, over a divider.
///
/// Tapping the row runs [onTap] where it is given — rows that only hold a
/// control (a switch, a segmented button) leave it null and let the control
/// take the tap. The row reads as one semantics node, so a screen reader says
/// the label with the control instead of announcing a nameless switch — except
/// where [mergeSemantics] is off.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    this.hint,
    this.leading,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.mergeSemantics = true,
  });

  final String label;
  final String? hint;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  /// Whether the row reads as a single semantics node.
  ///
  /// Off for a trailing control that is several controls at once (a
  /// [SegmentedButton]): merging runs their labels into one string, merges
  /// their conflicting selected states and leaves only the first segment able
  /// to receive a semantic tap.
  final bool mergeSemantics;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final typography = context.typography;

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: typography.resultTitle,
                ),
                if (hint != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(hint!, style: typography.menuSectionLabel),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 16),
            trailing!,
          ],
        ],
      ),
    );

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              child: content,
            ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        mergeSemantics ? MergeSemantics(child: row) : row,
        if (showDivider) Divider(height: 1, color: colors.outlineVariant),
      ],
    );
  }
}

/// The rounded square that carries a row's icon or a dictionary's
/// abbreviation on the Anumodanā page.
class SettingsTile extends StatelessWidget {
  const SettingsTile({super.key, this.icon, this.text})
      : assert(icon != null || text != null, 'a tile needs an icon or text');

  final IconData? icon;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: icon != null
          ? Icon(icon, size: 20, color: colors.primary)
          // The tile is a fixed square but `badgeLabel` follows the font-size
          // slider, so at 1.5x a four-letter abbreviation ("DPDC") is wider
          // than the tile. Shrink the text rather than widen the tile, which
          // would push one row's label out of line with the rest.
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text!,
                  maxLines: 1,
                  style: context.typography.badgeLabel.copyWith(
                    color: colors.primary,
                  ),
                ),
              ),
            ),
    );
  }
}
