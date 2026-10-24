import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisdom_shared/wisdom_shared.dart' show beautifyPaliText;

import '../../../core/localization/app_language.dart';
import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/text_entry_theme.dart';
import '../../../core/theme/theme_notifier.dart';
import '../../../core/version/app_version.gen.dart';
import '../../../domain/entities/content/content_language.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/content_language_provider.dart';
import '../../providers/pali_letter_options_provider.dart';
import 'settings_row.dart';

/// Settings → General: appearance, language, Pali letters and the version.
///
/// Everything here applies app-wide. The settings you change while reading
/// (font size, hide navigation bar) stay in the reader's own menu.
class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        settingsGutter,
        0,
        settingsGutter,
        24,
      ),
      children: [
        SettingsSection(
          title: l10n.settingsAppearance,
          isFirst: true,
          children: [
            SettingsRow(
              label: l10n.theme,
              hint: l10n.themeDarkComingSoon,
              // A SegmentedButton is several controls in one row.
              mergeSemantics: false,
              trailing: const _ThemeSelector(),
            ),
          ],
        ),
        SettingsSection(
          title: l10n.settingsLanguage,
          children: [
            SettingsRow(
              label: l10n.appLanguage,
              hint: l10n.appLanguageHint,
              mergeSemantics: false,
              trailing: const _AppLanguageSelector(),
            ),
            SettingsRow(
              label: l10n.contentLanguage,
              hint: l10n.contentLanguageHint,
              mergeSemantics: false,
              trailing: const _ContentLanguageSelector(),
            ),
          ],
        ),
        SettingsSection(
          title: l10n.paliLetters,
          hint: l10n.paliLettersHint,
          children: const [
            _PaliLettersSample(),
            SizedBox(height: 4),
            _PaliLettersSwitches(),
          ],
        ),
        SettingsSection(
          title: l10n.settingsAbout,
          children: [
            SettingsRow(
              label: l10n.versionLabel,
              trailing: Text(
                AppVersion.display,
                style: context.typography.menuSectionLabel,
              ),
              showDivider: false,
            ),
          ],
        ),
      ],
    );
  }
}

/// Theme selection.
///
/// Dark is shown but not selectable: [AppThemeMode.dark] is still the old
/// near-black theme, and the warm dark that replaces it is the next piece of
/// work (`docs/todo/theme/warm-dark-theme.md`). Turning it on is deleting
/// `enabled: false` here and the hint on the row.
class _ThemeSelector extends ConsumerWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final l10n = AppLocalizations.of(context);

    return SegmentedButton<AppThemeMode>(
      segments: [
        // Icon only: two themes need no words. The name is the tooltip, which
        // is also what a screen reader announces for the segment.
        ButtonSegment(
          value: AppThemeMode.light,
          icon: const Icon(Icons.light_mode_outlined, size: 18),
          tooltip: l10n.themeLight,
        ),
        ButtonSegment(
          value: AppThemeMode.dark,
          icon: const Icon(Icons.dark_mode_outlined, size: 18),
          tooltip: l10n.themeDark,
          enabled: false,
        ),
        // Carried over from the reader menu this selector came from:
        // AppThemeMode.warm exists and AppTheme.warm() builds, but it has
        // never been offered.
        // ButtonSegment(
        //   value: AppThemeMode.warm,
        //   label: Text('Warm'),
        //   icon: Icon(Icons.palette, size: 16),
        // ),
      ],
      selected: {currentTheme},
      showSelectedIcon: false,
      onSelectionChanged: (newSelection) {
        ref.read(themeNotifierProvider.notifier).setTheme(newSelection.first);
      },
    );
  }
}

/// App Language (UI localization) selector.
///
/// Options are self-labelled in their own language — standard for a language
/// picker — so a user can always find their language regardless of the current
/// UI language.
class _AppLanguageSelector extends ConsumerWidget {
  const _AppLanguageSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(appLanguageProvider);

