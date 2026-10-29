# Singlish typing on the static site

The app's search box converts typed Singlish to Sinhala and shows the result in
a chip beside the query. The site's search dialog does neither, so a reader
with a Latin keyboard has no way in. This brings both across at strict parity.

**Status: not started.** The `c` and `R` entries in §6 are already **done** in
the app (2026-10-29); the site inherits them the moment it reads the same
tables.

## 1. The constraint that shapes everything

`assets/site.js` holds no Sinhala and no URLs — every label and path arrives on
a `data-` attribute the generator wrote — and it is a committed file the build
*copies*, never generates. So the mapping tables cannot be pasted into it, and
`@pnfo/singlish-search` cannot be bundled (no bundler, one script file).
Whatever the script needs has to arrive as data.

## 2. The split: tables shared, algorithm transcribed

- **Move `SinglishTransliterator` into `wisdom_shared`** (`src/text/`), tables
  public. The generator has no Flutter dependency on purpose, so it cannot
  import the app — the same reason the zero-width list needs a shared constant
  (backlog C11), and what the Jaspr findings already recommended instead of
  copying the file.
- **The generator serializes the tables** into `search-index.json`.
- **site.js transcribes `convert()`**: the same six passes in the same order.

Verified 2026-10-29: tables generated from Dart, the JS written against them,
then 5,019 cases run through both — the realistic queries, the `~` escapes,
rakaransha, Sinhala input, and 5,000 random strings over the key alphabet.
**0 mismatches.** 0.29 ms per conversion, against a per-keystroke scan of every
index row that already happens.

The port exposed one thing the tables do not carry: `convert()` inserts the hal
and the rakaransha ්‍ර itself, so those two strings must ride along as data too.

## 3. Where the tables ride

In `search-index.json`, not on the dialog element: **+542 bytes once** (measured
2026-10-29) against the same bytes on every page the build writes
(`FIGURES.realPages`), which would also re-upload the whole corpus.

Two consequences, both acceptable. The chip waits for the index — the gate
search already has, and it is cached `immutable` after the first open. And the
top-level JSON becomes `{"rows": […], "singlish": {…}}`: one line in
`search_index.dart`, one in site.js (`rows = data.rows`), one in the wiring
test's row reader.

## 4. The five edits

| # | Where | What |
|---|---|---|
| 1 | `packages/wisdom_shared/lib/src/text/` | move the transliterator in, tables public; update one app import and one test import |
| 2 | `render/search_index.dart` | wrap the output, emit the tables |
| 3 | `assets/site.js` | port `convert()`; converted query into `fold()`; draw the chip with `textContent` |
| 4 | `render/search_dialog.dart` | a `<span class="search-chip">` between the input and the close button |
| 5 | `render/stylesheet.dart` | ~10 lines, the app's own tokens |

## 5. Parity with the app

| App | Site |
|---|---|
| `convert()` — Sinhala-favouring, deterministic, one result | the same tables, the transcribed passes |
| no chip unless the query holds a Latin letter | same gate, `/[A-Za-z]/` |
| no chip for `SN 15.3` (`parseRef`) | open — see §8 |
| chip keeps the ZWJ, the query strips it | same split: chip gets the raw conversion, `fold()` feeds the search |
| pill: `surfaceContainerLow`, radius 6, max 45% of the field, ellipsis | the same, via `--c-surface-container-low` |

One difference that cannot go: the chip sits *beside* the field rather than
inside it, because an `<input>` takes no children.

## 6. `c` and `R` — done in the app, free here

Both were unmapped letters, and an unmapped Latin letter can never match a
corpus name, so both changes are purely additive.

