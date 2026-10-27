# Icons: Material Symbols vs classic Material Icons

Recorded 2026-10-27. The icon swaps below are done; the migration question at
the end is open.

## Two icon sets are in play

| | Package | Dart | Style |
|---|---|---|---|
| Classic | ships with Flutter | `Icons.*` | Material Icons, frozen upstream |
| Symbols | `material_symbols_icons` | `Symbols.*` | Material Symbols, maintained |

`Symbols.x` is the **Outlined** family, `Symbols.x_sharp` is Sharp,
`Symbols.x_rounded` is Rounded. A fonts.google.com link showing
"Material Symbols Outlined, FILL@0, wght@400" is the bare `Symbols.x` form.

The two sets do **not** share codepoints — `find_in_page` is `0xe285` in
classic and `0xe880` in Symbols. They are different fonts, not variants.

## What changed

| Where | Was | Now |
|---|---|---|
| Reader toolbar, find in page | `Icons.search` | `Icons.find_in_page_outlined` |
| Search Refine chip | `Icons.tune` | `Icons.filter_list` |
| Search refine dialog header | `Icons.tune` | `Icons.filter_list` |
| Dictionary refine button | `Icons.tune` | `Icons.filter_list` |
| Dictionary refine dialog header | `Icons.tune` | `Icons.filter_list` |
| Dictionary exact-word toggle | `Icons.abc` @28 | `Symbols.match_word` @24 |

Find-in-page used the same magnifier as the app bar's global search, so one
glyph meant two scopes. Only the toolbar one moved; the app bar keeps the
magnifier.

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
  already filled when selected. One implementation, three controls.
- **Icon buttons in a row share one size.** `CircularToggleButton` defaulted to
  20 while the plain `IconButton`s around it took Flutter's 24, which read as
  "that icon is smaller". Default is now 24.

### Two traps

`match_word` does **not exist in classic** — it is Symbols-only. Checked all
8,825 `Icons` entries; there is no `match_word`, no `match_case`, nothing
matching `match` at all. Same for anything else Symbols-only: check before
promising it.

A **bare name means filled in classic and unfilled in Symbols**. Classic ships
`find_in_page` (filled, `0xe285`) plus `_outlined`, `_sharp` and `_rounded`, all
four in `MaterialIcons.ttf` — the unfilled look just needs the explicit suffix.
`Symbols.find_in_page` is unfilled already, because `FILL` defaults to 0.

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

- Symbols at `wght` 400 is drawn **lighter than classic**, so a Symbols icon
  dropped among classic ones reads thin. `weight: 500` is the usual match.
  Nothing in `lib/` sets `weight` yet, including `Symbols.match_word` next to
  classic `Icons.filter_list` in the dictionary sheet header.
- A selected state can be `fill: 1` instead of a background colour.

## Open question: migrate everything to Symbols?

Measured 2026-10-27 over `lib/`.

**Scale.** 54 distinct icons, 92 call sites, 29 files. 52 of the 54 map
straight across. (A raw grep of `lib/` says 56 and 94: `Icons.palette` sits in
a commented-out block and `Icons.refresh` in a doc-comment example, so neither
is a call site.) The two that don't map:

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

**No bytes are saved.** Flutter's own Material widgets hardcode classic icons —
AppBar back (`Icons.arrow_back`), dropdowns (`Icons.arrow_drop_down`), overflow
menus (`Icons.more_vert`) and more. `MaterialIcons.ttf` ships whether we use it
or not. Release builds tree-shake icon fonts to the referenced glyphs, so the
raw font sizes don't reach users — but **only while every `IconData` stays
const**; a non-const one disables the shaker.

**Cheap win available now, independent of the migration.** Two Symbols variants
are currently pulled: Outlined (`folded_hands`, `match_word`) and Sharp
(`book_5_sharp`, `book_4_sharp`, `description_sharp` — 4 usages in
`content_icons.dart` and `reader_action_buttons.dart`). Moving those to
Outlined drops the Sharp family and leaves one Symbols variant.

### Verdict

Worth doing — classic is frozen, Symbols is maintained, and the variable axes
are genuinely useful. But it is its own chore, not something to fold into an
icon tweak, and a half-migration looks worse than either end state.

If done: pick Outlined, set it once via a global `IconTheme`, land it in a
single commit, and add a CI grep banning bare `Icons.` outside a small
allowlist (the adaptive-share site, plus whatever the framework forces).

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
