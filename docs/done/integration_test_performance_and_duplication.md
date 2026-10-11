# Integration Tests — Faster Waits

**Status:** DONE 2026-10-11 — branch `feat/search-pane-redesign`
**Goal:** take the fixed sleep out of the integration suite without changing
what any test checks.

## Why the waits were slow

In an integration test, `pumpAndSettle(step)` waits `step` of **real time**
before each frame, and goes round again while a frame is still scheduled
(`LiveTestWidgetsFlutterBinding.pump` starts a real `Timer(step)`). So
`pumpForSettle(tester, const Duration(seconds: 2))` costs at least 2 s even
when the screen is already idle. Most of these settles went round 2–4 times,
so opening a tab cost ~8 s. The default step is 100 ms.

A short step is only safe when something animates while the work runs:

- A spinner on screen keeps frames scheduled, so a 100 ms step keeps waiting
  until it goes. The reader shows one while it loads.
- A pending timer (a debounce) or a database read with nothing animating
  schedules no frame, so a 100 ms step returns before the work is done.

## What changed

1. `openTab` (`test_overrides.dart`) settles on the default step. 37 calls; each
   went from ~8 s to ~0.6 s.
2. The other 42 two-second waits use the default step (8 files).
3. One shared `pumpReaderApp` in `test_overrides.dart` replaces the copies in
   in_page_search, layout_switch, dictionary_editable_word,
   sutta_step_navigation and the 4 inline ones in scroll_restoration. The
   dictionary_editable_word and sutta_step copies had no settle after the tree
   loaded, so their 17 tests now get one short settle more (~0.1 s each).
   scroll_restoration never waited for the tree; now it does.
4. Shared helpers instead of inline copies: `search_tab_highlight` uses
   `waitForSearchResults` and `searchFor`; `language_independence` uses
   `openTab`.
5. `search_test_helper.dart` settles with `pumpForSettle` everywhere (15 s cap
   instead of 10 min); it had 15 bare `pumpAndSettle()` calls.
6. scroll_restoration's scrolls fail when the reader list or its controller is
   missing, instead of being skipped. Tests 2 and 4 used to pass anyway.

Left alone on purpose:

| Wait | Why |
|---|---|
| 1 s waits in dictionary_editable_word (9) and `settleUntilStill` | They cross the dictionary's 300 ms debounce; `settleUntilStill` uses a whole settle to see that scrolling stopped |
| 7 other 1 s waits (in_page_search 1, layout_switch 6) | They follow a jump, a match step, a layout change or a tab switch, not a timer, so the default step is probably fine. Not part of this change; each needs its own checked run. ~10 s to gain |
| Search polling (250 ms) | ~10 s to gain |
| Tree decoded again per test | 2–5 s (one decode measured 32–86 ms); not worth a cache shared across tests |

## Results

Test time per file, run alone on macOS (first test start → last test end, so
build and launch are excluded). Measured 2026-10-11.

| File | Tests | Before | After |
|---|---|---|---|
| breadcrumb_navigation | 8 | 75 s | 11 s |
| dictionary_editable_word | 4 | 67 s | 38 s |
| in_page_search | 8 | 119 s | 32 s |
| language_independence | 1 | 11 s | 3 s |
| layout_switch | 4 | ~115 s ¹ | 58 s |
| scroll_restoration | 4 | 55 s | 10 s |
| search_mode | 5 | 32 s | 23 s |
| search_tab_highlight | 1 | 23 s | 9 s |
| sutta_step_navigation | 13 | 141 s | 15 s |
| **Total** | 48 | **~638 s** | **199 s** |

About **7 minutes less per macOS run**. Chrome was not timed. The "After"
column is one full run of all 12 files after the review fixes. The three
search-only files passed too: search_flow_integration 96 s (138 s the run
before — mostly run-to-run variation), dictionary_filter_flow 13 s,
search_language_toggle 8 s. All 12 files: 316 s of test time, ~14 min wall
clock with a build and launch per file. Only failure: sutta_step "Previous 1"
(below).

¹ The first layout_switch baseline measured 398 s during a frame stall (below).
A re-run of the original code took 87 s with its first test failing early;
~115 s is that run with the first test at its normal length.

## Found along the way (not fixed here)

- **Frame stalls are the display, not the code.** When the display sleeps, the
  screen locks, or the test window is fully covered, macOS stops drawing it and
  a `pump` waits forever. `--timeout` doesn't stop it. Seen four times. One test
  sat frozen from display-off at 18:25 to display-on at 20:11, then finished.
  The test app never comes to the front ("Failed to foreground app"). Keep
  the screen awake (e.g. `caffeinate -d`) and the window uncovered while the
  suite runs.
- **`sutta_step_navigation` "Previous 1" fails on unchanged code.** The tab
  opens at offset 0, not at its landing row. That's
  `anchor-reader-at-landing-plan.md`.
- **The first test in a file can race the cold database**, with any step. The
  original layout_switch test 1 once failed (no reader list yet). Dictionary
  test 1 once failed because its 1 s wait went round only once before the
  results arrived. Both pass on re-run.

## Later

- `test_overrides.dart` now holds all shared test helpers (typing, tabs, the
  reader), so the name no longer fits. Rename it when no runs are in progress.
- Two helper styles remain: `tester.waitForSearchResults()` (extension) and
  `pumpForSettle(tester)` (function). Pick one.

## Overlapping tests (for information only)

Each pair pumps the app and loads the same text twice. Kept on purpose until
someone decides the overlap isn't worth it.

- `search_flow_integration_test` 1.1 / 1.2 and 2.1 / 2.2 — Singlish and
  Sinhala spellings of the same query, expecting the same counts.
- `sutta_step_navigation_test` previous 2 / 3 and next 1 / 2 — the first hop of
  "repeated navigation" repeats the single-step test; only the tooltip check is
  unique.
- `in_page_search_test` 1 / 3b — 3b asserts the match index after every tap,
  which is all test 1 checks.
- `scroll_restoration_test` "start with scroll position 0 for new tabs" —
  test 1 already asserts the second tab opens at 0.
