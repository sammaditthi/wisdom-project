import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/vinaya_times/uposatha_day.dart';

part 'vinaya_times_state.freezed.dart';

/// What the Today card shows. Times are UTC instants; the widget shows them
/// on the device clock.
@freezed
class VinayaTimesState with _$VinayaTimesState {
  const VinayaTimesState._();

  const factory VinayaTimesState({
    /// The device clock, to the minute.
    required DateTime now,

    /// Aruṇa, midday and sunset of the city's calendar day.
    required DateTime dawn,
    required DateTime midday,
    required DateTime sunset,

    /// The aruṇa that ends the current vikāla, or the coming one.
    required DateTime vikalaEnds,

    /// The sunset that began this night, or the one that begins the next.
    /// The night runs from here to [vikalaEnds].
    required DateTime nightStart,

    /// The current day, which runs aruṇa to aruṇa, as a UTC-midnight date.
    required DateTime buddhistDay,

    /// The uposathas on or after [buddhistDay], soonest first; empty past the
    /// calendar's end.
    required List<UposathaDay> uposathas,
  }) = _VinayaTimesState;

  /// Kāla runs from aruṇa to midday; every other hour is vikāla.
  bool get isVikala => now.isBefore(dawn) || !now.isBefore(midday);

  /// Aruṇa to sunset. Outside it the card draws the night.
  bool get sunIsUp => !now.isBefore(dawn) && !now.isAfter(sunset);

  UposathaDay? get nextUposatha => uposathas.isEmpty ? null : uposathas.first;

  /// Days until [nextUposatha]: 0 on the day itself.
  int? get daysToUposatha => nextUposatha?.date.difference(buddhistDay).inDays;

  /// Which day of its fortnight [buddhistDay] is: 1 the day after an
  /// uposatha, the fortnight's length on the next one.
  int? get fortnightDay {
    final next = nextUposatha;
    return next == null ? null : next.fortnightDays - daysToUposatha!;
  }
}
