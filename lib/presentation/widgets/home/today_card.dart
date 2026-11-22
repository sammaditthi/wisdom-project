import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/moon_photos.dart';
import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/today_sky_theme.dart';
import '../../../domain/entities/vinaya_times/city.dart';
import '../../../domain/entities/vinaya_times/uposatha_day.dart';
import '../../providers/vinaya_times_provider.dart';
import '../../providers/vinaya_times_state.dart';
import '../common/vinaya_times_labels.dart';
import '../settings/settings_dialog.dart';
import '../settings/settings_tab.dart';
import 'today_sky_painter.dart';

/// Home's Today card: the day's or the night's arc with midday and vikāla on
/// one side, the moon's fortnight and the next uposatha on the other. Bold is
/// only for what is near. In the light theme a sky of the time of day runs
/// behind the header and the arc.
class TodayCard extends ConsumerWidget {
  const TodayCard({super.key});

  /// Narrower than this, the moon's side drops under the sun's.
  static const _sideBySideWidth = 520.0;

  static const _padding = 20.0;
  static const _radius = 16.0;
  static const _border = 1.0;

  /// Side by side, the sun's side and the moon's share the row three parts
  /// to two.
  static const _sunFlex = 3;
  static const _moonFlex = 2;
  static const _columnGap = 24.0;

  static const _arcMaxWidth = 360.0;

  /// The moon's glow is full once it is this many degrees up.
  static const _moonUpAt = 5.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vinayaTimesProvider);
    final city = ref.watch(vinayaTimesCityProvider);
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final typography = context.typography;
    final sky = context.todaySky;

    final header = Row(
      // TODAY sits on the date's first line.
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          l10n.homeToday.toUpperCase(),
          style: typography
              .sectionHeaderFor(l10n.homeToday)
              .copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _DateAndCity(now: state.now, city: city),
          ),
        ),
      ],
    );
    final sunLine = _ArcHeadline(state: state);
    // Past the calendar's end there is no uposatha to show, so no moon side.
    final hasMoon = state.uposathas.isNotEmpty;

    final card = Container(
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant, width: _border),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final wide = hasMoon && width >= _sideBySideWidth;
          // As the row's Expanded children share it out.
          final share = (width - _columnGap) / (_sunFlex + _moonFlex);
          final sunWidth = wide ? share * _sunFlex : width;
          final arc = _ArcLayout.of(
            context,
            state,
            width: math.min(_arcMaxWidth, sunWidth),
          );
          final sunSky = Center(child: _SkyArc(state: state, arc: arc));

          // The header and the row above the horizon, with the sky behind
          // them both: the sky reaches the card's top.
          Widget overSky(Widget row) {
            final top = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                const SizedBox(height: 16),
                _Horizon(child: row),
              ],
            );
            if (sky == null) return top;

            final (:look, :night) = sky.at(
              state.now,
              sunrise: state.sunrise,
              sunset: state.sunset,
            );
            final moonUp = (state.moonAltitude / _moonUpAt).clamp(0.0, 1.0);
            return CustomPaint(
              // Worth keeping as a bitmap where the renderer can (Skia).
              isComplex: true,
              painter: TodaySkyPainter(
                look: look,
                night: night,
                strength: sky.strength,
                stars: sky.stars,
                fromBottom: _Horizon.fromBottom(context),
                inset: _padding,
                corner: _radius - _border,
                // The arc is centred in the sun's column, its centre on the
                // horizon.
                marker: Offset((sunWidth - arc.width) / 2, -arc.centre.dy) +
                    arc.marker,
                moon: wide
                    ? Offset(
                        sunWidth + _columnGap + share * _moonFlex / 2,
                        -_MoonSky.centreAboveHorizon,
                      )
                    : null,
                moonGlow: hasMoon ? _moonLit(_moonAge(state)) * moonUp : 0,
              ),
              // The date button's hover and ripple repaint this layer only,
              // not the sky behind it.
              child: RepaintBoundary(child: top),
            );
          }

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                overSky(sunSky),
                const SizedBox(height: 8),
                sunLine,
                if (hasMoon) ...[
                  // A solid rule, not a second horizon: here the moon has no
                  // sky of its own.
                  const SizedBox(height: 20),
                  Divider(height: 1, color: colors.outlineVariant),
                  const SizedBox(height: 20),
                  _MoonRow(state: state),
                ],
              ],
            );
          }
          // The two skies share a bottom edge, so one horizon runs under
          // both. The lines under them differ in size, so they sit on one
          // baseline.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              overSky(
                _columns(
                  sunSky,
                  _MoonSky(state: state),
                  CrossAxisAlignment.end,
                ),
              ),
              const SizedBox(height: 8),
              _columns(
                sunLine,
                Center(
                  heightFactor: 1,
                  child: _UposathaLine(
                    state: state,
                    textAlign: TextAlign.center,
                  ),
                ),
                CrossAxisAlignment.baseline,
              ),
            ],
          );
        },
      ),
    );

    // Its own layer, so scrolling Home moves the card instead of repainting it.
    return RepaintBoundary(child: card);
  }

  /// The sun's side and the moon's.
  static Widget _columns(Widget sun, Widget moon, CrossAxisAlignment align) {
    return Row(
      crossAxisAlignment: align,
      // Used only by CrossAxisAlignment.baseline; a column lines up by its
      // first line.
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(flex: _sunFlex, child: sun),
        const SizedBox(width: _columnGap),
        Expanded(flex: _moonFlex, child: moon),
      ],
    );
  }
}

