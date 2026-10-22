# Rename `docs/General` to `docs/general`

A one-command chore, left out of the versioning work because it has to touch
the git index and that round was keeping a staged snapshot intact. Do it on a
clean tree.

## What is wrong

Git tracks the folder as `docs/General`; the folder on disk is `docs/general`.
Both are true at once because this repo has `core.ignorecase = true` on a
case-insensitive filesystem: somebody renamed the folder on disk, git saw
nothing, and the capital-G entries stayed in the index.

```
git ls-files docs/General   →  8 files, all under docs/General/
ls -d docs/[Gg]eneral       →  docs/general
git status                  →  clean
```

It is the only case mismatch in the repo. Checked by comparing every component
of every tracked path against the real directory listing.

## Why it matters

Nothing breaks today. No script, config or code reads these paths — they appear
only in doc prose, and macOS resolves either spelling. It bites on a
case-sensitive checkout (any Linux box, so CI): the folder arrives as
`General`, and this relative link lands nowhere:

```
docs/done/ops/versioning-system.md:16
  [docs/general/how-to-release.md](../../general/how-to-release.md)
```

Lowercase is the intended name. Every one of the five references in the repo
already writes `docs/general/`, none writes `General`, and the sibling folders
are `docs/todo`, `docs/done`, `docs/decisions`. So the index is the only
outlier and **no prose needs rewording** — the rename alone makes the repo
consistent.

## Do it

Two steps through a temporary name. The one-step form cannot work on a
case-insensitive filesystem:

```bash
git mv -f docs/General docs/general
# fatal: renaming 'docs/General' failed: Invalid argument
```

```bash
git mv docs/General docs/general-tmp && git mv docs/general-tmp docs/general
```

Git records it as renames, so `git log --follow` still reaches each file's
history:

```
R  docs/General/how-to-release.md -> docs/general/how-to-release.md
R  docs/General/how_search_works.md -> docs/general/how_search_works.md
... 8 in all
```

Commit it on its own — a rename mixed into a content commit is hard to read.

## Verify

```bash
git ls-files docs | grep -i general   # all lowercase, 8 files
git status --porcelain                # clean
```

Then open `docs/done/ops/versioning-system.md` and follow the link on line 16.

## Note for anyone with an older checkout

A `git pull` across this rename on a case-insensitive filesystem can leave both
spellings in the index. If `git status` looks strange afterwards,
`git checkout -- docs/` or a fresh clone settles it. Nobody else works in this
repo today, so this is only here in case that changes.
