# App reader backlog

Open work on the app's reading surface. Opened 2026-09-11, when
`reading-units-and-grouping.md` moved to `docs/decisions/` — the reader rework it
planned (Part 4, B1–B6) is done, and this is where the leftovers live so the rule
doc can be a rule doc.

**Scope: the app.** The apex static site has its own list,
`docs/todo/web-strategy/static-site-backlog.md`. The rule both surfaces follow is
[`../../decisions/reading-units-and-grouping.md`](../../decisions/reading-units-and-grouping.md).

---

## R1. The tab label and breadcrumb do not follow the scroll

Scrolling from Mūlapariyāya into Sabbāsava leaves the app claiming you are still
in Mūlapariyāya. The label is set when the tab opens and never revisited.

**Much smaller than it was.** It was hard while a tab ran to the end of a content
file; now a unit is bounded and `SliceIndex.keyAt` already answers *which node
owns this row* — the same lookup search landing uses. **Nothing calls it for
this yet**, and that is the whole of the work: watch the top-visible row, ask
`keyAt`, update the label and the breadcrumb when the answer changes.

Two things to decide when someone picks it up:

- **A container unit renders many leaves.** Does the label track the leaf under
  the reader, or stay on the node that was tapped? Tracking is what the user
  sees; staying is what they asked for. The breadcrumb probably wants to track
  even if the tab label does not.
- **How often to ask.** Per scroll frame is wasteful and per settle is laggy;
  the answer only changes at a row boundary, so it should key off the
  top-visible index changing, not off scroll offset.

## R2. Review the Sinhala labels in the search match menu

The "Starts with ▾" menu (search pane redesign, Task 8, 2026-10-07) shipped with
first-draft Sinhala. Review the titles in `app_si.arb`: `matchOptions`,
`matchEachWord`, `matchStartsWith`, `matchWholeWord`, `matchHowWordsSit`,
`matchPhrase`, `matchPhraseShort`, `matchAnywhereShort`, `matchNear`,
`matchNearShort`, `matchNearWithin`, `fewerWords`, `moreWords`,
`resetToDefault`.

Phones show no tooltips, so each title must make sense alone. The least clear
is ඇරඹෙන වචන ("Starts with").

## R3. Find-in-page can leave its match off screen

Read a few screens into a sutta, then search a word whose first hit is near
the top. The bar says "1 / N" and the tab is anchored at the hit's row, but the
view settles below that row and never draws it.

Measured 2026-10-28 on macOS, dn-1-1, "එවං": the first hit is row (0,6). Two
screens down, searching again leaves the anchor at (0,6) and the offset at 328,
with the row off screen. The code before the reveal-count fix does exactly the
same, so this is older than that fix.

Where: the far-row branch of `_revealEntry` (`multi_pane_reader_widget.dart`),
which anchors at the row and settles it with `ensureVisible` after the frame.
A lead, not proven: test 3c also returns to a hit near the top and passes, but
there the tab already had an anchor further down. Here it has none, so the jump
to offset 0 lands on the sutta's top, where the row is already built in the old
layout.

Test 3f in `integration_test/in_page_search_test.dart` reproduces it and is
skipped until this is fixed. Unskip it as part of the fix.
