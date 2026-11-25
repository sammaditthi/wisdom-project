# Top Performance Killers — Audit & Backlog

> **Status:** Backlog (perf TODO worklist — pick items from here to plan/implement)
> **Source:** Full-project performance code review (static, traced through `lib/`),
> plus an interaction-jank investigation addendum (2026-06-05).
> **Related:**
> - `docs/done/performance/perf-fts-snippet-text-loading.md` — full plan for **#2** (per-hit JSON reload).
> - `docs/todo/performance/perf-search_label_and_tree_lookup_followups.md` — the old item **#4**
>   (`_buildNodeMap` rebuilt per search) now lives there as its item 2.

All findings are based on actual code paths. Each item lists where it lives, how it
hurts, the fix, the expected gain, effort, and blast-radius on existing flows.

---

## Summary

| # | Issue | Effort | Impact to flows |
|---|---|---|---|
| 1 | Tree navigator full re-render on every expand / select / language change | Medium | Low |
| 2 | — *moved to `docs/done/performance/perf-fts-snippet-text-loading.md` (own plan, shipped)* | — | — |
| 3 | All JSON parsing runs on the UI isolate (tree.json; every sutta page) | Medium | None |
| 4 | — *moved to `perf-search_label_and_tree_lookup_followups.md` (item 2)* | — | — |
| 5 | Search widgets watch the entire `searchStateProvider` | Low–Medium | None |
| 6 | ✅ *Done 2026-11-25 — `Entry.plainText` cached* | — | — |
| 7 | `formatContentLabel` (Pali letters) re-runs on every rebuild for every label | Low | None |
| 8 | Per-word `TapGestureRecognizer` allocation in `TextEntryWidget` | High | Medium |
| 9 | Unbounded document cache in `BJTDocumentRepositoryImpl` | Low | None |
| 10 | `SingleChildScrollView` for "Top Results" + no `RepaintBoundary` in lazy lists | Low | None |
| A1 (interaction) | Font scale routed through the **global** `ThemeData` | Low–Medium | Medium |

Bonus findings (B1–B2) and the interaction-jank addendum (A1) follow the main list.

---

## Top 10 performance killers

### 1. Tree navigator full re-render on every expand / select / language change

**Where:** `TreeNodeWidget.build` (`lib/presentation/widgets/navigation/tree_navigator_widget.dart:149-152`)
calls `ref.watch(expandedNodesProvider)`, `ref.watch(selectedNodeProvider)`,
`ref.watch(effectiveContentLanguageProvider)`, `ref.watch(paliLetterOptionsProvider)`
and recursively renders all `childNodes`.
Tipitaka has thousands of nodes.