/// Today's date with the city under it, as one button that opens
/// Settings > Time.
class _DateAndCity extends StatelessWidget {
  const _DateAndCity({required this.now, required this.city});

  final DateTime now;
  final City city;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final typography = context.typography;
    final locale = l10n.localeName;

    // The device's date, like the clock times on the card. The weekday is
    // bold wherever the language puts it, so it is found in the full date.
    final date =
        DateFormat(l10n.vinayaTimesFullDatePattern, locale).format(now);
    final weekday = DateFormat('EEEE', locale).format(now);
    final at = date.indexOf(weekday);
    final rest = typography.menuSectionLabel.copyWith(color: colors.onSurface);

    return Tooltip(
      message: l10n.vinayaTimesChangeLocation(city.label(l10n)),
      child: TextButton(
        onPressed: () => SettingsDialog.show(
          context,
          initial: SettingsTab.vinayaTimes,
        ),
        // As small as its two lines allow. The theme still gives it a 48px
        // tap area on touch screens.
        style: TextButton.styleFrom(
          foregroundColor: colors.onSurfaceVariant,
          textStyle: typography.menuSectionLabel,
          minimumSize: Size.zero,
          // TextButton's own pill shape; its round ends need this much room
          // or they cut into the text.
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          visualDensity: VisualDensity.standard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                style: rest,
                children: at < 0
                    ? [TextSpan(text: date)]
                    : [
                        TextSpan(text: date.substring(0, at)),
                        TextSpan(
                          text: weekday,
                          style: typography.listRowTitle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: date.substring(at + weekday.length)),
                      ],
              ),
              textAlign: TextAlign.end,
            ),
            Text(
              city.label(l10n),
              textAlign: TextAlign.end,
              style: typography.menuSectionLabel,
            ),
          ],
        ),
      ),
    );
  }
}

const _tabular = [FontFeature.tabularFigures()];

/// Gap between the arc and a label beside it, and between the horizon and
/// the labels under it.
const _labelGap = 8.0;

/// Room for one line of label at the app's and the system's text size, sized
/// for the largest drawn in it: the 14px countdown under the moon. One value
/// for both sides, since they share the horizon. Rounded up, as the text
/// engine draws a line a whole number of pixels tall: a 19.6 box would shrink
/// a 20px line.
double _labelLineHeight(BuildContext context) {
  final style = context.typography.listRowTitle;
  return (MediaQuery.textScalerOf(context).scale(style.fontSize!) *
          style.height!)
      .ceilToDouble();
}

