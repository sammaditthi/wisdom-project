# DPD Provenance + Dictionary Refresh

> **Opened 2026-10-18.** The canon text has a receipt and a one-command sync;
> the dictionaries have neither. This doc adds the receipt first, then
> automates the flow around it.
>
> Of the seven steps in *Automation, in order*, two are done: the scripted
> export (`dpd_export.sh`) and the validation gate (`validate_dict_json.py`),
> both beside this doc. `dpd_view.sql` also carries a key filter and a
> parse-error fix. Steps 1, 3, 4, 5 and 7 are open.
>
> Modelled on [`bjt-sync-regen.md`](../canon-sources/bjt-sync-regen.md), which
> owns the *canon* side. The two are independent: different upstream, different
> cadence, so this gets its own script, not a step inside `sync-regen.sh`.

## The gap

`assets/dictionary/*.json` are hand-copied, and nothing in the repo records
where from or when. There is no DPD version string anywhere in the tree — not
in `dictionary_info.dart`, not in a receipt, not in an about screen. So
"is our dictionary stale?" cannot be answered without opening an external disk
and comparing file sizes by eye.

The canon answers it in one line, because `scripts/bjt-sync-regen/bjt-provenance.json`
records the upstream SHA it was synced from.

**The recipe was nearly lost too.** `dpd_view.sql` — the SQL that *defines*
what our DPD entries contain (headword split, meaning concatenation, the
`(lit.)` / `(ref.)` / pos formatting, the dpdict.net "Read more" link) — lived
only on the external SSD. Lose that disk and no rebuild reproduces today's
JSON. It is now in the repo beside this doc, `dpd_view.sql`, **as a temporary
home**, and `dpd_export.sh` and `validate_dict_json.py` sit with it: all three
move to `scripts/dpd-sync-regen/` when that script exists, since build inputs
do not belong under `docs/`.

`dpd_view.sql` would not in fact have rebuilt anything as it stood. Its last
statement had no terminating semicolon, so `sqlite3 dpd.db < dpd_view.sql`
died with `Parse error near line 56: near "SELECT": syntax error` — DB Browser
tolerates a trailing statement, the CLI does not. Fixed 2026-10-18; it is the
only change the file needed.

## The flow as it actually is today

Reconstructed from `Anigha_SSD/Dev - Ext/DB Script and Generation/`:

1. Download a DPD release `dpd.db` (~2 GB) into a new version folder.
2. Run `dpd_view.sql` against it, defining three views:
   `view_lookup_split_values` (helper), `view_dpd`, `view_dpd_construction`.
   `dpd_export.sh` now does this as part of step 3, as `TEMP` views over an
   immutable database, so the 2 GB input is no longer modified to be read.
3. Export the two output views to JSON. This **was** done by hand in DB
   Browser for SQLite (a `.sqbpro` project file sits beside the `ver2.2`
   database), and that was the weak link, because the exporter can write
   either of two shapes and **only one of them loads**:

   ```jsonc
   [ [ "akakkasa", "na > a + kakkasa" ] ]                      // required
   [ { "aword": "akakkasa", "meaning": "na > a + kakkasa" } ]  // crashes the build
   ```

   `dict-populate.js` destructures each element as an array
   (`for (const [rawWord, rawMeaning] of data)`), so an array-of-objects
   export dies on the first entry with `TypeError: .for is not iterable`.
   DB Browser writes the objects shape, so some undocumented conversion sat
   between export and copy — a second hole in the recipe, alongside the one
   that nearly took `dpd_view.sql`.

   **Now `./dpd_export.sh <dpd.db> <out-dir>`** (step 6, done 2026-10-18).
   Whatever that manual conversion was, the hole is closed by proof rather
   than by reconstruction: run against `ver2.3/dpd.db`, the script reproduces
   the shipped `en-dpd.json` **byte for byte**, sha256 and all. So the recipe
   in the repo is now known to be the recipe the shipped dictionary came from.
