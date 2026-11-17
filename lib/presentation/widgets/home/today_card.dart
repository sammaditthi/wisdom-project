import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/moon_photos.dart';
import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/buddhist_times/uposatha_day.dart';
import '../../providers/buddhist_times_provider.dart';
import '../../providers/buddhist_times_state.dart';
import '../common/buddhist_times_labels.dart';
import '../settings/settings_dialog.dart';
import '../settings/settings_tab.dart';

/// Home's Today card: the day's or the night's arc with midday and vikāla on
/// one side, the moon's fortnight and the coming uposathas on the other.
class TodayCard extends ConsumerWidget {
  const TodayCard({super.key});

  /// Narrower than this, the moon panel drops under the sun arc.
  static const _sideBySideWidth = 520.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(buddhistTimesProvider);
    final city = ref.watch(buddhistTimesCityProvider);
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final typography = context.typography;

    final sun = _ArcSide(state: state);
    // Past the calendar's end there is no uposatha to show, so no panel.
    final moon = state.uposathas.isEmpty ? null : _MoonPanel(state: state);

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
                        l10n.buddhistTimesFullDatePattern,
                        l10n.localeName,
                      ).format(state.now),
                      style: typography.resultTitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Tooltip(
                message: l10n.buddhistTimesChangeLocation(city.label(l10n)),
                child: OutlinedButton.icon(
                  onPressed: () => SettingsDialog.show(
                    context,
                    initial: SettingsTab.buddhistTimes,
                  ),
                  icon: const Icon(Icons.location_on_outlined, size: 16),
                  label: Text(city.label(l10n)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (moon == null) return sun;
              if (constraints.maxWidth < _sideBySideWidth) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [sun, const SizedBox(height: 16), moon],
                );
              }
              return Row(
                children: [
                  Expanded(flex: 3, child: sun),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: moon),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

const _tabular = [FontFeature.tabularFigures()];

/// The arc with its headline: how long until midday, or until when vikāla
/// lasts.
class _ArcSide extends StatelessWidget {
  const _ArcSide({required this.state});

  final BuddhistTimesState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = context.typography;

    final String headline;
    String? detail;
    if (state.isVikala) {
      headline = l10n.buddhistTimesVikalaUntil(clockTime(state.vikalaEnds));
    } else {
      final left = state.midday.difference(state.now);
      final minutes = left.inMinutes.remainder(60);
      headline = left.inHours == 0
          ? l10n.buddhistTimesMiddayIn(minutes)
          : l10n.buddhistTimesMiddayInHours(left.inHours, minutes);
      detail = l10n.buddhistTimesVikalaSpan(
        clockTime(state.midday),
        clockTime(state.vikalaEnds),
      );
    }

    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: _SkyArc(state: state),
        ),
        const SizedBox(height: 8),
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
/// night it runs sunset to aruṇa, all of it in peach.
class _SkyArc extends StatelessWidget {
  const _SkyArc({required this.state});

  final BuddhistTimesState state;

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

    // Room for one line of label, which grows with the system text size.
    final lineHeight = MediaQuery.textScalerOf(context).scale(20);

    final day = state.sunIsUp;
    final start = day ? state.dawn : state.nightStart;
    final end = day ? state.sunset : state.vikalaEnds;
    final span = end.difference(start).inSeconds;
    double along(DateTime instant) =>
        instant.difference(start).inSeconds / span;
    final nowAt = along(state.now);
    // Kāla ends at midday; the night is one stretch from end to end.
    final stretchTo = day ? along(state.midday) : 1.0;

    final middayText = l10n.buddhistTimesMiddayAt(clockTime(state.midday));
    final middayWidth = _textWidth(context, middayText, strong);
    final nowText = l10n.buddhistTimesNowAt(clockTime(state.now));
    final nowWidth = _textWidth(context, nowText, dark);

    return Semantics(
      label: day
          ? l10n.buddhistTimesArcLabel(
              clockTime(start),
              clockTime(state.midday),
              clockTime(end),
            )
          : l10n.buddhistTimesNightArcLabel(clockTime(start), clockTime(end)),
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            // The end labels are centred on the arc's ends, so the arc
            // stands in by about half a label.
            final widest = width / 2 - 2 * lineHeight;
            // It stands in a little more when the Now label needs the room.
            // When even half the arc would not make room, the label goes.
            final fitted = (width / 2 - nowWidth) * math.sqrt2 - _nowReach;
            final nowFits = fitted >= widest / 2;
            final radius = nowFits ? math.min(widest, fitted) : widest;
            final centre = Offset(width / 2, lineHeight + 8 + radius);
            Offset onArc(double fraction) {
              final angle = math.pi * (1 + fraction);
              return centre + Offset(math.cos(angle), math.sin(angle)) * radius;
            }

            final belowEnd = Offset(0, 8 + lineHeight / 2);
            final middayRect = Rect.fromCenter(
              center: onArc(stretchTo) - belowEnd,
              width: middayWidth,
              height: lineHeight,
            );

            // Now keeps a fixed spot outside the arc, 45 degrees up on the
            // marker's side. Its nearest corner sits on that line, so the
            // whole label is further out than the marker ever reaches.
            final onLeft = nowAt < 0.5;
            final corner = centre +
                Offset(onLeft ? -1 : 1, -1) *
                    ((radius + _nowReach) * math.sqrt1_2);
            final nowRect = Rect.fromLTWH(
              onLeft ? corner.dx - nowWidth : corner.dx,
              corner.dy - lineHeight,
              nowWidth,
              lineHeight,
            );
            final showNow = nowFits && !(day && nowRect.overlaps(middayRect));

            return SizedBox(
              height: centre.dy + 8 + lineHeight,
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
                        stretchColor:
                            day ? colors.primaryFixedDim : colors.primaryFixed,
                        restColor: colors.outlineVariant,
                        markerColor: colors.onSurface,
                        // The sun is a ring, the moon a pale disc.
                        markerFill: day ? colors.surface : colors.tertiaryFixed,
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
                        ? l10n.buddhistTimesArunaAt(clockTime(start))
                        : l10n.buddhistTimesSunsetAt(clockTime(start)),
                    style: label,
                  ),
                  _ArcLabel(
                    at: onArc(1) + belowEnd,
                    text: day
                        ? l10n.buddhistTimesSunsetAt(clockTime(end))
                        : l10n.buddhistTimesArunaAt(clockTime(end)),
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
    // The horizon, dashed.
    final horizon = Paint()
      ..color = restColor
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 7) {
      canvas.drawLine(
        Offset(x, centre.dy),
        Offset(math.min(x + 3, size.width), centre.dy),
        horizon,
      );
    }

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

/// The moon's fortnight: how far along it is, the uposatha it ends on, and
/// the two uposathas after that.
class _MoonPanel extends StatelessWidget {
  const _MoonPanel({required this.state});

  final BuddhistTimesState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final typography = context.typography;
    final date = DateFormat(l10n.buddhistTimesDatePattern, l10n.localeName);

    final next = state.uposathas.first;
    final later = state.uposathas.skip(1);
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

    String line(UposathaDay uposatha) =>
        '${date.format(uposatha.date)} · ${uposatha.phase.label(l10n)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Image.asset(
                  photo,
                  width: moonSize,
                  height: moonSize,
                  // The files are larger than they are shown, for sharp
                  // screens; medium scales them down smoothly.
                  filterQuality: FilterQuality.medium,
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      waxing
                          ? l10n.buddhistTimesWaxing(day, next.fortnightDays)
                          : l10n.buddhistTimesWaning(day, next.fortnightDays),
                      style: typography.menuSectionLabel,
                    ),
                    Text(
                      switch (state.daysToUposatha!) {
                        0 => l10n.buddhistTimesUposathaToday,
                        1 => l10n.buddhistTimesUposathaTomorrow,
                        final days => l10n.buddhistTimesUposathaIn(days),
                      },
                      style: typography.resultTitle
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            line(next),
            style: typography.listRowTitle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (later.isNotEmpty) ...[
            const SizedBox(height: 8),
            Divider(height: 1, color: colors.outlineVariant),
            const SizedBox(height: 8),
            for (final uposatha in later)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Text(line(uposatha), style: typography.resultSubtitle),
              ),
          ],
        ],
      ),
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
