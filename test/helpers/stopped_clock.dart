import 'package:the_wisdom_project/presentation/providers/vinaya_times_provider.dart';

/// The minute clock, stopped at [at], so a test can stand at any instant:
/// either side of aruṇa or midday, or between two minutes. The timer it
/// inherits fires only if a test waits past the next minute, and disposing
/// the container cancels it.
class StoppedClock extends MinuteClockNotifier {
  StoppedClock(DateTime at) {
    state = at;
  }
}
