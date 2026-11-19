import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/core/localization/l10n/app_localizations.dart';
import 'package:the_wisdom_project/core/theme/app_theme.dart';
import 'package:the_wisdom_project/data/repositories/sun_times_repository_impl.dart';
import 'package:the_wisdom_project/domain/entities/vinaya_times/city.dart';
import 'package:the_wisdom_project/domain/entities/vinaya_times/dawn_method.dart';
import 'package:the_wisdom_project/presentation/providers/vinaya_times_provider.dart';
import 'package:the_wisdom_project/presentation/widgets/home/today_card.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/stopped_clock.dart';
import '../../../helpers/test_view.dart';

// The card works out midday's countdown itself, so its words are tested here.
// The app's clock and midday both fall on whole minutes, so only a stopped
// clock reaches the in-between cases; they keep the rounding up honest should
// either change.
void main() {
  // Midday on 24 Nov 2026 in the default city.
  final midday = const SunTimesRepositoryImpl()
      .sunDay(DateTime.utc(2026, 11, 24), City.fallback, DawnMethod.fallback)
      .midday;

  Future<AppLocalizations> pumpCard(WidgetTester tester, Duration left) async {
    tester.useWindow(const Size(800, 1200));
    await tester.pumpApp(
      const TodayCard(),
      overrides: [
        minuteClockProvider
            .overrideWith((ref) => StoppedClock(midday.subtract(left))),
      ],
      theme: AppTheme.light(),
    );
    return AppLocalizations.of(tester.element(find.byType(TodayCard)));
  }

  testWidgets('40 s before midday reads "1 min", never "0 min"',
      (tester) async {
    final l10n = await pumpCard(tester, const Duration(seconds: 40));
    expect(find.text(l10n.vinayaTimesMiddayIn(1)), findsOneWidget);
  });

  testWidgets('59 min 30 s before midday rounds up to a whole "1 h"',
      (tester) async {
    final l10n =
        await pumpCard(tester, const Duration(minutes: 59, seconds: 30));
    expect(find.text(l10n.vinayaTimesMiddayInWholeHours(1)), findsOneWidget);
  });

  testWidgets('75 min before midday reads "1 h 15 min"', (tester) async {
    final l10n = await pumpCard(tester, const Duration(minutes: 75));
    expect(find.text(l10n.vinayaTimesMiddayInHours(1, 15)), findsOneWidget);
  });
}
