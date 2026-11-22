import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/core/storage/key_value_store_provider.dart';
import 'package:the_wisdom_project/data/repositories/sun_times_repository_impl.dart';
import 'package:the_wisdom_project/domain/entities/vinaya_times/city.dart';
import 'package:the_wisdom_project/domain/entities/vinaya_times/dawn_method.dart';
import 'package:the_wisdom_project/domain/repositories/sun_times_repository.dart';
import 'package:the_wisdom_project/presentation/providers/vinaya_times_provider.dart';
import 'package:the_wisdom_project/presentation/providers/vinaya_times_state.dart';

import '../../helpers/fake_key_value_store.dart';
import '../../helpers/stopped_clock.dart';

void main() {
  const sun = SunTimesRepositoryImpl();
  const minute = Duration(minutes: 1);

  // 24 Nov 2026 is a full-moon uposatha; the next is the new moon of 9 Dec.
  final uposatha = DateTime.utc(2026, 11, 24);
  final dayAfter = DateTime.utc(2026, 11, 25);

  ProviderContainer containerAt(DateTime now, {InMemoryKeyValueStore? store}) {
    final container = ProviderContainer(
      overrides: [
        keyValueStoreProvider
            .overrideWithValue(store ?? InMemoryKeyValueStore()),
        minuteClockProvider.overrideWith((ref) => StoppedClock(now)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  // With nothing saved: the default city and dawn method.
  VinayaTimesState stateAt(DateTime now) =>
      containerAt(now).read(vinayaTimesProvider);
  SunDay sunOn(DateTime day) =>
      sun.sunDay(day, City.fallback, DawnMethod.fallback);

  test('kāla runs from aruṇa to midday; vikāla ends at the next aruṇa', () {
    final today = sunOn(uposatha);

    final beforeAruna = stateAt(today.dawn.subtract(minute));
    expect(beforeAruna.isVikala, isTrue);
    expect(beforeAruna.vikalaEnds, today.dawn);

    expect(stateAt(today.dawn).isVikala, isFalse);
    expect(stateAt(today.midday.subtract(minute)).isVikala, isFalse);

    final atMidday = stateAt(today.midday);
    expect(atMidday.isVikala, isTrue);
    expect(atMidday.vikalaEnds, sunOn(dayAfter).dawn);
  });

  test('the uposatha day runs from aruṇa to the next aruṇa', () {
    final aruna = sunOn(uposatha).dawn;
    final nextAruna = sunOn(dayAfter).dawn;

    // Before aruṇa the night still belongs to the day before.
    expect(stateAt(aruna.subtract(minute)).daysToUposatha, 1);
    expect(stateAt(aruna).daysToUposatha, 0);
    expect(stateAt(nextAruna.subtract(minute)).daysToUposatha, 0);

    final afterIt = stateAt(nextAruna);
    expect(afterIt.nextUposatha!.date, DateTime.utc(2026, 12, 9));
    expect(afterIt.daysToUposatha, 14);
    expect(afterIt.fortnightDay, 1);
  });

  test('an uposatha is the last day of its fortnight: 15 of 15, or 14 of 14',
      () {
    // 24 Nov closes a 15-day fortnight, 9 Nov a 14-day one.
    final day15 = stateAt(sunOn(uposatha).dawn);
    expect(day15.nextUposatha!.fortnightDays, 15);
    expect(day15.fortnightDay, 15);

    final day14 = stateAt(sunOn(DateTime.utc(2026, 11, 9)).dawn);
    expect(day14.nextUposatha!.fortnightDays, 14);
    expect(day14.fortnightDay, 14);
  });

  test(
      'Anuradhapura and Na-Uyana until chosen; a choice applies at once and '
      'survives a restart', () async {
    final store = InMemoryKeyValueStore();
    final now = DateTime.utc(2026, 11, 24, 6); // 11:30 in Sri Lanka
    final first = containerAt(now, store: store);
    // Held open, as the card holds it, so each choice must change it in place.
    final card = first.listen(vinayaTimesProvider, (_, __) {});

    expect(first.read(vinayaTimesCityProvider), City.anuradhapura);
    expect(first.read(dawnMethodProvider), DawnMethod.naUyana);

    await first.read(vinayaTimesCityProvider.notifier).choose(City.jaffna);
    expect(
      card.read().dawn,
      sun.sunDay(uposatha, City.jaffna, DawnMethod.naUyana).dawn,
    );
    await first.read(dawnMethodProvider.notifier).choose(DawnMethod.paAuk);
    expect(
      card.read().dawn,
      sun.sunDay(uposatha, City.jaffna, DawnMethod.paAuk).dawn,
    );

    // A restart: a new container reading the same saved store.
    final restarted = containerAt(now, store: store);
    expect(restarted.read(vinayaTimesCityProvider), City.jaffna);
    expect(restarted.read(dawnMethodProvider), DawnMethod.paAuk);
  });
}