4. Rename → `en-dpd.json`, `en-dpd-construction.json`; copy into
   `assets/dictionary/`.
5. `cd tools && npm run generate-dict` → `dict.db`. DPD and DPDC are the two
   entries flagged `needsConversion` in `dict-populate.js`, so romanized Pali
   is converted to Sinhala script here, via `@pnfo/pali-converter`.
6. `db-finalize.js` rewrites `assets/databases/manifest.json` (bytes + sha256).
7. Deploy. `scripts/app/web/deploy.sh` names the R2 object from the hash, so a
   new `dict.db` is a new object and a ~170 MB upload; `scripts/app/test.sh`
   fails if the file and the manifest disagree.

Steps 2 and 3 are now one headless command; step 4 — the copy into `assets/`,
and the gate that should precede it — is the unscripted part that remains, and
step 7 is what absorbs it.

## Where we are

The repo's two DPD files are **byte-identical to the SSD's `ver2.3`**
(verified 2026-10-18):

| File | sha256 |
|---|---|
| `en-dpd.json` | `bf9eee6b3ff1…17affe2` |
| `en-dpd-construction.json` | `06977da4c098…4c592db3` |

`ver2.3`'s `dpd.db` is dated 2025-08-09; a later folder, `wp-web-1.0`, holds a
`dpd.db` from 2026-09-26. Both are now re-exported with `dpd_export.sh` and
both exports pass the gate; `wp-web-1.0/` holds the new pair, waiting on
step 3 before it can be committed.

**The release tags were not lost after all.** They are inside each database,
in its own `db_info` table — the folder names are ours, but DPD stamps its
own:

```sh
sqlite3 dpd.db "SELECT value FROM db_info WHERE key='dpd_release_version';"
```

| folder | `dpd_release_version` | `dpd.db` dated |
|---|---|---|
| `ver2.3` (shipped today) | `v0.2.20250709` | 2025-08-09 |
| `wp-web-1.0` (the refresh) | `v0.4.20260926` | 2026-09-26 |

So nothing has to be supplied by hand, and the receipt's `release_tag` can be
read out of the input rather than typed. `db_info` also carries the citation
string, the licence (CC BY-NC-SA 4.0) and the upstream URLs, which is where
step 4's version label should come from.

## What `wp-web-1.0` taught us

Validated 2026-10-18 against the shipped `ver2.3` files. The recipe had plainly
run unchanged — same markup vocabulary (`<b> <i> <br> <a>`, no new tags), same
construction symbol set, every Read-more `href` matching its own key, no
duplicate keys, no nulls, no non-NFC keys, same indentation and line endings.
The content diff was an ordinary 13-month DPD update; re-measured on the
scripted re-export, `en-dpd` is 415,904 keys shared, 99,948 meanings revised,
7,250 inflections pruned, 29,673 added (the earlier count of 42,761 included
the 13,088 junk keys the filter now drops), and `en-dpd-construction` is
39,947 shared, +4,218, −357, 346 changed.

Two things still blocked it, and **both are refresh-shaped, not one-offs** —
they will recur on every release unless the flow absorbs them.

1. **Export shape.** Covered in step 3 above: DB Browser cannot write the
   shape the build needs, so an undocumented manual conversion sat between
   export and copy and the build's survival depended on it. Closed by
   `dpd_export.sh`, which can only emit the right shape, and by the gate,
   which refuses the wrong one.
