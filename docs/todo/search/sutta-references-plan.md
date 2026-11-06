# Sutta references — plan

Started 2026-10-11. Part B and the reader's way back (Part C) done 2026-11-02. Part A done 2026-11-04, and A5 2026-11-05; the research Worker isn't deployed with it yet. The research store's names for range texts fixed 2026-11-06 (step 4), and research opens a range the way search does (step 5). Research answers show each source once per paragraph, and "AN 1.1" beside a cited AN 1.1-10 is one chip (step 6, 2026-11-06); that also waits for the Worker deploy.

Typing "SN 15.3" opens that sutta, and research answers link their sources the same way. This doc holds everything about it. It replaces Task 11 of `search-pane-redesign-plan.md`, `sutta-references-standards-report.md` (2026-10-10) and `suttacentral-bjt-concordance-findings.md` (2026-06-27). The last two are deleted.

Three parts:

- **Part A — read the reference.** Turn what people type ("SN 15.3", "Dhp 5", "AN 3:65") into a SuttaCentral ID (`sn15.3`).
- **Part B — the lookup file.** Turn that ID into our BJT page, for the whole canon. Done: research citations open in the reader.
- **Part C — the way back.** The reader opens the text it shows on SuttaCentral, from the Share menu. Done.

## Rules (decided)

- **One numbering: SuttaCentral's.** A reference opens the BJT sutta that SuttaCentral's number points to. Bodhi's translations use the same numbers. Old PTS numbers for a few SN and AN suttas are ignored.
- **One table of book names for the whole project:** the app, the research Worker and anything later. The Worker can't import Dart, so it keeps a hand copy, and a one-line comment on each side says to change both. No generator tool (2026-11-05). No other list anywhere.
- **The normal search always runs.** A reference only adds the jump row on top; a local result is never lost. No "reference mode" (2026-10-10).
- **A reference with no BJT page opens nothing.** Never the nearest page instead.
- The table is a `const` in `wisdom_shared`, not a JSON asset: no new static files on the app side (2026-10-06).
- SuttaCentral is the main source (2026-10-10). Checked that day against SuttaCentral, Access to Insight, the PTS standard (Critical Pāli Dictionary), Bhikkhu Bodhi and dhammatalks.org: the 14 books accepted today match SuttaCentral letter for letter.

## How it works today

- The one table is `canonBooks` (`packages/wisdom_shared/lib/src/refs/canon_books.dart`).
- `SuttaCentralRefResolver` (`suttacentral_ref_resolver.dart`, next to it): `parseRef` reads "SN 15.3" as `sn15.3` from the table; `displayRef` writes it back; `nodeKeyForUid` looks the ID up in `assets/data/sc-to-bjt.json`, exactly; `resolve` adds the range fallback (A3), and search and research both open through it; `suttaCentralUrl` goes the other way (Part C). `SuttaCentralRefResolver.fromJson` reads the asset. The app loads it once (`suttacentral_provider.dart`) for search, research and the reader.
- Search: `referenceSearchResultProvider` adds the jump row. `singlishPreviewText` (`lib/core/utils/search_query_utils.dart`) hides the Singlish preview by the A4 table.
- Typed punctuation no longer breaks the normal search (2026-10-29). `:` and `?` split words like `.` does, in the query, tree names and page text (`_wordBreakChars`, `lib/core/utils/text_utils.dart`), so "SN 15:3" reads "SN 15 3" and "15:3" never becomes "153". `'` is stripped. `~` was already safe: it is dropped after the Singlish conversion. FTS words are still sent unquoted; quoting them would let a row match that the highlighter cannot find.
- Research: the research Worker (`research_server/`, on Cloudflare) sends each citation's `uid` and a display `ref`. The app opens the `uid` through `resolve`, so "AN 1.1" written in an answer opens AN 1.1-10. The source sheet shows `ref` as sent, or the range's name when the range opens instead, like the jump row: "Dhp 5" shows "Dhp 1-20". When nothing opens, it says "This source isn't linked to this edition yet." Since step 4 that is only `unmatched.txt`'s research list.
- The research Worker's hand copy is `BOOKS` in `research_server/src/refs.ts`. `refFromUid` writes each citation's `ref` from it ("Dhp 1-20", "Bu Pj 1"). `REF_IN_PROSE` finds references in the answer by the same names, so "SN 15:3" and "Tha Ap 1" link whole; it keeps their case, so "an 8" in English stays a word. A reference found in the answer shows as `refFromUid` writes it, not as the model typed it. Each source shows once per paragraph, and a reference inside a range the store cites shows as that range (step 6).

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

**A3. One number inside a range.** SuttaCentral gives some texts one ID for a run of numbers: `dhp1-20` is the Dhammapada's first chapter (verses 1 to 20). Others are `an1.1-10` and `sn56.129-130`. People cite a single verse, "Dhp 5", and no `dhp5` ID exists. A research answer does too: the model writes "AN 1.1" (step 5). BJT also has one page for the whole chapter (`kn-dhp-1`, යමකවග්ගො).

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

