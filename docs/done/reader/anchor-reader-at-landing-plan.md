# Anchor the reader at its landing row — plan

Written against `0992a9c`, 2026-10-10. Done 2026-10-16 on
`feat/anchor-reader-at-landing` (from `main`), apart from some of step 6's
tests (see step 6).

## Problem

A search hit or a `?e=` link opens a tab that should land on its row. Before
`16cf0f6` the tab's list *started* at that row, so nothing above it was built.
Since then the tab renders the whole unit from its top and reaches the row by
scrolling, and that costs everything above it:

- A lazy list can't know where row N starts without laying out the rows
  before it. On a far jump, `RenderSliverList` builds and lays out every page
  in between, in one frame.
- Side-by-side builds every page up to the row on purpose (`_extendToReveal`).

What goes wrong:

1. **Lag.** In stacked and Pali/Sinhala-only since `5f4e5be`; before that the
   reveal gave up after 10 small steps, so far rows were never reached.
   Side-by-side has paid it since `2015bfc`.
2. **Side-by-side never lands.** In the frame the text arrives, the reveal
   jumps to the row, then the slice listener's restore runs `jumpTo(0)`.
3. **Landing lost on a slow load.** The reveal's 10 retries run out while the
   spinner shows. Not seen on macOS: the text is in within one frame.
   Possible on web.
4. **Side-by-side drift.** With 2 and 3 fixed it lands, then slides away:
   `_PairHeightSync` pads the Pali side one frame after the jump. Confirmed:
   with the padding off it lands exactly.

Fix (a) skipped the restore until the slice loaded. It fixed 2 and 3, not 4,
and was discarded uncommitted: the anchor doesn't need it, because offset 0 is
the landing row and the restore (step 5) waits for the rows it needs.

## Measured

Profile build, macOS, 1440×900 unless marked, `ReaderScreen`'s own tap
sequence (harness below). "Frame" is the longest frame's build time. Before is
`main`, after is this change, both 2026-10-16.