2. **Upstream added a key class.** This release publishes sutta references as
   lookup keys — `AN1.1`, `SN46.36`, `THAG1.1`, `JA99` — 13,087 of them, plus
   one row with an empty key. `dict-populate.js` strips trailing digits and
   converts every DPD key to Sinhala script, and this input survives both:

   ```
   "AN1.1"   → strip → "AN1."  → අන්1.
   "SN46.36" → strip → "SN46." → ස්න්46.
   ```

   13,087 junk rows collapsing onto 714 distinct keys, of which **five collide
   with real Pali headwords** and bolt nonsense onto live entries: `ජ` (547
   rows), `ඉති` (112), `උද්` (80), `ථි` (73), `අන්` (11).

   We do not want these keys at all — `wisdom_shared`'s SuttaCentral↔BJT
   resolver already turns `SN 15.3` into a node key, so DPD's references are
   redundant as well as mangled.

   **Filtered in `dpd_view.sql`, not in `dict-populate.js`** (done
   2026-10-18). The view is what the receipt's `view_sql_sha256` pins, so a
   filter living there is recorded; one living in the generator is not.
   `view_dpd` now ends with

   ```sql
   WHERE a.word <> '' AND a.word NOT GLOB '*[^a-zāīūṭḍṇṃñṅḷ ]*'
   ```

   an allowlist of `a`–`z`, the ten diacritics DPD uses
   (ā ī ū ṭ ḍ ṇ ṃ ñ ṅ ḷ) and the space a few compound headwords carry, so
   *any* future non-Pali key class is excluded too, not just this one. GLOB
   compares code points and is case-sensitive, so the diacritics inside the
   class work and an uppercase key fails it on the first letter; verified.

   Checked against every key of the shipped `ver2.3` pair and the new
   construction export — drops 0 of 507,623 — and against the new `en-dpd`
   keys, where it drops 13,088 and nothing else. **The patched view has now
   been run** (2026-10-18): both views re-exported from `wp-web-1.0/dpd.db`,
   and the gate reports 0 keys outside the Pali letter set in either file.

The general lesson: a DPD refresh can change the *shape* of the input, not just
its content, so the flow needs a gate that refuses a bad export before it
reaches `assets/`. That is now step 2 of the automation list.

## The 100 MiB wall

`en-dpd.json` is one release away from GitHub's hard file limit. This is a
constraint on the whole flow, so it is settled here rather than left to the
refresh that trips over it.

GitHub rejects any pushed file over 100 MiB (104,857,600 B) outright — not a
warning. Measured 2026-10-18, `en-dpd` in each form:

| form | size | |
|---|---|---|
| shipped `ver2.3` | 92.7 MiB | under |
| the hand export (objects, 4-space, unfiltered) | 110.8 MiB | over |
| **this refresh as `dpd_export.sh` writes it** | **98.9 MiB** | 1.1 MiB under |
| array-of-arrays, minified | 87.0 MiB | buys one release |
| **array-of-arrays, 4-space, gzipped** | **5.5 MiB** | ✓ |

The wall is not quite breached: dropping the 13,088 junk keys took the earlier
102.0 MiB figure down to 98.9 MiB, so this refresh would squeeze in
uncompressed. That is not a reprieve — `en-dpd` grew 6.2 MiB in these 13
months and has 1.1 MiB of room left, so the next release is over the limit and
the file has to be dealt with before it can be committed, not after.

**Decision: gzip the dictionary JSONs, keep them in git.**

What makes this cheap is that `assets/dictionary/*.json` is a **build input and
nothing else** — `dict-populate.js` is its only reader anywhere in the tree,
and `pubspec.yaml` ships `dict.db`, never the JSON. So compressing them cannot
touch the app, the asset bundle, or the R2 upload. The reader becomes a
`zlib.gunzipSync` around the existing `readFileSync`.

Verified in Node: `gzipSync(buf, { level: 9, mtime: 0 })` is byte-identical
across runs, so the committed file stays diff-stable; `gunzipSync` round-trips
byte-exact. `mtime: 0` is required — the default stamps the current time into
the header and every rebuild would then show a spurious diff.

Rejected: **Git LFS** (a new moving part on a history we just scrubbed, and the
free 1 GB/month bandwidth does not survive a ~104 MB file per release);
**minifying only** (buys one release, then the same wall, and costs the
readable diff); **sharding by first letter** (the limit returns, and the JSON
stops being one file per dictionary).