    return SegmentedButton<AppLanguage>(
      segments: const [
        ButtonSegment(value: AppLanguage.english, label: Text('English')),
        ButtonSegment(value: AppLanguage.sinhala, label: Text('සිංහල')),
      ],
      selected: {current},
      showSelectedIcon: false,
      onSelectionChanged: (newSelection) {
        ref.read(appLanguageProvider.notifier).setLanguage(newSelection.first);
      },
    );
  }
}

/// Content Language selector.
///
/// The available options come from the active edition (BJT → Pali, Sinhala).
/// Labels are localized so they follow the App Language. `selected` reads the
/// *effective* value (clamped to the edition), while changes write the raw
/// preference.
class _ContentLanguageSelector extends ConsumerWidget {
  const _ContentLanguageSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final available = ref.watch(availableContentLanguagesProvider);
    final current = ref.watch(effectiveContentLanguageProvider);

    return SegmentedButton<ContentLanguage>(
      segments: [
        for (final language in available)
          ButtonSegment(
            value: language,
            label: Text(_contentLanguageLabel(language, l10n)),
          ),
      ],
      selected: {current},
      showSelectedIcon: false,
      onSelectionChanged: (newSelection) {
        ref
            .read(contentLanguageProvider.notifier)
            .setLanguage(newSelection.first);
      },
    );
  }

  /// Maps a [ContentLanguage] to its localized label.
  String _contentLanguageLabel(
      ContentLanguage language, AppLocalizations l10n) {
    switch (language) {
      case ContentLanguage.pali:
        return l10n.paliLanguageLabel;
      case ContentLanguage.sinhala:
        return l10n.sinhalaLanguageLabel;
    }
  }
}

/// A line of Pali that follows the three switches below it.
///
/// The words are the worked example from
/// `docs/done/language/pali-letter-settings-bandi-special-toggles.md`: between
/// them they exercise all three switches. Not an ARB string — Pali reads the
/// same under either App Language, so a key would put one identical line in
/// both files.
class _PaliLettersSample extends ConsumerWidget {
  const _PaliLettersSample();

  static const _sample = 'ධර්ම බුද්ධ ධම්ම චන්ද';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    // The same transformer and the same options object the reading pane uses,
    // so the sample cannot drift from the text it is previewing.
    final options = ref.watch(paliLetterOptionsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.settingsSample, style: context.typography.menuSectionLabel),
          const SizedBox(height: 2),
          Text(
            beautifyPaliText(_sample, options),
            style: context.textEntryTheme.paragraphStyle,
          ),
        ],
      ),
    );
  }
}

/// The three Pali-letter (conjunct) display switches.
///
/// Each switch flips one boolean provider; every text surface watches the
/// combined [paliLetterOptionsProvider], so the reading pane, the sample above
/// and all labels update the instant a switch is toggled.
class _PaliLettersSwitches extends ConsumerWidget {
  const _PaliLettersSwitches();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _SwitchRow(
          label: l10n.paliStandardLigatures,
          value: ref.watch(standardLigaturesProvider),
          onToggle: () => ref.read(standardLigaturesProvider.notifier).toggle(),
        ),
        _SwitchRow(
          label: l10n.paliSpecialLetters,
          value: ref.watch(specialConjunctsProvider),
          onToggle: () => ref.read(specialConjunctsProvider.notifier).toggle(),
        ),
        _SwitchRow(
          label: l10n.paliTouching,
          value: ref.watch(touchingProvider),
          onToggle: () => ref.read(touchingProvider.notifier).toggle(),
          showDivider: false,
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onToggle,
    this.showDivider = true,
  });

  final String label;
  final bool value;
  final VoidCallback onToggle;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      label: label,
      showDivider: showDivider,
      trailing: Switch(
        value: value,
        // The new value is always !value, so we ignore the arg and toggle.
        onChanged: (_) => onToggle(),
      ),
    );
  }
}
