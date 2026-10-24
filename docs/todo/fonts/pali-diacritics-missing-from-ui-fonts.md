# Pali diacritics have no bundled glyph in UI text

Found 2026-10-24, while fixing the Settings dialog's labels. Not started.

**Symptom.** `Pāli` in the Content language selector rendered with an ā that
looked heavier than the letters beside it. It is not bolder — it is a different
font. No bundled face has the glyph, so the OS substitutes one.

## What is actually missing

Measured with fontTools on 2026-10-24:

| Face | Role | ā ī ū (U+0100–017F) | ṭ ḷ ṇ ṃ ñ (U+1E00–1EFF) |
|---|---|---|---|
| `NotoSansSinhala-*-Subset.ttf` | the UI font (`AppFonts.ui`) | ✗ | ✗ |
| `NotoSansSinhala-*.ttf` (source) | — | **✓** | ✗ |
| `NotoSans-*.ttf` | UI fallback (`AppFonts.uiFallback`) | ✗ | ✗ |
| `NotoSerif-*.ttf` | reader only | ✓ | ✓ |

Two independent faults:

1. **`subset_fonts.sh` discards a glyph we already ship.** It defines
   `LATIN_EXTENDED_A` but never passes it: `SINHALA_RANGES` is Basic Latin +
   Latin-1 + Sinhala + General Punctuation. The source face has ā; the subset
   drops it.
2. **The bundled Noto Sans is a stripped build** with no Latin Extended-A at
   all, so the fallback cannot cover for the first fault.

Also uncovered, same cause: `→` (U+2192) in `databaseInstallFailedDescription`.
No declared range includes the Arrows block.

## What it affects

Every UI string with a Pali diacritic: the **Anumodanā** tab label,
`aṭṭhakathā` in the tipitaka.lk row, `Digital Pāḷi Dictionary` in DPD's
citation, `Bhāṇaka` in the lineage section (commented out).

Only one of these can be spelled around. DPD's citation form is licence-
mandated, and Anumodanā is the feature's name. `paliLanguageLabel` was changed
to `Pali` on 2026-10-24 — not as a fix, but because English copy spells it that
way everywhere else anyway.

Rendering today depends on the host OS, so the same build looks different on
macOS, Windows and Android, and can show tofu where no system face covers the
range.

## Fix, in two steps

**Step 1 — add `LATIN_EXTENDED_A` to `SINHALA_RANGES`** and re-run
`subset_fonts.sh`. Costs a few KB and gets ā, ī, ū from the same family as the
letters around them. Fixes Anumodanā and Bhāṇaka.

**Step 2 — replace `assets/fonts/noto-sans/*.ttf` with the full Noto Sans**
and give `SANS_RANGES` both `LATIN_EXTENDED_A` and `LATIN_EXTENDED_ADD`. Every
Pali diacritic then has a bundled home. Noto Sans and Noto Sans Sinhala are
designed to pair, so the handoff inside `aṭṭhakathā` reads as one typeface
rather than two, and it is identical on every platform.

Step 2 does not remove the handoff: Noto Sans Sinhala's source has no
dotted-below letters, so nothing can be subset in. Removing it entirely means
making Noto Sans the primary UI font with Sinhala as the fallback — which
`app_fonts.dart` already anticipates (`// Change this to uiEnglish for English
locale`). That shifts metrics app-wide and needs a visual pass; it is not part
of this.

## Cost to know before starting

The same script emits the woff2 the **static site** self-hosts, and app and
site must render Sinhala from one identical glyph set (CLAUDE.md). Re-running
it changes the site's asset hashes, so the site needs a redeploy in the same
change. Measure the size delta before and after — the Sinhala subsets are the
largest assets in the app.
