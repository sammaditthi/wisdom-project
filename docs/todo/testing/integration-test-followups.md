# Integration Test Follow-ups

**Status:** open, 2026-10-11
1–3 are left over from the faster-waits work
([`../../done/testing/integration_test_performance_and_duplication.md`](../../done/testing/integration_test_performance_and_duplication.md)),
4 from the anchor-reader plan, 5 from the reader toolbar auto-hide review
(2026-10-17). Each is independent.

## 1. Rename `test_overrides.dart`

It now holds every shared integration helper: the in-memory store,
`pumpForSettle`, `typeText`, `pumpReaderApp`, `tabFromNode`, `openTab` and the
reader lookups (`readerScrollView`, `readerScrollController`, `readerRow`,
`isEntryOnScreen`).
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

## 4. Reader anchor: the rest of its tests

Step 6 of [`anchor-reader-at-landing-plan.md`](../../done/reader/anchor-reader-at-landing-plan.md).
Already covered: side-by-side Cmd+A in each column and the stacked heading gap
(`reader_panes_test.dart`), next from an anchored tab's top
(`sutta_step_navigation_test.dart`), closing a tab left of the active one
(`scroll_restoration_test.dart`).

How, for all of them:

- Pin the window to 1280×800. Open a tab with
  `tabFromNode(...).copyWith(layout: …, anchorPageIndex: …, anchorEntryIndex: …)`
  and find rows with `readerRow(page, entry)`. `reader_panes_test.dart` is the
  model; its header names usable rows.
- Pass `physicalKey:` to every `sendKey*Event`, or it crashes in the web
  release build.
- Run each file alone on macOS (`caffeinate -d`), then
  `scripts/app/web/test_chrome.sh <file>`. Add new files to `all_tests.dart`.

### 4a. Landing in each layout

A search hit or a `?e=` link must open with its row at the top of the
viewport, in all four layouts. Today only Pali-only is checked, and only
loosely (`extentBefore > 0`).

- Open the tab as a hit does (`openTabFromSearchResultProvider`), on a
  mid-sutta row, once per layout. Expect the row's top at the viewport's top
  (within 1 px) and pages above it.
- Repeat with a row on the unit's last page: before the anchor, such a row
  could not reach the top.

Catches: a layout that stops rendering through `AnchoredPageList`, or loses
the split.

### 4b. Restore with an anchor: tab switch and restart

An anchored tab's offset is measured from its anchor, and is negative when the
reader scrolled up above it. Today's restore tests use unanchored tabs and
positive offsets only.

- Tab switch: anchored tab A, scroll up above the anchor, switch to B and
  back. Expect the same row at the top.
- Restart: seed the store with a saved tab (anchor plus a negative offset),
  pump the app on it, expect that row at the top. `pumpReaderApp` needs to
  accept a pre-filled store for this.

Catches: a restore that clamps at 0 again, or only retries downward.

### 4c. Side-by-side selection: the other checks

The rest of the plan's selection table, scripted with a mouse (recipe at the
end of the plan):

- A drag inside one column, across the anchor row, stays in that column.
- A drag that wanders into the other column stays in the first one.
- Double-click a word, then shift-click in the margin: the selection extends,
  same column.
- Double-click a Sinhala word, then Cmd+A: the Sinhala column's built rows.
- A drag held just below the viewport auto-scrolls, same column.

Catches: the column gate breaking on a Flutter upgrade. It leans on how the
scroll view's selection container sends events, so write these before the
3.47 upgrade.

### 4d. Taps, double-click and Cmd+A in every layout

Tap-to-clear moved to one raw `Listener` around the pane. No test taps the
page: `search_tab_highlight_test.dart` calls `clearForActiveTab()` directly.

- Tap-to-clear: with a search highlight set and the dictionary sheet open, one
  click on the text clears both; a drag clears neither. Each layout.
- Double-click a Sinhala word selects it (Sinhala-only, stacked,
  side-by-side). Pali can't be checked this way: its word tap opens the
  dictionary instead (known, same on `main`).
- Cmd+A selects the built rows in Pali-only, Sinhala-only and stacked.

Catches: a `GestureDetector` back inside a `SelectionArea`, where it takes
every click from the selection.

## 5. Reader toolbar: its menus, and what brings it back

From [`reader-toolbar-auto-hide.md`](../../done/reader/reader-toolbar-auto-hide.md).
Already covered: the hide/show rule on its own
(`toolbar_auto_hide_test.dart`), a wheel scroll hiding it and the reveal
threshold (`sutta_step_navigation_test.dart` test 8), Back closing the Share
menu (`search_mode_test.dart` step 14).

How, for both:

- One new file, `integration_test/reader_toolbar_test.dart`. Add it to
  `all_tests.dart`.
- Hide the toolbar with a mouse-wheel scroll down mid-sutta, as test 8's
  `_wheel` does. A controller `jumpTo` never hides it. Move `_wheel` into
  `test_overrides.dart` rather than copying it.
- Use `.hitTestable()` in every check: the toolbar never leaves the tree, so a
  plain finder passes whether it shows or not.
- Run it alone on macOS (`caffeinate -d`), then
  `scripts/app/web/test_chrome.sh <file>`.

### 5a. The toolbar's own actions

The old pill and FAB widget tests were deleted with them, and nothing
replaced them. The layout tests switch layout through the provider, not the
menu.

- Layout menu: open it (tooltip `Layout: …`), pick another layout. Expect the
  tab's layout to change, and on reopening, the check on the new one.
- Share → Copy link: expect the tab's link on the clipboard (mock
  `SystemChannels.platform`, as `pressSystemBack` does) and the "Link copied"
  SnackBar.
- Commentary: on a sutta that has one, the button's tooltip says Commentary;
  tapped, the commentary opens and the tooltip says Root text.

Catches: a menu row wired to the wrong action, or a lost check mark.

### 5b. What brings a hidden toolbar back

Each of these has its own listener in `multi_pane_reader_widget.dart`, and no
test starts with the toolbar hidden. If one goes, the toolbar stays hidden.

- Tab switch: hide it on tab A, switch to B, expect it shown. Back to A
  (still mid-sutta): shown.
- Find: hide it, open find (`inPageSearchStatesProvider.notifier.openSearch()`)
  and close it. Expect it shown, mid-sutta.
- Section: hide it, switch `selectedAppSectionProvider` to Home and back.
  Expect it shown.

Previous/Next needs no test here: it lands at the top, which shows the
toolbar anyway.

Catches: a removed or broken show listener.
