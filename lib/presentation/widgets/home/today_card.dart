import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/moon_photos.dart';
import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/vinaya_times/uposatha_day.dart';
import '../../providers/vinaya_times_provider.dart';
import '../../providers/vinaya_times_state.dart';
import '../common/vinaya_times_labels.dart';
import '../settings/settings_dialog.dart';
import '../settings/settings_tab.dart';

/// Home's Today card: the day's or the night's arc with midday and vikāla on
/// one side, the moon's fortnight and the coming uposathas on the other, both
/// over one horizon.
class TodayCard extends ConsumerWidget {
  const TodayCard({super.key});

  /// Narrower than this, the moon's side drops under the sun's.
  static const _sideBySideWidth = 520.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vinayaTimesProvider);
    final city = ref.watch(vinayaTimesCityProvider);
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final typography = context.typography;

    final sunSky = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: _SkyArc(state: state),
      ),
    );
    final sunLines = _ArcHeadline(state: state);
    // Past the calendar's end there is no uposatha to show, so no moon side.
    final hasMoon = state.uposathas.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeToday.toUpperCase(),
                      style: typography
                          .sectionHeaderFor(l10n.homeToday)
                          .copyWith(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      // The device's date, like the clock times beside it.
                      DateFormat(
                        l10n.vinayaTimesFullDatePattern,
                        l10n.localeName,
                      ).format(state.now),
                      style: typography.resultTitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Tooltip(
                message: l10n.vinayaTimesChangeLocation(city.label(l10n)),
                child: OutlinedButton.icon(
                  onPressed: () => SettingsDialog.show(
                    context,
                    initial: SettingsTab.vinayaTimes,
                  ),
                  // As small as its label allows. The theme still gives it
                  // a 48px tap area on touch screens.
                  style: OutlinedButton.styleFrom(
                    textStyle: typography.actionLabel,
                    minimumSize: Size.zero,
                    padding: const EdgeInsetsDirectional.fromSTEB(6, 4, 10, 4),
                    visualDensity: VisualDensity.standard,
                  ),
                  icon: const Icon(Icons.location_on_outlined, size: 14),
                  label: Text(city.label(l10n)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (!hasMoon || constraints.maxWidth < _sideBySideWidth) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Horizon(child: sunSky),
                    const SizedBox(height: 8),
                    sunLines,
                    if (hasMoon) ...[
                      const SizedBox(height: 16),
                      _Horizon(child: _MoonSky(state: state)),
                      const SizedBox(height: 8),
                      _UposathaLines(state: state),
                    ],
                  ],
                );
              }
              // The two skies share a bottom edge, so one horizon runs
              // under both, and the lines under them start level.
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Horizon(
                    child: _columns(
                      sunSky,
                      _MoonSky(state: state),
                      CrossAxisAlignment.end,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _columns(
                    sunLines,
                    _UposathaLines(state: state),
                    CrossAxisAlignment.start,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// The sun's side and the moon's, three parts to two.
  static Widget _columns(Widget sun, Widget moon, CrossAxisAlignment align) {
    return Row(
      crossAxisAlignment: align,
      children: [
        Expanded(flex: 3, child: sun),
        const SizedBox(width: 24),
        Expanded(flex: 2, child: moon),
      ],
    );
  }
}

const _tabular = [FontFeature.tabularFigures()];

/// Gap between the arc and a label beside it, and between the horizon and
/// the labels under it.
const _labelGap = 8.0;

/// Room for one line of label, which grows with the system text size.
double _labelLineHeight(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(20);

/// The headline under the arc: how long until midday, or until when vikāla
/// lasts.
class _ArcHeadline extends StatelessWidget {
  const _ArcHeadline({required this.state});

  final VinayaTimesState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = context.typography;

    final String headline;
    String? detail;
    if (state.isVikala) {
      headline = l10n.vinayaTimesVikalaUntil(clockTime(state.vikalaEnds));
    } else {
      final left = state.midday.difference(state.now);
      final minutes = left.inMinutes.remainder(60);
      headline = left.inHours == 0
          ? l10n.vinayaTimesMiddayIn(minutes)
          : l10n.vinayaTimesMiddayInHours(left.inHours, minutes);
      detail = l10n.vinayaTimesVikalaSpan(
        clockTime(state.midday),
        clockTime(state.vikalaEnds),
      );
    }

    return Column(
      children: [
        Text(
          headline,
          textAlign: TextAlign.center,
          style: typography.resultTitle.copyWith(
            fontWeight: FontWeight.w600,
            fontFeatures: _tabular,
          ),
        ),
        if (detail != null) ...[
          const SizedBox(height: 2),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: typography.resultSubtitle.copyWith(fontFeatures: _tabular),
          ),
        ],
      ],
    );
  }
}

/// A half circle with a marker where the sun or the moon is now. By day it
/// runs aruṇa to sunset with the kāla stretch, up to midday, in orange; by
/// night it runs sunset to aruṇa, all of it in midnight blue.
class _SkyArc extends StatelessWidget {
  const _SkyArc({required this.state});

  final VinayaTimesState state;

  static const _stroke = 6.0;
  static const _markerRadius = 8.0;

  /// How far outside the arc the Now label keeps: past the marker, plus a gap.
  static const _nowReach = _markerRadius + 6;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final label = context.typography.menuSectionLabel.copyWith(
      fontFeatures: _tabular,
    );
    final dark = label.copyWith(color: colors.onSurface);
    final strong = dark.copyWith(fontWeight: FontWeight.w600);

    final lineHeight = _labelLineHeight(context);

    final day = state.sunIsUp;
    final start = day ? state.dawn : state.nightStart;
    final end = day ? state.sunset : state.vikalaEnds;
    final span = end.difference(start).inSeconds;
    double along(DateTime instant) =>
        instant.difference(start).inSeconds / span;
    final nowAt = along(state.now);
    // Kāla ends at midday; the night is one stretch from end to end.
    final stretchTo = day ? along(state.midday) : 1.0;

    final middayText = l10n.vinayaTimesMiddayAt(clockTime(state.midday));
    final middayWidth = _textWidth(context, middayText, strong);
    final nowText = l10n.vinayaTimesNowAt(clockTime(state.now));
    final nowWidth = _textWidth(context, nowText, dark);

    return Semantics(
      label: day
          ? l10n.vinayaTimesArcLabel(
              clockTime(start),
              clockTime(state.midday),
              clockTime(end),
            )
          : l10n.vinayaTimesNightArcLabel(clockTime(start), clockTime(end)),
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            // The end labels are centred on the arc's ends, so the arc
            // stands in by about half a label.
            final widest = width / 2 - 2 * lineHeight;

            // Now is centred on the line 45 degrees up from the arc's centre,
            // [out] along each axis: as near as it can be while its nearest
            // corner, (out - w, out - h) from the centre, is past the
            // marker's reach.
            final w = nowWidth / 2;
            final h = lineHeight / 2;
            double out(double radius) {
              final reach = radius + _nowReach;
              final root = 2 * reach * reach - (w - h) * (w - h);
              return (w + h + math.sqrt(math.max(0, root))) / 2;
            }

            // The arc stands in a little more when Now needs the room: the
            // radius where out + w is half the width. When even half the arc
            // would not make room, the label goes.
            final room = width - 3 * w - h;
            final fitted = room <= 0
                ? 0.0
                : math.sqrt((room * room + (w - h) * (w - h)) / 2) - _nowReach;
            final nowFits = fitted >= widest / 2;
            final radius = nowFits ? math.min(widest, fitted) : widest;
            final centre = Offset(width / 2, lineHeight + _labelGap + radius);
            Offset onArc(double fraction) {
              final angle = math.pi * (1 + fraction);
              return centre + Offset(math.cos(angle), math.sin(angle)) * radius;
            }

            final belowEnd = Offset(0, _labelGap + lineHeight / 2);
            final middayRect = Rect.fromCenter(
              center: onArc(stretchTo) - belowEnd,
              width: middayWidth,
              height: lineHeight,
            );

            // On the marker's side, mirrored exactly on the other.
            final onLeft = nowAt < 0.5;
            final nowRect = Rect.fromCenter(
              center: centre + Offset(onLeft ? -1 : 1, -1) * out(radius),
              width: nowWidth,
              height: lineHeight,
            );
            // A very small arc at a large text size would push it above the
            // card's header gap; then it goes too.
            final showNow = nowFits &&
                nowRect.top >= 0 &&
                !(day && nowRect.overlaps(middayRect));

            return SizedBox(
              // The horizon goes here, painted by [_Horizon] behind.
              height: centre.dy + _labelGap + lineHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SkyArcPainter(
                        centre: centre,
                        radius: radius,
                        stretchTo: stretchTo,
                        nowAt: nowAt,
                        stroke: _stroke,
                        markerRadius: _markerRadius,
                        stretchColor: day
                            ? colors.primaryFixedDim
                            : colors.tertiaryFixedDim,
                        restColor: colors.outlineVariant,
                        markerColor: colors.onSurface,
                        // The sun is a ring, the moon an amber disc.
                        markerFill: day ? colors.surface : colors.primaryFixed,
                        markerRing: day ? 3 : 1.5,
                      ),
                    ),
                  ),
                  if (day)
                    _ArcLabel(
                      at: middayRect.center,
                      text: middayText,
                      style: strong,
                    ),
                  _ArcLabel(
                    at: onArc(0) + belowEnd,
                    text: day
                        ? l10n.vinayaTimesArunaAt(clockTime(start))
                        : l10n.vinayaTimesSunsetAt(clockTime(start)),
                    style: label,
                  ),
                  _ArcLabel(
                    at: onArc(1) + belowEnd,
                    text: day
                        ? l10n.vinayaTimesSunsetAt(clockTime(end))
                        : l10n.vinayaTimesArunaAt(clockTime(end)),
                    style: label,
                  ),
                  if (showNow)
                    _ArcLabel(at: nowRect.center, text: nowText, style: dark),
                ],
              ),
            );
          },
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
    required this.nowAt,
    required this.stroke,
    required this.markerRadius,
    required this.stretchColor,
    required this.restColor,
    required this.markerColor,
    required this.markerFill,
    required this.markerRing,
  });

  final Offset centre;
  final double radius;

  /// Where the coloured stretch ends and where the marker is, as fractions
  /// of the way along the arc.
  final double stretchTo;
  final double nowAt;

  final double stroke;
  final double markerRadius;
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
    canvas.drawArc(rect, math.pi, math.pi, false, arc..color = restColor);
    canvas.drawArc(
      rect,
      math.pi,
      math.pi * stretchTo,
      false,
      arc..color = stretchColor,
    );

    final angle = math.pi * (1 + nowAt);
    final marker = centre + Offset(math.cos(angle), math.sin(angle)) * radius;
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
      old.nowAt != nowAt ||
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

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HorizonPainter(
        fromBottom: _labelGap + _labelLineHeight(context),
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

/// The moon above the horizon and, under it level with the arc's end labels,
/// how far along its fortnight it is.
class _MoonSky extends StatelessWidget {
  const _MoonSky({required this.state});

  final VinayaTimesState state;

  /// Clear sky between the moon and the horizon.
  static const _clearance = 20.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    final next = state.uposathas.first;
    final day = state.fortnightDay!;
    final waxing = next.phase == MoonPhase.fullMoon;
    // The moon's age as an angle: 0 at new moon, pi at full.
    final age = math.pi * (waxing ? 0 : 1) + math.pi * day / next.fortnightDays;
    // One photo a step round the cycle: the first the new moon, the middle
    // one the full moon.
    final photo = moonPhotoAsset(
      (age / math.pi * (moonPhotoCount / 2)).round() % moonPhotoCount,
    );
    const moonSize = 64.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Image.asset(
            photo,
            width: moonSize,
            height: moonSize,
            // No photo (web, offline, not yet stored): the drawn moon.
            errorBuilder: (_, __, ___) => CustomPaint(
              size: const Size.square(moonSize),
              painter: _MoonPainter(
                age: age,
                litColor: colors.tertiaryFixed,
                darkColor: colors.surfaceContainerHighest,
                rimColor: colors.outline,
              ),
            ),
          ),
        ),
        const SizedBox(height: _clearance + _labelGap),
        SizedBox(
          height: _labelLineHeight(context),
          // One line, like the end labels beside it: wrapping would push
          // the label's top onto the horizon, so a long one shrinks.
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                waxing
                    ? l10n.vinayaTimesWaxing(day, next.fortnightDays)
                    : l10n.vinayaTimesWaning(day, next.fortnightDays),
                maxLines: 1,
                style: context.typography.menuSectionLabel,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// When the next uposatha is, its date, and the one after it.
class _UposathaLines extends StatelessWidget {
  const _UposathaLines({required this.state});

  final VinayaTimesState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = context.typography;
    final date = DateFormat(l10n.vinayaTimesDatePattern, l10n.localeName);

    String line(UposathaDay uposatha) =>
        '${date.format(uposatha.date)} · ${uposatha.phase.label(l10n)}';

    return Column(
      children: [
        Text(
          switch (state.daysToUposatha!) {
            0 => l10n.vinayaTimesUposathaToday,
            1 => l10n.vinayaTimesUposathaTomorrow,
            final days => l10n.vinayaTimesUposathaIn(days),
          },
          textAlign: TextAlign.center,
          style: typography.resultTitle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          line(state.uposathas.first),
          textAlign: TextAlign.center,
          style: typography.listRowTitle.copyWith(fontWeight: FontWeight.w500),
        ),
        for (final uposatha in state.uposathas.skip(1)) ...[
          const SizedBox(height: 2),
          Text(
            line(uposatha),
            textAlign: TextAlign.center,
            style: typography.menuSectionLabel,
          ),
        ],
      ],
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
