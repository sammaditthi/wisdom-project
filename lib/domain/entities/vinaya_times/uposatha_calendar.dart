import 'uposatha_day.dart';

enum _Season { hemanta, gimhana, vassana }

/// The Sangha uposatha calendar, counted out by rule from one known full moon.
///
/// A year is three seasons of eight fortnights, each fortnight ending on an
/// uposatha: new moon first, then full moon, and so on. A fortnight has 15
/// days, except the 3rd and 7th of a season, which have 14. The rule's
/// sources and checks are in the Vinaya times plan under `docs/`.
class UposathaCalendar {
  const UposathaCalendar._();

  /// The Kattika full moon that closes the year before [_firstYear].
  static final _seed = DateTime.utc(2025, 11, 5);

  /// A year is named after the calendar year its Gimhāna falls in; it begins
  /// the November before.
  static const _firstYear = 2026;

  /// Years whose Gimhāna gets two more 15-day fortnights.
  static const _extraMonthYears = {2026, 2029, 2031, 2034};

  /// Years whose 7th Gimhāna fortnight has 15 days instead of 14.
  static const _extraDayYears = {2032};

  /// The last uposatha before 2035's extra day, which is in doubt.
  static final _lastDate = DateTime.utc(2035, 6, 20);

  /// Every uposatha from the seed to [_lastDate], oldest first.
  static final List<UposathaDay> days = List.unmodifiable(_build());

  /// The first [count] uposathas on or after [day], soonest first: fewer near
  /// the calendar's end, none past it.
  static List<UposathaDay> upcoming(DateTime day, int count) => days
      .where((uposatha) => !uposatha.date.isBefore(day))
      .take(count)
      .toList();

  static List<UposathaDay> _build() {
    final days = <UposathaDay>[];
    var date = _seed;
    for (var year = _firstYear;; year++) {
      for (final season in _Season.values) {
        final isGimhana = season == _Season.gimhana;
        final extraMonth = isGimhana && _extraMonthYears.contains(year);
        final extraDay = isGimhana && _extraDayYears.contains(year);
        for (var n = 1; n <= (extraMonth ? 10 : 8); n++) {
          final isShort = n == 3 || (n == 7 && !extraDay);
          final length = isShort ? 14 : 15;
          date = date.add(Duration(days: length));
          if (date.isAfter(_lastDate)) return days;
          days.add(
            UposathaDay(
              date: date,
              phase: n.isOdd ? MoonPhase.newMoon : MoonPhase.fullMoon,
              fortnightDays: length,
            ),
          );
        }
      }
    }
  }
}
