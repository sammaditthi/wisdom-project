# Sutta references — plan

Started 2026-10-11. Part B and the reader's way back (Part C) done 2026-11-02. Part A done 2026-11-04, apart from A5, which is not started.

Typing "SN 15.3" opens that sutta, and research answers link their sources the same way. This doc holds everything about it. It replaces Task 11 of `search-pane-redesign-plan.md`, `sutta-references-standards-report.md` (2026-10-10) and `suttacentral-bjt-concordance-findings.md` (2026-06-27). The last two are deleted.

Three parts:

- **Part A — read the reference.** Turn what people type ("SN 15.3", "Dhp 5", "AN 3:65") into a SuttaCentral ID (`sn15.3`).
- **Part B — the lookup file.** Turn that ID into our BJT page, for the whole canon. Done: research citations open in the reader.
- **Part C — the way back.** The reader opens the text it shows on SuttaCentral, from the Share menu. Done.

## Rules (decided)

- **One numbering: SuttaCentral's.** A reference opens the BJT sutta that SuttaCentral's number points to. Bodhi's translations use the same numbers. Old PTS numbers for a few SN and AN suttas are ignored.
- **One table of book names for the whole project:** the app, the research Worker and anything later. No other list anywhere.
- **The normal search always runs.** A reference only adds the jump row on top; a local result is never lost. No "reference mode" (2026-10-10).
- **A reference with no BJT page opens nothing.** Never the nearest page instead.
- The table is a `const` in `wisdom_shared`, not a JSON asset: no new static files on the app side (2026-10-06).
- SuttaCentral is the main source (2026-10-10). Checked that day against SuttaCentral, Access to Insight, the PTS standard (Critical Pāli Dictionary), Bhikkhu Bodhi and dhammatalks.org: the 14 books accepted today match SuttaCentral letter for letter.

## How it works today

- The one table is `canonBooks` (`packages/wisdom_shared/lib/src/refs/canon_books.dart`).
- `SuttaCentralRefResolver` (`suttacentral_ref_resolver.dart`, next to it): `parseRef` reads "SN 15.3" as `sn15.3` from the table; `displayRef` writes it back; `nodeKeyForUid` looks the ID up in `assets/data/sc-to-bjt.json`, exactly; `uidToOpen` adds the range fallback (A3) for search; `suttaCentralUrl` goes the other way (Part C). `SuttaCentralRefResolver.fromJson` reads the asset. The app loads it once (`suttacentral_provider.dart`) for search, research and the reader.
- Search: `referenceSearchResultProvider` adds the jump row. `singlishPreviewText` (`lib/core/utils/search_query_utils.dart`) hides the Singlish preview by the A4 table.
- Typed punctuation no longer breaks the normal search (2026-10-29). `:` and `?` split words like `.` does, in the query, tree names and page text (`_wordBreakChars`, `lib/core/utils/text_utils.dart`), so "SN 15:3" reads "SN 15 3" and "15:3" never becomes "153". `'` is stripped. `~` was already safe: it is dropped after the Singlish conversion. FTS words are still sent unquoted; quoting them would let a row match that the highlighter cannot find.
- Research: the research Worker (`research_server/`, on Cloudflare) sends each citation's `uid` and a display `ref`. The app shows `ref` as sent and opens the `uid` through `nodeKeyForUid`; when that fails, the source sheet says "This source isn't linked to this edition yet." Since Part B that is only `unmatched.txt`'s research list.
- The research Worker keeps its own list (`NIKAYAS` in `research_server/src/refs.ts`), and `refFromUid` capitalises every book. So answers show "DHP 1-20" and "THAG 1.1", and Vinaya citations show raw IDs like `pli-tv-bu-vb-pj1`.

## Part A — read the reference

**A1. One table.** Abbreviation → SuttaCentral ID prefix + display name, next to the resolver. It replaces `knownBooks` and `_displayBook`, so `displayRef('kp1')` gives "Kp 1", not "KP 1".