/// Midday's countdown turns orange inside the hour, red inside the half hour.
const _middaySoon = Duration(hours: 1);
const _middayVerySoon = Duration(minutes: 30);

/// The line under the arc: how long until midday, or until when vikāla
/// lasts.
class _ArcHeadline extends StatelessWidget {
  const _ArcHeadline({required this.state});

  final VinayaTimesState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final typography = context.typography;

    final String headline;
    final TextStyle style;
    if (state.isVikala) {
      headline = l10n.vinayaTimesVikalaUntil(clockTime(state.vikalaEnds));
      // Nothing is near once midday has passed: the uposatha line's style,
      // so the two lines under the horizon match.
      style = typography.menuSectionLabel;
    } else {
      final left = state.midday.difference(state.now);
      // Round up, as a countdown does: 40 s left reads "1 min", not "0 min".
      final totalMinutes =
          (left.inMicroseconds / Duration.microsecondsPerMinute).ceil();
      final minutes = totalMinutes % 60;
      headline = switch ((totalMinutes ~/ 60, minutes)) {
        (0, _) => l10n.vinayaTimesMiddayIn(minutes),
        // On the hour, no "0 min".
        (final hours, 0) => l10n.vinayaTimesMiddayInWholeHours(hours),
        (final hours, _) => l10n.vinayaTimesMiddayInHours(hours, minutes),
      };
      // The size of the moon's near countdown: one size for what is near.
      style = typography.listRowTitle.copyWith(
        fontWeight: FontWeight.w600,
        // The words carry it too; the colour only adds to them.
        color: switch (left) {
          <= _middayVerySoon => colors.error,
          // Dark orange reads on a light card only; a dark one takes the
          // sun's orange.
          <= _middaySoon => colors.brightness == Brightness.light
              ? colors.onPrimaryFixedVariant
              : colors.primaryFixedDim,
          _ => colors.onSurface,
        },
      );
    }

    return Text(
      headline,
      textAlign: TextAlign.center,
      style: style.copyWith(fontFeatures: _tabular),
    );
  }
}

/// The arc's labels: small, with figures of one width.
TextStyle _arcLabelStyle(BuildContext context) =>
    context.typography.menuSectionLabel.copyWith(fontFeatures: _tabular);

/// The Now label over the arc, as [_SkyArc] draws it and [_ArcLayout] makes
/// room for it.
({String text, TextStyle style}) _nowLabel(BuildContext context, DateTime now) {
  return (
    text: AppLocalizations.of(context).vinayaTimesNowAt(clockTime(now)),
    style: _arcLabelStyle(context)
        .copyWith(color: Theme.of(context).colorScheme.onSurface),
  );
}

/// The arc in a box [width] wide: its size, where it stands and where its
/// marker is. Worked out once for the arc and for the sky behind it, so the
/// sky's glow sits on the marker.
class _ArcLayout {
  const _ArcLayout._({
    required this.width,
    required this.lineHeight,
    required this.day,
    required this.start,
    required this.end,
    required this.nowAt,
    required this.stretchTo,
    required this.radius,
    required this.nowFits,
    required this.nowSize,
  });

