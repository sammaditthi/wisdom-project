import '../entities/buddhist_times/city.dart';
import '../entities/buddhist_times/dawn_method.dart';

/// Sun times for a city on a calendar day.
///
/// [day] is the day in the city; only its year, month and day are read. The
/// results are UTC instants, already rounded to the minute on the safe side.
/// No `Either`: this is maths on a fixed city list and cannot fail.
abstract class SunTimesRepository {
  /// Solar midday, rounded down to the minute.
  DateTime midday(DateTime day, City city);

  /// Aruṇa by [method], rounded up to the minute.
  DateTime dawn(DateTime day, City city, DawnMethod method);

  /// Sunset, rounded to the nearest minute: it is shown, and times nothing.
  DateTime sunset(DateTime day, City city);
}