- Sutta: DN, MN, SN, AN, Kp, Dhp, Ud, Iti, Snp, Vv, Pv, Thag, Thig, Tha Ap, Thi Ap, Bv, Cp, Ja, Mnd, Cnd, Ps, Ne, Pe.
- Abhidhamma: Ds, Vb, Dt, Pp, Kv, Ya, Patthana.
- Vinaya: Kd → `pli-tv-kd`, Pvr → `pli-tv-pvr`; the monks' rule books Bu Pj, Ss, Ay, Np, Pc, Pd, Sk, As → `pli-tv-bu-vb-pj` …; the nuns' Bi Pj, Ss, Np, Pc, Pd, Sk, As → `pli-tv-bi-vb-pj` ….
- Other spellings open the same book: Khp → Kp, Nm → Mnd, Nc → Cnd, It → Iti.
- Not in the table, because they would open nothing: Mil (BJT has no Milindapañha), KN, Nd (Mnd or Cnd?), Cv and Mv (old Vinaya style), the commentaries DhpA, KhpA, ThagA and ThigA (SuttaCentral has none), and the single letters A, D, M and S. They are listed in a comment under the table, with how to add one (2026-11-04). They stay Singlish words.
- "Sn" means SN, because case is ignored, as on SuttaCentral. Sutta Nipāta is "Snp": SuttaCentral's ID is `snp1.8`, shown "Snp 1.8". Access to Insight, dhammatalks.org and Wikipedia write "Sn".
- "Ps" is the Paṭisambhidāmagga, as on SuttaCentral. PTS uses "Ps" for the Majjhima commentary.
- Never build a tree key from an abbreviation: in `tree.json`, `ap` is the Abhidhamma and `vp-pv` the Parivāra.

**A2. `parseRef` reads more forms.**

- A colon works like a dot: "SN 15:3" = "SN 15.3". Bodhi and dhammatalks.org write colons.
- A book name may have one space: "Tha Ap 1" → `tha-ap1`, "Bu Pj 1" → `pli-tv-bu-vb-pj1`.
- A range as SuttaCentral writes it: "Dhp 1-20" → `dhp1-20`, so a jump row's label opens again when typed or pasted. A range the map doesn't have ("Dhp 1-5") opens nothing (2026-11-05).

**A3. One number inside a range.** SuttaCentral gives some texts one ID for a run of numbers: `dhp1-20` is the Dhammapada's first chapter (verses 1 to 20). Others are `an1.1-10` and `sn56.129-130`. People cite a single verse, "Dhp 5", and no `dhp5` ID exists. BJT also has one page for the whole chapter (`kn-dhp-1`, යමකවග්ගො).

So: look up the exact ID first. If it's missing, find the range of the same book that holds the number (`dhp1-20`) and open that. The ranges are read from the lookup file's own keys, so no extra list is needed.

The jump row names what opens: "Dhp 5" shows "Dhp 1-20" (decided 2026-11-04).

**A4. When the Singlish preview hides** (`singlishPreviewText`):

| Typed | Preview | Saved to recent searches |
| --- | --- | --- |
| Book + number, any case ("SN 15.3", "sn15.3", "AN 3:65", "dhp 5") | Hidden | As typed |
| Book alone, with at least one capital ("SN", "Dhp", "Sn") | Hidden | As typed |
| All lowercase ("an", "sn", "dhp") | Shown: it's Singlish | As Sinhala |

- Only books in the table count. KN, Nd, the single letters and the other names left out of it keep their preview.
- Saving a reference as typed loses nothing: running "an 3" again converts it again, while a saved "අන් 3" would lose the jump.
- Why this is enough (measured 2026-10-10 on `bjt.db`, `dict.db` and `tree.json`, all six match modes): a capitalised book plus a number finds nothing in the default match mode. In "near" and "anywhere" a few do ("A 3.65", "Pe 1"), and those hits still show because the normal search runs. Capital S, M, C, U, V and J have no Singlish letter, so "SN" converts to "Sණ්", which matches nothing. A few rare Singlish words start like a book (AN → ඇණ, Ne → ණෙ, Pe → ඵෙ, Thag → ථග); their preview hides for one keystroke and returns with the next letter. Our search boxes don't turn on auto-capitals, so phones type lowercase. No corpus test needed.

**A5. The research Worker uses the same table.** `NIKAYAS` and the capitalising in `refFromUid` go. Display names and the prose matcher (which must take "SN 15:3" too, not link it as "SN 15") come from the one table. How is open: see "To decide", item 1. Separate commit; the user decides when to deploy the worker.

## Part B — the lookup file

`assets/data/sc-to-bjt.json`, built by `python3 tools/suttacentral_map/build_map.py`. Nothing in it is hand-edited: change the builder and re-run it.

