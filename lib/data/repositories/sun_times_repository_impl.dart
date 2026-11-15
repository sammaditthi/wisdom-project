import 'package:nrel_spa/nrel_spa.dart';

import '../../domain/entities/buddhist_times/city.dart';
import '../../domain/entities/buddhist_times/dawn_method.dart';
import '../../domain/repositories/sun_times_repository.dart';

/// [SunTimesRepository] on the NREL solar position algorithm.
///
/// Sunrise is the package's default: the sun's top edge on a sea-level
/// horizon with standard refraction.
class SunTimesRepositoryImpl implements SunTimesRepository {
  const SunTimesRepositoryImpl();

  /// Civil twilight as a zenith angle: 90° + 6° below the horizon.
  static const _civilZenith = 96.0;

  static const _microsPerHour = Duration.microsecondsPerHour;
  static const _microsPerMinute = Duration.microsecondsPerMinute;

  @override
  DateTime midday(DateTime day, City city) {
    final micros = _micros(day, _spa(day, city).solarNoon);
    // Rounded down: the shown midday is never after the real one.
    return _fromMicros(micros - micros % _microsPerMinute);
  }

  @override
  DateTime dawn(DateTime day, City city, DawnMethod method) {
    final spa = _spa(day, city, civil: method == DawnMethod.civilTwilight);
    final hours = switch (method) {
      DawnMethod.paAuk => spa.sunrise - 40 / 60,
      DawnMethod.naUyana => spa.sunrise - 30 / 60,
      DawnMethod.civilTwilight => spa.angles.single.sunrise,
      DawnMethod.sunrise => spa.sunrise,
    };
    final micros = _micros(day, hours);
    // Rounded up: the shown dawn is never before the real one.
    final over = micros % _microsPerMinute;
    return _fromMicros(over == 0 ? micros : micros - over + _microsPerMinute);
  }

  @override
  DateTime sunset(DateTime day, City city) {
    final micros = _micros(day, _spa(day, city).sunset);
    final over = micros % _microsPerMinute;
    final down = micros - over;
    return _fromMicros(
      over * 2 < _microsPerMinute ? down : down + _microsPerMinute,
    );
  }

  /// The day is passed as a string, which the package reads as a calendar
  /// day. The times come back as hours on the city's clock.
  SpaResult _spa(DateTime day, City city, {bool civil = false}) {
    String two(int n) => n.toString().padLeft(2, '0');
    return getSpa(
      '${day.year}-${two(day.month)}-${two(day.day)}',
      city.latitude,
      city.longitude,
      City.utcOffset.inMinutes / 60,
      customAngles: civil ? const [_civilZenith] : const [],
    );
  }

  /// [cityHours] on [day] in the city, as microseconds since the epoch.
  int _micros(DateTime day, double cityHours) =>
      DateTime.utc(day.year, day.month, day.day).microsecondsSinceEpoch +
      (cityHours * _microsPerHour).round() -
      City.utcOffset.inMicroseconds;

  DateTime _fromMicros(int micros) =>
      DateTime.fromMicrosecondsSinceEpoch(micros, isUtc: true);
}
