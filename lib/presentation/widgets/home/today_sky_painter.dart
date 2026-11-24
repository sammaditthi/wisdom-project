import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../../../core/theme/today_sky_theme.dart';

/// Where the gradient's zenith stop sits above the horizon.
const _zenithAbove = 240.0;

/// The mid stop, at H − 96, as a fraction of zenith to horizon.
const _midStop = 0.6;

/// The skyline fade: 1 − smoothstep from H − 24 to H + 36, sampled.
const _fadeAbove = 24.0;
const _fadeBelow = 36.0;
const _fadeStops = <double>[0, .133, .267, .4, .533, .667, .8, .933, 1];
const _fadeAlphas = <double>[1, .95, .83, .65, .45, .26, .10, .01, 0];

/// The Today card's sky: one decorative layer behind the card's header and
/// its arc row, faded out just under the horizon.
///
/// The painted box is that stretch of the card's content; the sky also
/// covers the card's padding, [inset] wide, up to the card's inner edge.
/// y offsets are from the horizon, [fromBottom] above the box's bottom.
class TodaySkyPainter extends CustomPainter {
  const TodaySkyPainter({
    required this.look,
    required this.night,
    required this.strength,
    required this.stars,
    required this.fromBottom,
    required this.inset,
    required this.corner,
    required this.marker,
    required this.moon,
    required this.moonGlow,
  });

  final SkyKeyframe look;

  /// Late night's share of the blend: how far out the stars are, 0 to 1.
  final double night;

  final double strength;
  final List<SkyStar> stars;
  final double fromBottom;
  final double inset;

  /// The card's inner corner radius, where the sky is trimmed.
  final double corner;

  /// The marker the arc draws, the sun by day and the moon by night: x from
  /// the box's left, y from the horizon.
  final Offset marker;

  /// The moon photo's centre, in the same terms; null when the layout has no
  /// moon above the horizon.
  final Offset? moon;

  /// How lit the moon is times how far up it is, 0 to 1.
  final double moonGlow;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height - fromBottom;
    // The card's width inside its border, which star and bloom x are of.
    final width = size.width + 2 * inset;
    Offset at(double ofWidth, double fromHorizon) =>
        Offset(ofWidth * width - inset, h + fromHorizon);

    final bounds = Rect.fromLTRB(
      -inset,
      -inset,
      size.width + inset,
      h + _fadeBelow,
    );
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndCorners(
        bounds,
        topLeft: Radius.circular(corner),
        topRight: Radius.circular(corner),
      ),
    );
    canvas.saveLayer(
      bounds,
      Paint()..color = Color.fromRGBO(0, 0, 0, strength),
    );

    canvas.drawRect(
      bounds,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, h - _zenithAbove),
          Offset(0, h),
          [look.zenith, look.mid, look.horizon],
          const [0, _midStop, 1],
        ),
    );
    _glow(
      canvas,
      at(look.bloomAt.dx, look.bloomAt.dy),
      look.bloomRadii,
      look.bloom,
    );
    _glow(
      canvas,
      Offset(marker.dx, h + marker.dy),
      look.sunRadii,
      look.sunGlow,
    );
    final moon = this.moon;
    if (moon != null) {
      _glow(
        canvas,
        Offset(moon.dx, h + moon.dy),
        Size.square(look.moonRadius),
        Colors.white.withValues(alpha: look.moonHalo * moonGlow),
      );
    }

    // They come out as the sky darkens; a bright moon dims them.
    final starAlpha = night * (1 - 0.5 * moonGlow);
    if (starAlpha > 0) {
      final dot = Paint();
      for (final star in stars) {
        final radius = star.size / 2;
        canvas.drawCircle(
          at(star.x, star.y) + Offset(radius, radius),
          radius,
          dot..color = Colors.white.withValues(alpha: star.alpha * starAlpha),
        );
      }
    }

    // No hard edge at the skyline: everything fades out under it.
    canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = ui.Gradient.linear(
          Offset(0, h - _fadeAbove),
          Offset(0, h + _fadeBelow),
          [for (final a in _fadeAlphas) Color.fromRGBO(0, 0, 0, a)],
          _fadeStops,
        ),
    );
    canvas.restore();
    canvas.restore();
  }

  /// An elliptical glow of [color] centred on [at], transparent at [radii]
  /// out from it.
  static void _glow(Canvas canvas, Offset at, Size radii, Color color) {
    if (color.a == 0 || radii.width <= 0) return;
    // A circle of the ellipse's width, squashed to its height about [at].
    final squash = radii.height / radii.width;
    final matrix = Matrix4.diagonal3Values(1, squash, 1)
      ..setTranslationRaw(0, at.dy * (1 - squash), 0);
    canvas.drawPaint(
      Paint()
        ..shader = ui.Gradient.radial(
          at,
          radii.width,
          [color, color.withValues(alpha: 0)],
          null,
          TileMode.clamp,
          matrix.storage,
        ),
    );
  }

  @override
  bool shouldRepaint(TodaySkyPainter old) =>
      old.look != look ||
      old.night != night ||
      old.strength != strength ||
      old.stars != stars ||
      old.fromBottom != fromBottom ||
      old.inset != inset ||
      old.corner != corner ||
      old.marker != marker ||
      old.moon != moon ||
      old.moonGlow != moonGlow;
}