Keeping the inputs in git at all is the point of this doc: `dpd.db` is 2 GB and
cannot be committed, so the JSON is the only committed evidence of what the
shipped `dict.db` was built from.

## `dpd-provenance.json`

Lives where its script will live, `scripts/dpd-sync-regen/`, mirroring the
canon's receipt. Proposed shape:

```json
{
  "source": "https://github.com/digitalpalidictionary/dpd-db",
  "release_tag": "v0.2.20250709",
  "dpd_db_sha256": "<ver2.3/dpd.db>",
  "view_sql_sha256": "<dpd_view.sql>",
  "exported_on": "2025-08-09",
  "synced_on": "2026-01-19T00:00:00Z",
  "files": {
    "en-dpd.json": { "bytes": 97157674, "sha256": "bf9eee6b…" },
    "en-dpd-construction.json": { "bytes": 2889539, "sha256": "06977da4…" }
  }
}
```

`release_tag` is read out of the database, not typed —
`SELECT value FROM db_info WHERE key='dpd_release_version'`, which
`dpd_export.sh` already prints when it finishes.

`view_sql_sha256` is the part the canon receipt has no equivalent of: our JSON
is a *derived* artifact, so the recipe's hash belongs in the receipt beside the
input's. A changed `dpd_view.sql` with an unchanged `dpd.db` still means a
different dictionary.

`files` records each one's **uncompressed** bytes and sha256, even though what
is committed is the `.gz`. The uncompressed hash is the content identity: it
survives a change of gzip level or library, and it is what the validation gate
and `dict-populate.js` both actually see.

Everything the two receipts need is now measured (2026-10-18), so step 1 is a
transcription:

| | `ver2.3` = what ships today | `wp-web-1.0` = the refresh |
|---|---|---|
| `release_tag` | `v0.2.20250709` | `v0.4.20260926` |
| `dpd_db_sha256` | `fde4b1b633642cd7…` | `739fec5c07be47bb…` |
| `exported_on` | 2025-08-09 | 2026-10-18 |
| `en-dpd.json` bytes | 97,157,674 | 103,657,162 |
| `en-dpd.json` sha256 | `bf9eee6b3ff12294…` | `4199348e60a8be3e…` |
| `en-dpd-construction.json` bytes | 2,889,539 | 3,175,290 |
| `en-dpd-construction.json` sha256 | `06977da4c09876fc…` | `0d061d3f0ec915c1…` |

`view_sql_sha256` for the fixed `dpd_view.sql` is
`2bcc0a048da133efb1e1de991c35b9335f5273e10ce5795fb571e65613ee7c7c`. The
`ver2.3` column's hashes were produced *by* that file, so it is the recipe for
both columns, and the receipt for the shipped files can be written now rather
than waiting for the refresh to land.

## Automation, in order

Each step stands alone and is useful without the next.

1. **Write the receipt by hand**, transcribing the `ver2.3` column of the
   table above — release tag, hashes and byte counts are all measured. Stale
   becomes a one-line answer, and everything below reads or writes this file.
2. **A validation gate** — **done 2026-10-18**, `validate_dict_json.py`
   beside this doc. Run on a candidate export *before* it is copied into
   `assets/`; it is what would have caught both `wp-web-1.0` problems in
   seconds instead of at `generate-dict` time.

   ```sh
   ./validate_dict_json.py <candidate.json[.gz]> --against assets/dictionary/en-dpd.json
   ```

   It refuses anything but a top-level array of two-element string arrays; any
   duplicate, empty or non-NFC key; a key outside the Pali letter set, so a new
   upstream key class is reported rather than silently converted; an empty
   meaning; a markup tag outside `<b> <i> <br> <a>`; a Read-more link that does
   not match its own key; formatting that is not the committed files'
   4-space, unescaped-unicode, no-trailing-newline JSON; and a key count more
   than 10% smaller or 50% larger than the file it replaces, since a collapsed
   export is the quiet failure. It reads `.gz` directly, so it still works
   after step 3. It prints the added/removed/changed counts as the review
   summary, and exits non-zero on any failure.
