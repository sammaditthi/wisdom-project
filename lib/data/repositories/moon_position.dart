import 'dart:math' as math;

const _rad = math.pi / 180;

/// Unix days at J2000.0, 2000-01-01 12:00 UTC.
const _j2000 = 10957.5;

const _obliquity = _rad * 23.4397;
const _earthRadiusKm = 6378.14;

/// The moon's altitude in degrees at [instant], as seen from the ground at
/// [latitude], [longitude]: parallax and refraction included. Low precision
/// (Meeus's truncated lunar terms, as SunCalc uses): rise and set to within a
/// few minutes, enough for a glow that fades in over the first 5°.
double moonAltitude(DateTime instant, double latitude, double longitude) {
  final d =
      instant.millisecondsSinceEpoch / Duration.millisecondsPerDay - _j2000;

  // Geocentric ecliptic position.
  final meanLongitude = _rad * (218.316 + 13.176396 * d);
  final meanAnomaly = _rad * (134.963 + 13.064993 * d);
  final argumentOfLatitude = _rad * (93.272 + 13.229350 * d);
  final lon = meanLongitude + _rad * 6.289 * math.sin(meanAnomaly);
  final lat = _rad * 5.128 * math.sin(argumentOfLatitude);
  final distanceKm = 385001 - 20905 * math.cos(meanAnomaly);

  // To the equator, then to the local sky.
  final rightAscension = math.atan2(
    math.sin(lon) * math.cos(_obliquity) - math.tan(lat) * math.sin(_obliquity),
    math.cos(lon),
  );
  final declination = math.asin(
    math.sin(lat) * math.cos(_obliquity) +
        math.cos(lat) * math.sin(_obliquity) * math.sin(lon),
  );
  final siderealTime = _rad * (280.16 + 360.9856235 * d + longitude);
  final hourAngle = siderealTime - rightAscension;
  final phi = _rad * latitude;
  final geocentric = math.asin(
    math.sin(phi) * math.sin(declination) +
        math.cos(phi) * math.cos(declination) * math.cos(hourAngle),
  );

  // From the ground, not the Earth's centre, the moon sits up to 1° lower.
  final parallax =
      math.asin(_earthRadiusKm / distanceKm) * math.cos(geocentric);
  final altitude = (geocentric - parallax) / _rad;

  // Refraction lifts it near the horizon (Sæmundsson); below the horizon,
  // its value on it.
  final h = math.max(altitude, 0.0);
  final refraction = 1.02 / math.tan(_rad * (h + 10.3 / (h + 5.11))) / 60;
  return altitude + refraction;
}
