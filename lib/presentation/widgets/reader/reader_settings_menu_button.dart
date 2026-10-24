import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_notifier.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../providers/navigation_rail_provider.dart';

/// The reader toolbar's menu: only what you adjust while reading.
///
/// Everything that applies app-wide — theme, languages, Pali letters — lives
/// in the Settings dialog, opened from the gear on the navigation rail.
/// Hide navigation bar stays here on purpose: it is the way back once the rail
/// (and with it that gear) is hidden.
class ReaderSettingsMenuButton extends ConsumerWidget {
  const ReaderSettingsMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      icon: const Icon(Icons.tune),
      tooltip: l10n.readerSettings,
      onSelected: (value) {
        // Menu items are handled by their own callbacks
      },
      itemBuilder: (context) => [
        // Font size slider
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MenuSectionLabel((l10n) => l10n.fontSize),
              const SizedBox(height: 4),
              const _FontSizeSelector(),
            ],
          ),
        ),

        // Layout — only where the navigation rail exists (phones have none).
        if (ResponsiveUtils.isTabletOrDesktop(context)) ...[
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MenuSectionLabel((l10n) => l10n.appLayout),
                const SizedBox(height: 4),
                const _LayoutSection(),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// A localized section header inside the reader settings popup menu.
///
/// Why this is its own widget: the menu is a [PopupMenuButton], whose
/// `itemBuilder` runs only ONCE — when the menu opens. A plain `Text(l10n.xxx)`
/// built there would freeze at whatever App Language was active at open-time, so
/// switching the language with the menu open left stale headers until you closed
/// and reopened it.
///
/// Resolving [AppLocalizations.of] inside this widget's own `build` registers a
/// dependency on the [Localizations] ancestor. The open menu lives in the
/// navigator overlay (below that ancestor), so when the App Language changes —
/// which rebuilds the MaterialApp's [Localizations] — this header rebuilds with
/// it and the label switches live.
class _MenuSectionLabel extends StatelessWidget {
  const _MenuSectionLabel(this.selector);

  /// Picks the string to show, e.g. `(l10n) => l10n.fontSize`.
  final String Function(AppLocalizations l10n) selector;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Text(
      selector(l10n),
      style: context.typography.menuSectionLabel,
    );
  }
}

/// Font size slider with A-/A+ labels and reset button.
///
/// Label styles are intentionally NOT scaled — they stay fixed so the
/// slider UI remains stable while the user adjusts the scale.
class _FontSizeSelector extends ConsumerWidget {
  const _FontSizeSelector();

  /// Number of discrete steps between min and max (0.05 increments)
  static const int _scaleDivisions = 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = ref.watch(fontScaleProvider);
    final notifier = ref.read(fontScaleProvider.notifier);
    final colors = Theme.of(context).colorScheme;
    final isDefault = (scale - notifier.platformDefault).abs() < 0.01;
    final percentage = (scale * 100).round();
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Slider row: A- [slider] A+
        Row(
          children: [
            Text(
              'A-',
              style: TextStyle(
                fontFamily: AppFonts.ui,
                fontSize: AppFonts.labelFontSize,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 7),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 14),
                ),
                child: Slider(
                  value: scale.clamp(
                    FontScaleNotifier.minScale,
                    FontScaleNotifier.maxScale,
                  ),
                  min: FontScaleNotifier.minScale,
                  max: FontScaleNotifier.maxScale,
                  divisions: _scaleDivisions,
                  onChanged: (value) {
                    // Round to avoid floating point drift
                    final rounded = (value * 20).round() / 20; // nearest 0.05
                    notifier.setScale(rounded);
                  },
                ),
              ),
            ),
            Text(
              'A+',
              style: TextStyle(
                fontFamily: AppFonts.ui,
                fontSize: AppFonts.baseFontSize,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        // Percentage and reset row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$percentage%',
              style: TextStyle(
                fontFamily: AppFonts.ui,
                fontSize: AppFonts.labelFontSize,
                color: colors.onSurfaceVariant,
              ),
            ),
            if (!isDefault)
              TextButton(
                onPressed: () => notifier.reset(),
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 36),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.reset,
                  style: TextStyle(
                    fontFamily: AppFonts.ui,
                    fontSize: AppFonts.labelFontSize,
                    color: colors.primary,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Screen-layout switches.
class _LayoutSection extends ConsumerWidget {
  const _LayoutSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final railHidden = ref.watch(navigationRailHiddenProvider);
    return _MenuSwitch(
      label: l10n.hideNavigationBar,
      value: railHidden,
      onToggle: () =>
          ref.read(navigationRailHiddenProvider.notifier).state = !railHidden,
    );
  }
}

/// A single compact label + [Switch] row.
class _MenuSwitch extends StatelessWidget {
  const _MenuSwitch({
    required this.label,
    required this.value,
    required this.onToggle,
  });

  final String label;
  final bool value;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toggle = Switch(
      value: value,
      // The new value is always !value, so we ignore the arg and toggle.
      onChanged: (_) => onToggle(),
    );
    // The theme pads tap targets to 48px only on touch platforms.
    final isTouch = theme.materialTapTargetSize == MaterialTapTargetSize.padded;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // The M3 Switch has a fixed size and ignores visualDensity, so with a
        // mouse scale it down to match the menu's compact controls.
        if (isTouch)
          toggle
        else
          SizedBox(height: 28, child: FittedBox(child: toggle)),
      ],
    );
  }
}