- **How it affects performance:** Each expand/select tap mutates the Set → every
  `TreeNodeWidget` in the tree rebuilds and recomputes `formatContentLabel` (see #7).
  On a deep tree this can be 10–50 ms+ jank per chevron tap on mid-range Android, and
  tap latency feels mushy.
- **How to prevent:** Replace whole-set watches with select-based scoped watches:
  `ref.watch(expandedNodesProvider.select((s) => s.contains(node.nodeKey)))` and the
  same for selected. Cache the label per node (see #7).
  Also wrap each row in a `KeyedSubtree` + `RepaintBoundary`.
- **Gain:** 5–20× faster expand/collapse; sub-frame chevron taps; visibly smoother
  navigator scroll.
- **Effort:** Medium
- **Impact to existing flows:** Low — pure rebuild-locality fix; no public API change.

### 2. — Moved out of this list

This was `TextSearchRepositoryImpl._loadTextForMatch` re-reading & re-parsing the whole
sutta JSON for every FTS hit. It now has a dedicated implementation plan in
`docs/done/performance/perf-fts-snippet-text-loading.md`, which covers both the native/client fix
(group-by-file + parse-once + LRU + optional isolate) and the remote/web server path.
Tracked there to keep the detailed plan in one place.

### 3. All JSON parsing happens on the UI isolate

**Where:** `tree.json` (several MB) is parsed via `rootBundle.loadString` + `json.decode` in
`TreeLocalDataSourceImpl._decodeSharedTree`
(`lib/data/datasources/tree_local_datasource.dart:102-103`). Every sutta page is a zlib
blob in `bjt.db`, inflated + `json.decode`d the same way in
`BJTContentLocalDataSourceImpl._decode` (`lib/data/datasources/bjt_content_local_datasource.dart:135`).

- **How it affects performance:** Cold-start parse of `tree.json` blocks the first frame
  for 100–400 ms on mid-range Android / older iPhones. Each sutta open re-blocks the UI
  thread proportional to file size.
- **How to prevent:** Wrap `json.decode` + the subsequent entity parsing in `compute()`, not
  `Isolate.run`: that throws on web, which has no isolates, while `compute` runs inline there.
  So this only helps native. For `tree.json` specifically, pre-parse to a binary
  format (e.g. msgpack, or just a flatter Dart-friendly JSON shape — the current schema
  needs a second pass through `_buildTreeStructure`).
- **Gain:** First frame appears 100–400 ms sooner; sutta opens become jank-free.
- **Effort:** Medium
- **Impact to existing flows:** None — same data, just moved off the UI isolate.

### 4. — Moved out of this list

This was `TextSearchRepositoryImpl._buildNodeMap` being rebuilt on every search call.
It is the **same issue** as item 2 (🔴) in
`docs/todo/performance/perf-search_label_and_tree_lookup_followups.md`, which now carries the full fix:
reuse the data layer's **existing** cached index via `NavigationTreeRepository.getNodeByKey`
instead of rebuilding `_buildNodeMap`. Tracked there to avoid two sources of truth.

### 5. Search panel & in-page search widgets watch the entire `searchStateProvider`

**Where:** `SearchResultsPanel` (`lib/presentation/widgets/search/search_results_panel.dart`)
does `ref.watch(searchStateProvider)`. `GroupedFTSTile` and the panel header (`_PanelHeader`)
already watch only what they show (`select`), but gain little: the panel rebuilds them anyway.
The header can't be `const` (it takes `onClose`), so on the Definitions tab its
`DictionaryFilterChips` rebuild on every keystroke too (four buttons: cheap). `ScopeFilterChips`
is `const` and selects its own fields, so it escapes.

- **How it affects performance:** `SearchState` changes on every keystroke, and also when
  counts arrive, a group expands, or recent searches load on focus. Each change rebuilds
  the tab bar and every visible tile, and each tile redoes its snippet highlight (see B2).
  While typing, a spinner replaces the tiles, so typing itself costs less than it looks.
  The list is at most 50 rows and builds only the rows on screen: small today.
- **How to prevent:** Turn `_buildTopResultsTabContent` and `_buildResultTypeTabContent`
  into small widgets that each `select` only what they render. That also replaces their
  ~10 parameters copied out of `searchState`. The header then stops rebuilding too.
- **Gain:** Fewer rebuilds of the tiles and their highlight work.
- **Effort:** Low–Medium
- **Impact to existing flows:** None — same data, finer-grained subscriptions.

### 6. ✅ Done (2026-11-25) — `Entry.plainText` cached

Cached in an `Expando<String>`, the same way `markedRanges` is
(`lib/domain/entities/content/entry.dart`). The reader's `buildEntry` and in-page
search's scan (once per debounced query) now strip markers once per entry instead of every time.

### 7. `formatContentLabel` re-runs on every rebuild for every label

**Where:** `formatContentLabel` (`lib/presentation/utils/content_text_formatter.dart`) calls
`beautifyPaliText` (`packages/wisdom_shared/lib/src/text/pali_conjuncts.dart:183`), a chain of
`replaceAll` / `replaceAllMapped` passes per call. Used by `TreeNodeWidget`, the tab bar,
breadcrumbs, search result labels, etc., none of which cache the result.

- **How it affects performance:** Tree node display names get re-transformed on every node
  rebuild (compounding with #1). Search result titles re-transform on every keystroke
  (compounding with #5). The cost grows linearly with the number of items the user sees.
- **How to prevent:** Memoize the Pali branch of `formatContentLabel`, keyed by `(raw, options)`
  — the three Pali-letter switches change the output, so the key must include them
  (`PaliLetterOptions` has value equality). The existing `LRUCache` lives in `lib/data/cache/`,
  which presentation must not import: move it to `lib/core/` first.
- **Gain:** Removes the dominant per-frame string work in 3 different screens.
- **Effort:** Low
- **Impact to existing flows:** None — pure caching.

### 8. Per-word `TapGestureRecognizer` allocation in `TextEntryWidget`

**Where:** `lib/presentation/widgets/reader/text_entry_widget.dart:193-234` — one recognizer
per word, disposed + recreated whenever text changes.

- **How it affects performance:** The reader can render dozens of entries × dozens of words.
  Cold-loading a Dīgha Nikāya sutta builds 1000s of recognizers. Each is an Object + listener
  list + Flutter gesture-arena registration — both allocation pressure and gesture-routing
  overhead per tap.
- **How to prevent:** (a) Use a single `TapGestureRecognizer` at the entry level and resolve
  the tapped word from the tap position (`RenderParagraph`'s `getPositionForOffset`).
  (b) Only attach recognizers when `enableTap && onWordTap != null` — already true, but
  additionally short-circuit for Sinhala entries upstream.
- **Gain:** Big memory drop on suttas; faster `ListView` item-build; smoother scroll.
- **Effort:** High
- **Impact to existing flows:** Medium — touches the dictionary-tap UX; needs a careful
  regression pass.

### 9. Unbounded document cache in `BJTDocumentRepositoryImpl`

**Where:** `lib/data/repositories/bjt_document_repository_impl.dart:13, 38` —
`Map<String, BJTDocument>` never evicts. Documents are large (deeply nested
`BJTDocument → BJTPage → BJTSection → Entry`).

- **How it affects performance:** Over a long session the user can browse hundreds of suttas;
  every parsed document stays resident even after the tab/provider is disposed. This pairs
  poorly with the provider-layer `autoDispose` + `keepAlive` because the repo cache outlives
  the provider. Memory monotonically grows → background OOM kills on mobile.
- **Check the growth from #6:** each cached `Entry` now also keeps its `plainText` alive (an
  `Expando`, like `markedRanges`), so every resident document holds its text about twice.
  Measure memory over a long session (DevTools → Memory) before and after this fix. Evicting
  a document frees its cached strings too, so this fix covers both.
- **How to prevent:** Replace `_cache` with the existing `LRUCache` (config e.g. 20 documents).
  Or drop the repo cache entirely and rely on the Riverpod `keepAlive`.
- **Gain:** Stable long-session memory; prevents Android background kills; faster GC pauses.
- **Effort:** Low
- **Impact to existing flows:** None — caller-transparent.

### 10. `SingleChildScrollView` for the "Top Results" tab + no `RepaintBoundary` in lazy lists

**Where:** `SearchResultsPanel._buildTopResultsTabContent`
(`lib/presentation/widgets/search/search_results_panel.dart:172`) wraps a `Column` of every
group inside a `SingleChildScrollView`. The reader's `AnchoredPageList` uses lazy
`ListView` builders (good) but doesn't wrap items in `RepaintBoundary`.

- **How it affects performance:** Top Results panel builds + lays out every group up front
  (defeats lazy rendering for big result sets). In the reader, any state change (FTS
  highlight, in-page match index) repaints every visible page rather than just the affected
  one — observable as paint-time spikes on sutta-heavy suttas.
- **How to prevent:** (a) Use `ListView.builder` (or slivers) for Top Results content.
  (b) Wrap each list item in `RepaintBoundary` in `anchored_page_list.dart` and the
  search list builders. (c) Also wrap individual `TextEntryWidget`s
  when they sit inside large rebuilding trees.
- **Gain:** Smoother scroll under highlight/animation; predictable frame times on long results.
- **Effort:** Low
- **Impact to existing flows:** None — Flutter idioms.

---

## Bonus findings

### B1. First-launch DB copy reads the entire DB into memory

`dict.db` and `bjt.db` (each well over 100 MB) are copied by loading the whole asset with
`rootBundle.load` (`lib/data/database/local_database_executor_native.dart:61`) and
writing it out.

- **Why it matters:** A transient allocation the size of the DB on first install of a mobile device.
  Risk of OOM on low-RAM phones.
- **Fix:** The write is already chunked (8 MB pieces); the peak is `rootBundle.load` holding the
  whole asset. Copy directly from the asset bundle's file instead (`AssetManager` / a native plugin).

### B2. `HighlightedFtsSearchText` re-creates `SearchMatchFinder` + normalizes text on every build

`lib/presentation/widgets/search/highlighted_fts_search_text.dart:72`.

- **Why it matters:** One result tile typically rebuilds 3–5× per panel update. The finder +
  position-map build is O(text length).
- **Fix:** Cache by `(matchedText, effectiveQuery, isPhraseSearch, isExactMatch)` inside the
  widget; or hoist computation into a Provider keyed on the result ID.

---

## Why these are the priorities

In rough order of perceived user impact:

1. **#3** — removes the worst UI-thread stall left on native (#2 shipped; old #4 moved to
   `perf-search_label_and_tree_lookup_followups.md`, item 2).
2. **#1 + #5** make the two most-touched UIs (tree navigator and search panel) feel
   responsive instead of mushy.
3. **#7** is a tiny, low-risk caching win that compounds across every screen.
4. **#8 + #9** are foundations for a long session without memory growth or scroll jitter.
5. **#10** restores the lazy-render and paint-locality contracts that Flutter expects.

**Quick wins to land first:** #7, #9 — mechanical, measurable, and don't touch the UI tree.

---

## Addendum (2026-06-05) — Interaction-jank investigation

The audit above is a static review optimised for cold-start / UI-thread stalls. A follow-up
investigation into reported **interaction** jank (font-size changes and divider dragging
janking "like crazy", worst on low-/mid-end web) surfaced one finding that outranks
everything above for that class of symptom but was **not** in the original list. Ranked #1
for perceived interaction smoothness on the reader.

### A1 (interaction). Font scale is routed through the global `ThemeData`

**Where:** `fontScaleProvider → currentThemeDataProvider`
(`lib/core/theme/theme_notifier.dart:128-135`) rebuilds a brand-new `ThemeData` on any scale
change, and `MaterialApp.theme` watches it (`lib/main.dart:265`). The font-size slider
(`lib/presentation/widgets/reader/reader_settings_menu_button.dart:144`) calls `setScale` on every drag
tick (no `onChangeEnd` / no debounce — only the step-rounding dedupes equal values).

- **How it affects performance:** Each effective font-scale step swaps `MaterialApp.theme`,
  so **every** widget in the tree re-inherits `Theme.of(context)` and re-lays-out its text.
  Font size travels through the single most global object in the app. On CanvasKit web every
  visible Sinhala glyph re-rasterises into the glyph atlas. Net: dragging the font slider triggers an app-wide relayout per step →
  visible jank, worst on low-/mid web. This is fixable rebuild waste, **not** a CanvasKit floor.
- **How to prevent:** Stop sending font scale through global `ThemeData`. Keep `ThemeData`
  font-scale-independent and have reader text widgets read `fontScaleProvider` at the leaf
  (scoped select-watch) so a scale change repaints only the text, not the whole app. Add
  `onChangeEnd` / debounce to the slider (or apply on release) so mid-drag ticks don't each
  trigger an app-wide relayout. (The both-mode lazy builder is won't-do —
  `docs/done/reader/both_mode_lazy_builder.md`: the reading unit is now one bounded sutta,
  so the reader's share of the relayout is small; what's left is the app-wide theme swap.)
- **Gain:** Eliminates the dominant interaction-jank source — the font slider goes from
  whole-app relayout per step to text-only repaint. Largest single perceived-smoothness win
  for the reading screen; directly resolves the reported "font size janks like crazy" symptom.
- **Effort:** Low–Medium
- **Impact to existing flows:** Medium — changes how text sizing is applied app-wide. Needs a
  pass to confirm every surface that currently relies on the theme's scaled text styles still
  scales correctly (reader + non-reader surfaces like settings/menus).