**A5. The research Worker uses the same table,** as a hand copy (decided 2026-11-05). Display names and the prose matcher come from it, so the matcher takes "SN 15:3" whole, not as "SN 15". Separate commit; the user decides when to deploy the Worker.

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

1. A1, A2, A3 and A4: the table, the new forms, a number inside a range, the preview rule. A3 moved here from step 2. **Done 2026-11-04.** Handover: `canonBooks` replaced `knownBooks` and `_displayBook`. `parseRef` builds "table prefix + number". `displayRef` takes the book whose prefix is followed by a digit, so `snp1.8` is never SN. `isBookName` serves the A4 rule. `uidToOpen` is the range fallback (`resolve` since step 5). On a miss it scans the map's own keys (about 50 µs on the real map), so there is no index, and a resolver made with the plain const constructor has the fallback too. Checked against the real lookup file: every "Done when" case, and every numbered ID that isn't a range reads back to itself through `displayRef` then `parseRef`. Unit tests written 2026-11-05.
2. Part B: the builder and the full lookup file. **Done 2026-11-02**, with Part C and the weekly check. Handover: research citations open for the whole canon; the reader links back. The resolver gained `fromJson` and `suttaCentralUrl`, and lost the unused `resolveToNodeKey` and `isReady`. The new two are covered by the map-file test (`suttacentral_concordance_datasource_test.dart`) and the Share menu test (`reader_share_menu_test.dart`); `wisdom_shared` has no unit tests for them yet.
3. A5: the research Worker on the one table. Its own commit. **Done 2026-11-05, not deployed.** Handover: `BOOKS` in `refs.ts` replaced `NIKAYAS`. `refFromUid` and `uidFromRef` mirror `displayRef` and `parseRef`. `knownUid` is gone: `uidFromRef` only returns a book from the table, so the shape check had nothing left to drop. Checked with a scratch script against the lookup file: every numbered uid reads back to itself, apart from the chapter uid `an2-balavagga2`, as on the Dart side. The Worker has no tests.
4. The research store's names for range texts. **Done 2026-11-06.** Handover: the ingest took each uid from the file's first line, so a range file went into the store under its first verse: `dhp1-20` as `dhp1`, `sn34.46-49` as `sn34.46`. On 2026-11-05 that was 99 files (95 Sujato, 4 Brahmali). The lookup file has only the real uids, so those citations said "This source isn't linked to this edition yet", and the Worker wrote "Dhp 1". `load_unit` (`tools/research_ingest/ingest.py`) now takes the uid from the file name. The heading check still uses the first line's uid, because the lines are keyed by the first verse. The dry run changed those 99 names and nothing else, text included. The 99 were uploaded under the new names, then the old 99 deleted by a one-off script, not added to the ingest; the store's document count is the same as before. Checked with one live call: a Dhammapada question cites `dhp1-20` as "Dhp 1-20". The Worker and the app didn't change.
5. Research opens a range the way search does. **Done 2026-11-06.** Handover: a reference the model writes in its answer ("AN 1.1") becomes a citation with that uid, and the source sheet looked it up exactly, so it said "not linked" while the store's own citation, `an1.1-10`, opened. `uidToOpen` became `resolve`, which returns the uid that opens and its node; the jump row and the source sheet both call it. The sheet names what opens, as the jump row does: "AN 1.1" opens and names "AN 1.1-10"; a citation that opens its own uid keeps the `ref` the Worker sent. `nodeKeyForUid` stays as the exact lookup. Tests: `resolve` in `suttacentral_ref_resolver_test.dart`, and the sheet's first widget test (`citation_source_sheet_test.dart`), each checked by putting the old code back in a scratch copy.
6. Research chips: each source once per paragraph, and a reference inside a cited range is that range. **Done 2026-11-06, not deployed.** Handover: a source showed a chip after every sentence it supported and on every reference the model wrote, and the model's "AN 1.1" beside the store's `an1.1-10` gave two chips for one text. An answer still takes its chips from one path only: the model's references, or the injected ones when it wrote none. In `research_server/src/pipeline.ts`, `firstInParagraph` keeps the first chip of each source per paragraph, with paragraphs split as the app's `_parseBlocks` splits them (`paragraphStarts`; a comment on each side says change both). A repeat in brackets goes, with its separator, and the brackets go once empty. A repeat the sentence needs ("as AN 1.1 says") stays as the model's words. Bold or italic marks round a reference (`*`, `**`, `***`) go with it when it becomes a chip or leaves a bracket, so "(**MN 138**)" counts as a bracket like any other; the model writes that form in the saved chats. A repeat kept as words keeps its marks. `citedHolding` (`refs.ts`, a hand copy of `resolve`) turns a reference the model wrote into the range the store cites, so `an1.1` is no longer a citation of its own. Checked in a scratch harness: with the new steps switched off, the output is byte-identical to HEAD. Replaying the 23 saved Mac-app chats, no paragraph lost a source, none shows one twice, and no bracket of references is left without a chip (3 were before the bold step). Bench worst case, cold, about 7.9 ms (HEAD 6.9 ms, budget 10 ms); `test.sh` passes. Two live calls (the Dhammapada question, Fast). In the first, the first model gave a 503 and the second answered with no retrieved sources, so no chips. In the second, "MN 128" became one chip; the model wrote "Dhammapada verses 3-5" in words, which isn't a reference, so Dhp 1-20 showed under Other sources only, as before. Neither answer had a repeat to drop, so the manual check below is still the real test. That call's log read `build=10.8ms` on a freshly started Node server; the same answer timed on its own costs about 2.7 ms cold (HEAD about 2.0 ms). The Worker has no tests.