  factory _ArcLayout.of(
    BuildContext context,
    VinayaTimesState state, {
    required double width,
  }) {
    final lineHeight = _labelLineHeight(context);
    final day = state.sunIsUp;
    final start = day ? state.dawn : state.nightStart;
    final end = day ? state.sunset : state.vikalaEnds;
    final span = end.difference(start).inSeconds;
    double along(DateTime instant) =>
        instant.difference(start).inSeconds / span;

    final now = _nowLabel(context, state.now);
    final nowWidth = _textWidth(context, now.text, now.style);

    // The end labels are centred on the arc's ends, so the arc stands in by
    // about half a label.
    final widest = width / 2 - 2 * lineHeight;

    // The arc stands in a little more when Now needs the room: the radius
    // where Now's far edge (see [nowRect]) is at the box's edge. When even
    // half the arc would not make room, the label goes.
    final w = nowWidth / 2;
    final h = lineHeight / 2;
    final room = width - 3 * w - h;
    final fitted = room <= 0
        ? 0.0
        : math.sqrt((room * room + (w - h) * (w - h)) / 2) - _SkyArc._nowReach;
    final nowFits = fitted >= widest / 2;

    return _ArcLayout._(
      width: width,
      lineHeight: lineHeight,
      day: day,
      start: start,
      end: end,
      nowAt: along(state.now),
      // Kāla ends at midday; the night is one stretch from end to end.
      stretchTo: day ? along(state.midday) : 1.0,
      radius: nowFits ? math.min(widest, fitted) : widest,
      nowFits: nowFits,
      nowSize: Size(nowWidth, lineHeight),
    );
  }

  final double width;
  final double lineHeight;

  /// The day's arc, aruṇa to sunset, or the night's, sunset to aruṇa.
  final bool day;
  final DateTime start;
  final DateTime end;

  /// Where the marker is and where the coloured stretch ends, as fractions
  /// of the way along the arc.
  final double nowAt;
  final double stretchTo;

  final double radius;

  /// Whether the Now label has room beside the arc.
  final bool nowFits;
  final Size nowSize;

  /// On the horizon, which runs a label gap above the end labels.
  Offset get centre => Offset(width / 2, lineHeight + _labelGap + radius);

  /// Down to the end labels' bottom.
  double get height => centre.dy + _labelGap + lineHeight;

  Offset onArc(double fraction) {
    final angle = math.pi * (1 + fraction);
    return centre + Offset(math.cos(angle), math.sin(angle)) * radius;
  }

  /// The sun by day, the moon by night.
  Offset get marker => onArc(nowAt);

  /// Now is centred on the line 45 degrees up from the arc's centre, [out]
  /// along each axis: as near as it can be while its nearest corner,
  /// (out - w, out - h) from the centre, is past the marker's reach. It goes
  /// on the marker's side, mirrored exactly on the other.
  Rect get nowRect {
    final w = nowSize.width / 2;
    final h = nowSize.height / 2;
    final reach = radius + _SkyArc._nowReach;
    final root = 2 * reach * reach - (w - h) * (w - h);
    final out = (w + h + math.sqrt(math.max(0, root))) / 2;
    return Rect.fromCenter(
      center: centre + Offset(nowAt < 0.5 ? -1 : 1, -1) * out,
      width: nowSize.width,
      height: nowSize.height,
    );
  }
}

/// A half circle with a marker where the sun or the moon is now. By day it
/// runs aruṇa to sunset, sky blue up to midday (kāla) and slate after; by
/// night it runs sunset to aruṇa, all of it in midnight blue.
class _SkyArc extends StatelessWidget {
  const _SkyArc({required this.state, required this.arc});

  final VinayaTimesState state;
  final _ArcLayout arc;

  static const _stroke = 6.0;
  static const _markerRadius = 8.0;
  static const _markerRing = 1.5;

  /// How far outside the arc the Now label keeps: past the marker, plus a gap.
  static const _nowReach = _markerRadius + 6;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final label = _arcLabelStyle(context);
    final now = _nowLabel(context, state.now);
    final dark = now.style;
    // Bold until midday, regular once it has passed.
    final middayStyle =
        state.isVikala ? dark : dark.copyWith(fontWeight: FontWeight.w600);

    final lineHeight = arc.lineHeight;
    final day = arc.day;

    final middayText = l10n.vinayaTimesMiddayAt(clockTime(state.midday));
    final middayWidth = _textWidth(context, middayText, middayStyle);

