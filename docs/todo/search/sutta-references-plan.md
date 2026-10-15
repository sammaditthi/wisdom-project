# Sutta references — plan

Started 2026-10-11. Not started; nothing built yet.

Typing "SN 15.3" opens that sutta, and research answers link their sources the same way. This doc holds everything about it. It replaces Task 11 of `search-pane-redesign-plan.md`, `sutta-references-standards-report.md` (2026-10-10) and `suttacentral-bjt-concordance-findings.md` (2026-06-27). The last two are deleted.

Two parts, done together:

- **Part A — read the reference.** Turn what people type ("SN 15.3", "Dhp 5", "AN 3:65") into a SuttaCentral ID (`sn15.3`).
- **Part B — the lookup file.** Turn that ID into our BJT page. Today it covers SN 15 only, so every other reference opens nothing. Part A alone changes little for users; Part B is what makes references open.

## Rules (decided)

- **One numbering: SuttaCentral's.** A reference opens the BJT sutta that SuttaCentral's number points to. Bodhi's translations use the same numbers. Old PTS numbers for a few SN and AN suttas are ignored.
- **One table of book names for the whole project:** the app, the research server and anything later. No other list anywhere.
- **The normal search always runs.** A reference only adds the jump row on top; a local result is never lost. No "reference mode" (2026-10-10).
- **A reference with no BJT page opens nothing.** Never the nearest page instead.
- The table is a `const` in `wisdom_shared`, not a JSON asset: no new static files on the app side (2026-10-06).
- SuttaCentral is the main source (2026-10-10). Checked that day against SuttaCentral, Access to Insight, the PTS standard (Critical Pāli Dictionary), Bhikkhu Bodhi and dhammatalks.org: the 14 books accepted today match SuttaCentral letter for letter.

## How it works today

- `SuttaCentralRefResolver` (`packages/wisdom_shared/lib/src/refs/suttacentral_ref_resolver.dart`): `parseRef` reads "SN 15.3" as `sn15.3` for the books in `knownBooks`; `displayRef` writes it back using `_displayBook`; `resolveToNodeKey` and `nodeKeyForUid` look the ID up in `assets/data/sc-to-bjt.json`.
- Search: `referenceSearchResultProvider` adds the jump row. `singlishPreviewText` (`lib/core/utils/search_query_utils.dart`) hides the Singlish preview when `parseRef` reads a reference.
- Research: the server (`research_server/`, the live Cloudflare Worker) sends each citation's `uid` and a display `ref`. The app shows `ref` as sent and opens the `uid` through `nodeKeyForUid`; when that fails, the source sheet says "This source isn't linked to this edition yet."
- The research server keeps its own list (`NIKAYAS` in `research_server/src/refs.ts`), and `refFromUid` capitalises every book. So answers show "DHP 1-20" and "THAG 1.1", and Vinaya citations show raw IDs like `pli-tv-bu-vb-pj1`.

## Part A — read the reference

**A1. One table.** Abbreviation → SuttaCentral ID prefix + display name, next to the resolver. It replaces `knownBooks` and `_displayBook`, so `displayRef('kp1')` gives "Kp 1", not "KP 1".

- Sutta: DN, MN, SN, AN, Kp, Dhp, Ud, Iti, Snp, Vv, Pv, Thag, Thig, Tha Ap, Thi Ap, Bv, Cp, Ja, Mnd, Cnd, Ps, Ne, Pe, Mil.
- Abhidhamma: Ds, Vb, Dt, Pp, Kv, Ya, Patthana.
- Vinaya: Kd → `pli-tv-kd`, Pvr → `pli-tv-pvr`; the monks' rule books Bu Pj, Ss, Ay, Np, Pc, Pd, Sk, As → `pli-tv-bu-vb-pj` …; the nuns' Bi Pj, Ss, Np, Pc, Pd, Sk, As → `pli-tv-bi-vb-pj` ….
- Other spellings open the same book: Khp → Kp, Miln → Mil, Nm → Mnd, Nc → Cnd, It → Iti.
- Kept, but open nothing (every Access to Insight entry stays, 2026-10-06): KN, Nd (Mnd or Cnd?), Cv and Mv (old Vinaya style), the commentaries DhpA, KhpA, ThagA and ThigA (SuttaCentral has none), and the single letters A, D, M and S.
- "Sn" means SN, because case is ignored, as on SuttaCentral. Sutta Nipāta is "Snp": SuttaCentral's ID is `snp1.8`, shown "Snp 1.8". Access to Insight, dhammatalks.org and Wikipedia write "Sn".
- "Ps" is the Paṭisambhidāmagga, as on SuttaCentral. PTS uses "Ps" for the Majjhima commentary.
- Never build a tree key from an abbreviation: in `tree.json`, `ap` is the Abhidhamma and `vp-pv` the Parivāra.

