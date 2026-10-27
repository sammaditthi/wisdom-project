# Icons: Material Symbols vs classic Material Icons

Recorded 2026-10-27. The swaps are done and the migration question at the end
is settled: no migration. Classic stays the default set.

## Two icon sets are in play

| | Package | Dart | Style |
|---|---|---|---|
| Classic | ships with Flutter | `Icons.*` | Material Icons, frozen upstream |
| Symbols | `material_symbols_icons` | `Symbols.*` | Material Symbols, maintained |

`Symbols.x` is the **Outlined** family, `Symbols.x_sharp` is Sharp,
`Symbols.x_rounded` is Rounded. A fonts.google.com link showing
"Material Symbols Outlined, FILL@0, wght@400" is the bare `Symbols.x` form.

The three are not variants of one font, they are three fonts. They share the
codepoint and differ by family: `find_in_page`, `find_in_page_rounded` and
`find_in_page_sharp` are all `0xe880`, in `MaterialSymbolsOutlined.ttf`,
`MaterialSymbolsRounded.ttf` and `MaterialSymbolsSharp.ttf`. Sharp squares the
corners Outlined rounds. Picking a suffix picks a font file to ship.

The two sets do **not** share codepoints — `find_in_page` is `0xe285` in
classic and `0xe880` in Symbols. They are different fonts, not variants.

## What changed

| Where | Was | Now |
|---|---|---|
| Reader toolbar, find in page | `Icons.search` | `Symbols.find_in_page_sharp`, `wght` 500 |
| Search Refine chip | `Icons.tune` | `Icons.filter_list` |
| Search refine dialog header | `Icons.tune` | `Icons.filter_list` |
| Dictionary refine button | `Icons.tune` | `Icons.filter_list` |
| Dictionary refine dialog header | `Icons.tune` | `Icons.filter_list` |
| Dictionary exact-word toggle | `Icons.abc` @28 | `Symbols.match_word_sharp` @24, `wght` 500 |
| Reader toolbar, commentary toggle | `Symbols.description_sharp` | same, `wght` 500 |
| Settings, Anumodanā tab | `Symbols.folded_hands` | `Symbols.folded_hands_sharp` |

Find-in-page used the same magnifier as the app bar's global search, so one
glyph meant two scopes. Only the toolbar one moved; the app bar keeps the
magnifier. It went to classic `find_in_page_outlined` first and that sat badly
among the toolbar's other icons, so it is `Symbols.find_in_page_sharp` — Sharp
to match `description_sharp`, the other Symbols glyph in that toolbar.

Six swapped call sites cost three test files: `find.byIcon` finders in
`dictionary_editable_word_test.dart` and `search_test_helper.dart`, and a
comment in `in_page_search_test.dart`. The migration's bill in miniature.

### Rules this settled

- **`Icons.tune` means "adjust values", nothing else.** It survives in exactly
  one place, `reader_settings_menu_button.dart` (font size, layout). Anything
  that narrows a list is `Icons.filter_list`.
- **Active state is a pressed look, not a dot.** The dictionary refine button
  hand-rolled a `Stack` + `Positioned` dot; it now uses `CircularToggleButton`
  like the exact-word toggle beside it, and the Refine chip (`PillChip.refine`)
  already filled when selected — same `primaryContainer` pair in both. Both
  now carry `Semantics(selected:)` too, so the state is announced, not only
  coloured. One implementation, three controls.
- **Icon buttons in a row share one size.** `CircularToggleButton` forced 20
  while the plain `IconButton`s around it took Flutter's 24, which read as
  "that icon is smaller". It now passes no size at all, so it inherits the
  same 24 they do and the row cannot drift apart again.

### Two traps

`match_word` does **not exist in classic** — it is Symbols-only. Checked all
8,825 `Icons` entries; there is no `match_word`, no `match_case`, nothing
matching `match` at all. Same for anything else Symbols-only: check before
promising it.

A **bare name means filled in classic and unfilled in Symbols**. Classic ships
`find_in_page` (filled, `0xe285`) plus `_outlined`, `_sharp` and `_rounded`, all
four in `MaterialIcons.ttf` — the unfilled look just needs the explicit suffix.
`Symbols.find_in_page` is unfilled already, because `FILL` defaults to 0 —
which is why the toolbar ended up on a Symbols variant of it.

## The Symbols font is variable

`MaterialSymbolsOutlined.ttf` (package 4.2928.1) carries an `fvar` table:

| Axis | Range | Default |
|---|---|---|
| `FILL` | 0–1 | 0 |
| `wght` | 100–700 | 400 |
| `GRAD` | -50–200 | 0 |
| `opsz` | 20–48 | 24 |

Flutter's `Icon` exposes all four as `fill`, `weight`, `grade`, `opticalSize`.
Useful consequences:

- Symbols at `wght` 400 has **thinner strokes than classic**, so a Symbols
  glyph among classic ones wants `weight: 500`. All three that sit beside
  classic icons landed there on screen on 2026-10-27: the toggle in the
  dictionary sheet header as `match_word_sharp`, and `find_in_page_sharp`
  and `description_sharp`
  in the reader toolbar. At 400 the toolbar pair read small rather than heavy
  — a page and a magnifier inside 20px draws finer than the solid classic
  shapes beside it. 300 was tried on `match_word` first and was worse. Trust
  the rule; 500 is the number.
