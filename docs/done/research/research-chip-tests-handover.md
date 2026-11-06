# Research chip tests — handover

2026-11-06. For the test agent: write the tests below. No production code changes.

The research Worker (`research_server/`) turns the model's references into chips (`[[cite:uid]]`). Step 6 of `docs/todo/search/sutta-references-plan.md` (commit `c6b4490`) changed the rules: each source once per paragraph, a reference inside a cited range becomes that range, and the regex was made linear for the 10 ms CPU budget. Nothing tests any of it: the Worker has no tests, and `ResearchAnswerView` has no widget test.

## Rules

- Production code is read-only: nothing under `research_server/src/` or `lib/` changes. No exports or `@visibleForTesting` added for tests. If a test finds a bug, stop and report it.
- Test through public surfaces only: `buildResponse` (`research_server/src/pipeline.ts`), the `refs.ts` exports (`uidFromRef`, `refFromUid`, `citedHolding`, `REF_IN_PROSE`), and the `ResearchAnswerView` widget.
- No live calls. Never call `answer()`. The shared helper replaces `globalThis.fetch` with one that throws.
- Short comments only (CLAUDE.md). Sinhala text in Sinhala script; if you write `\u` escapes, dump the code points afterwards.
- `REF_IN_PROSE` has the `g` flag: use `String.match` or `matchAll`, never `.test()` (it keeps `lastIndex`).
- Leave everything uncommitted.

## Setup (no new packages)

Node's built-in runner (`node:test` with `node:assert/strict`), built the way the bench is built.

- `research_server/tsconfig.json`: add `"test/**/*.ts"` to `include`.
- `research_server/package.json`: `"test": "npm run build && node --test \"dist/test/**/*.test.js\""`. The glob needs Node 21 or later.
- `scripts/research_server/test.sh`: the `typecheck` step becomes `npm run build`, named "typecheck + build" (tsc typechecks and writes `dist/`, even on a type error). Then a new step, `run_step "unit tests"`, runs `node --test "dist/test/**/*.test.js"`. One compile, as today. Update the header's "There are no tests yet".
- `research_server/README.md`: add `npm test` to the Run block.
- The default shell has Node 18. Run `PATH=~/.nvm/versions/node/v22.2.0/bin:$PATH npm test`, or `./scripts/research_server/test.sh`, which picks Node 22 itself.

| File | Holds |
|---|---|
| `research_server/test/helpers.ts` | `respOf`, `chipsOf`, a copy of the app's paragraph rule for the invariants, the throwing `fetch` (installed on import) |
| `research_server/test/refs.test.ts` | §1 |
| `research_server/test/chips.test.ts` | §2, §3, §4 |
| `research_server/test/worst_case.test.ts` | §5 |
| `research_server/test/paragraphs.test.ts` | §6, Worker side |
| `test/fixtures/research_answer_paragraphs.json` | §6, read by both sides |
| `test/presentation/widgets/research/research_answer_view_test.dart` | §6, app side |

`respOf(store, supports = [], parts = 1)` builds a `GenerateResponse`: one grounding chunk per store uid (`retrievedContext: { title: uid, text: 'H\nbody' }`), `groundingSupports` from `{ end, idx }` pairs (`segment.endIndex` counts UTF-8 bytes), and `parts` entries in `content.parts` (the fallback skips multi-part answers). Call `buildResponse(text, respOf(...), 'q', false, 220)`.

## Cases

Every expected value below was checked against the Worker at `c6b4490` on 2026-11-06. Strings are JS literals.

### 1. Book table and ranges (`refs.test.ts`)

