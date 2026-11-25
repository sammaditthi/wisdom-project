# Riverpod 3 upgrade

Investigated 2026-10-08 on 3.4.3. Done 2026-11-25 on `chore/riverpod-3`, on 3.5.0 (the latest; no 3.6 or 4.0 out).

## Decision

`flutter_riverpod` 2.6.1 → 3.5.0 as a plain version bump, with Riverpod's automatic retry turned off. No refactor rode along.

## What came after

| Follow-up | Where it went |
| --- | --- |
| Tabs in one notifier, keyed by a stable id; settings save themselves; tab actions as notifier methods | [`tab-ids-and-drag-to-reorder.md`](../../todo/reader/tab-ids-and-drag-to-reorder.md): the way to drag tabs safely |
| Theme and font size load like other settings | [`pinch-to-zoom.md`](../../todo/reader/pinch-to-zoom.md), Phase 1 |
| `riverpod_lint`, code generation | Not planned ([below](#riverpod_lint-and-code-generation)) |
| Rules for new code the upgrade taught | `CLAUDE.md`, *Riverpod* |

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

**1. Automatic retry: turned off.** A provider that throws an `Exception` is retried up to 10 times, waiting 200 ms and doubling up to 6.4 s, about 38 s in total. Dart `Error`s and other providers' failures are not retried. 8 of the 11 `FutureProvider`s turn a `Failure` into `throw Exception(failure.userMessage)`, which is exactly what gets retried.

While it retries, the provider is "loading" but carries the error, and `.when()` shows that error at once (its `skipLoadingOnRefresh` is on by default). So the screen would not have shown a spinner. Leaving retry on would instead have re-run a failed DB query or JSON parse up to 10 more times, and left `await ref.read(sitePlanProvider.future)` (deep links) and `readerUnitResolverProvider.future` (tabs) waiting the whole 38 s. Our data is all local, so a failed load fails again.

The fix is `noProviderRetry` (`lib/presentation/providers/provider_retry.dart`), passed as `retry:` to the root `ProviderScope` in `main.dart`, to `pumpApp` / `pumpAppWithScaffold` / `createTestContainer`, to every integration-test scope, and to the two tests that build their own scope around a failing provider (`status_message_view_panels_test.dart`, `dictionary_bottom_sheet_test.dart`). Riverpod's default can't be changed globally: `ProviderContainer.defaultRetry` is a static method.

A provider can opt back in with its own `retry:`, which wins over the scope's (`origin.retry ?? container.retry` in `element.dart`). Nothing today fetches over the network through a provider: Research's question goes through `ResearchChatNotifier`. The notes sync with Google Sheets ([`study-space-design.md`](../../todo/notes/study-space-design.md)) may be the first, so decide there.

**2. Overriding one provider twice now throws** (`Tried to override a provider twice within the same container`). Hit by `tab_provider_test.dart` and `general_settings_page_test.dart`, which passed their own store on top of `createTestContainer`'s. `createTestContainer` and `defaultTestOverrides` now take `keyValueStore:` instead.

**3. A listener of a derived provider must not write state that feeds back** ([riverpod#4808](https://github.com/rrousselGit/riverpod/issues/4808), open, not fixed in 3.5.0). Such a listener runs inside Riverpod's refresh pass. If its write dirties a provider that already rebuilt in that pass, Riverpod 3 throws `Tried to rebuild … multiple times in the same frame` (debug only), and the throw skips the scheduler's cleanup, so no provider refreshes again for the rest of the session. Release builds don't check, so they don't throw. Found by the integration suite, not the plan: `MultiPaneReaderWidget` listened to `activeInPageSearchStateProvider` and `activeReaderLayoutProvider`, and both callbacks anchor the tab (`setTabAnchor`), which rebuilt `activeTabProvider` twice. `in_page_search_test` 3b (Previous wrapping to the last match) and every `layout_switch_test` test failed, and the next test hung. Fixed by listening to `inPageSearchStatesProvider` and `tabsProvider` instead: a `StateNotifier` notifies inside the action itself, before any pass. A `Future.microtask` would also avoid the throw (what others on #4808 did), but when the pass runs inside a frame, that frame paints the new layout at the old position. The catch: a notifier's listener runs part-way through an action. `closeTabProvider` re-indexes the search map before it moves the active index, so closing the active tab looked like "the next tab got a new match" and anchored that tab at it. The reader now treats any tab opening or closing as a tab switch until the next frame (`in_page_search_test` 6b; found in review). The other listeners that write (overlay stack, last selection, app-bar tint) write providers nothing derived watches.

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
- **Simpler tests.** `ProviderContainer.test()` disposes itself; `tester.container()` replaces `ProviderScope.containerOf(...)` lookups. New tests use them; old ones aren't swept.
- **`ref.mounted`**, a safe check after an `await` inside a notifier.

## Considered, not worth it

Assessed 2026-11-25, after the upgrade. None of these fixes a bug users see, and the legacy providers carry no deprecation in 3.5.0.

- **Converting every `StateNotifier` to `Notifier`** (15 classes, the "legacy" exit). Not deprecated. `FakeSearchStateNotifier` serves 9 test files and `search_state_notifier_test.dart` builds its notifier directly, so `SearchStateNotifier` alone means a test rewrite. New notifiers are `Notifier`s; an old one converts only when it is being rewritten anyway (the tab-ids plan rewrites seven).
- **The 16 simple `StateProvider`s as `Notifier`s.** A class per value, and the legacy import is fine.
- **`ProviderContainer.test()` and `tester.container()` in tests.** Tests dispose containers by hand about 55 times and call `ProviderScope.containerOf` 19 times. No sweep; new tests should use them.
- **`switch` on `AsyncValue` instead of `.when`** (it is sealed in 3.x). Only 8 `.when` calls, and `.when` also covers the refresh and reload cases (`skipLoadingOnRefresh`) that a plain `switch` would have to spell out; that rule is why a retrying provider still showed its error.
- **Pausing hidden sections** (wrapping `app_shell.dart`'s `IndexedStack` children in `TickerMode`, which Riverpod 3 pauses on). Home's minute clock and hidden screens would stop rebuilding, but their listeners would not run while hidden: the reader's tab-switch listener, which saves the old tab's scroll offset before the switch, would run late for a tab opened from Home by a deep link.
- **Throwing the `Failure` instead of `Exception(failure.userMessage)`** (8 places). Not a Riverpod question now that retry is off; the panels already pick their copy by context. It belongs to [the error-handling standard](../refactor/generic-server-call-and-error-handling-standard.md) if ever.
- **Offline persistence and mutations.** Experimental in 3.x, and the app has its own `KeyValueStore` persistence.
- **`ref.mounted`.** Nothing needs it: every notifier that holds a `Ref` lives as long as the app.

## `riverpod_lint` and code generation

Tried 2026-11-25 (`plugins: riverpod_lint: ^3.2.0` in `analysis_options.yaml`, then reverted). One finding, a false positive: `missing_provider_scope` on the `runApp(_DatabaseMissingError(...))` error screen, which uses no providers. A warm `dart analyze` went from 4 s to 24 s, and a fresh machine must download the plugin first. Most of its lints are for `Notifier` classes or the generator, so revisit once the tab-ids plan has added some.

Code generation (`riverpod_generator` 4.0.10 resolves on the current lock): probably not worth it. It would turn every provider into an annotated function or class.

## Handover notes

**2026-11-25.** Branch `chore/riverpod-3`: the upgrade, the reader listener fix (runtime change 3), its review follow-up, and this doc. 22 test files changed, all forced by the upgrade: imports (`legacy.dart`, `Override`), `valueOrNull`, `retry: noProviderRetry`, and `keyValueStore:` replacing a second store override. One new test, at the user's request: `in_page_search_test` 6b (closing the active tab keeps the next tab's reading position), checked to fail without the follow-up. `in_page_search_test` 3b and `layout_switch_test` already fail without the listener fix itself. Full gate (`scripts/app/test.sh`), 2026-11-25: 9 of 9 steps passed (897 unit + widget tests, 96 macOS integration tests in one launch, all 13 files in Chrome). After the follow-up, on macOS: `in_page_search_test` and `layout_switch_test` pass in full.

Checked by hand 2026-11-25, all as before, since no harness covers it: open and close tabs, restart, and check the active tab and the navigator's open/closed state come back; the dictionary sheet; a deep link; Research.

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