- The tree's Symbols icons (`book_4_sharp`, `book_5_sharp`,
  `description_sharp` via `content_icons.dart`) are outside the rule: their
  call sites in the tree and the tab bar have asked for `weight: 600` since
  long before this migration. They have no classic neighbours — the tree draws
  only these three — so there is nothing for them to match.
- `grade` (`GRAD`) is the finer version of the same dial — Flutter's own docs
  call it "stroke weight in a more granular way". Reach for it when `weight`
  overshoots. `opticalSize` is the other one worth knowing: these icons render
  at 20 while `opsz` defaults to 24, so telling the font the truth is
  available if 500 is ever not enough.
- A selected state can be `fill: 1` instead of a background colour.

## The migration question

Measured 2026-10-27 over `lib/`.

**Scale.** 53 distinct classic icons, 91 call sites, 29 files, beside 7
Symbols ones. 51 of the 53 map straight across. (A raw grep of `lib/` says 55
and 93: `Icons.palette` sits in a commented-out block and `Icons.refresh` in a
doc-comment example, so neither is a call site.) The two that don't map:

- `info_outline` — legacy name only; Symbols calls it `info` and outlined is
  its default. Not a real gap.
- `Icons.adaptive.share` (`reader_action_buttons.dart`) — a platform-switching
  accessor, not an icon; resolves to `ios_share` on Apple platforms. Symbols
  ships both `share` and `ios_share` but no adaptive accessor, so this site
  stays classic or gets a manual platform branch.

**The cost is tests, not code.** 126 `find.byIcon` assertions across 29
distinct icons; `skip_previous` appears 18 times, `skip_next` 16,
`error_outline` 12. Mechanical, but it is the bulk of the work and the main
way the suite breaks.

**No bytes are saved.** `MaterialIcons.ttf` ships whether we use it or not —
the verdict below says why. Release builds tree-shake icon fonts down to the
glyphs referenced, so the raw font sizes never reach users, but **only while
every `IconData` stays const**; a non-const one disables the shaker.

**One Symbols family: Sharp.** All 7 usages carry the `_sharp` suffix —
`book_5_sharp`, `book_4_sharp`, `description_sharp` ×2, `find_in_page_sharp`,
`match_word_sharp`, `folded_hands_sharp`. The last two were bare Outlined
names until 2026-10-27, so every Symbols glyph in the app is now drawn in one
style. That bought consistency, not bytes: `material_symbols_icons` declares
all three families whatever we reference, and tree-shaking subsets each to the
glyphs actually used, so an unreferenced family costs nothing either way.

### Decided: no migration

**Classic cannot be left behind.** Flutter's own widgets draw classic icons and
nothing in `lib/` changes that: `action_buttons.dart:135` returns
`Icons.arrow_back` for every `BackButton`, and one of those sits inside the
search field at `search_bar.dart:252`. `PopupMenuButton` defaults to
`Icons.more_vert`. `MaterialIcons.ttf` ships either way.

So a full migration does not end with one icon set. It ends with two, split
along a line a user can see: framework chrome classic, everything we drew
Symbols. Today that split is 7 Symbols among ~90 classic and nobody notices.
Migrated, it is ~90 Symbols against the framework's classic, with the seam
running through the search field — framework back arrow inches from our own
icons, in a different font. Today they match. That is a migration away from
consistency, not toward it.

The rest, in order of weight:

- **The bill is 126 test assertions** in the flakiest suite we own, for nothing
  a user can see.
- **No bytes are saved**, per above: classic ships regardless, so the swap
  trades ~90 classic glyphs for ~90 Symbols ones and carries both fonts
  either way.
- **"Frozen" costs nothing** while the escape hatch holds. Frozen is stable,
  not broken. The only real bite is wanting a glyph classic lacks, and that is
  a one-line fix — `match_word` was. Symbols carries ~4,204 distinct names to
  classic's ~2,231, so it is a good hatch.

Genuinely given up: the variable axes, Symbols-only. But they work per icon
without migrating anything, which is how `match_word` got its `weight: 300`.

**The policy.** Classic is the default. Reach for Symbols one glyph at a time,
when classic has no equivalent or the Symbols picture is plainly better. Take
the `_sharp` name, and `weight: 500` wherever it sits beside classic icons;
keep the list of Symbols sites in this doc current so the mixing stays
deliberate. Revisit only if Flutter moves its own framework widgets to
Symbols — that one event flips every line above, and it is not ours to
schedule.

## Re-checking any of this

```sh
SDK=~/development/flutter/bin/cache/dart-sdk/bin/dart   # skips the sandbox-blocked wrapper
ICONS=~/development/flutter/packages/flutter/lib/src/material/icons.dart
# Several versions sit in the pub-cache, so take the resolved one — a glob
# answers for a package we may not ship.
VER=$(sed -n '/^  material_symbols_icons:/,/^  [a-z]/{s/^    version: "\(.*\)"/\1/p;}' pubspec.lock)
SYM=~/.pub-cache/hosted/pub.dev/material_symbols_icons-$VER/lib/symbols.dart

grep -c "static const IconData" "$ICONS"          # classic set size
grep -n "static const IconData match_word" "$SYM" # does Symbols have it
grep -rho "Icons\.[a-z_0-9]*" lib/ | sort -u      # what we use, comments and all
```

Note `dart analyze` via the `flutter` wrapper fails under the Bash sandbox
(it writes `bin/cache/engine.stamp`); call the SDK binary above directly.
