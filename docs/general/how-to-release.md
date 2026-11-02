# How to Release

**Every release is these two commands. Don't release any other way.**

```bash
# write the notes under "## Unreleased" in CHANGELOG.md, then:
./scripts/release.sh minor     # raise the version, date the notes, commit (local only)
./scripts/deploy.sh --prod     # test everything, ask, tag, push, deploy every product
```

If anything fails, fix it and run `./scripts/deploy.sh --prod` again. Don't
fall back to a product's own `deploy.sh --prod`: it ships one product, skips
the push and the order, and refuses unless `deploy.sh` already tagged this
commit and pushed it to GitHub.

`./scripts/release.sh` on its own says where things stand. Dev deploys stay
each product's own `deploy.sh --dev`.

## Which part

| Part | When | Example |
|---|---|---|
| `patch` | a fix: wording, a crash, a layout | `1.1.0+2 → 1.1.1+3` |
| `minor` | something new that keeps everyone's saved state | `1.1.0+2 → 1.2.0+3` |
| `major` | a rewrite, or anything that breaks saved settings, bookmarks or deep links | `1.1.0+2 → 2.0.0+3` |

A site-only or Worker-only change still takes a version, usually `patch`.

## The version

One version covers the whole repo, in the `version:` line of `pubspec.yaml`:
`1.1.0+2` is the name (tagged `v1.1.0`) plus the build number the stores
compare, which only climbs. Only `release.sh` changes it, and
`lib/core/version/app_version.gen.dart` follows from it — never edit either
by hand. macOS still hardcodes its bundle version in `project.pbxproj`
(deferred, `docs/done/ops/versioning-system.md`).

## The CHANGELOG entry

`CHANGELOG.md` is the release notes, shown as written in the app's "What's new"
and pasted as is into a store's.

```markdown
## Unreleased
### New
- Singlish: R types repaya, and c types ච

### Fixed
- Searches with : or ? no longer fail
```

`release.sh` turns the heading into `## 1.2.0 - <today>`. It refuses unless:

- `## Unreleased` is the newest entry and has at least one note.
- Every `- ` note sits under a `### ` group.
- **At most 5 notes a group, 500 characters an entry** (Google Play's limit).
  Merge similar ones: "UI improvements: …" is fine.

`deploy.sh` checks the entry again before it tags. By convention: groups are
`### New`, `### Improved`, `### Fixed`, in that order; a plain headline line
under the heading for x.0.0 only; English, written for a reader, not copied
from commits; only what an app reader sees ("On the web, …" for one platform;
website-only changes get no line).

## When something goes wrong

| What happened | Do |
|---|---|
| A test failed | Fix, commit, `./scripts/deploy.sh --prod`. Nothing was tagged, so the fixed commit gets the version. |
| The push or an upload failed | `./scripts/deploy.sh --prod`. The tag is on HEAD, so it skips the tests and re-deploys what already shipped unchanged. Rebuilt the databases since? Run `./scripts/app/test.sh` first: the tag covers committed files only. |
| Picked the wrong part | See below, while the release commit is unpushed. |

```bash
git reset HEAD~1     # drop the release commit; the notes stay in the file
git checkout -- pubspec.yaml lib/core/version/app_version.gen.dart
# in CHANGELOG.md, turn "## 1.2.0 - …" back into "## Unreleased"
./scripts/release.sh patch
```

Once the tag is pushed the version stands; a mistake gets a new one.

## Why a prod deploy refuses

Every product's prod deploy runs `require_release_commit`
(`scripts/lib/common.sh`). That is what lets `deploy.sh` pass `--skip-tests`
to them, and what makes `git checkout v1.2.3` give a user's exact code.

| Refusal | Fix |
|---|---|
| not on main | merge first |
| working tree dirty (staged and untracked count) | commit or stash |
| `app_version.gen.dart` drifted from the pubspec | undo the hand edit, commit |
| newest CHANGELOG entry isn't this version's, or breaks the rules | `release.sh` first |
| HEAD has no tag for this version | `./scripts/deploy.sh --prod` makes it |
| GitHub lacks that tag | `./scripts/deploy.sh --prod` pushes it |
| GitHub's tag is a different one | a pushed tag never moves: `release.sh patch` |

The android, ios and macos `deploy.sh` are placeholders (exit 3). Store
releases are gated by `docs/todo/mobile-release/`.

## Underneath

```bash
dart run tools/release.dart status      # ./scripts/release.sh alone
dart run tools/release.dart cut minor   # ./scripts/release.sh minor
dart run tools/release.dart check       # exit 1 on drift or a bad entry; else `tag  v1.1.0`
```

## Later: CI

A job runs the same `./scripts/deploy.sh --prod --yes`. It needs the
databases (gitignored: build them or fetch from R2), a macOS runner (the app's
tests need macOS and Chrome), `fetch-depth: 0` for the tags, `contents: write`
to push the tag, and pinned Flutter and Node 22.

## Notes

- A store re-upload on the *same* name can't be tagged (`v<name>` has no
  build number): `release.sh patch` is the way out.
- Follows Semantic Versioning, Keep a Changelog (groups named for store
  readers), annotated tags, never moving a pushed tag, and tagging only after
  tests pass.
