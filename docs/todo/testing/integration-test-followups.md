# Integration Test Follow-ups

**Status:** open, 2026-10-11
Left over from the faster-waits work
([`../../done/testing/integration_test_performance_and_duplication.md`](../../done/testing/integration_test_performance_and_duplication.md)).
Each is small and independent.

## 1. Rename `test_overrides.dart`

It now holds every shared integration helper: the in-memory store,
`pumpForSettle`, `typeText`, `pumpReaderApp`, `tabFromNode` and `openTab`.
The name only fits the first one. Every integration file imports it, so rename
it in one go, and only when no test run is in progress.

## 2. Pick one helper style

Two styles are mixed:

- `search_test_helper.dart`: an extension on `WidgetTester`, e.g.
  `tester.searchFor(...)`, `tester.waitForSearchResults()`.
- `test_overrides.dart`: plain functions, e.g. `pumpForSettle(tester)`,
  `openTab(tester, container, tab)`.

Choose one and move the other over.

## 3. Seven 1-second waits that may not need it

`pumpForSettle(tester, const Duration(seconds: 1))` in:

- `in_page_search_test.dart`: 1, after wrapping to the last match
- `layout_switch_test.dart`: 6, after a `jumpTo` (2), a match step, a layout
  change (2) and a tab switch

None of them waits out a timer, so the default step is probably enough: the
reveal retries on later frames and the scroll animations keep frames coming.
About 10 s to gain.

Change one file at a time and run it alone on macOS with the screen awake
(`caffeinate -d`).

**Keep at 1 s:** the 9 in `dictionary_editable_word_test.dart` (they cross the
300 ms debounce) and the one inside `settleUntilStill` in layout_switch (it
needs a whole settle to see that scrolling stopped).