**Why it can't be a formula.**

- No source has the mapping. The tipitaka.lk project has no SuttaCentral IDs, and neither has our `tree.json`.
- Each book nests differently in BJT: SN has book → saṁyutta → vagga → sutta (`sn-2-3-1-3`), DN vagga → sutta (`dn-1-1`), MN paṇṇāsaka → vagga → sutta. A Dhp chapter is one node (`kn-dhp-1`). AN 1 splits finer than SuttaCentral (`an-1-1-1` … where SuttaCentral has `an1.1-10`).
- BJT puts SN 12 and SN 13 in one node, `sn-2-1`, titled for SN 13 but starting with SN 12.1. So positions shift, and saṁyutta titles can't be trusted.
- Peyyāla: SuttaCentral often abbreviates a run of suttas into one range (`sn24.20-35`) that BJT spells out node by node, and sometimes the other way round.
- Titles differ between the editions more than expected (SN 15.4 Khīra is මාතුථඤ්ඤසුත්තං in BJT), so they can't be the main signal.

**How it pairs (decided 2026-11-02).** SuttaCentral does publish BJT page numbers: bilara-data's `reference/` files mark each BJT page break on its segments, `bj<volume>.<page>` (`bj17.1.2` for a split volume), and those pages are the `pageNum`s in our `assets/text` files. That is the independent signal, so no title list is needed:

- Per book, SuttaCentral's texts in its order are aligned with BJT's text-bearing nodes in reading order: the heaviest chain of pairs whose pages agree, titles breaking ties. A range gets one slot per sutta it covers, so it has to line up with BJT's spelled-out nodes.
- A text's page is the marker on its first segment, or the page the text before it ended on. A text with no marker of its own that opens a new volume may also start on the page before its first marker.
- Between pairs: a text runs on over the BJT nodes after it while they sit within its pages (or as many as its range counts). A text with no node of its own sits inside the node before it, if its page agrees. What is left pairs on page and title regardless of order; Jātaka 542 and 543 are ordered differently in the two editions.
- BJT keeps text in some parents too (a Vinaya rule before its case stories), so a parent whose own text runs past its heading counts as a node.
- A SuttaCentral division (vagga, saṁyutta, nipāta, the book) maps to the BJT node holding exactly its texts. A BJT-only sutta inside doesn't stop it; a node mixing two divisions (`sn-2-1`) gets none.

**What the builder reads.** All pinned, so two runs give the same bytes:

- bilara-data at the research store's snapshot (`published@ce5b98f`, `docs/done/canon-sources/sc-sync-ingest.md`): the page markers, the Pali names of texts and divisions, and the file lists of the root text and the two ingested translations.
- sc-data (pinned in `sc_source.py`): SuttaCentral's navigation tree, and its legacy translations, where Bhikkhu Bodhi's are.
- Ours: `tree.json` and `assets/text`. It clones what it needs into `tools/suttacentral_map/.cache/` (ignored), so it needs nothing on the Desktop.

**What the file holds.**

- `map`: SuttaCentral ID → BJT node, texts and divisions, in SuttaCentral's order. A range maps to the node holding the whole range when one does, else to where it starts. Root text only, never an `atta-` node. No BJT node holds it → no entry.
- `reverse`: BJT node → SuttaCentral ID, for the nodes `map` doesn't name the right way round (a node inside a range, or one a division shares with its single text, where the text wins).
- `english`: the uids whose link opens a translation, by translator. The reader prefers Bhikkhu Bodhi, then Bhikkhu Sujato, or Ajahn Brahmali for the Vinaya. Anything else opens SuttaCentral's own page for it.
- `tools/suttacentral_map/unmatched.txt` lists what is in neither, with the reason, the research store's uids first. `review.txt` lists pairs whose titles differ, for a human to glance at.

**Keeping it right.**

- `verify_corpus_invariants.dart` section 7: every node the file names is in `tree.json`. It runs at every canon sync, but it can't see a key that still exists and now names another sutta.
- So when a sync changes `tree.json`, `sync-regen.sh` asks for a rebuild: re-run the builder and review the git diff of the file. The build is exact, so an empty diff means nothing moved.
- `.github/workflows/suttacentral-check.yml`, every Monday (and from the Actions tab): `check_upstream.py` reads SuttaCentral's file lists as they are today and fails when an ID the file names, or a translation the reader opens, is gone. Research citations keep working either way, because the store and this file are pinned together; what breaks is the reader's link. Then fix it in the builder (an alias for the moved ID; the builder has none yet), not by moving the pin.
- The repo is public, so GitHub pauses the schedule after 60 days without a commit. Turn it back on from the Actions tab.
- Moving the bilara-data pin only goes with a re-ingest of the store (`sc-sync-ingest.md` §2).