    final belowEnd = Offset(0, _labelGap + lineHeight / 2);
    final middayRect = Rect.fromCenter(
      center: arc.onArc(arc.stretchTo) - belowEnd,
      width: middayWidth,
      height: lineHeight,
    );
    final nowRect = arc.nowRect;
    // A very small arc at a large text size would push it above the card's
    // header gap; then it goes too.
    final showNow = arc.nowFits &&
        nowRect.top >= 0 &&
        !(day && nowRect.overlaps(middayRect));

    return Semantics(
      label: day
          ? l10n.vinayaTimesArcLabel(
              clockTime(arc.start),
              clockTime(state.midday),
              clockTime(arc.end),
            )
          : l10n.vinayaTimesNightArcLabel(
              clockTime(arc.start),
              clockTime(arc.end),
            ),
      child: ExcludeSemantics(
        child: SizedBox(
          width: arc.width,
          // The horizon goes through the arc's centre, painted by [_Horizon]
          // behind.
          height: arc.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _SkyArcPainter(
                    centre: arc.centre,
                    radius: arc.radius,
                    stretchTo: arc.stretchTo,
                    marker: arc.marker,
                    stroke: _stroke,
                    markerRadius: _markerRadius,
                    // Keeps the arc clear of the sky behind it.
                    casingColor: colors.surface,
                    stretchColor:
                        day ? colors.secondaryFixed : colors.tertiaryFixedDim,
                    // The afternoon; the night's stretch covers it all.
                    restColor: colors.secondaryFixedDim,
                    markerColor: colors.onSurface,
                    // Both are discs: the sun orange, the moon amber.
                    markerFill:
                        day ? colors.primaryFixedDim : colors.primaryFixed,
                    markerRing: _markerRing,
                  ),
                ),
              ),
              if (day)
                _ArcLabel(
                  at: middayRect.center,
                  text: middayText,
                  style: middayStyle,
                ),
              _ArcLabel(
                at: arc.onArc(0) + belowEnd,
                text: day
                    ? l10n.vinayaTimesArunaAt(clockTime(arc.start))
                    : l10n.vinayaTimesSunsetAt(clockTime(arc.start)),
                style: label,
              ),
              _ArcLabel(
                at: arc.onArc(1) + belowEnd,
                text: day
                    ? l10n.vinayaTimesSunsetAt(clockTime(arc.end))
                    : l10n.vinayaTimesArunaAt(clockTime(arc.end)),
                style: label,
              ),
              if (showNow)
                _ArcLabel(at: nowRect.center, text: now.text, style: dark),
            ],
          ),
        ),
      ),
    );
  }
}

/// The width [text] takes on one line, as [_ArcLabel] draws it.
double _textWidth(BuildContext context, String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: DefaultTextStyle.of(context).style.merge(style),
    ),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 1,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

/// One line of text centred on [at], whatever its width.
class _ArcLabel extends StatelessWidget {
  const _ArcLabel({required this.at, required this.text, required this.style});

  final Offset at;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: at.dx,
      top: at.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Text(text, maxLines: 1, softWrap: false, style: style),
      ),
    );
  }
}

class _SkyArcPainter extends CustomPainter {
  const _SkyArcPainter({
    required this.centre,
    required this.radius,
    required this.stretchTo,
    required this.marker,
    required this.stroke,
    required this.markerRadius,
    required this.casingColor,
    required this.stretchColor,
    required this.restColor,
    required this.markerColor,
    required this.markerFill,
    required this.markerRing,
  });

  final Offset centre;
  final double radius;

  /// Where the coloured stretch ends, as a fraction of the way along.
  final double stretchTo;
  final Offset marker;

  final double stroke;
  final double markerRadius;

  /// A wider stroke under the coloured ones, so a blue sky behind does not
  /// swallow the sky-blue stretch.
  final Color casingColor;
  final Color stretchColor;
  final Color restColor;
  final Color markerColor;
  final Color markerFill;

  /// The width of the marker's outline.
  final double markerRing;

