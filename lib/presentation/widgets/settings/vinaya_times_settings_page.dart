import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/vinaya_times/city.dart';
import '../../../domain/entities/vinaya_times/dawn_method.dart';
import '../../providers/vinaya_times_provider.dart';
import '../common/vinaya_times_labels.dart';
import 'settings_row.dart';

/// Settings → Time: the city and the dawn method behind the Today
/// card, each option shown with the time it gives.
class VinayaTimesSettingsPage extends ConsumerWidget {
  const VinayaTimesSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final city = ref.watch(vinayaTimesCityProvider);
    final method = ref.watch(dawnMethodProvider);
    final sunTimes = ref.watch(sunTimesRepositoryProvider);

    // Watched so the times roll over with the day while the dialog is open.
    final today = City.dayAt(ref.watch(minuteClockProvider));
    final tomorrow = today.add(const Duration(days: 1));

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        settingsGutter,
        0,
        settingsGutter,
        24,
      ),
      children: [
        // The tab is named just "Time", which could read as a clock setting.
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SettingsProse(l10n.vinayaTimesIntro),
        ),
        SettingsSection(
          title: l10n.vinayaTimesLocation,
          hint: l10n.vinayaTimesLocationHint,
          children: [
            for (final option in City.values)
              SettingsRow(
                label: option.label(l10n),
                onTap: () =>
                    ref.read(vinayaTimesCityProvider.notifier).choose(option),
                trailing: _Choice(
                  value: l10n.vinayaTimesMiddayAt(
                    clockTime(sunTimes.sunDay(today, option, method).midday),
                  ),
                  selected: option == city,
                ),
                showDivider: option != City.values.last,
              ),
          ],
        ),
        SettingsSection(
          title: l10n.vinayaTimesDawn,
          hint: l10n.vinayaTimesDawnHint(city.label(l10n)),
          children: [
            for (final option in DawnMethod.values)
              SettingsRow(
                label: option.label(l10n),
                hint: option.rule(l10n),
                onTap: () =>
                    ref.read(dawnMethodProvider.notifier).choose(option),
                trailing: _Choice(
                  value:
                      clockTime(sunTimes.sunDay(tomorrow, city, option).dawn),
                  selected: option == method,
                ),
                showDivider: option != DawnMethod.values.last,
              ),
          ],
        ),
        const SizedBox(height: 20),
        _Summary(
          title: l10n.vinayaTimesSummaryTitle(city.label(l10n)),
          midday: l10n.vinayaTimesMiddayAt(
            clockTime(sunTimes.sunDay(today, city, method).midday),
          ),
          vikala: l10n.vinayaTimesSummaryVikala(
            clockTime(sunTimes.sunDay(tomorrow, city, method).dawn),
          ),
        ),
        const SizedBox(height: 12),
        SettingsProse(l10n.vinayaTimesCalendarNote),
      ],
    );
  }
}

/// A pick-one row's trailing end: the time the option gives, and a tick on
/// the chosen one. Read out as a radio button with the row's label.
class _Choice extends StatelessWidget {
  const _Choice({required this.value, required this.selected});

  final String value;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: context.typography.menuSectionLabel.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 12),
          // Kept when empty, so the times stay in one column.
          SizedBox(
            width: 20,
            child: selected
                ? Icon(Icons.check, size: 20, color: colors.primary)
                : null,
          ),
        ],
      ),
    );
  }
}

/// What the two choices above come to for today.
class _Summary extends StatelessWidget {
  const _Summary({
    required this.title,
    required this.midday,
    required this.vikala,
  });

  final String title;
  final String midday;
  final String vikala;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final typography = context.typography;
    final value = typography.resultTitle.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: typography.menuSectionLabel),
          const SizedBox(height: 6),
          Wrap(
            spacing: 24,
            runSpacing: 4,
            children: [
              Text(midday, style: value),
              Text(vikala, style: value),
            ],
          ),
        ],
      ),
    );
  }
}
