import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/data/repositories/sun_times_repository_impl.dart';
import 'package:the_wisdom_project/domain/entities/vinaya_times/city.dart';
import 'package:the_wisdom_project/domain/entities/vinaya_times/dawn_method.dart';

// The plan's *Reference values* (docs/todo/vinaya-times/), from an independent
// NOAA calculation: midday on 14 Nov 2026, aruṇa on 15 Nov 2026. The plan's
// seconds make these check the rounding too: Colombo's midday is 11:54:54 and
// must read 11:54 (down), Kandy's Na-Uyana is 05:28:10 and must read 05:29
// (up). Colombo's and Kurunegala's midday and Colombo's civil aruṇa sit within
// 3 s of a minute edge: if an nrel_spa upgrade flips one, re-check against the
// plan before editing it.
void main() {
  const sun = SunTimesRepositoryImpl();
  final middayDay = DateTime.utc(2026, 11, 14);
  final arunaDay = DateTime.utc(2026, 11, 15);

  // An instant as Sri Lanka's clock reads it, whatever the test machine's zone.
  // HH:mm alone reads an unrounded midday as one rounded down, so each time
  // must also be a whole minute.
  String sriLankaClock(DateTime instant) {
    expect(
      instant.microsecondsSinceEpoch % Duration.microsecondsPerMinute,
      0,
      reason: '$instant is not a whole minute',
    );
    final local = instant.toUtc().add(City.utcOffset);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.hour)}:${two(local.minute)}';
  }

  // City, midday, then aruṇa by Pa-Auk, Na-Uyana, civil twilight and sunrise
  // (the plan's Sunrise column, rounded up like every aruṇa).
  const reference = [
    (City.colombo, '11:54', '05:21', '05:31', '05:39', '06:01'),
    (City.kandy, '11:51', '05:19', '05:29', '05:37', '05:59'),
    (City.galle, '11:53', '05:19', '05:29', '05:37', '05:59'),
    (City.kurunegala, '11:52', '05:20', '05:30', '05:38', '06:00'),
    (City.anuradhapura, '11:52', '05:21', '05:31', '05:39', '06:01'),
    (City.jaffna, '11:54', '05:24', '05:34', '05:42', '06:04'),
    (City.trincomalee, '11:49', '05:18', '05:28', '05:36', '05:58'),
    (City.batticaloa, '11:47', '05:15', '05:25', '05:33', '05:55'),
  ];

  for (final (city, midday, paAuk, naUyana, civil, sunrise) in reference) {
    test('${city.name}: midday and aruṇa match the reference', () {
      String arunaBy(DawnMethod method) =>
          sriLankaClock(sun.sunDay(arunaDay, city, method).dawn);

      expect(
        sriLankaClock(sun.sunDay(middayDay, city, DawnMethod.naUyana).midday),
        midday,
      );
      expect(arunaBy(DawnMethod.paAuk), paAuk);
      expect(arunaBy(DawnMethod.naUyana), naUyana);
      expect(arunaBy(DawnMethod.civilTwilight), civil);
      expect(arunaBy(DawnMethod.sunrise), sunrise);
    });
  }
}