3. **Gzip the dictionary inputs.** The decision and the measurements are in
   *The 100 MiB wall*; this is the work. It **blocks the pending refresh** —
   the new `en-dpd.json` cannot be committed in any uncompressed form.

   In `dict-populate.js`, wrap the one existing read:

   ```js
   const buf = fs.readFileSync(filePath);
   const content = filePath.endsWith('.gz')
       ? zlib.gunzipSync(buf).toString('utf-8')
       : buf.toString('utf-8');
   ```

   Then gzip all ten entries in `CONFIG.DICTIONARIES` and add `.gz` to their
   filenames — not DPD alone, so the reader keeps one rule. Always
   `{ level: 9, mtime: 0 }`; the default mtime stamps the current time into
   the header and every rebuild would show a spurious diff.

   `en-dpd.json` 97 MB → ~5 MB and `en-critical.json` 25 MB → ~2 MB, so the
   tracked assets drop ~130 MB and the 407 MB `.git` stops growing by ~100 MB
   a release. Nothing about the app changes: these files are build inputs,
   `pubspec.yaml` ships `dict.db`, and `dict.db` itself is unaffected.
4. **Show the version in the app.** The receipt's `release_tag` is the only
   place it would come from, which is the other reason to write the receipt
   first. A dictionary this prominent should name its edition; where it goes
   needs a decision, since there is no about or credits screen today — the
   dictionary sheet's existing DPD badge and its "Read more" link are the
   nearest surfaces. Keep it a build-time constant generated from the receipt,
   not a runtime read of a JSON asset.
5. **Heartbeat.** Compare `dpd-db`'s newest release tag to the receipt's and
   print how far behind we are. Read-only, no download. The canon's equivalent
   runs at the end of `scripts/release_all_dryrun.sh` (`canon_heartbeat`,
   added 2026-10-18) — copy its shape: report only, and stay silent when the
   receipt, `jq` or the network is missing. DPD tags its releases, so this
   needs no GitHub API and no token, just the same `git ls-remote` the canon
   heartbeat already uses:

   ```sh
   git ls-remote --tags --refs https://github.com/digitalpalidictionary/dpd-db \
     | awk -F/ '{print $NF}' | sort -V | tail -1
   ```
6. **Script the export** — **done 2026-10-18**, `dpd_export.sh` beside this
   doc. DB Browser is out of the flow, so the shape is no longer a mouse
   click: `./dpd_export.sh <dpd.db> <out-dir>`, ~2 minutes for both views.

   Three things in it are load-bearing:

   - `json_group_array(json_array(aword, meaning))`, **not `.mode json`** —
     that writes the array-of-objects shape that breaks the build. This is the
     only form that emits the required array-of-arrays. Its output is
     minified, so it is piped through `json.dumps(indent=4,
     ensure_ascii=False)`, which reproduces the committed files exactly.
   - `ORDER BY aword` on the **export query, not in the view**, because
     neither view promises a row order: `view_dpd` ends in `GROUP BY`, which
     in practice comes out in group-key order, and `view_dpd_construction`
     has no ordering at all. Ordering in the query makes both files
     byte-reproducible without churning `view_sql_sha256`.
   - The database is opened **immutable** (`file:…?immutable=1`) and the views
     created `TEMP` by a `sed` over `dpd_view.sql`. A WAL database cannot even
     be opened `-readonly` without writing its `-shm`, and DB Browser wrote
     the views into the 2 GB file itself; nothing now writes to the input.

   Proven, not assumed: run against `ver2.3/dpd.db` it reproduces the shipped
   `en-dpd.json` byte for byte, and two runs against `wp-web-1.0/dpd.db` are
   byte-identical to each other. `en-dpd-construction.json` reproduces
   `ver2.3`'s content exactly — same 40,304 entries, same meanings — but in
   sorted order rather than the shipped file's arbitrary one, which is the
   point of the `ORDER BY` and the only difference.

   The order *within* an entry is a separate matter — the meanings of a
   multi-headword word are concatenated in the inner query's
   `ORDER BY a.Id, lemma_1`, a subquery ordering SQLite is free to ignore —
   and it can only be fixed in the view. The byte-identical `ver2.3`
   reproduction says it has not moved in 13 months and two SQLite versions, so
   leave it until it does.