The test agent writes the unit tests (CLAUDE.md). Add a handover note under each step when it's done.

## To decide

1. **Optional, static site.** "SN 15.3" in the site's search dialog could open the BJT page. Cost: the lookup file as extra rows in `search-index.json`, plus a small reference parser in `site.js`. The parser holds only Latin letters and digits, so "no Sinhala, no URLs in site.js" still holds. Do it only while it stays small; the lookup file now covers the whole canon, so check its size first.
2. **Follow-up: ranges written with an en dash** (found 2026-11-06 in a saved research answer). The model wrote "SN 15.15–19". `NUMBER` in `research_server/src/refs.ts` and `_refPattern` in the Dart resolver read only a hyphen, so the answer shows an "SN 15.15" chip and a loose "–19". A pasted "Dhp 1–20" gets no jump row in search either. Two kinds: "Dhp 1–20" is a real ID (`dhp1-20`), so reading `–` as `-` opens it. "SN 15.15–19" is five separate texts with no ID for the run: decide between a chip for the first text and plain text. Change both copies.

## Not supported

Edge cases, left out on purpose: old PTS numbers, PTS volume/page references ("S II 178"), and PTS verse numbers for Sn and Th ("Sn 143").

## Manual check after the prod release

Once the research Worker and the app are on prod, check these on app.sammaditthi.net and on macOS. Move this doc to `docs/done/search/` only when every box is ticked.

**Research (new Worker)**

- [ ] Ask (Fast): "What does the Dhammapada say about overcoming hatred?" Chips read "Dhp 1-20", not "DHP 1-20" or "Dhp 1"; at most one per paragraph; no leftover "(Dhp 1-20)" in plain or bold text; not again under Other sources.
- [ ] Tap that chip: the sheet shows the English passage; Open in reader opens 1. යමකවග්ගො.
- [ ] Ask: "What does AN 1.1 teach?" One "AN 1.1-10" chip per paragraph, no separate "AN 1.1" chip; it opens 1. චිත්තපරියාදානවග්ගො.
- [ ] Ask: "What is the first pārājika rule for monks?" Chip "Bu Pj 1", not `pli-tv-bu-vb-pj1`; opens වෙරඤ්ජකණ්ඩො.
- [ ] Ask in Sinhala: "වෛරය සංසිඳවීම ගැන ධම්මපදය කියන්නේ කුමක්ද?" Same chip behaviour as the first check.
- [ ] Open a chat saved before the release (Recent): its chips still show and open.

**Search**

- [ ] "SN 15.3", "sn15.3", "SN 15:3", "AN 3.65", "Tha Ap 1": jump row on top, no Singlish preview, normal results still below; each opens its page.
- [ ] "Dhp 5": the row names "Dhp 1-20" and opens 1. යමකවග්ගො.
- [ ] "an" and "sn" alone show the Singlish preview; "SN" and "Dhp" don't. Recent searches keep "SN 15.3" as typed.

**Reader**

- [ ] AN 3.65 → Share → "Open on SuttaCentral" opens Bhikkhu Bodhi's translation; SN 15.3 opens Sujato's (SuttaCentral has no Bodhi for it). On a commentary tab the row isn't shown.

## Done when

- [x] "SN 15.3", "sn15.3", "SN 15:3", "Dhp 5", "Dhp 1-20", "Tha Ap 1" and "AN 3.65" show no preview, are saved as typed, and open their BJT page.
- [x] "SN", "Dhp" and "Thag" alone show no preview. "an", "sn", "a", "s", "m" and "KN" alone show theirs.
- [x] `displayRef('kp1')` is "Kp 1".
- [x] "AN 1.1" in a research answer opens AN 1.1-10, and its source sheet names "AN 1.1-10", as "Dhp 5" in search shows "Dhp 1-20" (step 5).
- [x] Research answers show "Dhp 1-20", not "DHP 1-20" or "Dhp 1", and "Bu Pj 1", not `pli-tv-bu-vb-pj1` (A5, step 4). Live once the Worker is deployed.
- [x] A research answer shows each source at most once per paragraph: a repeat in brackets goes, bold or not, one in the sentence stays as words, and "AN 1.1" beside a cited AN 1.1-10 is one "AN 1.1-10" chip (step 6). Live once the Worker is deployed.
- [x] The lookup file covers Sutta, Abhidhamma and Vinaya, apart from what `unmatched.txt` lists with a reason. Every value exists in `tree.json`.
- [x] The reader opens the text it shows on SuttaCentral, Bhikkhu Bodhi's translation first, and a weekly check says when SuttaCentral moves a page it links to.
- [x] No list of book names exists outside the one table and the Worker's hand copy of it.

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
