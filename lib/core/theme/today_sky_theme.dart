import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';

// ============================================
// Today card sky (option A2), light theme only
// ============================================
// Design: "Build spec · option A2, more color" on the Today card canvas.
// y is px from the horizon (H); x is a fraction of the card's width (W).
// Each colour is the tint before the whole layer's strength is applied.

/// The whole sky layer's opacity. At this strength the card's muted text
/// (onSurfaceVariant, #705E46) stays at 4.5:1 or better through every
/// keyframe and blend (lowest 4.58:1); recheck before raising it.
const _strength = 0.85;

const _lateNight = SkyKeyframe(
  zenith: Color(0x24384684),
  mid: Color(0x335C68A4),
  horizon: Color(0x29848CC0),
  bloom: Color(0x94242E68),
  bloomAt: Offset(0.5, -270),
  bloomRadii: Size(260, 240),
  sunGlow: Color(0x00FF9660),
  sunRadii: Size(420, 190),
  moonHalo: 0.9,
  moonRadius: 160,
);

const _dawn = SkyKeyframe(
  zenith: Color(0x5CB8ACDE),
  mid: Color(0x47ECC8D6),
  horizon: Color(0x57FABAA0),
  bloom: Color(0x4CB8ACDE),
  bloomAt: Offset(0.5, -280),
  bloomRadii: Size(340, 260),
  sunGlow: Color(0x70FFAA8C),
  sunRadii: Size(380, 190),
  moonHalo: 0,
  moonRadius: 170,
);

/// Morning is the clearest, most saturated blue, with a small crisp glow.
const _morning = SkyKeyframe(
  zenith: Color(0x5C82B4E8),
  mid: Color(0x38B8D6F0),
  horizon: Color(0x2EDEECF8),
  bloom: Color(0x5282B4E8),
  bloomAt: Offset(0.583, -280),
  bloomRadii: Size(460, 280),
  sunGlow: Color(0x7AFFEEC4),
  sunRadii: Size(170, 170),
  moonHalo: 0,
  moonRadius: 170,
);

/// By afternoon haze washes the blue out: a paler veil, milky low down,
/// brightest round the sun. Keep a hint of blue; grey reads as a dirty card.
const _afternoon = SkyKeyframe(
  zenith: Color(0x61A8BCDA),
  mid: Color(0x52DCD8CC),
  horizon: Color(0x5CE2D8C6),
  bloom: Color(0x3DBEC6D0),
  bloomAt: Offset(0.583, -280),
  bloomRadii: Size(460, 280),
  sunGlow: Color(0x9EFFF8E8),
  sunRadii: Size(260, 260),
  moonHalo: 0,
  moonRadius: 170,
);

const _evening = SkyKeyframe(
  zenith: Color(0x4FA092C8),
  mid: Color(0x42ECB0B0),
  horizon: Color(0x42FAA06E),
  bloom: Color(0x4CA092C8),
  bloomAt: Offset(0.5, -280),
  bloomRadii: Size(340, 260),
  sunGlow: Color(0x59FF9660),
  sunRadii: Size(420, 190),
  moonHalo: 0,
  moonRadius: 170,
);

const _stars = <SkyStar>[
  (x: 0.222, y: -144, size: 2, alpha: 0.85),
  (x: 0.244, y: -210, size: 2, alpha: 0.9),
  (x: 0.297, y: -182, size: 2, alpha: 0.85),
  (x: 0.347, y: -122, size: 2, alpha: 0.8),
  (x: 0.364, y: -218, size: 3, alpha: 0.95),
  (x: 0.411, y: -84, size: 2, alpha: 0.75),
  (x: 0.417, y: -166, size: 2, alpha: 0.9),
  (x: 0.469, y: -200, size: 2, alpha: 0.9),
  (x: 0.517, y: -144, size: 2, alpha: 0.85),
  (x: 0.561, y: -222, size: 2, alpha: 0.9),
  (x: 0.597, y: -178, size: 3, alpha: 0.95),
  (x: 0.619, y: -112, size: 2, alpha: 0.75),
  (x: 0.65, y: -206, size: 2, alpha: 0.9),
  (x: 0.703, y: -156, size: 2, alpha: 0.8),
  (x: 0.75, y: -192, size: 2, alpha: 0.8),
];

// When each keyframe peaks, as a rule on the city's sunrise and sunset, so
// it holds for any place. Night is the sun more than 12° down, twilight
// colours peak near 4° down, plain day by 13° up. These offsets suit the
// tropics; far from them, anchor on those sun angles instead.
const _nightEnds = Duration(minutes: -50); // from sunrise
const _dawnPeak = Duration(minutes: -15); // from sunrise
const _morningPeak = Duration(hours: 1); // from sunrise
const _afternoonPeak = Duration(hours: -1); // from sunset
const _eveningPeak = Duration(minutes: 15); // from sunset
const _nightBegins = Duration(minutes: 50); // from sunset

/// One star: x a fraction of the card's width, y px from the horizon, its
/// diameter in px and its alpha at full night.
typedef SkyStar = ({double x, double y, double size, double alpha});

/// The sky at one time of day. Two keyframes blend field by field.
@immutable
class SkyKeyframe {
  const SkyKeyframe({
    required this.zenith,
    required this.mid,
    required this.horizon,
    required this.bloom,
    required this.bloomAt,
    required this.bloomRadii,
    required this.sunGlow,
    required this.sunRadii,
    required this.moonHalo,
    required this.moonRadius,
  });

  /// The sky's gradient: at H − 240, H − 96 and H.
  final Color zenith;
  final Color mid;
  final Color horizon;

  /// An ellipse that deepens the sky overhead, fading to transparent.
  final Color bloom;
  final Offset bloomAt;
  final Size bloomRadii;