## Part C — the way back

The reader's Share menu has "Open on SuttaCentral" when the active tab's node has a counterpart there (`activeSuttaCentralUrlProvider`, `openOnSuttaCentral` in `reader_link_actions.dart`). It opens `suttacentral.net/<uid>/en/<translator>` for a text with a translation, else `suttacentral.net/<uid>`, which for a division is SuttaCentral's list of its suttas. No counterpart, a commentary tab, or a BJT node mixing two of SuttaCentral's divisions: the row isn't shown. Never the nearest page instead.

## Steps

1. A1, A2, A3 and A4: the table, the new forms, a number inside a range, the preview rule. A3 moved here from step 2: research citations carry exact IDs, so only typed references need it. **Done 2026-11-04.** Handover: `canonBooks` replaced `knownBooks` and `_displayBook`. `parseRef` builds "table prefix + number". `displayRef` takes the book whose prefix is followed by a digit, so `snp1.8` is never SN. `isBookName` serves the A4 rule. `uidToOpen` is the range fallback, and only the jump row calls it. On a miss it scans the map's own keys (about 50 µs on the real map), so there is no index, and a resolver made with the plain const constructor has the fallback too. Checked against the real lookup file: every "Done when" case, and every numbered ID that isn't a range reads back to itself through `displayRef` then `parseRef`. Unit tests written 2026-11-05.
2. Part B: the builder and the full lookup file. **Done 2026-11-02**, with Part C and the weekly check. Handover: research citations open for the whole canon; the reader links back. The resolver gained `fromJson` and `suttaCentralUrl`, and lost the unused `resolveToNodeKey` and `isReady`. The new two are covered by the map-file test (`suttacentral_concordance_datasource_test.dart`) and the Share menu test (`reader_share_menu_test.dart`); `wisdom_shared` has no unit tests for them yet.
3. A5: the research Worker on the one table. Its own commit.

The test agent writes the unit tests (CLAUDE.md). Add a handover note under each step when it's done.

## To decide

1. **How the research Worker shares the one table.** TypeScript can't import Dart. The Worker uses book names twice: for the `ref` it sends with each citation, and to find references the model writes in its answer (`REF_IN_PROSE`). Two ways:
   - The Dart table stays the source, and a small tool writes a generated TypeScript copy for the worker.
   - The app writes `ref` itself from the `uid` (it already has the table), and finding references in the answer moves to the app too. The Worker then needs no book names, but the answer format changes.
2. **Optional, static site.** "SN 15.3" in the site's search dialog could open the BJT page. Cost: the lookup file as extra rows in `search-index.json`, plus a small reference parser in `site.js`. The parser holds only Latin letters and digits, so "no Sinhala, no URLs in site.js" still holds. Do it only while it stays small; the lookup file now covers the whole canon, so check its size first.

## Not supported

Edge cases, left out on purpose: old PTS numbers, PTS volume/page references ("S II 178"), and PTS verse numbers for Sn and Th ("Sn 143").

## Done when

- [x] "SN 15.3", "sn15.3", "SN 15:3", "Dhp 5", "Dhp 1-20", "Tha Ap 1" and "AN 3.65" show no preview, are saved as typed, and open their BJT page.
- [x] "SN", "Dhp" and "Thag" alone show no preview. "an", "sn", "a", "s", "m" and "KN" alone show theirs.
- [x] `displayRef('kp1')` is "Kp 1".
- [ ] Research answers show "Dhp 1-20", not "DHP 1-20", and "Bu Pj 1", not `pli-tv-bu-vb-pj1` (A5).
- [x] The lookup file covers Sutta, Abhidhamma and Vinaya, apart from what `unmatched.txt` lists with a reason. Every value exists in `tree.json`.
- [x] The reader opens the text it shows on SuttaCentral, Bhikkhu Bodhi's translation first, and a weekly check says when SuttaCentral moves a page it links to.
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