**A2. `parseRef` reads more forms.**

- A colon works like a dot: "SN 15:3" = "SN 15.3". Bodhi and dhammatalks.org write colons.
- A book name may have one space: "Tha Ap 1" → `tha-ap1`, "Bu Pj 1" → `pli-tv-bu-vb-pj1`.

**A3. One number inside a range.** SuttaCentral gives some texts one ID for a run of numbers: `dhp1-20` is the Dhammapada's first chapter (verses 1 to 20). Others are `an1.1-10` and `sn56.129-130`. People cite a single verse, "Dhp 5", and no `dhp5` ID exists. BJT also has one page for the whole chapter (`kn-dhp-1`, යමකවග්ගො).

So: look up the exact ID first. If it's missing, find the range of the same book that holds the number (`dhp1-20`) and open that. The ranges are read from the lookup file's own keys, so no extra list is needed.

**A4. When the Singlish preview hides** (`singlishPreviewText`):

| Typed | Preview | Saved to recent searches |
| --- | --- | --- |
| Book + number, any case ("SN 15.3", "sn15.3", "AN 3:65", "dhp 5") | Hidden | As typed |
| Book alone, with at least one capital ("SN", "Dhp", "Sn") | Hidden | As typed |
| All lowercase ("an", "sn", "dhp") | Shown: it's Singlish | As Sinhala |

- Only books that open something count. KN, Nd, the single letters and the other "open nothing" entries keep their preview.
- Saving a reference as typed loses nothing: running "an 3" again converts it again, while a saved "අන් 3" would lose the jump.
- Why this is enough (measured 2026-10-10 on `bjt.db`, `dict.db` and `tree.json`, all six match modes): a capitalised book plus a number finds nothing in the default match mode. In "near" and "anywhere" a few do ("A 3.65", "Pe 1"), and those hits still show because the normal search runs. Capital S, M, C, U, V and J have no Singlish letter, so "SN" converts to "Sණ්", which matches nothing. A few rare Singlish words start like a book (AN → ඇණ, Ne → ණෙ, Pe → ඵෙ, Thag → ථග); their preview hides for one keystroke and returns with the next letter. Our search boxes don't turn on auto-capitals, so phones type lowercase. No corpus test needed.

**A5. The research server uses the same table.** `NIKAYAS` and the capitalising in `refFromUid` go. Display names and the prose matcher (which must take "SN 15:3" too, not link it as "SN 15") come from the one table. How is open: see "To decide", item 2. Separate commit; the user decides when to deploy the worker.

## Part B — the lookup file

`assets/data/sc-to-bjt.json`: SuttaCentral ID → BJT node key. Today it holds SN 15, checked by hand. Part B builds it for the whole canon with a tool, `tools/suttacentral_map/`, modelled on `tools/mahamevnawa_map/build_map.py`: propose pairs by position, confirm each one against an independent signal, drop any pair the signal contradicts, and write the rest to `unmatched.txt` with a reason.

**Why it can't be a formula.**

- No source has the mapping. The tipitaka.lk project has no SuttaCentral IDs, and neither has our `tree.json`.
- Each book nests differently in BJT:
  - SN: book → saṁyutta → vagga → sutta (`sn-2` → `sn-2-3` → `sn-2-3-1` → `sn-2-3-1-3`). The vagga level inside each saṁyutta is always there.
  - DN: vagga → sutta (`dn-1-1`). MN: paṇṇāsaka → vagga → sutta.
  - Dhp: each chapter is one page (`kn-dhp-1`).
  - AN 1: BJT splits finer than SuttaCentral (`an-1-1-1`, `an-1-1-2` … where SuttaCentral has `an1.1-10`).
