# Word-joining characters in the FTS index

Handover, 2026-10-26. The snippet crash is fixed (working tree, uncommitted).
The retrieval half is **not** done — the user chose to leave it, and wants it
dug into properly before anything touches `bjt.db`. A second, unrelated defect
found while investigating is recorded at the end.

## The two gates

A search passes through two independent gates, and they disagree about which
characters split a word.

| Gate | Decides | Where it is decided | Status |
|---|---|---|---|
| **Retrieval** | is the record found at all | `cleanTextForIndexing()` in `tools/bjt-populate.js`, plus the `tokenchars` list on the `bjt_fts` virtual table — both baked into `assets/databases/bjt.db` at build time | **open** |
| **Display** | can the snippet locate and highlight the hit | `SearchResult.plainMatchedText`, `normalizeSearchText()` (`lib/core/utils/text_utils.dart`) and `HighlightedFtsSearchText` | fixed |

Any character the indexer removes but the app keeps makes the app unable to
find a hit the index found. Any character the indexer keeps but should have
removed makes the record unfindable in the first place. The bug report that
started this was the first kind; the open work is the second.

## What was fixed

A search for `ඡන්දරාගවෙමත්තතාති` crashed its result tile with
`RangeError (length): Invalid value: Not in inclusive range 0..914: -1`.

The commentary entry (`atta-sn-3` page 47, entry 0, pali) stores the word split
by bold markers:

```
**ඡන්දරාගවෙමත්තතා**ති
```

`cleanTextForIndexing` strips `**`, so fts5 indexed one token. The app's
`normalizeSearchText` deliberately kept markers, so `indexOf` returned `-1`,
and `NormalizedTextMatcher.mapToOriginal` indexed its position map with it.

The reader never had this bug because it was already marker-free on the way in:
`reader_entry_builder.dart` passes `entry.plainText`, and
`in_page_search_provider` matches against `entries[i].plainText`. The search
tile was the one surface handing `SearchMatchFinder` raw corpus text.

So the fix gives the search path the accessor the reader already had.
`SearchResult.plainMatchedText` strips the markers through
`ContentMarkers.stripMarkers`
(`packages/wisdom_shared/lib/src/text/content_markers.dart`) and caches the
result in an `Expando`, exactly as `Entry.plainText` and `Entry.markedRanges`
do; the two result tiles read it instead of `matchedText`.
`NormalizedTextMatcher.mapToOriginal` collapses a negative start to an empty
range, so an unlocatable hit degrades to a snippet from the head of the entry
rather than throwing. `stripMarkers` was checked against
`cleanTextForIndexing` over every entry in the corpus and joins words
identically; see the measurement block below.

`matchedText` itself stays raw, deliberately. Group 9 of
`integration_test/search_flow_integration_test.dart` pins it byte-for-byte
against recorded goldens that carry `**` and `{1}` on purpose — they are what
proves the `bjt_content` pipeline loses nothing. Stripping in the repository
would have forced all of them to be re-recorded and would have retired that
coverage; a getter leaves it intact and still parses once per result rather
than once per rebuild.

Adding a getter to a Freezed class needs `const SearchResult._();` and a
`build_runner` run — that is what flips the generated `_SearchResult` from
`implements SearchResult` to `extends SearchResult` so the getter is
inherited. Five lines of `search_result.freezed.dart` change; nothing else.

## What is open

The mirror-image failure. The user's example:

```
https://sammaditthi.net/tipitaka/an-3-1-5-1#an-3-1-5-7
an-3 page 39 entry 9 (pali):
  '47. තීණි’මානි භික්ඛවෙ සඞ්ඛතස්ස සඞ්ඛතලක්ඛණානි. ...'
            ↑ U+2019 RIGHT SINGLE QUOTATION MARK
```

