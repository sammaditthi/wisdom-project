# Things to Consider Before Going Live

The cross-product items that have to hold before the first public `--prod`, and
the ones deliberately accepted. Nothing here is a deploy procedure: the release
itself is [`web-release.md`](../todo/web-strategy/web-release.md), and the
version-and-tag mechanics are [`how-to-release.md`](./how-to-release.md).

Swept 2026-10-22 against the tree and against the live hosts. Measurements are
dated because they are measurements, not rules.

---

## Blockers

### 1. Attribution and licence notices

Neither product credits its sources. `grep -rn -i "licen\|attribut" lib/` and the
same over `static_site_generator/lib/render/` both return nothing: no about
screen, no licence row, no site footer credit. The settings menu's version row
is the only thing there, and it opens nothing.

Two licences are already breached the moment the site is public:

- **The canon text — CC BY-ND 4.0** (`LICENSE.md` in the upstream mirror). Four
  terms, and term 4 is *"Attribution should be given to tipitaka.lk"*. Term 2
  forbids local modification — errors go to path.nirvana@gmail.com, never into
  our copy. Term 3 wants an automated or easy sync method, which
  `scripts/bjt-sync-regen/sync-regen.sh` satisfies, and
  `release_all_dryrun.sh` reports when the vendored canon has fallen behind.
- **The dictionary — CC BY-NC-SA 4.0**, carried in `dpd.db`'s own `db_info`
  table beside its citation string (`docs/todo/dictionary/dpd-provenance-and-refresh.md`).
  Attribution, share-alike and non-commercial. Free app, so NC is fine; the
  notice is not optional.

**Unresolved:** that licence covers *"the Buddha Jayanthi Pali text"* only. The
Sinhala translation and the aṭṭhakathā have no stated terms in the upstream repo
— its README says only "check the LICENSE file if you wish to extract any
content". Ask path.nirvana what covers them rather than assuming the same file
does.

Needed: one about/credits surface per product naming the canon source, the
dictionary and its licence, and the translation and commentary sources. A site
footer or `/` section, and one settings row in the app.

### 2. The research Worker's prod CORS is a deploy behind

Measured 2026-10-22, preflight only — no Gemini call:

| `Origin:` | live `access-control-allow-origin` |
|---|---|
| `https://app-sammaditthi-test.pages.dev` | the same origin ✅ |
| `http://localhost:8080` | the same origin ✅ |
| `https://app.sammaditthi.net` | **`http://localhost:8080`** ❌ |

`wrangler.jsonc` lists the prod origin; the deployed Worker predates that line.
Hono's `cors()` answers `allowed[0]` on a miss (`app.ts`), so that fallback *is*
the symptom. Research is CORS-blocked in the prod app until
`scripts/research_server/deploy.sh --prod` runs.

### 3. Cloudflare's managed robots.txt is answering at the apex

`curl https://sammaditthi.net/robots.txt` → 200, `max-age=14400`, and it is
Cloudflare's content-signals preamble with **no directives at all**: no
`User-agent`, no `Allow`, and no `Sitemap:` line. Pages has no deployment yet,
so that file is purely the zone's.

The generated `robots.txt` exists for its `Sitemap:` line (`robots.dart`), and
the zone will alter or shadow it. The signals it injects may also assert
`ai-train=no`, the opposite of the decision in `web-release.md` to let AI
crawlers in for both search and training. Dashboard, before the first `--prod`:
AI Crawl Control → managed robots.txt off, or confirm its signals say what we
want.

### 4. HEAD carries no tag

The version system landed in `2db020c`, but `git tag -l` is empty. Every prod
deploy calls `require_release_commit`, which refuses an untagged HEAD — and
`static_site/deploy.sh --prod` refuses even for `--dry-run`. The first release
is `dart run tools/release.dart finish` (no bump; `1.0.0` is the version),
then `git push --tags`.

---

## Settled — do not re-open

- **Caching and content hashing.** Pages answers every file
  `public, max-age=0, must-revalidate` and revalidates at the edge; the static
  site adds one `immutable` tier for `/assets/*` and `/fonts/*`, keyed by the
  build-computed `?v=` hash. The app's `/assets/*` is deliberately left
  revalidating — Flutter's asset URLs carry no hash, so an `immutable` manifest
  would pair a new app with an old database (`web-release.md` §6). There is
  nothing to hash by hand and no header work left.
- **Service workers.** Flutter's is deprecated and off: the generated
  `flutter_bootstrap.js` sets `serviceWorkerVersion = null`, and the
  `flutter_service_worker.js` in the build is a 0-byte file that is never
  registered. No stale-SW lockout to design against, nothing to strip from the
  build. Revisit only for a real offline or installable-PWA requirement.
- **CORS allow-list.** Pinned to local, dev and prod web in
  `RESEARCH_CORS_ORIGINS` — exact origin match, no trailing slash. (Deploying
  it is blocker 2.)