7. **`dpd-sync-regen.sh`**, only once 1–6 exist: download → export (step 6) →
   validate (step 2) → gzip → copy → `generate-dict` → show the diff → write
   the receipt. Same shape as the canon script, including a loud stop before
   overwriting assets. Move `dpd_view.sql`, `dpd_export.sh` and
   `validate_dict_json.py` out of `docs/` and in beside it — with steps 2 and 6
   done, this one is mostly glue plus the receipt write.

## Decisions for the user

- **Is the SSD the source of truth for `dpd.db`?** The 2 GB input is too big
  for git. Either the script downloads the release each time (slow, but the
  receipt makes it verifiable), or the SSD folder stays the cache and the
  script takes a path to it. `dpd_export.sh` already takes a path and reads it
  immutably, and both databases are now hashed in the receipt table, so either
  answer works; only step 7 has to choose.

- **`en-dpd-construction.json` gets a one-time whole-file diff.** Its shipped
  row order is arbitrary and the export now sorts by key, so the first
  committed version reorders all 40,304 entries even where content is
  unchanged. Deliberate, and the price of byte-reproducibility; worth knowing
  before reading that diff. `en-dpd.json` is unaffected — its order already
  matched.
- **Where in the app does the version show?** Decided 2026-10-18 that it
  should (step 4); the surface is still open.
- **Does this refresh ship on its own?** It is a 13-month content update with
  no structural change beyond the two above, so there is no reason to hold
  it — but it costs a ~170 MB `dict.db` re-upload, so it may as well ride
  along with whatever release is next.

## Settled

- **The pending refresh is re-exported, not converted — and now is**
  (2026-10-18). Converting the hand export instead was rejected: it would
  leave `dpd_view.sql` disagreeing with the shipped JSON, which is exactly
  what `view_sql_sha256` exists to rule out. Since DB Browser cannot write the
  required shape, this pulled step 6 forward.

  Both views are re-exported from `wp-web-1.0/dpd.db` with `dpd_export.sh` and
  both pass the gate. The pair sits beside its database on the SSD
  (`wp-web-1.0/en-dpd.json`, `wp-web-1.0/en-dpd-construction.json`) and is
  **deliberately not copied into `assets/dictionary/`**: step 3 has to land
  first, because the 98.9 MiB `en-dpd.json` is 1.1 MiB from a limit that
  rejects the push outright.

- **`dpd_view.sql` had a parse error** (2026-10-18). No terminating semicolon
  on the last statement, so the CLI rejected the whole script; DB Browser had
  been hiding it. One character, and the only change the SQL needed — the
  views themselves were correct, which the byte-identical `ver2.3`
  reproduction confirms.

- **Release tags come from the database** (2026-10-18), `db_info`'s
  `dpd_release_version`, so the history that looked lost was never missing.
  See *Where we are*.

- **Gzip, in git** (2026-10-18) — see *The 100 MiB wall* and step 3. Rejected:
  Git LFS, minifying, sharding.

- **DPD only.** The other eight dictionaries (`en-critical`, `en-pts`,
  `en-vri`, `en-dppn`, `en-buddhadatta`, `en-nyanatiloka`, and the two Sinhala
  ones) have the same gap, but they receive no upstream updates, so they are
  out of scope: no receipt, no heartbeat (2026-10-18). Revisit only if one of
  them ever publishes a new edition.
