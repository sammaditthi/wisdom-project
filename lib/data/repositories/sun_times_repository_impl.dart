import 'package:nrel_spa/nrel_spa.dart';

import '../../domain/entities/vinaya_times/city.dart';
import '../../domain/entities/vinaya_times/dawn_method.dart';
import '../../domain/repositories/sun_times_repository.dart';
import 'moon_position.dart' as moon;

/// [SunTimesRepository] on the NREL solar position algorithm, with a
/// low-precision lunar position for the moon.
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
  SunDay sunDay(DateTime day, City city, DawnMethod method) {
    // The civil angle leaves sunrise, noon and sunset as they are.
    final spa = _spa(day, city, civil: method == DawnMethod.civilTwilight);
    final dawnHours = switch (method) {
      DawnMethod.paAuk => spa.sunrise - 40 / 60,
      DawnMethod.naUyana => spa.sunrise - 30 / 60,
      DawnMethod.civilTwilight => spa.angles.single.sunrise,
      DawnMethod.sunrise => spa.sunrise,
    };
    return (
      dawn: _minuteUp(_micros(day, dawnHours)),
      sunrise: _nearestMinute(_micros(day, spa.sunrise)),
      midday: _minuteDown(_micros(day, spa.solarNoon)),
      sunset: _nearestMinute(_micros(day, spa.sunset)),
    );
  }

  @override
  double moonAltitude(DateTime instant, City city) =>
      moon.moonAltitude(instant, city.latitude, city.longitude);

  DateTime _minuteDown(int micros) =>
      _fromMicros(micros - micros % _microsPerMinute);

  DateTime _minuteUp(int micros) {
    final over = micros % _microsPerMinute;
    return _fromMicros(over == 0 ? micros : micros - over + _microsPerMinute);
  }

  DateTime _nearestMinute(int micros) {
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