- **The research privacy notice.** Shipped with the Settings dialog
  (2026-10-24): a line on Research's empty state (`researchPrivacyNote`) and
  the full statement under Settings > General > Privacy
  (`researchPrivacyDetail`). The wording tracks Google's *unpaid*-tier terms —
  re-check it only if the Worker moves to the paid tier, where Google does not
  use prompts to improve its products. Store listings will still need a hosted
  URL.
- **Request size and deadline caps.** `contracts.ts` caps the question and the
  history; `config.ts` gives each mode a deadline.
- **Rate limiting.** A per-IP zone rule on `/research`, set up 2026-09-27
  (recipe in `scripts/research_server/README.md`). It is why `workers_dev` and
  `preview_urls` stay off — either address would bypass the rule. App Check is
  consciously deferred; the accepted residual risk is quota burn, not money
  (`research-endpoint-security-before-testers.md`).
- **The apex is attached** to the `sammaditthi` Pages project: apex and
  `sammaditthi.pages.dev` serve the identical not-yet-deployed placeholder.
- **`www` redirects** to the apex with a 301.
- **Soft-404 and the `immutable` tier work on live Pages**, checked on dev
  2026-10-22: `/tipitaka/does-not-exist` → a real 404 with `no-store`, and
  `/assets/site.css` → `max-age=31536000, immutable`. `web-release.md` §4 owes
  the same two checks against prod, but the mechanism is no longer in doubt.
- **Rollback** is the Pages dashboard: project → Deployments → the last good one
  → *Rollback to this deployment*. It names its own database versions and those
  are still on R2 (`scripts/app/web/README.md`).

---

## Open, not blocking

- **No error reporting and no analytics.** Nothing in either product. After
  launch the only signal is Cloudflare's request counts — a database install
  that fails on a real network is invisible. The CSP also blocks zone-injected
  scripts (Rocket Loader, Web Analytics), so this is a choice to make
  deliberately. The known-wrong offline-vs-error icon in
  `web_database_installer.dart` (`web-release.md` §6, "banked for prod") is the
  kind of thing we would otherwise never hear about.
- **Logging PII.** The Worker's own lines hold a request id, mode, model,
  status and timings, never the question. Still to check: what Workers Logs
  (`observability` in `wrangler.jsonc`) retains per request, and what the
  `unhandled:` dump in `app.ts` can carry out of a provider error object.
- **The app origin answers 200 for everything.** An unknown path serves
  `index.html` (checked on dev), which is right for client-side deep links and
  harmless for search because the app is `noindex` on every host. Worth
  confirming a bad `nodeKey` lands somewhere graceful rather than on a blank
  reader.
- **`og-card.png` is referenced without a `?v=`.** `web/index.html` points the
  app's share card at the static site's copy, which sits under the `immutable`
  tier. Replacing that image later leaves scrapers on the old one for a year;
  rename it if it ever changes.
- **Asset size.** `main.dart.js` was 3.5 MB on 2026-10-22. Nothing watches it,
  and Flutter web bundles grow quietly with dependencies. A budget check in the
  deploy would catch a regression before users do.
- **No CI.** `.github/` does not exist, so `scripts/test_all.sh` by hand is the
  whole gate. The workflow is specified in `web-release.md` §5.
- **The site never names the app.** "Sammaditthi" appears only in the domain;
  `/` and the TOC pages carry no app link. Product gap, tracked in
  `web-release.md` §6.

---

## Deploy pipeline

- **Nothing verifies *which* build went live.** Each deploy does check its own
  product after the upload, past the bare 200 from `expect_http`
  (`scripts/lib/common.sh`, six tries): the app asserts `noindex` and both
  isolation headers, the static site asserts the live CSP equals the generated
  `_headers` value exactly, and the research Worker parses `/health` for
  `"mode":"live"` and a configured key. What none of them assert is the build
  that answered — a server serving a stale static root passes every one. The
  versioning work supplies the marker: every prod deploy has `v<name>` at HEAD,
  so the build could stamp its version into the output and the deploy could
  compare it. That needs the generated version file to move out of `lib/` first
  — see the changelog seams in `docs/done/ops/versioning-system.md`.

---

## Launch order

1. The credits surface (blocker 1) — the only code work on this list. The app
   side is done: Settings > Anumodanā names the sources, the dictionaries and
   their licences. The site footer is still open.
2. The `unhandled:` log line.
3. Dashboard: managed robots.txt off, AI Crawl Control allowing search and
   training (blocker 3).
4. `scripts/release_all_dryrun.sh` — proves all six targets still build, and
   reports whether the vendored canon is stale.
5. `dart run tools/release.dart finish`, then `git push && git push --tags`
   (blocker 4).
6. `scripts/research_server/deploy.sh --prod`, then re-run the preflight table
   in blocker 2.
7. `scripts/static_site/deploy.sh --prod`, then `scripts/app/web/deploy.sh --prod`
   — the site bakes app links and the app bakes site links.
8. Walk `web-release.md` §4, the post-deploy list.

Mobile stays gated by `docs/todo/mobile-release/`; the android, ios and macos
`deploy.sh` are placeholders that exit 3.
