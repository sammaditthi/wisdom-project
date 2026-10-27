# Search hits by sutta, and in-page search — plan

Started 2026-10-16, decided with the user the same day. Not started.

"Show more" for the Content tab is its own plan:
`search-results-show-more-plan.md`. It needs steps 1–3 here first.

## Problem

- Search fetches the best-scoring **rows** (Content tab: 50; Top results:
  21, which is 3 groups × 7), then groups them by sutta. A tile opens the
  earliest row *it fetched*. So the row a tile opens, and its "View N more"
  count, depend on how other suttas scored.
- Measured 2026-10-16, query කර්ම*: 8,003 matching rows in 2,912 suttas. The
  50 rows make 30 tiles; 27 of them hide matches (`vp-mv-9` shows 2 of 114).
  Sutta Nipāta වාසෙට්ඨ (`kn-snp-3-9`) has 9 matching rows, verses 599–658;
  only 654 and 655 were in the 50, so its tile opened 654.
- The footer, "Viewing 50 out of 8003 results", counts rows. The list shows
  suttas.
- In-page search lists a page's Pali matches, then its Sinhala ones, so in
  stacked and side-by-side ↓ jumps back up the page. It always starts at the
  unit's first match, wherever you are reading.

## Decided (2026-10-16)

1. **Rank suttas, not rows.** A sutta's rank is its best row's score, as
   today.
2. **A tile opens the sutta's first match**, in reading order, and its snippet
   is that row. Not the best-scoring row: for කර්ම the two differ in 69% of
   suttas, and "best" only means the word is densest in a short row (in
   `ap-kvu-15-11` it is a one-line question; the first match is the thesis).
3. **"View N more" lists every other match**, in reading order, with the true
   N.
4. **The Content tab shows the top 50 suttas**, and its footer counts suttas.
5. **Top results** works the same way, with 3 suttas, and keeps "See all".
6. **In-page search lists matches in reading order.**
7. **In-page search starts where you are reading**, as browser find does.
8. **Opening a search hit opens the in-page search bar** with the query, on
   the first match: "1 of N".

## How it works today

- `fts_local_datasource.dart` `searchFullText`: `ORDER BY score, id LIMIT ?
  OFFSET ?`.
- `text_search_repository_impl.dart`: `_searchFullText` turns each row into a
  `SearchResult` with its snippet; the Top results path overfetches ×7 and
  cuts with `_limitToGroups`; the Content tab asks for `query.limit` (50).
- `grouped_fts_match.dart` `fromSearchResults`: groups by `unitKey(resolver)`,
  sorts by position, first one is the tile.
- `search_results_panel.dart`: tiles, "See all", footer. The counts come
  from `countByResultType`, which counts rows.
- `in_page_search_provider.dart`: `_findAllMatches` scans each page Pali then
  Sinhala; `_setMatches` parks on match 0; the finder is hard-wired to exact
  phrase.
- `fts_highlight_provider.dart` + the FTS branch in `text_entry_widget.dart`:
  a second highlight for the hit's query, drawn with the hit's match options.
  In-page search hides it entry by entry.
- `reader_screen.dart` `_handleSearchResultTap`: opens the tab, then sets the
  FTS highlight.

## Steps

### 1. Fetch every hit, rank suttas (data)

- One query for every hit's `filename, eind, language, nodeKey, score`: no
  LIMIT, no text. Measured 2026-10-16 on macOS: 55–100 ms for 8k–42k rows
  (කර්ම*, ධම්ම*, භික්ඛ*). Measure on web (wasm) before building on it.
- Group in Dart by `unitKey(resolver)`, never `GROUP BY nodeKey` in SQL: the
  stored `nodeKey` names the wrong sutta for some rows (see
  `openTabFromSearchResultProvider`).
  - One path already breaks that rule: "Anywhere in the same text"
    (`FtsSameTextSql`) intersects at `GROUP BY nodeKey, language`, so inside a
    corrected leaf it can span the wrong boundary, and the badge can count two
    units the tiles then show as one. Measured 2026-10-27: 1,297 of 456,977
    `bjt_meta` rows sit in a shifted interval, across all 88
    `correctedTreeCoordinates` leaves. This step removes that grouping.
