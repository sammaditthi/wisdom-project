import 'package:freezed_annotation/freezed_annotation.dart';

part 'uposatha_day.freezed.dart';

/// The moon an uposatha falls on.
enum MoonPhase { fullMoon, newMoon }

/// One uposatha of the Sangha calendar.
@freezed
abstract class UposathaDay with _$UposathaDay {
  const factory UposathaDay({
    /// The calendar day, as a UTC-midnight date.
    required DateTime date,
    required MoonPhase phase,

    /// Days in the fortnight this uposatha closes: 14 or 15.
    required int fortnightDays,
  }) = _UposathaDay;
}
