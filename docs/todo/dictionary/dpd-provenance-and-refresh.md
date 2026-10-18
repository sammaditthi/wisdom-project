# DPD Provenance + Dictionary Refresh

> **Opened 2026-10-18.** The canon text has a receipt and a one-command sync;
> the dictionaries have neither. This doc adds the receipt first, then
> automates the flow around it.
>
> Of the seven steps in *Automation, in order*, none are done. The only code
> written so far is the key filter in `dpd_view.sql`, forced by the refresh
> that is waiting on this doc (see *What `wp-web-1.0` taught us*).
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
home**: it moves to `scripts/dpd-sync-regen/` when that script exists, since a
build input does not belong under `docs/`.

## The flow as it actually is today

Reconstructed from `Anigha_SSD/Dev - Ext/DB Script and Generation/`:

1. Download a DPD release `dpd.db` (~2 GB) into a new version folder.
2. Run `dpd_view.sql` against it. It creates three views:
   `view_lookup_split_values` (helper), `view_dpd`, `view_dpd_construction`.
3. Export the two output views to JSON **by hand in DB Browser for SQLite**
   (a `.sqbpro` project file sits beside the `ver2.2` database). DB Browser can
   write either of two shapes, and **only one of them loads**:

   ```jsonc
   [ [ "akakkasa", "na > a + kakkasa" ] ]                      // required
   [ { "aword": "akakkasa", "meaning": "na > a + kakkasa" } ]  // crashes the build
   ```

   `dict-populate.js` destructures each element as an array, so an
   array-of-objects export dies on the first entry with
   `TypeError: .for is not iterable`.

   **DB Browser only writes the objects shape**, so this step as described
   cannot produce the shipped files. Some conversion must have happened
   between export and copy for `ver2.3`, and what it was is lost — a second
   hole in the recipe, alongside the one that nearly took `dpd_view.sql`.
   Rather than reconstruct it, step 6 replaces the export outright with a
   `sqlite3` query that can only emit the right shape, which is also why that
   step is worth doing early.
4. Rename → `en-dpd.json`, `en-dpd-construction.json`; copy into
   `assets/dictionary/`.
5. `cd tools && npm run generate-dict` → `dict.db`. DPD and DPDC are the two
   entries flagged `needsConversion` in `dict-populate.js`, so romanized Pali
   is converted to Sinhala script here, via `@pnfo/pali-converter`.
6. `db-finalize.js` rewrites `assets/databases/manifest.json` (bytes + sha256).
7. Deploy. `scripts/app/web/deploy.sh` names the R2 object from the hash, so a
   new `dict.db` is a new object and a ~170 MB upload; `scripts/app/test.sh`
   fails if the file and the manifest disagree.

Steps 2–4 are the unscripted part, and step 3 cannot be run headless at all.

## Where we are

The repo's two DPD files are **byte-identical to the SSD's `ver2.3`**
(verified 2026-10-18):

| File | sha256 |
|---|---|
| `en-dpd.json` | `bf9eee6b3ff1…17affe2` |
| `en-dpd-construction.json` | `06977da4c098…4c592db3` |

`ver2.3`'s `dpd.db` is dated 2025-08-09. A later folder, `wp-web-1.0`, holds a
`dpd.db` from 2026-09-26 and, as of 2026-10-18, both views exported — a
refresh in flight. Those two exports are **not loadable as they stand**; the
section below says why.

Which upstream DPD release `ver2.3` and `wp-web-1.0` correspond to is **not
recorded anywhere**; the folder names are ours, not DPD's. Recovering those two
tags is the one piece of history that has to be supplied by hand — after that
the receipt carries it forward.

## What `wp-web-1.0` taught us

Validated 2026-10-18 against the shipped `ver2.3` files. The recipe had plainly
run unchanged — same markup vocabulary (`<b> <i> <br> <a>`, no new tags), same
construction symbol set, every Read-more `href` matching its own key, no
duplicate keys, no nulls, no non-NFC keys, same indentation and line endings.
The content diff was an ordinary 13-month DPD update: 415,904 keys shared,
~100k meanings revised, 7,250 inflections pruned, 42,761 added.

Two things still blocked it, and **both are refresh-shaped, not one-offs** —
they will recur on every release unless the flow absorbs them.

1. **Export shape.** Covered in step 3 above: the exporter cannot write the
   shape the build needs, so an undocumented manual conversion sits between
   export and copy, and whether the build runs at all depends on it.
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
   keys, where it drops 13,088 and nothing else. **The patched view itself has
   not been run against a release yet** (2026-10-18); the first run is the
   re-export in *Settled*.

The general lesson: a DPD refresh can change the *shape* of the input, not just
its content, so the flow needs a gate that refuses a bad export before it
reaches `assets/`. That is now step 2 of the automation list.

## The 100 MiB wall

`en-dpd.json` crossed GitHub's hard file limit. This is a constraint on the
whole flow, so it is settled here rather than left to the refresh that trips
over it.

GitHub rejects any pushed file over 100 MiB (104,857,600 B) outright — not a
warning. Measured 2026-10-18 on the `wp-web-1.0` export:

| form | size | |
|---|---|---|
| as exported (objects, 4-space) | 110.8 MiB | over |
| array-of-arrays, 4-space — repo style | 102.0 MiB | over |
| array-of-arrays, minified | 89.8 MiB | ~2 releases of headroom |
| **array-of-arrays, 4-space, gzipped** | **5.7 MiB** | ✓ |

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
free 1 GB/month bandwidth does not survive a 116 MB file per release);
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
  "release_tag": "<the DPD release dpd.db came from>",
  "dpd_db_sha256": "<the downloaded dpd.db>",
  "view_sql_sha256": "<dpd_view.sql, once vendored>",
  "exported_on": "2025-08-09",
  "synced_on": "2026-01-19T00:00:00Z",
  "files": {
    "en-dpd.json": { "bytes": 0, "sha256": "" },
    "en-dpd-construction.json": { "bytes": 0, "sha256": "" }
  }
}
```

`view_sql_sha256` is the part the canon receipt has no equivalent of: our JSON
is a *derived* artifact, so the recipe's hash belongs in the receipt beside the
input's. A changed `dpd_view.sql` with an unchanged `dpd.db` still means a
different dictionary.

`files` records each one's **uncompressed** bytes and sha256, even though what
is committed is the `.gz`. The uncompressed hash is the content identity: it
survives a change of gzip level or library, and it is what the validation gate
and `dict-populate.js` both actually see.

## Automation, in order

Each step stands alone and is useful without the next.

1. **Write the receipt by hand**, seeded with the `ver2.3` facts above plus the
   release tag once recovered. Stale becomes a one-line answer, and everything
   below reads or writes this file.
2. **A validation gate**, run on a candidate export *before* it is copied into
   `assets/`. This is what would have caught both `wp-web-1.0` problems in
   seconds instead of at `generate-dict` time. It checks a candidate against
   the file it replaces: top-level array of two-element arrays; no duplicate,
   empty, null or non-NFC keys; every key within the Pali letter set, so a new
   upstream key class is reported rather than silently converted; markup
   vocabulary and construction symbol set unchanged; and the key count within a
   sane band of the previous file, since a collapsed export is the quiet
   failure. It prints the added/removed/changed counts as the review summary.

   Cheap and standalone — worth having even while the export is still done by
   hand, because the manual path is exactly where a bad export enters.
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
5. **Heartbeat.** Ask GitHub for `dpd-db`'s latest release tag, compare to the
   receipt, print how far behind we are. Read-only, no download. The canon's
   equivalent now runs at the end of `scripts/release_all_dryrun.sh`
   (`canon_heartbeat`, added 2026-10-18) — copy its shape: report only, and
   stay silent when the receipt, `jq` or the network is missing.
6. **Script the export**, replacing DB Browser — the step that removes the
   shape trap for good, since the shape stops being a mouse click.
   `sqlite3 dpd.db < dpd_view.sql`, then one query per view:

   ```sql
   SELECT json_group_array(json_array(aword, meaning)) FROM view_dpd;
   ```

   **Not `.mode json`** — that writes the array-of-objects shape that breaks
   the build. `json_group_array(json_array(…))` is the only form that emits
   the required array-of-arrays. Its output is minified; pipe it through a
   4-space formatter to match today's files, which costs ~0.2 MiB gzipped and
   keeps `gunzip | less` readable.

   Check the output against the receipt's hashes to prove the script
   reproduces the shipped files before trusting it on a new release.

   One caveat to settle while doing it: **neither view's row order is
   guaranteed.** `view_dpd` ends in `GROUP BY`, which in practice comes out in
   group-key order, and `view_dpd_construction` has no ordering at all; SQL
   promises neither. Put an explicit `ORDER BY aword` on the **export query**,
   not in the view: that makes both files byte-reproducible, the way the rest
   of the repo expects, without churning `view_sql_sha256`. The order *within*
   an entry is a separate matter — the meanings of a multi-headword word are
   concatenated in the inner query's `ORDER BY a.Id, lemma_1`, a subquery
   ordering SQLite is free to ignore — and it can only be fixed in the view,
   so leave it until it is seen to move.
7. **`dpd-sync-regen.sh`**, only once 1–6 exist: download → views → export →
   validate (step 2) → gzip → copy → `generate-dict` → show the diff → write
   the receipt. Same shape as the canon script, including a loud stop before
   overwriting assets. Move `dpd_view.sql` out of `docs/` and in beside it.

## Decisions for the user

- **Is the SSD the source of truth for `dpd.db`?** The 2 GB input is too big
  for git. Either the script downloads the release each time (slow, but the
  receipt makes it verifiable), or the SSD folder stays the cache and the
  script takes a path to it.
- **Where in the app does the version show?** Decided 2026-10-18 that it
  should (step 4); the surface is still open.
- **Does this refresh ship on its own?** It is a 13-month content update with
  no structural change beyond the two above, so there is no reason to hold
  it — but it costs a ~170 MB `dict.db` re-upload, so it may as well ride
  along with whatever release is next.

## Settled

- **The pending refresh is re-exported, not converted** (2026-10-18). Re-run
  the patched `dpd_view.sql` against `wp-web-1.0/dpd.db` and export both views
  fresh. Converting the existing export instead was rejected: it would leave
  `dpd_view.sql` disagreeing with the shipped JSON, which is exactly what
  `view_sql_sha256` exists to rule out.

  Since DB Browser cannot write the required shape, this pulls step 6 forward
  — the re-export is done with `sqlite3`, which is a query against the local
  `dpd.db`, not another download.

- **Gzip, in git** (2026-10-18) — see *The 100 MiB wall* and step 3. Rejected:
  Git LFS, minifying, sharding.

- **DPD only.** The other eight dictionaries (`en-critical`, `en-pts`,
  `en-vri`, `en-dppn`, `en-buddhadatta`, `en-nyanatiloka`, and the two Sinhala
  ones) have the same gap, but they receive no upstream updates, so they are
  out of scope: no receipt, no heartbeat (2026-10-18). Revisit only if one of
  them ever publishes a new edition.