  /// An ellipse on the arc's marker: the sun by day, the moon by night.
  final Color sunGlow;
  final Size sunRadii;

  /// A white circle on the moon photo; its alpha is scaled by how lit and
  /// how high the moon is.
  final double moonHalo;
  final double moonRadius;

  static SkyKeyframe lerp(SkyKeyframe a, SkyKeyframe b, double t) {
    return SkyKeyframe(
      zenith: Color.lerp(a.zenith, b.zenith, t)!,
      mid: Color.lerp(a.mid, b.mid, t)!,
      horizon: Color.lerp(a.horizon, b.horizon, t)!,
      bloom: Color.lerp(a.bloom, b.bloom, t)!,
      bloomAt: Offset.lerp(a.bloomAt, b.bloomAt, t)!,
      bloomRadii: Size.lerp(a.bloomRadii, b.bloomRadii, t)!,
      sunGlow: Color.lerp(a.sunGlow, b.sunGlow, t)!,
      sunRadii: Size.lerp(a.sunRadii, b.sunRadii, t)!,
      moonHalo: lerpDouble(a.moonHalo, b.moonHalo, t)!,
      moonRadius: lerpDouble(a.moonRadius, b.moonRadius, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SkyKeyframe &&
      other.zenith == zenith &&
      other.mid == mid &&
      other.horizon == horizon &&
      other.bloom == bloom &&
      other.bloomAt == bloomAt &&
      other.bloomRadii == bloomRadii &&
      other.sunGlow == sunGlow &&
      other.sunRadii == sunRadii &&
      other.moonHalo == moonHalo &&
      other.moonRadius == moonRadius;

  @override
  int get hashCode => Object.hash(zenith, mid, horizon, bloom, bloomAt,
      bloomRadii, sunGlow, sunRadii, moonHalo, moonRadius);
}

/// The Today card's sky: five keyframes through the day, blended on the
/// city's sunrise and sunset. Only the light theme registers it; a theme
/// without it has no sky.
@immutable
class TodaySkyTheme extends ThemeExtension<TodaySkyTheme> {
  const TodaySkyTheme({
    required this.strength,
    required this.lateNight,
    required this.dawn,
    required this.morning,
    required this.afternoon,
    required this.evening,
    required this.stars,
  });

  factory TodaySkyTheme.standard() => const TodaySkyTheme(
        strength: _strength,
        lateNight: _lateNight,
        dawn: _dawn,
        morning: _morning,
        afternoon: _afternoon,
        evening: _evening,
        stars: _stars,
      );

  final double strength;
  final SkyKeyframe lateNight;
  final SkyKeyframe dawn;
  final SkyKeyframe morning;
  final SkyKeyframe afternoon;
  final SkyKeyframe evening;

  /// Shown only by late night, dimmed by a bright moon.
  final List<SkyStar> stars;

  /// The sky at [now]: neighbouring keyframes eased with smoothstep, and
  /// late night's share of that blend, which is how far out the stars are.
  ({SkyKeyframe look, double night}) at(
    DateTime now, {
    required DateTime sunrise,
    required DateTime sunset,
  }) {
    // Late night holds before the first stop and after the last.
    final stops = [
      (sunrise.add(_nightEnds), lateNight, 1.0),
      (sunrise.add(_dawnPeak), dawn, 0.0),
      (sunrise.add(_morningPeak), morning, 0.0),
      (sunset.add(_afternoonPeak), afternoon, 0.0),
      (sunset.add(_eveningPeak), evening, 0.0),
      (sunset.add(_nightBegins), lateNight, 1.0),
    ];
    for (var i = 0; i < stops.length; i++) {
      final (to, look, night) = stops[i];
      if (now.isAfter(to)) continue;
      if (i == 0) break;
      final (from, previous, previousNight) = stops[i - 1];
      final t = now.difference(from).inSeconds / to.difference(from).inSeconds;
      final eased = t * t * (3 - 2 * t);
      return (
        look: SkyKeyframe.lerp(previous, look, eased),
        night: lerpDouble(previousNight, night, eased)!,
      );
    }
    return (look: lateNight, night: 1.0);
  }

  @override
  TodaySkyTheme copyWith({
    double? strength,
    SkyKeyframe? lateNight,
    SkyKeyframe? dawn,
    SkyKeyframe? morning,
    SkyKeyframe? afternoon,
    SkyKeyframe? evening,
    List<SkyStar>? stars,
  }) =>
      TodaySkyTheme(
        strength: strength ?? this.strength,
        lateNight: lateNight ?? this.lateNight,
        dawn: dawn ?? this.dawn,
        morning: morning ?? this.morning,
        afternoon: afternoon ?? this.afternoon,
        evening: evening ?? this.evening,
        stars: stars ?? this.stars,
      );

  @override
  TodaySkyTheme lerp(covariant ThemeExtension<TodaySkyTheme>? other, double t) {
    if (other is! TodaySkyTheme) return this;
    return TodaySkyTheme(
      strength: lerpDouble(strength, other.strength, t)!,
      lateNight: SkyKeyframe.lerp(lateNight, other.lateNight, t),
      dawn: SkyKeyframe.lerp(dawn, other.dawn, t),
      morning: SkyKeyframe.lerp(morning, other.morning, t),
      afternoon: SkyKeyframe.lerp(afternoon, other.afternoon, t),
      evening: SkyKeyframe.lerp(evening, other.evening, t),
      stars: t < 0.5 ? stars : other.stars,
    );
  }
}

/// The Today card's sky from a [BuildContext]. Unlike the other theme
/// extensions there is no fallback: null means this theme has no sky.
extension TodaySkyThemeExtension on BuildContext {
  TodaySkyTheme? get todaySky => Theme.of(this).extension<TodaySkyTheme>();
}
