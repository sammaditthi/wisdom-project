# SC Snapshot — the research corpus stays pinned

> Status: **Done 2026-11-02.** The research store is pinned to one SuttaCentral
> snapshot and is not re-synced. The first full ingest:
> [research-ingestion-ops-chunking-full-corpus.md](../research/research-ingestion-ops-chunking-full-corpus.md).
> Sibling: [bjt-sync-regen.md](../../todo/canon-sources/bjt-sync-regen.md). The
> BJT copy *does* re-sync, and this one doesn't.

---

## 1. What is ingested

The research (RAG) store answers from SuttaCentral's English translations, both CC0:

```
translation/en/sujato/sutta/**/*-sujato.json      # Suttas (Bhikkhu Sujato)
translation/en/brahmali/vinaya/**/*-brahmali.json # Vinaya (Ajahn Brahmali)
```

Source: `suttacentral/bilara-data`, branch `published`, commit `ce5b98f`
(2026-09-28). The receipt is the comment above `RESEARCH_STORE` in
`research_server/wrangler.jsonc`:

```
// bilara-data published@ce5b98f (2026-09-28), chunks default
"RESEARCH_STORE": "fileSearchStores/tipitakaen-j02s31fl1p4q",
```

## 2. The decision: pinned, no routine re-ingest

- **We don't re-ingest just because SuttaCentral changed.** The canon doesn't
  change, and wording revisions to the translations don't change the answers. A
  re-ingest also costs Gemini quota.
- **Re-ingesting is a deliberate choice**, for example adding the Pali text or
  another translator. If that happens, follow the ingestion doc: upload to a new
  store, point `RESEARCH_STORE` at it, and update the receipt in the same commit.
  To roll back, point it at the old store again.
- **Only structural changes matter**, and for us that means the **sutta IDs**
  (`sn15.3`, `mn10`), which come from the file names. Citations are per sutta:
  uid → `assets/data/sc-to-bjt.json` → BJT node. Nothing uses segment IDs.
- **The store and `sc-to-bjt.json` are both frozen**, so they agree with each
  other even if SuttaCentral renumbers. They can drift apart only when
  `sc-to-bjt.json` is rebuilt from SuttaCentral's live API, so run the check (§3)
  first.

## 3. The structural check (by hand, no Gemini quota)

Run it before any rebuild of `sc-to-bjt.json`, or whenever you're curious.
It lists suttas that were added or removed in our two folders. If it prints
nothing, nothing structural changed.

```bash
cd ~/Desktop/Dev/bilara-data-readonly
git fetch --depth 1 origin published   # downloads only; the mirror stays pinned
git diff --name-status --no-renames HEAD FETCH_HEAD -- \
  translation/en/sujato/sutta translation/en/brahmali/vinaya | grep -v '^M'
```

Drop the `grep` to also see wording changes (`M` lines). Run it outside the
sandbox, because the mirror is outside the project.

**If it lists suttas:** a renamed or removed uid that the store still cites
needs an entry in `sc-to-bjt.json` under the old ID. Decide case by case, and
re-ingest only if the text itself must change.

Last run 2026-11-02 against `e8690f3`, 195 commits ahead: 1005 files changed
upstream, none in our two folders.

**Weekly, automatically:** `.github/workflows/suttacentral-check.yml` runs
`tools/suttacentral_map/check_upstream.py` every Monday. It covers what the
reader links to on SuttaCentral (every ID in `sc-to-bjt.json`, and the
translations it opens), and lists suttas added to our two folders without
failing on them. This section stays the by-hand check before a rebuild.

## 4. The read-only mirror

`~/Desktop/Dev/bilara-data-readonly` is shallow, blobless and sparse, covering
only the two folders above. **It stays on the pinned commit, so it always matches
what's in the store.** Fetch only. Never `pull` or `reset` it, never commit to it,
and never add a remote. The ingest reads it by default (`--bilara-dir` /
`BILARA_DATA_DIR` override).

To recreate it on the pinned commit:

```bash
cd ~/Desktop/Dev
git clone --depth 1 --filter=blob:none --sparse --branch published \
  https://github.com/suttacentral/bilara-data.git bilara-data-readonly
cd bilara-data-readonly
git sparse-checkout set translation/en/sujato/sutta translation/en/brahmali/vinaya
git fetch --depth 1 origin ce5b98f032ec20132a5678bddf15a76c94263913
git checkout --detach FETCH_HEAD
```