  @override
  void paint(Canvas canvas, Size size) {
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(center: centre, radius: radius);
    // Angles run clockwise from three o'clock, so the left end is pi and
    // the sweep over the top to the right end is another pi.
    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke + 3
        ..strokeCap = StrokeCap.round
        ..color = casingColor,
    );
    canvas.drawArc(rect, math.pi, math.pi, false, arc..color = restColor);
    canvas.drawArc(
      rect,
      math.pi,
      math.pi * stretchTo,
      false,
      arc..color = stretchColor,
    );

    canvas.drawCircle(marker, markerRadius, Paint()..color = markerFill);
    canvas.drawCircle(
      marker,
      markerRadius - markerRing / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = markerRing
        ..color = markerColor,
    );
  }

  @override
  bool shouldRepaint(_SkyArcPainter old) =>
      old.centre != centre ||
      old.radius != radius ||
      old.stretchTo != stretchTo ||
      old.marker != marker ||
      old.casingColor != casingColor ||
      old.stretchColor != stretchColor ||
      old.restColor != restColor ||
      old.markerColor != markerColor ||
      old.markerFill != markerFill ||
      old.markerRing != markerRing;
}

/// [child] in front of a dashed horizon across its full width, as far above
/// its bottom as the arc's end labels hang below the arc.
class _Horizon extends StatelessWidget {
  const _Horizon({required this.child});

  final Widget child;

  /// How far above the bottom the horizon runs.
  static double fromBottom(BuildContext context) =>
      _labelGap + _labelLineHeight(context);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HorizonPainter(
        fromBottom: fromBottom(context),
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
      child: child,
    );
  }
}

class _HorizonPainter extends CustomPainter {
  const _HorizonPainter({required this.fromBottom, required this.color});

  final double fromBottom;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height - fromBottom;
    final dash = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 7) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + 3, size.width), y),
        dash,
      );
    }
  }

  @override
  bool shouldRepaint(_HorizonPainter old) =>
      old.fromBottom != fromBottom || old.color != color;
}

/// The wide card's moon: above the horizon, with its line under it level
/// with the arc's end labels.
class _MoonSky extends StatelessWidget {
  const _MoonSky({required this.state});

  final VinayaTimesState state;

  static const _size = 72.0;

  /// Clear sky between the moon and the horizon.
  static const _clearance = 20.0;

  /// The photo's centre stands this far above the horizon.
  static const centreAboveHorizon = _clearance + _size / 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MoonImage(state: state, size: _size),
        const SizedBox(height: _clearance + _labelGap),
        SizedBox(
          height: _labelLineHeight(context),
          // One line, like the end labels beside it: wrapping would push
          // the label's top onto the horizon, so a long one shrinks.
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _MoonLine(state: state),
            ),
          ),
        ),
      ],
    );
  }
}

/// The narrow card's moon: the photo beside its two lines, with no sky.
class _MoonRow extends StatelessWidget {
  const _MoonRow({required this.state});

  final VinayaTimesState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _MoonImage(state: state, size: 56),
        const SizedBox(width: 16),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _MoonLine(state: state),
              const SizedBox(height: 2),
              _UposathaLine(state: state),
            ],
          ),
        ),
      ],
    );
  }
}

/// The moon's age as an angle, by the uposatha count: 0 at new moon, pi at
/// full. Only while an uposatha is ahead.
double _moonAge(VinayaTimesState state) {
  final next = state.uposathas.first;
  final waxing = next.phase == MoonPhase.fullMoon;
  return math.pi * (waxing ? 0 : 1) +
      math.pi * state.fortnightDay! / next.fortnightDays;
}

/// How much of the moon's face is lit: 0 at new moon, 1 at full.
double _moonLit(double age) => (1 - math.cos(age)) / 2;

/// Today's moon photo, or the drawn moon when there is no photo.
class _MoonImage extends StatelessWidget {
  const _MoonImage({required this.state, required this.size});

