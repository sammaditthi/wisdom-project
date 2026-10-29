# Testing the app ↔ site seam

> **Done 2026-10-29.** Every gap this plan listed was re-checked against the
> code. One test was missing and is written; the rest were already covered, or
> guarded nothing a gate does not already catch. This records what guards the
> seam and why the other tests are not written, so they are not proposed again.
>
> The rule lives in `docs/decisions/reading-units-and-grouping.md`; every
> corpus count lives in `static_site_generator/CORPUS_FIGURES.md`.

## The seam

Shipped 2026-08-23 (S8):

- `SitePlan` lives in `wisdom_shared`. `urlFor`, `pageOf`, `servingLink` and
  `resolveTarget` all read one map.
- The app decodes `tree.json` through `TipitakaTree.fromJson`, and so gets
  `correctedTreeCoordinates`.
- Links carry the page that serves them: `TipitakaLink.pageKey`, a
  `#<leafKey>` fragment, a `#via_<canonKey>` origin marker, `.html` tolerated.

The app does **not** adopt the site's grouping (decided 2026-09-07): its
reading unit is the tapped node's own subtree. It uses the plan for links only.

## What guards it

| what | where |
|---|---|
| `bjt.db` holds exactly the text the site reads | `static_site_generator/tool/verify_corpus_invariants.dart` §5 |
| Sibling order matches the pre-extraction app code | `verify_corpus_invariants.dart` §2 (frozen oracle) |
| Every URL the site writes opens the node it was written for | `verify_corpus_invariants.dart` §3, whole corpus, through `resolveTarget` |
| The frozen snapshot still describes the tree | `plan_corpus.dart` `_integrity` |
| The app gets the coordinate corrections | `packages/wisdom_shared/test/tree/tipitaka_tree_test.dart`, "coordinate corrections" — the site passes the map explicitly, the app relies on the default |
| Both surfaces cut a node's text at the same rows | shared `SliceIndex` — the app's `ReaderUnitResolver` and the site's slicer |
| One address per node from `urlFor` and `servingLink`, read back by `resolveTarget` | `packages/wisdom_shared/test/pages/site_plan_test.dart` |
| Search sends a hit to the URL the site writes | `static_site_generator/test/wiring_contract_test.dart` — `hrefFor` is transcribed into Dart, and a test pins the script's text so the copy cannot drift |
| Copy link and open link in the app, including the plan or tree failing | `test/presentation/providers/deep_link_provider_test.dart` |
| A web start URL keeps the sutta after its `#` | **manual only** — `docs/todo/web-strategy/web-release.md` § 6 |

`verify_corpus_invariants.dart` and `plan_corpus.dart` run in the corpus lane of
`scripts/static_site/test.sh`, which `sync-regen.sh` runs after every re-sync
and `scripts/static_site/deploy.sh` runs before every deploy.

## Not written, and why

- **`SitePlan.build`'s throw paths.** `_integrity` checks the same three
  snapshot shapes before the plan is built, in every gate that can see a stale
  snapshot. The four root guards fire only on a mistyped `--root`, loudly. In
  the app a firing guard is caught and links fall back, so a test changes
  nothing there.
- **An app-level test decoding the real `tree.json`.** The realistic way the
  app loses the corrections is the decoder's default changing, which the shared
  test pins (verified: flipping the default fails it).
- **`loadSitePlan` / `sitePlanProvider` unit tests.** The page rules are pinned
  in `site_plan_test`, a failed plan already falls back (pinned in
  `deep_link_provider_test`), and caching only affects speed.
- **Comparing the app's text with the built HTML.** Every input to it is shared
  or checked above. Since 2026-09-07 only a single sutta could be compared
  anyway, and the sandboxed macOS app cannot read the built site.
- **A stale-mock warning.** `scripts/app/test.sh` regenerates the mocks.
- **`plan_corpus.dart --check` in the app gate.** Only a re-sync can make the
  snapshot stale, and `sync-regen.sh` runs the corpus lane after every one.
- **An automated web start-link test.** Tried 2026-10-29; the integration
  harness cannot reproduce the start-up timing. Findings in the deep-linking
  doc, § D.

## Habit

Before a change to shared page logic, build one subtree (`--root an-1`) and
diff it against a build from before the change. A refactor must move no output.

## How to run

```bash
./scripts/app/test.sh           # app: unit + widget, wisdom_shared, integration (macOS + Chrome)
./scripts/static_site/test.sh   # wisdom_shared, wiring contract, corpus lane
```

A failing integration file is not a regression until it fails alone:
`flutter test integration_test/<file>.dart -d macos`. `all_tests.dart` flakes
under shared-database contention.
