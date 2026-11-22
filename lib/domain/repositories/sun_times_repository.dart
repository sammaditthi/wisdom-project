import '../entities/vinaya_times/city.dart';
import '../entities/vinaya_times/dawn_method.dart';

/// One day's sun in a city, as UTC instants rounded to the minute on the safe
/// side: aruṇa up, midday down, sunrise and sunset to the nearest. Sunset is
/// shown and times nothing; only the card's sky reads sunrise.
typedef SunDay = ({
  DateTime dawn,
  DateTime sunrise,
  DateTime midday,
  DateTime sunset,
});

/// Sun times for a city on a calendar day, and where the moon stands.
///
/// [day] is the day in the city; only its year, month and day are read.
/// No `Either`: this is maths on a fixed city list and cannot fail.
abstract class SunTimesRepository {
  /// [day]'s sun in [city], with aruṇa by [method]: all four times from one
  /// solar calculation.
  SunDay sunDay(DateTime day, City city, DawnMethod method);

  /// The moon's altitude in degrees at [instant], seen from [city]; below
  /// the horizon it is negative. Low precision: for the card's sky only.
  double moonAltitude(DateTime instant, City city);
}
