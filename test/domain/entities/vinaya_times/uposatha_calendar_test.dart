import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/domain/entities/vinaya_times/uposatha_calendar.dart';
import 'package:the_wisdom_project/domain/entities/vinaya_times/uposatha_day.dart';

// The 2026 dates are the plan's (docs/todo/vinaya-times/) and the fortnights
// below follow its inputs; both rest on the Buddhist Sun table until a
// Na-Uyana sheet confirms them.
void main() {
  const full = MoonPhase.fullMoon;
  const newMoon = MoonPhase.newMoon;

  test('the 2026 uposathas are the reference dates', () {
    // 2026 is an extra-month year: its Gimhāna has ten fortnights, not eight.
    final expected = [
      (DateTime.utc(2026, 1, 3), full),
      (DateTime.utc(2026, 1, 18), newMoon),
      (DateTime.utc(2026, 2, 2), full),
      (DateTime.utc(2026, 2, 16), newMoon),
      (DateTime.utc(2026, 3, 3), full),
      (DateTime.utc(2026, 3, 18), newMoon),
      (DateTime.utc(2026, 4, 2), full),
      (DateTime.utc(2026, 4, 16), newMoon),
      (DateTime.utc(2026, 5, 1), full),
      (DateTime.utc(2026, 5, 16), newMoon),
      (DateTime.utc(2026, 5, 31), full),
      (DateTime.utc(2026, 6, 14), newMoon),
      (DateTime.utc(2026, 6, 29), full),
      (DateTime.utc(2026, 7, 14), newMoon),
      (DateTime.utc(2026, 7, 29), full),
      (DateTime.utc(2026, 8, 13), newMoon),
      (DateTime.utc(2026, 8, 28), full),
      (DateTime.utc(2026, 9, 11), newMoon),
      (DateTime.utc(2026, 9, 26), full),
      (DateTime.utc(2026, 10, 11), newMoon),
      (DateTime.utc(2026, 10, 26), full),
      (DateTime.utc(2026, 11, 9), newMoon),
      (DateTime.utc(2026, 11, 24), full),
      (DateTime.utc(2026, 12, 9), newMoon),
      (DateTime.utc(2026, 12, 24), full),
    ];

    final actual = UposathaCalendar.days
        .where((uposatha) => uposatha.date.year == 2026)
        .map((uposatha) => (uposatha.date, uposatha.phase))
        .toList();

    expect(actual, expected);
  });

  // Every fortnight in the calendar: one line per Sangha year (named after its
  // Gimhāna, so it starts the November before), one group per season, in the
  // order Hemanta, Gimhāna, Vassāna. 4 is a 14-day fortnight, 5 a 15-day one.
  // A changed input moves dates, so it changes its year's line here too.
  const fortnights = [
    '55455545 5545554555 55455545', // 2026, extra month
    '55455545 55455545 55455545', // 2027
    '55455545 55455545 55455545', // 2028
    '55455545 5545554555 55455545', // 2029, extra month
    '55455545 55455545 55455545', // 2030
    '55455545 5545554555 55455545', // 2031, extra month
    '55455545 55455555 55455545', // 2032, extra day
    '55455545 55455545 55455545', // 2033
    '55455545 5545554555 55455545', // 2034, extra month
    '55455545 554555', // 2035, to 20 Jun: its extra day is in doubt
  ];

  test('every uposatha follows from the fortnights above', () {
    // Counted on from the seed, the Kattika full moon of 5 Nov 2025.
    var date = DateTime.utc(2025, 11, 5);
    final expected = <(DateTime, MoonPhase, int)>[];
    for (final digit in fortnights.join().replaceAll(' ', '').split('')) {
      final length = digit == '4' ? 14 : 15;
      date = date.add(Duration(days: length));
      expected.add((date, expected.length.isEven ? newMoon : full, length));
    }

    final actual = UposathaCalendar.days
        .map((day) => (day.date, day.phase, day.fortnightDays))
        .toList();

    expect(actual, expected);
  });
}