- `uidFromRef`: "SN 15.3", "SN 15:3" and "sn15.3" → `sn15.3`; "Tha Ap 1" → `tha-ap1`; "Bu Pj 1" → `pli-tv-bu-vb-pj1`; "Dhp 1-20" → `dhp1-20`; aliases "Khp 1" → `kp1`, "It 5" → `iti5`, "Nm 1" → `mnd1`, "Nc 1" → `cnd1`; "Mil 1" and "KN 1" → `null`.
- `refFromUid`: `kp1` → "Kp 1"; `pli-tv-bu-vb-pj1` → "Bu Pj 1"; `dhp1-20` → "Dhp 1-20"; `snp1.8` → "Snp 1.8" (not SN); `sn15.3` → "SN 15.3"; `pli-tv-bu-pm` comes back unchanged.
- `REF_IN_PROSE` keeps case: in `'Read an 8 page essay; AN 8 is apt. Tha Ap 1 and SN 15:3.'` the matches are exactly "AN 8", "Tha Ap 1", "SN 15:3".
- `citedHolding(uid, cited)`, with cited = `dhp1-20`, `dhp21-32`, `an1.1-10`, `sn15.3`, `sn1-nalavagga`. Same cases as the Dart `resolve` test (`packages/wisdom_shared/test/refs/suttacentral_ref_resolver_test.dart`):
  - `sn15.3` → itself
  - `dhp1` and `dhp20` → `dhp1-20`; `dhp21` → `dhp21-32`
  - `an1.1` and `an1.5` → `an1.1-10`
  - `null` for `dhp999`, `sn1.5` (a chapter uid isn't a range), `pli-tv-bu-pm` (no number) and `dhp1-5`
- Round trip over the lookup file `assets/data/sc-to-bjt.json` (its `map` keys): every uid ending in a digit gives `uidFromRef(refFromUid(uid)) === uid`, apart from the chapter uid `an2-balavagga2`. This catches `BOOKS` drifting from the lookup file. Open it with `new URL('../../../assets/data/sc-to-bjt.json', import.meta.url)`; the tests run from `research_server/dist/test/`.

### 2. Chips from the model's references (`chips.test.ts`)

| # | Input | Store | Expected `answer` | Citations | Shows |
|---|---|---|---|---|---|
| 1 | `Hatred never ceases by hatred (Dhp 5).` | `dhp1-20` | `Hatred never ceases by hatred [[cite:dhp1-20]].` | `dhp1-20` | a ref inside a cited range is that range |
| 2 | `X (SN 15.3). Y (SN 15.3), Z (SN 15.3) end.` | | `X [[cite:sn15.3]]. Y, Z end.` | `sn15.3` | a repeat in brackets goes, with the space before it |
| 3 | `X (SN 15.3; SN 15.3).` | | `X [[cite:sn15.3]].` | | |
| 4 | `X (AN 1.1). Y (MN 1; AN 1.1; DN 2).` | | `X [[cite:an1.1]]. Y [[cite:mn1]]; [[cite:dn2]].` | | the repeat's separator goes, the rest stay |
| 5 | `As SN 15.3 says, X (SN 15.3).` | | `As [[cite:sn15.3]] says, X.` | | |
| 6 | `X (SN 15.3). As SN 15.3 says, Y.` | | `X [[cite:sn15.3]]. As SN 15.3 says, Y.` | | a repeat in the sentence stays as words |
| 7 | `X (**MN 138**). Y (**MN 138**).` | | `X [[cite:mn138]]. Y.` | | |
| 8 | `**MN 138** says X. Later **MN 138** again.` | | `[[cite:mn138]] says X. Later **MN 138** again.` | | a chip drops the marks; a repeat keeps them |
| 9 | `X ***SN 15.3*** and (***SN 15.3***).` | | `X [[cite:sn15.3]] and.` | | |
| 10 | `text *(SN 15.3)* more.` | | `text *[[cite:sn15.3]]* more.` | | |
| 11 | `X (SN 15.3). Y (see SN 15.3).` | | `X [[cite:sn15.3]]. Y (see SN 15.3).` | | a bracket with words in it stays |
| 12 | `X (SN 15.3).\n\nY (SN 15.3).` | | `X [[cite:sn15.3]].\n\nY [[cite:sn15.3]].` | | a new paragraph gets its own chip |
| 13 | `- one (SN 15.3)\n- two (SN 15.3)\nafter bullet (SN 15.3)` | | `- one [[cite:sn15.3]]\n- two [[cite:sn15.3]]\nafter bullet [[cite:sn15.3]]` | | each bullet, and the line after one |
| 14 | `line one (SN 15.3)\nline two (SN 15.3)` | | `line one [[cite:sn15.3]]\nline two` | | soft-wrapped lines are one paragraph |
| 15 | `A (SN 15.3)\r\nB (SN 15.3)\r\n\r\nC (SN 15.3)` | | `A [[cite:sn15.3]]\r\nB\r\n\r\nC [[cite:sn15.3]]` | | |
| 16 | `A (SN 15.3) B \t(SN 15.3).` | | `A [[cite:sn15.3]] B.` | | |
| 17 | `Rule (Bu Pj 1). Verse (Tha Ap 1; Bu Pj 1).` | | `Rule [[cite:pli-tv-bu-vb-pj1]]. Verse [[cite:tha-ap1]].` | | |
| 18 | `X (**SN 15.3**and**AN 1.1**).` | | `X [[cite:sn15.3]]and[[cite:an1.1]].` | | review fix: was a wrong `sn15` chip |
| 19 | `X (Dhp 1-5).` | `dhp1-20` | `X [[cite:dhp1-5]].` | `dhp1-20`, `dhp1-5` | a range the model wrote stays its own |
| 20 | `X (SN 1.5).` | `sn1-nalavagga` | `X [[cite:sn1.5]].` | `sn1-nalavagga`, `sn1.5` | a chapter uid isn't a range |
| 21 | `Dhp 5 says hatred never ceases; Dhp 6 adds more.` | `dhp1-20` | `[[cite:dhp1-20]] says hatred never ceases; Dhp 6 adds more.` | `dhp1-20` | accepted: the chip names the range |
| 22 | `AN 1.1 says X (AN 1.1).` | | `[[cite:an1.1]] says X.` | `an1.1` | no range in the store: own uid |
| 23 | `X (Mil 5).` | | unchanged | none | not in the book table |
| 24 | `Read an 8 page essay (SN 15.3).` | | `Read an 8 page essay [[cite:sn15.3]].` | | |
| 25 | `වෛරයෙන් වෛරය නොසංසිඳේ (Dhp 5). නැවතත් (Dhp 5).` | `dhp1-20` | `වෛරයෙන් වෛරය නොසංසිඳේ [[cite:dhp1-20]]. නැවතත්.` | `dhp1-20` | |
| 26 | `Plain answer.` | | unchanged | none | |

### 3. Chips from grounding supports, the fallback (`chips.test.ts`)

It runs only when the model's text made no chip.

- **F1.** `First sentence here. Second sentence here.\n\nThird one.`, store `sn15.3`, `an1.1-10`, supports `{end: 20, idx: [0]}`, `{end: 42, idx: [0, 1]}`, `{end: 54, idx: [0]}` → `First sentence here.[[cite:sn15.3]] Second sentence here.[[cite:an1.1-10]]\n\nThird one.[[cite:sn15.3]]`.
- **F2.** `X (SN 15.3). Y.`, store `sn15.3`, `mn1`, support `{end: 15, idx: [1]}` → `X [[cite:sn15.3]]. Y.`, citations `sn15.3`, `mn1`. The text had a chip, so nothing is injected.
- **F3.** Two `content.parts`, `One. Two.`, store `sn15.3`, support `{end: 4, idx: [0]}` → unchanged.
- **F4.** Sinhala bytes. `s1 = 'වෛරයෙන් වෛරය නොසංසිඳේ.'`, `text = s1 + ' අවෛරයෙන් සංසිඳේ.'`, store `dhp1-20`, `sn15.3`, supports `{end: Buffer.byteLength(s1), idx: [0]}`, `{end: Buffer.byteLength(text), idx: [0, 1]}` → `s1 + '[[cite:dhp1-20]] අවෛරයෙන් සංසිඳේ.[[cite:sn15.3]]'`.
- **F5.** `Plain.`, store `sn15.3`, no supports → unchanged.

### 4. On every case, and on made-up answers (`chips.test.ts`)

Check these on every case in §2 and §3:

- every chip uid is in `citations`;
- no uid appears twice in `citations`;
- no paragraph holds the same chip twice (split with the helper's copy of the app's rule).

Add 5 or 6 made-up whole answers, no real chat text:

- English prose with brackets and a bullet list
- bold brackets repeated across paragraphs
- "AN 1.1" with `an1.1-10` in the store: one chip, and every citation has a chip, so nothing is left for Other sources
- a Sinhala answer on the fallback path with repeated supports
- refs written into the sentence, mixed with repeats in brackets
- no refs and no supports

Write each expected output by hand from the rules first, then run. If they differ, decide which one is wrong. Never paste the output in as the expectation.

### 5. CPU guards (`worst_case.test.ts`)

Each must finish under 100 ms, timed with `performance.now()` around `buildResponse`. Before the review fixes these took about 5 s and 0.6 s; now about 0.2 ms (2026-11-06).

- `'(SN 1***SN 2***…SN 14***'`, with no closing bracket
- `'A'`, then 20,000 spaces, then `'B (SN 15.3)'`

### 6. The paragraph rule, shared by the Worker and the app

The Worker (`paragraphStarts`, `pipeline.ts`) must split an answer the way the app does (`_parseBlocks`, `research_answer_view.dart`). Both sides read one fixture file, so neither can change alone.

`test/fixtures/research_answer_paragraphs.json` is a list of `{ "name", "text", "paragraphs" }`. `paragraphs` is what the app shows: each line trimmed, a paragraph's lines joined with one space, the bullet marker gone. Every case holds `(SN 15.3)` in each paragraph and has no `*` marks, because the app would hide them.

| Name | Text | Paragraphs |
|---|---|---|
| blank line splits | `One (SN 15.3).\n\nTwo (SN 15.3).` | `One (SN 15.3).` · `Two (SN 15.3).` |
| soft wrap joins | `A (SN 15.3)\nB (SN 15.3)` | `A (SN 15.3) B (SN 15.3)` |
| dash bullets | `- a (SN 15.3)\n- b (SN 15.3)` | `a (SN 15.3)` · `b (SN 15.3)` |
| star bullets | `* a (SN 15.3)\n* b (SN 15.3)` | `a (SN 15.3)` · `b (SN 15.3)` |
| line after a bullet | `- a (SN 15.3)\nafter (SN 15.3)` | `a (SN 15.3)` · `after (SN 15.3)` |
| lines after a bullet join | `- a (SN 15.3)\nafter one (SN 15.3)\nafter two (SN 15.3)` | `a (SN 15.3)` · `after one (SN 15.3) after two (SN 15.3)` |
| text, bullet, text | `Intro (SN 15.3)\n- a (SN 15.3)\nOutro (SN 15.3)` | `Intro (SN 15.3)` · `a (SN 15.3)` · `Outro (SN 15.3)` |
| several blank lines | `A (SN 15.3)\n\n\n\nB (SN 15.3)` | `A (SN 15.3)` · `B (SN 15.3)` |
| Windows line ends | `A (SN 15.3)\r\nB (SN 15.3)\r\n\r\nC (SN 15.3)` | `A (SN 15.3) B (SN 15.3)` · `C (SN 15.3)` |
| indented bullet | `  - a (SN 15.3)  \n   b (SN 15.3)` | `a (SN 15.3)` · `b (SN 15.3)` |

- **Worker side** (`paragraphs.test.ts`). For each case, `buildResponse(text, respOf([]), 'q', false, 220)` holds exactly `paragraphs.length` `[[cite:sn15.3]]` chips: one per paragraph. Open the file with `new URL('../../../test/fixtures/research_answer_paragraphs.json', import.meta.url)`.
- **App side** (`research_answer_view_test.dart`). For each case, `tester.pumpApp(ResearchAnswerView(answer: text, citations: const []))` (`test/helpers/pump_app.dart`; no theme needed, the typography falls back to `.standard()`). The plain text of each `RichText` under `ResearchAnswerView`, in order, must equal `paragraphs`. Open the file with `File('test/fixtures/research_answer_paragraphs.json')`; `flutter test` runs from the repo root.

This covers the paragraph part of W-ANS-1 in `research-feature-test-cases.md`. The rest of its §5.3 is out of scope.

## Don't test

These are known and accepted, or still undecided:

- A repeated bracket alone on its own line leaves a blank line, so the app shows an extra paragraph break.
- Unbalanced marks inside a bracket, e.g. `(SN 15.3**)`.
- En dash ranges ("SN 15.15–19"): still open, `sutta-references-plan.md`, To decide #2.

## Check that each test fails on the old code

Use a scratch copy, never the repo. For the Worker, copy `research_server/` to `<scratch>/repo/research_server` (symlink its `node_modules`) and symlink `<scratch>/repo/assets` and `<scratch>/repo/test` to the real ones, so the fixture paths still resolve. For the app, copy `lib/` and `test/` and symlink `packages/` and `assets/`.

- **§2–§4:** with the Worker's `src/` at `1b977bc` (before step 6), the once-per-paragraph and range rows fail.
- **§5:** put back the old regex body `([ \t]*)\(\s*((?:\*{0,3}${REF}\*{0,3}(?:\s*(?:,|;|&|and)\s*)?)+)\)|(\*{0,3})${REF}\3`. Both guards take seconds.
- **§6, Worker:** drop `|| afterBullet` in `paragraphStarts`. "line after a bullet", "text, bullet, text" and "indented bullet" fail (checked 2026-11-06).
- **§6, app:** make `_parseBlocks` treat bullet lines as plain lines. The bullet cases fail.

## Run

- `cd research_server && PATH=~/.nvm/versions/node/v22.2.0/bin:$PATH npm test`
- `flutter test test/presentation/widgets/research/research_answer_view_test.dart`. The flutter CLI runs unsandboxed. Run `dart format` on the new Dart file.
- `./scripts/research_server/test.sh`, which `deploy.sh --prod` runs first.
- Not the integration suite: nothing here touches it.

Cost, measured 2026-11-06: the research step goes from about 0.6 s to 0.8 s, and `flutter test` gets one more file.

## Done when

- [x] `npm test` passes §1–§6, and `test.sh` runs it.
- [x] The widget test passes and reads the same fixture file.
- [x] Each section was shown to fail on the old code.
- [x] No production file changed, nothing committed.
- [x] A handover line below for each file written, plus anything surprising.

## Handover

- `research_server/tsconfig.json`, `research_server/package.json` (`npm test`), `research_server/README.md`, `scripts/research_server/test.sh` (steps "typecheck + build" and "unit tests"): setup as written.
- `research_server/test/helpers.ts`: `respOf`, `build` (a `buildResponse` shortcut), `chipsOf`, `paragraphsOf` (copy of the app rule), throwing `fetch`.
- `research_server/test/refs.test.ts`: §1, including the lookup-file round trip.
- `research_server/test/chips.test.ts`: §2 (26 rows), §3 (F1-F5), §4 invariants on every case plus 6 made-up answers.
- `research_server/test/worst_case.test.ts`: §5, both guards under 100 ms (about 4 ms and 0.3 ms).
- `research_server/test/paragraphs.test.ts` and `test/fixtures/research_answer_paragraphs.json`: §6 Worker side and the shared fixture.
- `test/presentation/widgets/research/research_answer_view_test.dart`: §6 app side.
- Result: 61 Worker tests pass, 9 widget tests pass. Every hand-written expectation matched the Worker on the first run.
- Old-code checks (scratch copies): old `pipeline.ts` (`1b977bc`) fails 28 Worker tests (§2 rows, F1, F4, made-up answers, soft wrap, Windows line ends); old regex fails both §5 guards (5027 ms, 620 ms); no `|| afterBullet` fails 4 (row 13, three §6 cases); app bullets-as-lines fails 5 bullet cases.
- Surprising: the old `1b977bc` `src/` has no `citedHolding` in `refs.ts`, so for the §2-§4 check the old `pipeline.ts` was paired with the current `refs.ts` (additions only).
- Review, 2026-11-06: the old-code checks above re-run and confirmed. Two gaps closed: a Worker that splits every line after a bullet passed all tests (fixture case "lines after a bullet join" added), and `paragraphsOf` was checked against nothing (now against the fixture).
