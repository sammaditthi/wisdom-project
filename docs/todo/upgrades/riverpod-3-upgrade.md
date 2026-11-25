# Riverpod 3 upgrade — findings and plan

Investigated 2026-10-08 on 3.4.3. Step 1 done 2026-11-25 on `chore/riverpod-3`, on 3.5.0 (the latest; no 3.6 or 4.0 out).

## Decision

`flutter_riverpod` 2.6.1 → 3.5.0 as a plain version bump, with Riverpod's automatic retry turned off. No refactor rode along: steps 2–6 stay optional, each its own PR.

## How to use this plan

| Step | What | Size | Worth it? ([why](#worth-doing)) | Status |
| --- | --- | --- | --- | --- |
| 1 | The upgrade itself | M | — | Done 2026-11-25 |
| 2 | Tabs in one notifier | L | Yes, the one real payoff; when tabs are next worked on | Optional |
| 3 | Settings save themselves | M | Small; only together with step 2 | Optional |
| 4 | Theme and font size load like other settings | S | Tidiness only; fold into the pinch-to-zoom work | Optional |
| 5 | Action providers become notifier methods | M | The tab ones with step 2; the rest no | Optional |
| 6 | `riverpod_lint`, maybe code generation | S | No (measured) | Not planned |

**Rules for new code**, from what the upgrade taught (no refactor needed):

- A `ref.listen` on a *derived* provider (one computed from others) never writes provider state. Listen to the `StateNotifier` / `StateProvider` that changes instead (runtime change 3).
- A test that builds its own `ProviderScope` around a provider that can fail passes `retry: noProviderRetry`.
- A test that needs its own store passes `createTestContainer(keyValueStore: …)`, never a second `keyValueStoreProvider` override.

Rules:

- Steps 2–5 are separate PRs, each cut from `main` after step 1 merges.
- They edit existing tests, so ask the user before starting. Write no new tests; a separate agent does that.
- When a step is done, set its status and add a handover note at the end of this doc.

## Findings

### Versions

- Was: `flutter_riverpod` 2.6.1 (2024-10-22), the last 2.x release. It gets no more fixes.
- Now: 3.5.0 (2026-11-06). The lock changed only `flutter_riverpod`, `riverpod` and one new package, `uuid`.
- The legacy providers (`StateProvider`, `StateNotifierProvider`) carry no deprecation in 3.5.0. 3.5.0 deprecates `Ref.exists`, which we don't use.

The app has 116 providers: 67 `Provider`, 17 `StateNotifierProvider` (15 notifier classes), 16 `StateProvider`, 11 `FutureProvider`, and 5 family/autoDispose `Provider`s. No code generation.

### What broke when compiling

446 analyzer errors after the bump, all fixed mechanically:

| Fix | Where |
| --- | --- |
| `StateProvider`, `StateNotifierProvider`, `StateNotifier` and `StateController` moved to `package:flutter_riverpod/legacy.dart` | 29 files |
| `AsyncValue.valueOrNull` was removed: use `.value` | 17 places |
| `Override` is no longer exported by `flutter_riverpod.dart`: import it from `package:flutter_riverpod/misc.dart` | 12 test files |
| `RemoveListener` is no longer exported: use `void Function()` | `tab_provider.dart` |

`AsyncValue.value` also changed meaning: in 2.x it rethrew the error, in 3.x it returns null (as `valueOrNull` did). The one older `.value` read of an `AsyncValue` (`multi_pane_reader_widget.dart`) is behind a `hasValue` check, so nothing changed there.

### What changes at runtime

**1. Automatic retry: turned off.** A provider that throws an `Exception` is retried up to 10 times, waiting 200 ms and doubling up to 6.4 s, about 38 s in total. Dart `Error`s and other providers' failures are not retried. All 11 `FutureProvider`s turn a `Failure` into `throw Exception(failure.userMessage)`, which is exactly what gets retried.

While it retries, the provider is "loading" but carries the error, and `.when()` shows that error at once (its `skipLoadingOnRefresh` is on by default). So the screen would not have shown a spinner. Leaving retry on would instead have re-run a failed DB query or JSON parse up to 10 more times, and left `await ref.read(sitePlanProvider.future)` (deep links) and `readerUnitResolverProvider.future` (tabs) waiting the whole 38 s. Our data is all local, so a failed load fails again.

The fix is `noProviderRetry` (`lib/presentation/providers/provider_retry.dart`), passed as `retry:` to the root `ProviderScope` in `main.dart`, to `pumpApp` / `pumpAppWithScaffold` / `createTestContainer`, to every integration-test scope, and to the two tests that build their own scope around a failing provider (`status_message_view_panels_test.dart`, `dictionary_bottom_sheet_test.dart`). Riverpod's default can't be changed globally: `ProviderContainer.defaultRetry` is a static method.

**2. Overriding one provider twice now throws** (`Tried to override a provider twice within the same container`). Hit by `tab_provider_test.dart` and `general_settings_page_test.dart`, which passed their own store on top of `createTestContainer`'s. `createTestContainer` and `defaultTestOverrides` now take `keyValueStore:` instead.

**3. A listener of a derived provider must not write state that feeds back** ([riverpod#4808](https://github.com/rrousselGit/riverpod/issues/4808), open, not fixed in 3.5.0). Such a listener runs inside Riverpod's refresh pass. If its write dirties a provider that already rebuilt in that pass, Riverpod 3 throws `Tried to rebuild … multiple times in the same frame` (debug only), and the throw skips the scheduler's cleanup, so no provider refreshes again for the rest of the session. Release builds don't check, so they don't throw. Found by the integration suite, not the plan: `MultiPaneReaderWidget` listened to `activeInPageSearchStateProvider` and `activeReaderLayoutProvider`, and both callbacks anchor the tab (`setTabAnchor`), which rebuilt `activeTabProvider` twice. `in_page_search_test` 3b (Previous wrapping to the last match) and every `layout_switch_test` test failed, and the next test hung. Fixed by listening to `inPageSearchStatesProvider` and `tabsProvider` instead: a `StateNotifier` notifies inside the action itself, before any pass. A `Future.microtask` would also avoid the throw (what others on #4808 did), but when the pass runs inside a frame, that frame paints the new layout at the old position. The other listeners that write (overlay stack, last selection, app-bar tint) write providers nothing derived watches.

**4. Checked and harmless:**

- **`ProviderException` wrapping.** Every `catch` in `lib/presentation` is untyped. `AsyncValue.error` and `.future` keep the original error. Same for 3.5.0's `ProviderDisposedException`, which replaces `StateError` when a provider is disposed before its `.future` completes.
- **`==` filtering.** `StateNotifier`s keep their old "notify unless identical" rule. `StateProvider` now uses `==`, so setting an equal value twice notifies once. The two places that set a value twice on purpose (null then the node in `navigator_sync_provider.dart`, -1 then the index in `closeTabProvider`) change it in between, so they still fire. One visible effect: tapping the dictionary word that is already open no longer moves the sheet above the find bar on the ESC stack.
- **Pausing hidden widgets.** 3.x pauses `ref.watch` in widgets whose `TickerMode` is off. Flutter 3.50's `IndexedStack` (`app_shell.dart`) hides children with `_VisibilityScope` and `ExcludeFocus` only, never `TickerMode`, so hidden sections aren't paused. Only the Research pane's nested navigator is affected.
- **Dead `Ref`s.** 3.x throws `UnmountedRefException` when a disposed `Ref` is used. The notifiers that hold a `Ref` (`InPageSearchNotifier`, `FtsHighlightNotifier`, `ResearchChatNotifier`) and the function-valued providers watch nothing that changes at runtime, so their `Ref` lives as long as the app.

### Performance

A compiled release build, best of 5 runs, three runs each (µs = millionths of a second):

| Operation | 2.6.1 | 3.5.0 |
| --- | --- | --- |
| `read` | 0.04 µs | 0.21 µs |
| one state update (4 listeners) | 0.2 µs | 0.89 µs |
| an update through 30 chained providers | 11.6 µs | 66 µs |
| create + dispose one family instance | 0.74 µs | 2.1 µs |

3.x is 3–6× slower per operation, but these are microseconds. A tab switch passes through roughly 20–40 providers, about 0.1 ms against an 8–16 ms frame. Scroll saving is debounced, so no provider updates every frame.

### Benefits

- **A maintained version.** 2.x is frozen; fixes land only in 3.x.
- **A Riverpod tab in Flutter DevTools** for inspecting providers live.
- **Simpler tests, when wanted.** `ProviderContainer.test()` disposes itself; `tester.container()` replaces `ProviderScope.containerOf(...)` lookups. Not adopted: it would only churn tests.
- **`ref.mounted`**, a safe check after an `await` inside a notifier.

## Steps 2–5 — Optional simplifications

The upgrade doesn't simplify anything by itself. But `Notifier` (available since Riverpod 2.0) is now the main style, so these become natural. They're ordered by payoff.

### Step 2 — Tabs in one notifier (L)

Tab state lives in five places: `tabsProvider`, `activeTabIndexProvider`, `inPageSearchStatesProvider` and `ftsHighlightProvider` (both maps keyed by tab *index*), and `activeTabIndexPersistenceProvider`. `closeTabProvider` (`lib/presentation/providers/tab_lifecycle_provider.dart`) keeps them in sync by hand. It re-numbers both maps, and it sets the index to `-1` and back "to force the listener to fire".

Give each tab a stable id. Let one `Notifier` own the tab list and the active tab, and key per-tab state by tab id. The re-indexing, the `-1` flip and the separate persistence provider all go away, and so does the layout listener's "same length, new layout at the active index" test in `multi_pane_reader_widget.dart`, which becomes a tab-id comparison. Tests name `activeTabIndexProvider` about 70 times, about 40 of them setting it.

### Step 3 — Settings save themselves (M)

`navigatorVisibleProvider`, `navigationRailHiddenProvider` and `activeTabIndexProvider` each have a separate `Provider<void>` that writes changes to disk, and `main.dart` must `read` all three at startup to keep them alive. Only a `Notifier` can save its own changes: `listenSelf` is on Riverpod's internal `$Ref`, not on the `Ref` a `StateProvider` gets. So each becomes a `Notifier`, and callers switch from `ref.read(navigatorVisibleProvider.notifier).state = x` to methods:

```dart
class NavigatorVisibleNotifier extends Notifier<bool> {
  @override
  bool build() {
    final store = ref.read(keyValueStoreProvider);
    // Save every change. No extra provider, nothing to start in main.dart.
    listenSelf((_, visible) =>
        store.setInt(StorageKeys.navigatorVisible, visible ? 1 : 0));
    // Nothing saved yet (first launch) means visible.
    return (store.getInt(StorageKeys.navigatorVisible) ?? 1) != 0;
  }

  void toggle() => state = !state;
}

final navigatorVisibleProvider =
    NotifierProvider<NavigatorVisibleNotifier, bool>(NavigatorVisibleNotifier.new);
```

The active tab's saving moves into step 2's notifier, so do this with step 2; done alone, `main.dart` still has one listener to start.

**One notifier per kind of saved setting.** Noted 2026-11-17 in the Vinaya times review. Two generic notifiers already exist, each in a feature file: `BoolSettingNotifier` (`pali_letter_options_provider.dart`) and `SavedChoiceNotifier<T extends Enum>` (`vinaya_times_provider.dart`). `ContentLanguageNotifier` and `AppLanguageNotifier` repeat `SavedChoiceNotifier` by hand: load the enum by name, save best-effort. App language works out its fallback from the device locales, so it can pass that in. Move both generics into one shared file, convert them to `Notifier` here, and replace the two hand-written ones. `LastReaderLayoutNotifier` stays as it is: "nothing saved" is a real state for it (`null`), not a fallback.

### Step 4 — Theme and font size load like other settings (S)

`ThemeNotifier` and `FontScaleNotifier` load late: `main.dart` calls `loadSavedTheme()` / `loadSavedScale()` in a startup microtask, and they call `SharedPreferences.getInstance()` themselves. Every other setting reads `keyValueStoreProvider` straight away, in its constructor. Make these two match and delete the two calls in `main.dart`. This also closes the TODO at the top of `lib/core/theme/theme_notifier.dart`.

Tidiness only: the saved theme already applies before the first paint, since `SharedPreferences` is loaded before `runApp` and the microtask finishes before the warm-up frame (reasoned from the startup order, not measured). `KeyValueStore` has no `getDouble` / `setDouble`, so font size needs them added to the interface and its three implementations (the SharedPreferences store and the two in-memory fakes, in `test/helpers` and `integration_test`).

### Step 5 — Action providers become notifier methods (M)

Fifteen providers only hold a function (`Provider<... Function(...)>`), for example `closeTabProvider`, `switchTabProvider`, `openTabFromNodeKeyProvider`, `selectNodeProvider` and `toggleNodeExpansionProvider`. Each action belongs on the notifier that owns the state it changes. The tab ones are best done together with step 2.

## Worth doing?

Assessed 2026-11-25, after step 1. The upgrade needs none of these: the legacy providers carry no deprecation in 3.5.0, and nothing below fixes a bug users see today.

- **Step 2 — yes, the one with a real payoff.** Tab state keyed by *position* is where this code keeps breaking: closing a tab re-keys two maps and the find bar's debounce timers by hand, and the `-1` flip exists only to make a listener fire. Step 1's reader fix also had to infer "same tab" from list length, because tabs have no id. Cost: L, with heavy test churn. Do it when tabs are next worked on, as its own PR.
- **Step 3 — small.** Only three older settings use the "separate listener started in `main.dart`" pattern; newer ones (`BoolSettingNotifier`, `SavedChoiceNotifier`) already save in their own methods, so the trap isn't spreading. Done alone, `main.dart` still starts the active tab's listener. Merging `ContentLanguageNotifier` and `AppLanguageNotifier` into the generic notifier saves two near-copies. Fold into step 2.
- **Step 4 — tidiness only.** Nothing visible changes. [`pinch-to-zoom.md`](../reader/pinch-to-zoom.md) already plans to change `FontScaleNotifier`; do it there.
- **Step 5 — the tab actions with step 2, the rest no.** Each function provider captures its `Ref`; Riverpod 3 throws if one is used after its provider rebuilds, and none rebuilds today. A latent risk, not a bug.
- **Step 6 — no.** Measured: one false positive and a 6× slower analyze.

### Anything else? Considered, not worth it

- **Converting every `StateNotifier` to `Notifier`** (15 classes, the "legacy" exit). Not deprecated. `FakeSearchStateNotifier` serves 9 test files and `search_state_notifier_test.dart` builds its notifier directly, so `SearchStateNotifier` alone means a test rewrite. Convert a notifier only when it is being rewritten anyway; steps 2–3 cover seven of them.
- **The 16 simple `StateProvider`s as `Notifier`s.** A class per value, and the legacy import is fine.
- **`ProviderContainer.test()` and `tester.container()` in tests.** Tests dispose containers by hand about 55 times and call `ProviderScope.containerOf` 19 times. No sweep; new tests should use them.
- **`switch` on `AsyncValue` instead of `.when`** (it is sealed in 3.x). Only 8 `.when` calls, and `.when` also covers the refresh and reload cases (`skipLoadingOnRefresh`) that a plain `switch` would have to spell out; that rule is why a retrying provider still showed its error.
- **Pausing hidden sections** (wrapping `app_shell.dart`'s `IndexedStack` children in `TickerMode`, which Riverpod 3 pauses on). Home's minute clock and hidden screens would stop rebuilding, but their listeners would not run while hidden: the reader's tab-switch listener, which saves the old tab's scroll offset before the switch, would run late for a tab opened from Home by a deep link.
- **Throwing the `Failure` instead of `Exception(failure.userMessage)`** (8 places). Not a Riverpod question now that retry is off; the panels already pick their copy by context. It belongs to [the error-handling standard](../refactor/generic-server-call-and-error-handling-standard.md) if ever.
- **Offline persistence and mutations.** Experimental in 3.x, and the app has its own `KeyValueStore` persistence.
- **`ref.mounted`.** Nothing needs it: every notifier that holds a `Ref` lives as long as the app.

## Step 6 — `riverpod_lint` and code generation

Tried 2026-11-25 (`plugins: riverpod_lint: ^3.2.0` in `analysis_options.yaml`, then reverted). One finding, a false positive: `missing_provider_scope` on the `runApp(_DatabaseMissingError(...))` error screen, which uses no providers. A warm `dart analyze` went from 4 s to 24 s, and a fresh machine must download the plugin first. Most of its lints are for `Notifier` classes or the generator, so revisit after steps 2–3.

Code generation (`riverpod_generator` 4.0.10 resolves on the current lock): probably not worth it. It would turn every provider into an annotated function or class.

## Handover notes

**Step 1, 2026-11-25.** Branch `chore/riverpod-3`: the upgrade, the reader listener fix (runtime change 3) and this doc are three commits. 22 test files changed, all forced by the upgrade: imports (`legacy.dart`, `Override`), `valueOrNull`, `retry: noProviderRetry`, and `keyValueStore:` replacing a second store override. No new tests: `in_page_search_test` 3b and `layout_switch_test` already fail without the listener fix. Full gate (`scripts/app/test.sh`), 2026-11-25: 9 of 9 steps passed (897 unit + widget tests, 96 macOS integration tests in one launch, all 13 files in Chrome).

Not checked by any harness, so left for a by-hand run (macOS, then web): open and close tabs, restart, and check the active tab and the navigator's open/closed state come back; the dictionary sheet; a deep link; Research.

## How the findings were checked

- **Compile:** bumped, analyzed, fixed, analyzed again (`lib`, `test`, `integration_test`).
- **Behaviour:** read the 3.5.0 source (`ProviderElement.triggerRetry`, `$Ref.listenSelf`, the duplicate-override check, widget pausing in `consumer.dart`) and Flutter 3.50's `IndexedStack`. The 2026-10-08 pure-Dart script against 2.6.1 and 3.4.3 measured the retry, `ProviderException` and `==` rows.
- **Benchmark:** `dart compile exe -Ddart.vm.product=true`, best of 5 runs, repeated three times, against 2.6.1 and 3.5.0.
- `pub get` and `flutter test` run outside the Bash sandbox (the proxy breaks Dart's TLS; the `flutter` CLI can't write its cache).

## Sources

- [Migrating from 2.0 to 3.0](https://riverpod.dev/docs/3.0_migration)
- [What's new in Riverpod 3.0](https://riverpod.dev/docs/whats_new)
- [flutter_riverpod changelog](https://pub.dev/packages/flutter_riverpod/changelog)
- [riverpod changelog](https://pub.dev/packages/riverpod/changelog)
