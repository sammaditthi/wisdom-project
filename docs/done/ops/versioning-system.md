# Versioning system

One version number for the project, bumped by one command, shown faintly in the
settings menu. Plus the removal of the stale update-banner stack it replaces.

The changelog and the in-app "What's new" log are **a separate plan**. This one
stops at the version number and leaves marked seams for it — see
[What the changelog plan inherits](#what-the-changelog-plan-inherits).

Built and verified on 2026-10-21, from `489853a`. Every path, constant and
line number below was checked against the tree first; where the brief and the
tree disagreed, the resolution is recorded in place.

This doc is the reasoning and the build record. The day-to-day steps for
cutting a bug-fix, feature or major release live in
[docs/general/how-to-release.md](../../general/how-to-release.md).

## Decisions

| | |
|---|---|
| Scheme | `MAJOR.MINOR.PATCH+BUILD` in `pubspec.yaml`, e.g. `1.4.0+128` |
| Shown as | `1.4.0 (128)` |
| First release | `1.0.0+1` — what the pubspec already holds. Tag `v1.0.0` |
| Source of truth | the `version:` line of `pubspec.yaml`. Nothing else holds a version |
| Build number | lives in the pubspec, `+1` on every release. Never typed, never computed from git |
| Tooling | one in-repo `tools/release.dart`. No new dependency |
| Scope | one version for the whole repo (app, static site, research Worker); tag `v<version>` |
| Release notes | out of scope. A separate plan owns `CHANGELOG.md` and the log UI |

Why a build number at all: both stores refuse an upload whose build number is
not higher than the last one, so a re-upload of the same `1.4.0` needs `+129`
rather than a burnt `1.4.1`. It is also what turns a bug report into a single
commit.

Why not `git rev-list --count HEAD`, the usual CI trick: this repo's history was
rewritten on 2026-10-16, and a future rewrite would make the count *drop*, which
locks the project out of store uploads permanently. In the pubspec it only ever
goes up.

### Verified platform facts

- pub **rejects** a two-part version. `version: 1.4+128` →
  `Invalid version number: Could not parse "1.4+1"`. Three parts are not
  optional, which is why the display rule is a display rule.
- Android (`flutter.versionCode` / `versionName`), iOS
  (`$(FLUTTER_BUILD_NAME)` / `$(FLUTTER_BUILD_NUMBER)`) and Windows (CMake
  `FLUTTER_VERSION_*`) all inherit the pubspec version correctly.
- **macOS does not.** `macos/Runner.xcodeproj/project.pbxproj` hardcodes
  `MARKETING_VERSION = 1.0` and `CURRENT_PROJECT_VERSION = 1`;
  `macos/Runner/Configs/AppInfo.xcconfig` carries no version keys. A plugin
  reading the bundle would report `1.0` on the primary dev platform. Hence a
  generated Dart constant rather than `package_info_plus`: one value, identical
  on all six platforms, present in `flutter run` too.
- SDK floor is `>=3.5.2`, i.e. the short formatter style. The generator emits
  that style directly and `scripts/app/test.sh` fails the gate if it ever stops
  matching, so nothing shells out to `dart format`; do not raise the floor here
  (see `docs/todo/upgrades/`).

## One version system

After this work, exactly these things exist, and nothing else expresses a
version:

- `pubspec.yaml` `version:` — the source.
- `lib/core/version/app_version.gen.dart` — generated from it.
- the git tag `v<version>`.

Deliberately **not** a version, and must not become one:

- `static_site_generator/lib/sitegen.dart` `generatorVersion` — provenance, as
  `CLAUDE.md` requires. Leave it alone (see step 4).
- `deprecated/server/` — an archive, excluded from analysis. Leave it alone.

## Step 0 — Remove the stale update-check stack

The `/healthz` "a new version is available" toast died with the content server.
Nothing passes its `--dart-define`s, so it has been inert for months, and
`RELEASE_NOTES.md` is the file that used to feed it.

Delete:

- `RELEASE_NOTES.md`
- `lib/core/version/build_info.dart`
- `lib/core/version/version_check_service.dart`
- `lib/core/version/web_reload.dart`, `web_reload_stub.dart`, `web_reload_web.dart`
- `lib/presentation/providers/version_check_provider.dart`
- `lib/presentation/widgets/app/update_available_banner.dart`

Edit:

- `lib/main.dart` — drop the `update_available_banner.dart` import (line 25) and
  the `Positioned.fill(child: UpdateAvailableBanner())` child of the `Stack` in
  `builder:`, plus the paragraph of comment above it that explains the card.
  `DeepLinkListener` / `AppShortcuts` / `OverlayStackSync` and their comments
  stay exactly as they are. The `Stack` itself can stay — one child is fine, and
  leaving it keeps the diff small.
- `lib/core/utils/start_failure.dart` — its header cites
  `core/version/web_reload.dart` as the pattern. Re-point it at
  `data/database/local_database_executor.dart`, which is what `web_reload.dart`
  itself cited.
- `lib/core/localization/l10n/app_en.arb` and `app_si.arb` — remove
  `updateBannerTitle`, `updateBannerRefreshAction`, `updateBannerDismissTooltip`
  and their `@` descriptions. Then regenerate (below).

Checked before writing this: nothing in `test/` or `integration_test/` refers to
`UpdateAvailableBanner`, `UpdateInfo`, `BuildInfo`, `VersionCheckService` or
`versionCheckProvider`, and `reloadPage` has no caller outside the banner. The
`http` dependency stays — `lib/data/datasources/api_client.dart` uses it.

**Verify:** `flutter analyze` clean, and
`grep -rn "healthz\|BuildInfo\|UpdateInfo" lib` returns nothing.

### After any ARB edit

`flutter gen-l10n` (the repo has `l10n.yaml`; `app_localizations*.dart` are
tracked, so commit the regenerated files). The `flutter` CLI cannot run inside
the Bash sandbox — run it unsandboxed.

## Step 1 — The version constant

One generated file, `lib/core/version/app_version.gen.dart`:

```dart
// GENERATED by tools/release.dart — do not edit.
// Source: the `version:` line of pubspec.yaml.

class AppVersion {
  const AppVersion._();

  static const String name = '1.0.0';
  static const int build = 1;

  /// `1.0.0 (1)` — what the settings menu shows.
  static const String display = '$name ($build)';
}
```

The generator writes the two literals; Dart computes `display` (a `const`
interpolation of a `const String` and a `const int` is legal). Committed, like
the Freezed `.g.dart` files are.

It lives in `lib/core/version/`, not `lib/domain/`, for the reason the deleted
`version_check_service.dart` header gave: no entity, no repository, no
`Either<Failure, T>`. After step 0 this file is the folder's only tenant.

**Verify:** `AppVersion.display` compiles and matches the pubspec.

## Step 2 — `tools/release.dart`

It goes in the existing `tools/`, not a new root `tool/`: `tools/` is already
where the repo's maintenance scripts live (one of them Dart), and it is already
in `DART_DIRS` in `scripts/app/test.sh`, so the format gate and `flutter
analyze` cover the new file with no change to any script. A second,
near-identically named directory would be a trap.

`dart:io` only — **no new dependency**. It rewrites the single `version:` line with a regex rather than
round-tripping YAML, because a round-trip would strip the pubspec's comments.

```
dart run tools/release.dart status        # version, last tag, commits since it
dart run tools/release.dart bump <part>   # major | minor | patch
dart run tools/release.dart finish
dart run tools/release.dart check         # exit 1 if app_version.gen.dart has drifted
dart run tools/release.dart tag           # print `v<name>`, and nothing else
```

- **`bump <part>`** — raises that part (`minor` zeroes `patch`; `major` zeroes
  both) and raises `+BUILD` by exactly one. Pubspec only; it does not commit.
- **`finish`** — regenerates `app_version.gen.dart` from the pubspec, commits
  `chore(release): v<version>`, and creates the annotated tag `v<version>` (message `Release <version>+<build>`, so the build
  number is recorded even though the tag name omits it). It does **not** push,
  and it refuses if the tag already exists.

  Two behaviours the brief did not pin down, settled while building:

  - It commits **only** `pubspec.yaml` and `app_version.gen.dart`, by pathspec, so
    anything else staged or dirty stays out of the release commit.
  - It applies two of the deploy guard's own preconditions first: HEAD on
    `main`, and nothing dirty outside those two paths. Without them the tool
    walks you into a state whose only exit is a burnt version — the guard
    rejects the dirty tree, committing the rest moves HEAD off the tag, and
    then the guard rejects the missing tag.
  - If neither file differs from HEAD it **skips the commit and still tags**.
    That is the first release exactly: the pubspec already holds `1.0.0+1`, so
    there is nothing to commit and `v1.0.0` still has to point somewhere.

  The tag name carries the marketing version only, so a store re-upload that
  needs a fresh build number on the *same* `MAJOR.MINOR.PATCH` cannot be tagged.
  `bump patch` is the way out. If build-only re-uploads ever become routine, the
  tag format is the thing to revisit.
- **`check`** — regenerates in memory and exits 1 if the result differs from
  what is on disk. This is the drift guard step 4 calls. On success it also
  names the tag, so the guard answers both of its questions with one Dart
  start; the line is found by its `tag` label, not its position, because the
  changelog parse will add lines here.
- **`status`** — read-only, for a glance before releasing. Its last tag is
  matched against `v*`, so a per-product tag (Deferred, below) could never be
  reported as the repo's version.

Build it so the changelog plan *extends* these commands rather than
replacing them: `bump` gains the step that drafts notes, `finish` gains the step
that regenerates the notes file, `check` gains the changelog parse. Keep each
command's body a short sequence of named steps so another one can be slotted in.

**Verify:** `bump minor` moves the pubspec only; `finish` produces one clean
commit and one tag; `check` exits 0 afterwards and 1 after hand-editing
`app_version.gen.dart`.

## Step 3 — Show it in the settings menu

`lib/presentation/widgets/app/settings_menu_button.dart` — after the Pali
Letters item, a `PopupMenuDivider` and a final row holding `AppVersion.display`,
faint and right-aligned.

- Style it from a new token on `context.typography` beside `menuSectionLabel` —
  not an inline `TextStyle`. Dim with `withValues`; the repo uses it in 11 files
  and `withOpacity` in none.
- `enabled: false`, like every other item in that menu. It is plain text for now
  — there is nothing to open until the changelog plan lands.
- ARB, EN and SI: one key, `version`, with its `@` description, then regenerate.
  It takes the version as a placeholder — `"Version {version}"` /
  `"අනුවාදය {version}"` — so the row reads `Version 1.0.0 (1)` and follows App
  Language. A bare number would have needed no ARB key at all.
  `අනුවාදය` is mined from the local tipitaka.lk project
  (`web/src/views/Settings.vue`: `ඔබගේ වත්මන් අනුවාදය (version)`), as the
  existing labels were — see `reference_sinhala_ui_terms`.
- The row resolves its own `AppLocalizations` inside its `build`, for the reason
  `_MenuSectionLabel` in the same file does: `itemBuilder` runs once, at open
  time, so a label built there freezes at the language that was active then.

**Verify:** the settings menu shows `1.0.0 (1)` faintly at the bottom in both
app languages, and tapping it does nothing (the menu stays open, as the other
disabled rows do).

## Step 4 — The release guard

In `require_release_commit` in `scripts/lib/common.sh`, after the existing
branch and dirty-tree checks, add two checks: `tools/release.dart check` passes,
then HEAD carries the tag matching the pubspec version. Both guard a real cost —
a user reporting `1.4.0 (128)` for a build no tag points at. Nothing else; keep
the script lean.

The drift check runs **first** because it is the one that can read a malformed
`version:` line and say so; the tag check would otherwise fail first, looking
for a tag named `v`.

A shallow checkout has no tags, so when CI is wired up its checkout must fetch
them (`fetch-depth: 0`). There are no workflow files in the repo yet. The guard
also needs a Dart SDK on PATH, which `scripts/research_server/deploy.sh` did not
before this work: its CI job will need one even though the Worker build does
not. The guard reads the tag name from `release.dart tag` rather than parsing the
pubspec in shell — `sed` yields a version for a line with a trailing comment and
a bare `v` for a two-part version, both of which the tool refuses outright.

Two consequences to know before writing it:

- The guard is shared, so **every** prod release now needs a tag, including a
  site-only or Worker-only one. That is the price of one repo version, and
  `bump patch` + `finish` is the intended cost.
- The three call sites are not symmetric. `research_server/deploy.sh:90` and
  `app/web/deploy.sh:143` wrap the guard in `if [ "$DRY_RUN" = false ]`;
  `static_site/deploy.sh:160` does not, so `--prod --dry-run` will now demand a
  tag. Leave it that way — a prod dry run is a release rehearsal and should
  rehearse the guard. `scripts/release_all_dryrun.sh` is unaffected: it sweeps
  the static site with `--dev --dry-run`.

The order a release then runs in:

```
1. dart run tools/release.dart bump minor
2. dart run tools/release.dart finish
3. ./scripts/app/web/deploy.sh --prod    # and/or static_site, research
4. git push && git push --tags
```

Keep the repo version out of the static site's per-page
`<meta name="generator">`. Threading it through every page would change every
page's bytes on every release and turn a no-op site deploy into a full
re-upload. If the site should record the release, it goes in
`build-manifest.json` alone.

**Verify:** a prod deploy from an untagged commit refuses to run; the same
commit tagged passes.

## What the changelog plan inherits

Seams this plan leaves deliberately, so the changelog work is additive:

- `AppVersion.name` / `.build` / `.display` — what a release entry is keyed on.
  **It has to move first if the log is to reach past the app.** The generated
  file is under `lib/`, so only the Flutter app can import it;
  `static_site_generator` depends on `packages/wisdom_shared` and carries no
  Flutter dependency by design (PREREQ-3), so it cannot see `lib/` at all.
  A "What's new" on the static site, or stamping each build with its version so
  a deploy can verify *which* build answered, both need the generated file in
  `packages/wisdom_shared/lib/src/version/`, re-exported from
  `wisdom_shared.dart`. Cheap while the app is the only reader — one path in
  `release.dart`, three imports, two test files — and a three-product refactor
  afterwards.
- The tag `v<version>`, which gives `git log <lastTag>..HEAD` a start point for
  drafting notes from conventional-commit subjects. The commits in this repo are
  already Conventional Commits (`fix(l10n):`, `feat(reader):`).
- The `tools/release.dart` commands, each a short sequence of named steps with
  room for a changelog step.
- `_releasePaths` in `tools/release.dart` — the paths a release commit carries,
  and the only ones `finish` tolerates as dirty. **`CHANGELOG.md` must be added
  to it**, or the first hand-edited entry between `bump` and `finish` makes the
  tree dirty and `finish` refuses to release.
- The settings row from step 3, which becomes the tap target that opens the log.
  Note for whoever does it: `PopupMenuItem.onTap` fires *before* the menu route
  pops, so the dialog has to open from a post-frame callback, and the row has to
  stop being `enabled: false`.
- One line worth keeping from the deleted `RELEASE_NOTES.md`, quoted here so it
  needn't be dug out of git. It announces the Pali-letter settings, which are
  still unannounced, so it is a candidate first-release bullet:

  > New: පාළි බැඳි අකුරු, සුලබ අකුරු හා විශේෂ අකුරු - settings බලන්න

  Its English sibling must say **touching**, not "bandi" — see
  `feedback_touching_not_bandi`. The Sinhala බැඳි label is a deliberate
  survivor.

## Deferred

- **The macOS bundle version.** Remove `MARKETING_VERSION` and
  `CURRENT_PROJECT_VERSION` from `project.pbxproj` and set them from
  `$(FLUTTER_BUILD_NAME)` / `$(FLUTTER_BUILD_NUMBER)` in `AppInfo.xcconfig`.
  Affects only the bundle's own metadata — Finder's Get Info, notarization — and
  never what the app displays. `scripts/app/macos/deploy.sh` is still a
  placeholder, so this belongs with the first real desktop release.
- **GitHub Releases.** `gh release create v1.0.0` once a release is worth
  announcing. A CLI step, not something to script blindly.
- **Update prompts, if they are ever wanted again.** The stack deleted in step 0
  polled a dead endpoint, but its approach was sound and is worth re-deriving
  rather than restoring: on web compare `AppVersion.build` against
  `build/web/version.json`, which `flutter build web` already emits with
  `version` and `build_number`; on iOS the App Store Lookup API
  (`itunes.apple.com/lookup?bundleId=`); on Android the Play Core in-app update
  flow (`package:in_app_update`). Nothing today needs it — the stores prompt by
  themselves, and the web app has no stale-tab complaint on record.
- **Per-product versions** (`site-v*`, `research-v*`). One repo version is the
  decision; this stays available later without redoing any of the above.

## Handover notes

- Order: step 0 first and on its own — it is pure deletion and should be a clean
  commit before anything is added. Then 1 → 2 → 3 → 4. All five were built
  together on 2026-10-21 and left unstaged in one working tree; step 0 is still
  worth splitting into its own commit.

- The first release has not been cut: no tag exists, and `app_version.gen.dart`
  was written by hand to be byte-identical to what `finish` generates, which
  `check` proves. `finish` itself was exercised in a throwaway repo rather than
  this one, so no commit or tag was created here.
- `app_version.gen.dart` is committed and must never be hand-edited.
  `tools/release.dart check` is what keeps it honest.
- Inside the Bash sandbox, `dart run` exits 1 on a telemetry write before the
  script runs; use the SDK binary with `--suppress-analytics`. The `flutter` CLI
  (`gen-l10n`, `analyze`, `test`) must run unsandboxed. Do not bake either
  workaround into the scripts.
- Two simple tests were written, at the user's request on the day:
  `test/core/version/app_version_test.dart` (the drift guard over
  `app_version.gen.dart` against the pubspec, plus the `display` rule) and a case
  appended to `test/presentation/widgets/settings_menu_button_test.dart` that
  opens the menu in EN and SI and asserts the row's text and that it is
  disabled. Nothing private was exposed and no `@visibleForTesting` was added.
  `tools/release.dart check` covers the same drift from the deploy side.
- `flutter test` needs confirmation before running, per `CLAUDE.md`.
