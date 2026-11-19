import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/key_value_store.dart';
import '../../core/storage/key_value_store_provider.dart';
import '../../core/storage/storage_keys.dart';
import '../../data/repositories/sun_times_repository_impl.dart';
import '../../domain/entities/vinaya_times/city.dart';
import '../../domain/entities/vinaya_times/dawn_method.dart';
import '../../domain/entities/vinaya_times/uposatha_calendar.dart';
import '../../domain/repositories/sun_times_repository.dart';
import 'vinaya_times_state.dart';

/// Only the next uposatha; a list of them belongs in a calendar view.
const _uposathasShown = 1;

final sunTimesRepositoryProvider = Provider<SunTimesRepository>((ref) {
  return const SunTimesRepositoryImpl();
});

/// The device clock, to the minute. Ticks on every minute boundary while
/// something is watching.
final minuteClockProvider =
    StateNotifierProvider.autoDispose<MinuteClockNotifier, DateTime>((ref) {
  return MinuteClockNotifier();
});

class MinuteClockNotifier extends StateNotifier<DateTime> {
  MinuteClockNotifier() : super(_thisMinute()) {
    _arm();
  }

  Timer? _timer;

  static DateTime _thisMinute() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, now.minute);
  }

  // One timer per minute, aimed at the boundary, so the clock never drifts
  // and a late wake (sleep, a throttled tab) corrects itself on the next tick.
  void _arm() {
    final nextMinute = _thisMinute().add(const Duration(minutes: 1));
    _timer = Timer(nextMinute.difference(DateTime.now()), () {
      state = _thisMinute();
      _arm();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// The city the times are worked out for.
final vinayaTimesCityProvider =
    StateNotifierProvider<SavedChoiceNotifier<City>, City>((ref) {
  return SavedChoiceNotifier(
    ref.watch(keyValueStoreProvider),
    key: StorageKeys.vinayaTimesCity,
    values: City.values,
    fallback: City.fallback,
  );
});

/// How aruṇa is reckoned.
final dawnMethodProvider =
    StateNotifierProvider<SavedChoiceNotifier<DawnMethod>, DawnMethod>((ref) {
  return SavedChoiceNotifier(
    ref.watch(keyValueStoreProvider),
    key: StorageKeys.vinayaTimesDawnMethod,
    values: DawnMethod.values,
    fallback: DawnMethod.fallback,
  );
});

/// One enum choice saved under [key] by its name; [fallback] until the user
/// picks, or when the saved name is no longer a value.
class SavedChoiceNotifier<T extends Enum> extends StateNotifier<T> {
  SavedChoiceNotifier(
    this._store, {
    required String key,
    required List<T> values,
    required T fallback,
  })  : _key = key,
        super(values.asNameMap()[_store.getString(key)] ?? fallback);

  final KeyValueStore _store;
  final String _key;

  /// Saving is best-effort: the UI already shows the new choice, so a failed
  /// write is logged instead of surfacing as an unhandled async error.
  Future<void> choose(T value) async {
    if (state == value) return;
    state = value;
    try {
      await _store.setString(_key, value.name);
    } catch (e) {
      debugPrint('Failed to save $_key: $e');
    }
  }
}

/// Today's times and the coming uposathas, for the saved city and dawn method.
final vinayaTimesProvider = Provider.autoDispose<VinayaTimesState>((ref) {
  final now = ref.watch(minuteClockProvider);
  final city = ref.watch(vinayaTimesCityProvider);
  final method = ref.watch(dawnMethodProvider);
  final sunTimes = ref.watch(sunTimesRepositoryProvider);

  final today = City.dayAt(now);
  final sun = sunTimes.sunDay(today, city, method);
  final beforeDawn = now.isBefore(sun.dawn);

  // The day runs aruṇa to aruṇa: before today's aruṇa it is still yesterday.
  final buddhistDay =
      beforeDawn ? today.subtract(const Duration(days: 1)) : today;

  return VinayaTimesState(
    now: now,
    dawn: sun.dawn,
    midday: sun.midday,
    sunset: sun.sunset,
    sunrise: sun.sunrise,
    moonAltitude: sunTimes.moonAltitude(now, city),
    // Before aruṇa the night began yesterday; after it, it ends tomorrow.
    // Either way one more day is worked out.
    vikalaEnds: beforeDawn
        ? sun.dawn
        : sunTimes
            .sunDay(today.add(const Duration(days: 1)), city, method)
            .dawn,
    nightStart: beforeDawn
        ? sunTimes.sunDay(buddhistDay, city, method).sunset
        : sun.sunset,
    buddhistDay: buddhistDay,
    uposathas: UposathaCalendar.upcoming(buddhistDay, _uposathasShown),
  );
});