- **`c` → ච.** The UCSC scheme has only `ch`/`Ch`, so a bare `c` survived every
  pass as a Latin letter wedged inside Sinhala — `dhammacakka` → `දම්මcඅක්ක`.
  Romanized Pali spells ච as `c` (cakka, citta, pañca), and both sibling
  schemes (UCSC's own Phonetic variant, pnfo) map it. Measured 2026-10-29:
  `cakka` went from no name hits to 75.
- **`R` → repaya ර්‍.** UCSC's own entry, lost in the port, so `vaRgaya` gave
  `වRගය`. Restoring it finds **nothing new** — search folds the ZWJ off both
  sides, so the plain `r` spelling already reached those names — it stops
  correct scheme input from silently failing, and makes the chip show the hook
  a reader expects. Ordered below `~R`, which would otherwise lose its R.

Checked rather than assumed: a differential run of HEAD against the edit over
40,038 inputs (every table key, plus letters neither table knows, plus the
literals every existing test types) — **every changed output contains a bare
`c` or a non-escape `R`, and nothing else moved.** Four new unit tests in
`singlish_transliterator_test.dart` and `search_query_utils_test.dart`.

## 7. What this does not fix

Measured 2026-10-29 against the vendored tree. Naive romanized Pali mostly
finds nothing — `mangala`, `sutta`, `nikaya`, `abhidhamma` all return no name
hits — while the scheme's own spelling works well: `suththa`, `jaathaka`,
`mahaa`, `ma~Ngala` return thousands, thousands, hundreds and dozens.

The reason is not a bug. UCSC's SinGlish is a **Sinhala** scheme: `t` is ට,
`th` is ත, capitals carry the aspirates, and length is spelled out (`aa`). A
reader who knows the canon as *Mahāsatipaṭṭhāna* has to learn it. That is the
app's position too, and this plan deliberately keeps the site at parity rather
than diverging. Fixing discovery properly is a separate decision: pnfo's
candidate generator, or romanized names (backlog D1) and aliases (D2).

## 8. Decisions still open

- **The reference carve-out.** The app shows no chip for `SN 15.3`.
  `SuttaCentralRefResolver.parseRef` is one anchored regex plus a 14-book set,
  both already in `wisdom_shared`, so shipping them as data buys exact parity
  for about six lines of JS. The alternative is letting a typed reference show
  a nonsense chip.
- **Chip accessibility.** The app announces nothing. An `aria-live` here would
  compete with the results line's `role="status"`; `aria-describedby` on the
  field is the quieter option.

## 9. Provenance — do not re-derive this

```
UCSC LTRL (2011)  ──►  Open-SL/sinhala-unicode-converter  ──►  the app
   feconverter          singlish_to_unicode.ts (MIT, TS)      singlish_transliterator.dart
```

Established 2026-10-29 from primary sources: Open-SL's README credits
*"Language Technology Research Laboratory - University of Colombo School of
Computing (2011)"* and links <https://www.ucsc.cmb.ac.lk/ltrl/services/feconverter/>,
whose own scheme page documents exactly what we implement — long vowels as `aa`
or `a)`, aspirates by `h`-suffix or capital, `\n` for anusvara, `R`/`\r` for
repaya, `Y`/`\y` for ya-phala, `nn`+consonant for the prenasalised.

A table-by-table diff found **every consonant and every base vowel identical**,
and the same pass order. `R` was lost in the port and is now restored. Every
deliberate divergence is listed once, in the header of
`singlish_transliterator.dart`.

Credits for both are planned in `docs/todo/settings/app-settings-dialog.md`
("Later, not in this scope").

## 10. Tests

- **Parity, not a transcription snapshot.** Node 18 is on the machine, so one
  test can run site.js's `convert` against the shared Dart over a word list and
  compare. Skipped when node is absent, so a plain `dart test` still passes.
- The index contract test gains the shape of the `singlish` block, beside the
  row offsets it already pins.

## 11. Not doing: pnfo

`@pnfo/singlish-search` (MIT, ESM-only, 108 KB unpacked, no deps) returns up to
300 trigram-ranked candidates and would genuinely fix §7 — tipitaka.lk ORs them
into one RegExp over its title index. It is not the shorter path: a second
script file with `type="module"` against a CSP built for one, 108 KB inside a
file the build copies rather than generates, 300 candidates against every name
per keystroke, and a chip that can no longer show *the* conversion. Loose
multi-candidate Singlish was also already taken to a branch for the app and
parked.

## Related

- `docs/todo/web-strategy/static-site-backlog.md` — C11 (the shared zero-width
  list), D1/D2 (romanized names, aliases)
- `docs/done/search/transliteration-search-implementation.md` — the app's
  original scheme write-up
- `docs/todo/settings/app-settings-dialog.md` — the credits rows