- BJT puts SN 12 and SN 13 in one node, `sn-2-1`. It is titled අභිසමයසංයුත්තං (SN 13) but starts with පටිච්චසමුප්පාදසුත්තං (SN 12.1), and SN 13 is its tenth vagga. So from SN 14 on the positions shift by one, and saṁyutta titles can't be trusted.
- Expect drift where the text abbreviates repeats (peyyāla), as the Mahamevnawa build does.
- Sutta titles are the reliable check, but not exact. Two of SN 15's suttas have other names in BJT: SN 15.4 Khīra is මාතුථඤ්ඤසුත්තං, SN 15.10 Puggala is එකපුග්ගලසුත්තං. So keep a short hand-made list of such pairs, and flag a near-miss for review instead of dropping it.

**What the builder reads.**

- BJT: `assets/data/tree.json`, a flat map nodeKey → `[paliTitle, sinhalaTitle, level, [page, entry], parentKey, contentFileId]`. The Pali title is in Sinhala script. `parentKey` is `root` at the top. A leaf is a node that no other node names as its parent (`TipitakaTree.isLeaf`); `contentFileId` is set on every node, so it can't tell them apart.
- Gotchas: sort children by the number at the end, not as text (`-10` sorts before `-2`). Titles hold ZWJ (U+200D): strip it before comparing. Commentary nodes start with `atta-`: map to the plain node.
- SuttaCentral: the IDs, ranges and Pali titles of every book, Abhidhamma and Vinaya included, from `suttacentral.net/api/suttaplex/<book>`. The local `~/Desktop/Dev/bilara-data-readonly` has only the translations. SuttaCentral's titles are in Roman letters, BJT's in Sinhala script, so convert one before comparing.
- Check first: does SuttaCentral publish BJT page numbers (bilara-data's `reference/` folder)? An older plan said so; it was never checked. If it does, that is a stronger signal than titles.

**What the file holds.**

- Keys are SuttaCentral IDs exactly as SuttaCentral writes them, ranges included (`dhp1-20`). Research citations carry these IDs, so they open directly.
- The value is the BJT node that holds the text. A range maps to the node that holds the whole range.
- No BJT node holds it → no entry.
- Root text only, never an `atta-` node.

**Keeping it right.**

- Every value must be a key in `tree.json`. The check goes in `static_site_generator/tool/verify_corpus_invariants.dart`.
- `wisdom_shared` unit tests use a few copied rows, not the asset, so the package keeps building on its own.
- Re-run the builder when SuttaCentral's numbering changes (a bilara-data sync, see `sc-sync-ingest.md`) and when `tree.json` node keys change (a canon sync).

## Steps

1. A1, A2 and A4: the table, the new forms, the preview rule.
2. Part B: the builder and the full lookup file, with A3 in the resolver.
3. A5: the research server on the one table. Its own commit.

The test agent writes the unit tests (CLAUDE.md). Add a handover note under each step when it's done.

## To decide

1. **Some characters break every search.** Tested 2026-10-11 with sqlite3: a word with `:` fails ("no such column: 15" for `15:3*`), and `'`, `?` and `~` fail with a syntax error. `sanitizeSearchQuery` (`lib/core/utils/text_utils.dart`) strips a fixed list of characters that misses these four, and `buildFtsQuery` (`packages/wisdom_shared/lib/src/fts/fts_query_builder.dart`) sends words without quotes. Not a reference problem, but "SN 15:3" hits it. Two ways:
   - Add the four to the strip list. Small, but the next missed character breaks search again.
   - Quote each word in `buildFtsQuery`: `"15:3"*` works, so no character can break a search. One place, and the strip list stops mattering for errors.

   Not yet tried in the running app.
2. **How the research server shares the one table.** TypeScript can't import Dart. The server uses book names twice: for the `ref` it sends with each citation, and to find references the model writes in its answer (`REF_IN_PROSE`). Two ways:
   - The Dart table stays the source, and a small tool writes a generated TypeScript copy for the worker.
   - The app writes `ref` itself from the `uid` (it already has the table), and finding references in the answer moves to the app too. The server then needs no book names, but the answer format changes.
3. **Optional, static site.** "SN 15.3" in the site's search dialog could open the BJT page. Cost: the lookup file as extra rows in `search-index.json`, plus a small reference parser in `site.js`. The parser holds only Latin letters and digits, so "no Sinhala, no URLs in site.js" still holds. Do it only while it stays small; the full lookup file will be much bigger than today's seed.

## Not supported

Edge cases, left out on purpose: old PTS numbers, PTS volume/page references ("S II 178"), and PTS verse numbers for Sn and Th ("Sn 143").

## Done when

- [ ] "SN 15.3", "sn15.3", "SN 15:3", "Dhp 5", "Tha Ap 1" and "AN 3.65" show no preview, are saved as typed, and open their BJT page.
- [ ] "SN", "Dhp" and "Thag" alone show no preview. "an", "sn", "a", "s", "m" and "KN" alone show theirs.
- [ ] `displayRef('kp1')` is "Kp 1". Research answers show "Dhp 1-20", not "DHP 1-20", and "Bu Pj 1", not `pli-tv-bu-vb-pj1`.
- [ ] The lookup file covers Sutta, Abhidhamma and Vinaya, apart from what `unmatched.txt` lists with a reason. Every value exists in `tree.json`.
- [ ] No list of book names exists outside the one table.

## Appendix: abbreviations by source

| Book | App today | SuttaCentral | Access to Insight | PTS (CPD) | dhammatalks |
| --- | --- | --- | --- | --- | --- |
| Dīgha / Majjhima / Saṃyutta / Aṅguttara | DN MN SN AN | same | same (also D M S A) | D M S A | same |
| Khuddakapāṭha | — | Kp | Khp | Khp | Khp |
| Dhammapada, Udāna | Dhp, Ud | same | same | same | same |
| Itivuttaka | Iti | Iti | Iti | It | Iti |
| Sutta Nipāta | Snp | Snp | Sn | Sn | Sn |
| Vimānavatthu, Petavatthu | Vv, Pv | same | same | same | — |
| Thera/Therīgāthā | Thag, Thig | same | same | Th, Thī | same |
| Buddhavaṃsa, Cariyāpiṭaka | Bv, Cp | same | — | same | — |
| Apadāna | — | Tha Ap / Thi Ap | — | Ap | — |
| Jātaka | — | Ja | — | Ja | — |
| Mahā/Cūḷaniddesa | — | Mnd / Cnd | Nm / Nc | Nidd I / II | — |
| Paṭisambhidāmagga | — | Ps | — | Paṭis | — |
| Netti, Peṭakopadesa | — | Ne, Pe | — | Nett, Peṭ | — |
| Milindapañha | — | Mil | Miln | Mil | — |
| Abhidhamma (7 books) | — | Ds Vb Dt Pp Kv Ya Patthana | — | Dhs Vibh Dhātuk Pp Kv Yam Paṭṭh | — |
| Vinaya | — | Kd, Pvr, Bu Pj 1, Bi Pc 5 … | Mv, Cv | Vin + volume/page | — |

Separators: SuttaCentral and Access to Insight write a dot ("SN 15.3"); Bodhi and dhammatalks.org write a colon ("SN 15:3").

Sources:

- [Access to Insight: abbreviations and sutta numbers](https://www.accesstoinsight.org/abbrev.html)
- [Pali Text Society: abbreviations of Pali texts](https://palitextsociety.org/abbreviations/)
- [Critical Pāli Dictionary: abbreviations of texts](https://cpd.uni-koeln.de/intro/vol1_epileg_abbrev_texts)
- [SuttaCentral abbreviations (2016 mirror)](https://www.dhammatalks.net/suttacentral/sc2016/sc/abbreviations.html)
- [SuttaCentral sutta numbering (2016 mirror)](https://dhammatalks.net/suttacentral/sc2016/sc/sutta_numbering.html)
- [SuttaCentral forum: inconsistent SN numbering](https://discourse.suttacentral.net/t/inconsistent-numbering-of-sn-sutta-translations/15891)
- [SuttaCentral forum: looking up Bhikkhu Bodhi's citations](https://discourse.suttacentral.net/t/how-to-look-up-venerable-bodhis-citations-on-sutta-central/24767)
- dhammatalks.org: [SN 22:59](https://www.dhammatalks.org/suttas/SN/SN22_59.html), [Sn 1:8](https://www.dhammatalks.org/suttas/KN/StNp/StNp1_8.html)
- SuttaCentral API, `suttacentral.net/api/suttaplex/<book>`: the real IDs and display names