- Per sutta: rows sorted by (page, entry), best score, count. Sort suttas by
  best score; ties by the best row's `id`, as `ORDER BY score, id` does now.
- Extend `GroupedFTSMatch` (first row = the tile, the rest = "more") rather
  than add a parallel type.
- Scope, language and edition filters as today. Cache the ranked list per
  query in the existing `caching_text_search_repository.dart`: both tabs and
  "show more" read it.

### 2. Snippets only for what is shown

- Load snippet text for the shown tiles' rows in one batch, as
  `loadPageSides` does today.
- "View N more" loads its rows' text when expanded (`vp-mv-9` has 113).

### 3. Counts and footer

- `countByResultType[fullText]` is the number of suttas, taken from step 1's
  list; the separate COUNT query goes.
- Footer: "Viewing 50 out of 2,912 suttas". New en/si strings; take the
  Sinhala word from tipitaka.lk as usual.
- "See all" on Top results compares sutta counts.

### 4. Top results

- The first 3 suttas of the same list. Drop the ×7 overfetch and
  `_limitToGroups`.

### 5. Tiles

- The tile opens the first row (it becomes the tab's anchor, as now). The
  "more" rows open themselves, as now.
- Fix the tile doc comments: today they say "first match", but the code only
  picks the first of the fetched rows.

### 6. In-page search: reading order

- After collecting, sort by page, entry, Pali before Sinhala, then position in
  the entry. Pali-only and Sinhala-only don't change.

### 7. In-page search: start where you are

- The start row is the row at the top of the reader when the bar opens. Keep
  it until the bar closes: re-reading the screen on each keystroke would
  drift, because each match moves the view.
- The current match is the first one at or after the start row; if none,
  wrap to the first.
- The provider can't see the screen, and Cmd+F (`shortcut_actions.dart:59`)
  opens the bar without the reader. So the reader publishes its top row for
  the active tab (when the debounced scroll save runs) and `openSearch` reads
  it. No caller passes a row.
- A layout switch never recomputes with the bar open: the layout buttons hide
  while it shows. With the bar closed it only drops the matches, and
  reopening the bar takes the start row as above.

### 8. Opening a hit opens the in-page search

- `_handleSearchResultTap` opens the new tab's in-page search with the hit's
  query and match options, start row = the hit's row. Your example would
  read "1 of 21": 21 highlights in 11 rows (measured 2026-10-16), while the
  tile said 9 matches. The bar counts each highlight, the tile counts rows.
- In-page search takes the hit's match options (phrase, exact, proximity,
  anywhere). Hard-wired to exact phrase, a proximity hit would read "0 of 0".
  `SearchMatchFinder` already handles every mode.
- The FTS highlight then draws the same thing twice: retire
  `ftsHighlightProvider` and the FTS branch in `TextEntryWidget`, so there is
  one highlight system.
- Highlighting finds the word anywhere in a word; FTS finds word starts. A
  row above the hit can hold the word inside a longer word, and the bar then
  reads e.g. "3 of N". It is true, so it is accepted.
- The anchor puts the hit's row at the top, under the floating bar. The
  match reveal (alignment 0.3) moves it down to where it can be seen; check
  this.

## Decisions for the user

- **D1. Tapping the page.** Since the anchor-reader change any tap clears the
  search highlight. After step 8 that highlight is the in-page search.
  Browser find bars stay open when you click the page. Recommended: a tap no
  longer clears search highlights (× and Esc do), and it still closes the
  dictionary.
- **D2. A layout that hides the hit's language.** New tabs take the last
  layout. If that is Pali-only and the hit is in the Sinhala, the bar reads
  "0 of 0" and the row shows no match. Recommended: open that one tab in the
  orientation default (stacked or side-by-side), and leave the remembered
  layout alone.

## Tests

Written by the test-writer agent, not here. They need: tile opens the first
match; true counts; Top results = first 3 of the same ranking; in-page
reading order in stacked and side-by-side; start row and wrap; "1 of N" after
opening a hit; a proximity hit reads more than 0.

## Handover

Not started.