That is the Pali elision mark (*tīṇi'māni*). It is neither stripped by
`cleanTextForIndexing` nor listed in `tokenchars`, so fts5 indexed
`තීණි` + `මානි` as two tokens. Searching `තීණිමානි` cannot reach the record.
The user wants it to.

```sh
sqlite3 assets/databases/bjt.db \
  "SELECT count(*) FROM bjt_fts WHERE bjt_fts MATCH 'තීණිමානි*';"   # 89, not this record
sqlite3 assets/databases/bjt.db \
  "SELECT count(*) FROM bjt_fts WHERE bjt_fts MATCH 'තීණි’මානි*';"  # 16, includes it
```

### Both gates must move together

If only the indexer changes, records like this start being returned and then
land on the negative-start guard in `mapToOriginal` — no crash now, but the
snippet starts at the head of the entry with no highlight. Whatever character
set the indexer starts removing has to be removed by `normalizeSearchText` too,
and `sanitizeSearchQuery` should drop it from typed queries.

Three places, one list. There is no shared source for it today:
`cleanTextForIndexing` is JavaScript and the app is Dart, so a guard test that
asserts the two agree is probably the honest way to keep them from drifting.

### The fix aligned the UI with `stripMarkers`, not with the indexer

Four things `cleanTextForIndexing` removes are **not** removed by
`stripMarkers`, so each is the fixed bug over again — the index joins the word,
the UI keeps it split, `indexOf` returns `-1`:

| removed by the indexer | `stripMarkers` | mid-word in the corpus today |
|---|---|---|
| a lone `*` (unpaired) | keeps | 0 |
| a lone `_` (unpaired) | keeps | 0 |
| `~` | keeps | 0 |
| `$` | keeps | 0 |
| `‍` ZWJ | keeps | 796,778 — harmless, `normalizeSearchText` drops it |
| `\n` → space | keeps | both gates split, so the record is never returned |

Measured 2026-10-26 over `assets/text/*.json`: none of the four sits between
two Sinhala letters anywhere in the corpus, which is why the crash was only
ever reachable through `**`, `__` and `{…}`. They are unreachable by corpus
state, not by construction — the text is re-synced from upstream
(`scripts/bjt-sync-regen/`), so a sync could introduce one and nothing would
catch it. The widget tests cover only the subset where the two already agree.

### The decision that was not made

Which characters count as joiners rather than separators.

- `’` U+2019 — the case above.
- `”` U+201D — the same shape, and far more common: `විහරාමී”ති` → `විහරාමීති`.
  Both are correct Pali sandhi forms.
- `-` `…` `.` `?` `(` `)` `,` — should stay separators. `චෙතනා-යා` is genuinely
  two words; joining them would be wrong.

Cost of joining a quote mark: the piece before it stops being its own token.
`“ආවුසො”ති` becomes `ආවුසොති`, so **exact-word** search for `ආවුසො` would miss
those spots. The app's default mode is prefix (`ඇරඹෙන වචන`), where `ආවුසො*`
still matches, so the default flow loses nothing. The joined forms are words
the corpus already writes unquoted elsewhere, so this merges into existing
tokens rather than inventing them — worth re-checking before committing to it.

### Practical cost

Changing retrieval means regenerating `assets/databases/bjt.db` through
`tools/bjt-populate.js`. The databases are gitignored, so the change leaves no
diff to review — and `search_flow` integration test B2 pins footer counts to
the built DBs, so it will break with no visible cause. Recompute those counts
in sqlite rather than trusting the old literals.

## Also open, unrelated: the highlight end swallows stripped characters

Found while verifying the fix; pre-existing, cosmetic, independent of
everything above. `NormalizedTextMatcher.mapToOriginal` maps the *end* of a
range with `_positionMap[normEnd]`, which is the original index of the first
character **after** the match in normalized space. Any character normalization
dropped in between — `.` `;` `!`, a zero-width joiner, a collapsed run of
whitespace — falls inside the mapped range and gets highlighted.

Seen on `an-3` page 39 entry 9 searching `සඞ්ඛතලක්ඛණානි`:

```
today : 'සඞ්ඛතලක්ඛණානි.'      ← the full stop is highlighted too
want  : 'සඞ්ඛතලක්ඛණානි'
```

The end wants to be the position just past the last matched character, not the
position of the next one. Each normalized character maps to exactly one
original index, so `_positionMap[normEnd - 1] + 1` is the value — with the
existing `normEnd >= _positionMap.length` branch and an empty-range guard kept.

Mostly invisible (a swallowed ZWJ renders as nothing), so it only shows on
punctuation. Worth fixing with the reader's highlighting in view too:
`in_page_search_provider.dart` and `text_entry_widget.dart` go through the same
`SearchMatchFinder`, so any change here moves those highlights as well, and the
existing `test/core/utils/search_match_finder_test.dart` expectations will need
rereading rather than blind updating.

## Measurements, taken 2026-10-26

Dated record of a measurement, not a corpus figure to cite. Re-measure rather
than trusting these; each was taken by walking every row of `bjt_content`,
inflating the zlib blob, and counting regex hits per entry.

- Entries carrying text: 456,979.
- Entries where a formatting marker splits a word: 33,487 (7.3%), 103,238
  occurrences. This is what made the crash reachable.
- Characters sitting between two Sinhala letters with no space, after applying
  `cleanTextForIndexing`'s own strip, most common first:

  | char | pali | sinh |
  |---|---|---|
  | `”` U+201D | 90,949 | 7,633 |
  | `’` U+2019 | 32,613 | 21,803 |
  | `-` | 3,476 | 6,151 |
  | `…` U+2026 | 3,149 | 0 |
  | `.` | 16 | 1,234 |

- `stripMarkers` vs `cleanTextForIndexing` divergence across the whole corpus:
  the four characters tabled under "The fix aligned the UI with
  `stripMarkers`" — all zero inside a word. `{…}` with three or more
  characters inside a word — 2, and in the harmless direction (`stripMarkers`
  joins, the indexer splits, so `indexOf` still succeeds).
- Every figure above was re-derived from `assets/text/*.json` during the
  2026-10-26 code review and matched. The two mutation checks were re-run and
  matched too: 8 widget tests fail without `stripMarkers`, 3 fail without the
  `-1` guards, with the original `RangeError`.

## Files

- `lib/domain/entities/search/search_result.dart` — `plainMatchedText`, the
  cached strip, and the `SearchResult._()` constructor Freezed needs for it.
- `lib/presentation/widgets/search/search_result_tile.dart`,
  `secondary_match_tile.dart` — the two tiles; they must read
  `plainMatchedText`, and nothing but their own test says so.
- `lib/presentation/widgets/search/highlighted_fts_search_text.dart` — snippet
  and highlight. Requires marker-free text; it no longer strips anything.
  `_createSnippet` and `_centreOn` ask `SearchMatchFinder` where the match is
  rather than carrying their own copy of the search; the widget's old
  `_findPhrasePosition` is gone. `_centreOn` returning an empty range is what
  keeps an unlocatable hit off the position map.
- `lib/core/utils/search_match_finder.dart` — `NormalizedTextMatcher`,
  `mapToOriginal` (the old crash site, and now the only `-1` guard).
- `lib/core/utils/text_utils.dart` — `normalizeSearchText`,
  `sanitizeSearchQuery`.
- `tools/bjt-populate.js` — `cleanTextForIndexing`, and the `tokenchars` list
  on the `CREATE VIRTUAL TABLE bjt_fts` statement.
- `packages/wisdom_shared/lib/src/text/content_markers.dart` — the one marker
  grammar, shared with the static-site generator.

Tests:

- `test/presentation/widgets/search/highlighted_fts_search_text_test.dart` —
  the class guard. A table of the markers the indexer removes **and**
  `stripMarkers` removes (`**`, `__`, `{}`, `{12}`, `{ab}`, ZWJ), each
  asserting that a word it splits is still highlighted; plus the reported
  commentary hit, and a **TRIPWIRE** test pinning the `’` gap. That tripwire
  is meant to fail the moment the indexer starts stripping `’` without
  `normalizeSearchText` following — that is the signal to update both sides,
  not to delete the test.

  One caveat on that table: the ZWJ row passes with or without the strip,
  because `normalizeSearchText` already drops ZWJ. It guards pre-existing
  normalization, not the strip. The other five rows do bite.

  A second **TRIPWIRE** group pins the four characters the indexer removes and
  `stripMarkers` keeps. They assert today's broken behaviour on purpose: a
  corpus sync that introduces one turns them red instead of silently shipping
  a snippet with no highlight. If one starts highlighting, move its row up
  into `joiners` rather than deleting it.

  The widget's own test feeds text through `stripMarkers` on the way in,
  because that is what the tile now hands it. The widget strips nothing, so
  the two halves of the contract are pinned where they live, not here.
- `test/data/repositories/text_search_repository_impl_test.dart` —
  `plainMatchedText` through the real search path: raw text survives in
  `matchedText`, markers come off in `plainMatchedText`, and the Expando
  returns the same instance twice.
- `test/presentation/widgets/search_results_panel_test.dart` — the tiles'
  choice of accessor. Both tiles render, neither shows a marker. This is the
  only test that fails if a tile goes back to raw `matchedText`.
- `test/core/utils/search_match_finder_test.dart` — the `mapToOriginal`
  negative-start guard.
- `test/core/utils/text_utils_test.dart`,
  `integration_test/search_flow_integration_test.dart` — pre-existing, pass
  unchanged. The latter has not been re-run on a device since the change; it
  should not be affected, because `matchedText` is untouched.

Mutation-checked on 2026-10-26, after the review moved the strip and folded
`_createSnippet` onto `SearchMatchFinder`: making `plainMatchedText` return
raw fails 4 tests, and pointing a tile back at `matchedText` fails 1.

Removing the `mapToOriginal` guard now fails only its own unit test. That is
expected and not a reason to drop it: `_centreOn` substitutes an empty range
before anything reaches the position map, so the guard is a backstop on the
function's documented contract rather than the live crash barrier. It was
measured load-bearing (7 failures) at the point where the widget had folded
but still passed a raw `-1` down.

### A note on separate-words centring

Folding the snippet onto the finder changed one case, and it was changed back
deliberately. In separate-words mode the highlighter marks *every* occurrence
of every word, so the earliest match can sit far from the cluster that made
the record match; centring on it opened the snippet on a lone word with the
real hit off-screen. `_centreOn` runs a proximity pass first
(`_separateWordsGap`, 100 normalized characters — snippet geometry only, not
the proximity the FTS query used) and only falls back to the earliest single
match when the words never come close together. Phrase and exact modes are
untouched: the finder's own branches already matched what the widget did,
including the hyphen fallback.