  final VinayaTimesState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final age = _moonAge(state);
    // One photo a step round the cycle: the first the new moon, the middle
    // one the full moon.
    final photo = moonPhotoAsset(
      (age / math.pi * (moonPhotoCount / 2)).round() % moonPhotoCount,
    );

    return ExcludeSemantics(
      child: Image.asset(
        photo,
        width: size,
        height: size,
        // No photo (web, offline, not yet stored): the drawn moon.
        errorBuilder: (_, __, ___) => CustomPaint(
          size: Size.square(size),
          painter: _MoonPainter(
            age: age,
            litColor: colors.tertiaryFixed,
            darkColor: colors.surfaceContainerHighest,
            rimColor: colors.outline,
          ),
        ),
      ),
    );
  }
}

/// The line under the moon. From five days before the uposatha, how near it
/// is, bold in the last two; before that, how far along its fortnight the
/// moon is.
class _MoonLine extends StatelessWidget {
  const _MoonLine({required this.state});

  final VinayaTimesState state;

  /// The countdown takes the fortnight line's place from this many days out.
  static const _countdownFrom = 5;

  /// ...and is bold from this many.
  static const _nearFrom = 2;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = context.typography;
    final next = state.uposathas.first;
    final days = state.daysToUposatha!;

    if (days > _countdownFrom) {
      final day = state.fortnightDay!;
      return Text(
        next.phase == MoonPhase.fullMoon
            ? l10n.vinayaTimesWaxing(day, next.fortnightDays)
            : l10n.vinayaTimesWaning(day, next.fortnightDays),
        style: typography.menuSectionLabel,
      );
    }
    return Text(
      switch (days) {
        0 => l10n.vinayaTimesUposathaToday,
        1 => l10n.vinayaTimesUposathaTomorrow,
        _ => l10n.vinayaTimesUposathaIn(days),
      },
      style: days <= _nearFrom
          ? typography.listRowTitle.copyWith(fontWeight: FontWeight.w600)
          : typography.menuSectionLabel,
    );
  }
}

/// The next uposatha's date and which moon it falls on.
class _UposathaLine extends StatelessWidget {
  const _UposathaLine({required this.state, this.textAlign});

  final VinayaTimesState state;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final next = state.uposathas.first;
    final date = DateFormat(l10n.vinayaTimesDatePattern, l10n.localeName);

    return Text(
      '${date.format(next.date)} · ${next.phase.label(l10n)}',
      textAlign: textAlign,
      style: context.typography.menuSectionLabel,
    );
  }
}

/// The moon as it stands in its cycle: a dark disc with the lit part on top.
class _MoonPainter extends CustomPainter {
  const _MoonPainter({
    required this.age,
    required this.litColor,
    required this.darkColor,
    required this.rimColor,
  });

  /// 0 at new moon, pi at full moon, 2 pi at the next new moon.
  final double age;
  final Color litColor;
  final Color darkColor;
  final Color rimColor;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 1;
    final top = centre - Offset(0, radius);
    final bottom = centre + Offset(0, radius);

    canvas.drawCircle(centre, radius, Paint()..color = darkColor);

    // The lit part is half the disc plus or minus half an ellipse, the
    // terminator, whose width follows the moon's age.
    final terminator = Radius.elliptical(radius * math.cos(age).abs(), radius);
    final waxing = age <= math.pi;
    final moreThanHalf = math.cos(age) < 0;
    final lit = Path()
      ..moveTo(top.dx, top.dy)
      // The lit limb: the right half while waxing, the left while waning.
      ..arcToPoint(bottom, radius: Radius.circular(radius), clockwise: waxing)
      ..arcToPoint(top, radius: terminator, clockwise: waxing == moreThanHalf)
      ..close();
    canvas.drawPath(lit, Paint()..color = litColor);

    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = rimColor,
    );
  }

  @override
  bool shouldRepaint(_MoonPainter old) =>
      old.age != age ||
      old.litColor != litColor ||
      old.darkColor != darkColor ||
      old.rimColor != rimColor;
}