| Hit | Before: to hit · frame · lands? | After |
|---|---|---|
| `mn-1-1-1` end, stacked | 117 ms · 29 ms · 670 px down (unit's end) | 67 ms · 17 ms · yes |
| `dn-1-1` middle, stacked | 216 ms · 80 ms · yes | 60 ms · 22 ms · yes |
| `dn-1-1` end, stacked | 367 ms · 155 ms · 294 px down (unit's end) | 60 ms · 11 ms · yes |
| `atta-dn-1-2` middle, stacked, 400 px | 433 ms · 181 ms · yes | 62 ms · 19 ms · yes |
| `mn-1-1-1` end, side-by-side | 102 ms · 63 ms · 13,013 px off | 46 ms · 14 ms · yes |
| `dn-1-1` middle, side-by-side | 207 ms · 148 ms · 29,260 px off | 60 ms · 23 ms · yes |
| `dn-1-1` end, side-by-side | 381 ms · 316 ms · 61,233 px off | 46 ms · 11 ms · yes |
| `atta-dn-1-2` middle, side-by-side | 436 ms · 351 ms · 54,302 px off | 55 ms · 18 ms · yes |

- Scrolling up three screens from a hit peaks at 16–22 ms a frame, the same
  as scrolling down (20–23 ms): a page lays out as it comes into view either
  way.
- Long frames are about ⅔ text layout and ⅓ widget build. Loading the unit
  (query, inflate, parse) takes about 5 ms.
- Debug is only about 1.5× profile, because text layout is native code.
- Side-by-side's opening window of 60 entry pairs cost every side-by-side
  open a ~100 ms first frame: `dn-1-1` from its top took 130 ms · 101 ms with
  the window, 53 ms · 15 ms without it (spike, 2026-10-10).

### Side-by-side selection

Scripted mouse, `dn-1-1` opened at a mid-sutta hit.

| Check | Before | After |
|---|---|---|
| Drag in one column, across the landing row | stays in its column | same |
| Drag that wanders into the other column | stays in its column | same |
| Double-click a word, then shift-click in the margin | the shift-click clears it | extends it, same column |
| Click in the margin, then Cmd+A | nothing | that column |
| Double-click a Sinhala word, then Cmd+A | the Sinhala column | the Sinhala column's built rows |
| Drag past the bottom edge | no auto-scroll | auto-scrolls, same column |

Also checked after, every layout: the hit lands at 0 px; any tap clears the
search highlight and the dictionary; scroll-to-top drops the anchor.

Not checked: shift+arrow keys, touch and handles, web.

## Flutter facts this rests on

Found during the spike; each cost a failed attempt.

- `Scrollable` puts its own selection container (private, in screen order)
  between a `SelectionArea` and the rows. A delegate above it that reorders
  children never sees the cells, so keeping a selection in one column is a
  gate on each cell, not an ordering.
- That container gives drag auto-scroll, and it sends its children
  synthesized edge events. So the gate takes its column from the pointer-down,
  not from selection events, which would flip it.
- After select-all it expects its first and last child to hold a selection:
  an assert in debug, a null error in release.
- A `GestureDetector(onTap:)` inside a `SelectionArea` wins plain clicks, so
  the selection never gets focus: no double-click word, no Cmd+A. A raw
  `Listener` doesn't join the gesture arena.
- Above the anchor, `minScrollExtent` is an estimate until those pages are
  built, so one `jumpTo(minScrollExtent)` stops short of the top.

## The change

Scroll offset 0 sits on the landing row. Pages above it are built only when
the reader scrolls up. `CustomScrollView.center` does this: slivers before the
center grow upward. Anything that changes height above the anchor (padding,
late layout) grows upward too, so the screen doesn't move.

Files: `lib/presentation/models/reader_tab.dart`,
`lib/presentation/providers/tab_provider.dart`,
`lib/presentation/providers/tab_lifecycle_provider.dart`,
`lib/presentation/providers/document_provider.dart` (`activeAnchorProvider`),
and in `lib/presentation/widgets/reader/` the new `anchored_page_list.dart`,
`multi_pane_reader_widget.dart`, `stacked_pane.dart`,
`single_column_pane.dart` and `dual_column_pane.dart`.

1. **Tab.** `ReaderTab` keeps a persisted anchor (`anchorPageIndex`/
   `anchorEntryIndex`, read as `ReaderTab.anchor`) in place of the one-shot
   landing, and `scrollOffset` is measured from it (negative above it).
   `TabsNotifier.setTabAnchor` moves both in one update. Search hits and `?e=`
   links set it. Tree taps and next/prev leave it null, which means the unit's
   top. `ReaderTab` is Freezed and saved as JSON: the fields stay nullable
   (see its persistence warning).
2. **One lazy list** (`AnchoredPageList`), which all four layouts render
   through. The anchor page is split at the anchor row: its rows before the
   anchor, under the page number, go in the sliver above; the anchor row and
   the rest go in the center sliver. With no anchor, one outside the slice (a
   stale `?e=` link), one on the unit's first row or one past its last, the
   center sliver holds everything. One `SelectionArea` still wraps the whole
   view, so selection doesn't change.
   - A rule about a row's place on its page compares with the page's first
     row in the unit, not the first row of the part being built: stacked's
     gap above a heading.
3. **Side-by-side** (`DualColumnPane`) is a lazy pane like the others: one
   list of pair rows, `Row(Pali cell, gap, Sinhala cell)`, under one
   `SelectionArea`, so a drag crosses the landing row.
   - Each row lines up its own pair, so `_PairHeightSync` and `_AlignedEntry`
     (the drift), the 60-pair window and its growth, and `revealTarget` are
     gone.
   - The page-number pair is a row too. The divider overlay stays.
   - Each row watches the split ratio in its own `Consumer`, so a divider
     drag re-lays only the built rows.
   - The entry key is on the whole row.
   - `_ColumnGate` keeps a selection in one column. A raw
     `Listener.onPointerDown` records the column of the press (left or right
     of the divider's center); a shift-click keeps it, so it extends. Each
     cell is a `SelectionContainer` with the gate as its delegate, owned and
     disposed by the cell's state.
   - Select-all takes that column's built rows only, as stacked does. That
     branch leans on the select-all fact above; `reader_panes_test.dart`
     covers Cmd+A in each column.
4. **Taps, every layout.** Any tap on the page clears the search highlight and
   closes the dictionary, as browsers do with a link-to-text highlight.
   Selection gestures keep working.
   - Before: stacked and Pali/Sinhala-only put `GestureDetector(onTap:
     onTapEmpty)` inside their `SelectionArea`, where it won every click, so
     double-click and Cmd+A did nothing there. Side-by-side put it outside its
     areas, so only margin taps cleared.
   - Now: one raw `Listener` around the pane in `MultiPaneReaderWidget` calls
     `_clearAllHighlights` on pointer-up when the pointer stayed within the
     tap slop. It takes no click from the selection or a word. Up, not down:
     on a word tap the clear and the new word land in the same frame, so the
     dictionary sheet swaps its word instead of closing and reopening.
   - `_clearAllHighlights` has no `unfocus`: the selection gets the click and
     clears itself. Not yet checked on touch.
5. **Reader widget.**
   - The pane is keyed by the tab's index, and the controller starts each new
     scroll view at the active tab's saved offset (`_TabScrollController`),
     so a tab switch's first frame is already in place.
   - Restore clamps to `minScrollExtent`, and retries while the saved offset
     is past what's built, above the anchor or below it.
   - Mode 1/Mode 2 and the app-bar tint read `extentBefore`, not `pixels`.
   - "Scroll to beginning" and next/prev drop the anchor instead of scrolling
     (see the `minScrollExtent` fact above). `_anchorAt` jumps to 0 without
     measuring the old layout, then re-reads Mode 1/2 after the new one.
   - A reveal whose row isn't built re-anchors at it instead of stepping
     toward it: layout switch (the top visible row) and far in-page matches.
   - `_stepViewportToward`, `_revealTarget`/`_extendToReveal` and most retry
     code are gone.
   - Closing a tab before the active one moves the active index before
     removing the tab (`closeTabProvider`), so the reader's save on the index
     change lands on the active tab, not the one to its right.
6. **Tests.** Done: the existing integration tests, updated to the new
   behaviour; `reader_panes_test.dart` (stacked heading gap at the anchor,
   side-by-side Cmd+A in each column); next from the top of an anchored tab
   (`sutta_step_navigation_test.dart`); closing a tab left of the active one
   (`scroll_restoration_test.dart`, `tab_provider_test.dart`). The rest is §4
   of [`integration-test-followups.md`](../../todo/testing/integration-test-followups.md).
7. **Measure** before and after: see Measured.

Known edges, not fixed:

- Double-click on a Pali word selects nothing, in every layout: the word's
  dictionary tap takes the click. Same on `main`, so not from this change.
- Closing the active first tab leaves the index at 0, so the next tab draws
  one frame at the closed tab's offset before the restore corrects it. Same
  on `main`. A stable tab id as the pane's key would fix it.
- A layout switch while the search bar is open would land on the first match,
  not the top visible row: the recompute's reveal runs after the switch's
  anchor and re-anchors. Unreachable today, because the layout controls hide
  while the bar is open.

## How to measure and check

- Use `flutter drive --profile -d macos --driver=test_driver/integration_test.dart --target=<harness>`.
  `flutter test` has no profile mode. Run it outside the sandbox, and never
  run two macOS runs at once (they share a bundle id).
- In the harness:
  - Pass `semanticsEnabled: false` to `testWidgets`; the real app has no
    semantics tree unless an accessibility client asks for one.
  - Set `framePolicy = benchmarkLive` for the timed part.
  - Read frame build times with `addTimingsCallback`.
  - Read the hit's rect after the scroll settles.
- Timeline: use `traceAction(streams: ['Dart', 'Embedder', 'GC'])`. The
  default `all` floods the buffer with API events, and the frames you want
  are dropped.
- The macOS window must stay visible, or frames stop.
- Harness recipe (in `integration_test/`, helpers from `test_overrides.dart`):
  - Pump `ReaderScreen` in a `ProviderScope` with
    `BJTDocumentLocalDataSourceImpl` and an `InMemoryKeyValueStore` whose
    `StorageKeys.lastReaderLayout` is the layout. Await
    `navigationTreeProvider` and `readerUnitResolverProvider`.
  - Build a `SearchResult` with `SearchResultType.fullText`, the absolute
    `pageIndex`/`entryIndex`, the `nodeKey` and the unit's `contentFileId`.
  - Time `_ReaderScreenState._handleSearchResultTap`'s sequence:
    `openTabFromSearchResultProvider`, `ftsHighlightProvider.setForTab`,
    `saveRecentSearchAndDismiss`, `closeSearchProvider`. Landed means the
    text is in and the scroll has been still for 800 ms.
  - Find a row with `readerRow(page, entry)`: its registry key, a
    `GlobalKey` whose `toString()` ends with ` entry_<page>_<entry>]`.
- Selection checks, scripted mouse:
  - Click with `tester.tapAt(…, kind: PointerDeviceKind.mouse)`. A
    double-click is two clicks 60 ms apart. After a clearing click, wait
    600 ms, or the next click counts as a double.
  - Shift-click: `sendKeyDownEvent(shiftLeft)`, click, `sendKeyUpEvent`.
    Cmd+A: `metaLeft` down, `keyA`, `metaLeft` up.
  - Read the selection from `lastSelectedTextProvider`. Strip ZWJ (U+200D)
    and collapse whitespace before comparing.
  - Auto-scroll: hold the drag just below the viewport, moving 1 px every
    30 ms.
