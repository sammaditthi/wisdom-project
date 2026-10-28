# Web Release

> **Opened 2026-09-11.** The checklist for putting the two web surfaces live.
> Open *work* lives in [`static-site-backlog.md`](./static-site-backlog.md);
> hosting, topology and `_headers` in
> [`static-web-hosting.md`](../../decisions/static-web-hosting.md); the bar the
> site has to clear in
> [`static-site-constraints.md`](../../decisions/static-site-constraints.md); how
> it was built in `docs/done/web/`. This doc owns the release itself and the CI
> that runs it, and nothing else.
>
> **Scope: the apex static site**, and Flutter web's prod in §6, which goes out
> with it.

---

## The blocker

**Attaching the apex to the `sammaditthi` project is the next physical step, and
it must happen before the first `--prod`.** Until then a release bakes
canonicals, `og:url`s and every sitemap entry with an origin nobody can resolve.

Everything production lives in the **ops** account — the Pages projects, the
`sammaditthi.net` zone, R2, and the research Worker. Bulk Redirects only fire on
a zone in the same account, and Pages projects **cannot be moved between
accounts**.

**Same visit, same zone — two settings** (found 2026-10-05; why in
[`static-web-hosting.md`](../../decisions/static-web-hosting.md), SEO plumbing →
`robots.txt`):

- **Let AI crawlers in.** Cloudflare changed its AI-crawler defaults in July
  2025 (new domains blocked them) and on 15 Sept 2026 (separate search, training
  and agent settings). The domain was registered between the two, so check AI
  Crawl Control: allow search *and* training — search is how assistants cite
  the site, training is how models learn the text. The managed-`robots.txt`
  switch, renamed **Bot Preference Sync**, is already off (checked 2026-10-25 —
  [`things-to-consider-before-going-live.md`](../../general/things-to-consider-before-going-live.md));
  leave it off, because with it on and Training set to Block it prepends
  `Disallow: /` for GPTBot, ClaudeBot, CCBot and Google-Extended to the
  generated file.
- **`www` → apex**: a proxied `www` record and one permanent redirect rule.
  Nothing in the plan covers `www`, and people type it.

---

## 1. Before the release build

Ranked. Nothing left on it is a must.

| | item | why |
|---|---|---|
| ✅ done | ~~**C9 — HTML parse check over a full build**~~ | Shipped 2026-10-17: `check_markup.dart` in `deploy.sh`, on every deploy (§2). |
| ✅ done | ~~**C1 — asset-wiring tests**~~ | Shipped 2026-10-17: tests in the generator's suite and a `?v=` check in `deploy.sh` (§2). |
| ✅ done | ~~**B2 + B1 in one deploy**~~ | Shipped 2026-10-17, together: the toolbar icons are drawn from `site.css`, and the emblem is drawn at 36px from 1×/2×/3× copies. |
| ✅ done | ~~**C2 — CSP header**~~ | Shipped 2026-10-18: one `_headers` rule on `/*`, its script hash computed by the build; `deploy.sh` checks the live header after every upload (§3). |
| optional | A9 font preload, A8 heading duplication | Small, measure first. |

All five are specified in [`static-site-backlog.md`](./static-site-backlog.md).

---

## 2. Verify the build

**Lifted from the archived site plan §11**, which was the only live procedure in
it. `deploy.sh` enforces the first list on every deploy; the second is run
before a release, by the three tools below it.

**Automatic, in `deploy.sh` — a release forbids `--root` and `--skip-build`
both, so what ships is always the whole corpus and always checked:**

- the baked origin matches the deploy target, and every canonical names it
- `robots.txt` carries the matching `Sitemap:` line
- every `/assets/` and `/fonts/` link carries a `?v=` — both are cached
  `immutable` for a year, so a link without one is stale on readers' disks
  with no way to purge it (backlog C1)
- `check_links.dart` — every internal reference and every `#fragment` resolves,
  case-exact, no duplicate ids; it fails on zero links or zero fragments, so a
  pattern that stops matching cannot pass by checking nothing
- `check_markup.dart` — every page parses with no HTML5 parse error, so no
  unclosed or misnested element and no `<head>` closed early ahead of its
  canonical (backlog C9). Runs on every deploy, partial builds included

**Before a release — last run 2026-10-25.** Items 1 and 2 ran against two full
`--root all` builds sent by `--out` to a scratch directory, so a deploy
rebuilding `build/` at the time was never touched. Items 3–7 are now three
tools, each failing on a finding, so a release re-runs them rather than
trusting this list:

```sh
dart run static_site_generator/tool/check_in_browser.dart   # 3-6, in Chrome
dart run static_site_generator/tool/check_no_js.dart        # 3, every page
dart run static_site_generator/tool/check_unique_text.dart  # 7
```

`check_in_browser.dart` serves the build and drives headless Chrome itself, and
asks the page through CDP's DOM and CSS domains rather than through injected
script — the only way to see a page that has script execution switched off. It
finds the page of each shape in the build instead of naming node keys, so an
upstream re-sync cannot quietly narrow it to nothing: a shape it cannot find is
a failure. Nothing calls the three yet — wiring them in is §5's open item.

1. ✅ **Determinism — the hard one.** Two builds of the same input, same file
   count, `diff -r` silent: zero files differ. Cloudflare's upload dedup is
   purely content-hash, so a timestamp, a build id or unstable `Map` ordering
   would re-upload the entire site every deploy.
2. ✅ **Re-sync.** One Pali entry edited in `assets/text/kn-khp.json`, rebuilt →
   exactly `tipitaka/kn-khp-3.html` changed, plus the build's own
   `.manifest.json`. Sitemap and search index untouched, so neither carries body
   text. The content file was reverted: term 2 of the canon licence forbids
   keeping a local modification.
3. ✅ **JS off**, with script execution disabled at the engine. Every shape —
   leaf, chapter, container TOC, top TOC, `/` — renders its text and its links,
   all four layouts switch by clicking the radio labels, and the breadcrumb and
   the up button both navigate on a real mouse press. The search button never
   appears, which is also the proof that nothing ran: `site.js` is the only
   thing that unhides it. `check_no_js.dart` then carries the claim across
   `FIGURES.realPages` — no inline handler, no `javascript:` URL, no
   destination-less link, and no script but the inline layout restorer and the
   deferred `site.js`.
4. ✅ **Webfont off**, with every WOFF2 blocked at the network layer and the
   cache off. The reader text falls to Sinhala MN and the UI to Sinhala Sangam
   MN on macOS, nothing paints as tofu, and phone width falls back the same
   way; Windows gets Iskoola Pota from the same stacks. One real degradation:
   the system faces have no welded glyph for the Pali's touching consonants, so
   the Pali column shows a visible hal where the bundled face welds. Readable,
   and the Sinhala column is untouched — but it is what a reader loses while
   the webfont is still arriving, and the reason `font-display` matters here.
5. ✅ **Back/Forward across `#anchors`** → the `:has(:target)` filter
   re-evaluates on every Back and every Forward, and the chapter bar and the
   pager swap follow it. Checked in both engines: Chrome through real history
   traversal, and WebKit (iOS 26.2 Safari) driven the same way through the
   simulator, since `safaridriver` needs Safari's remote-automation switch
   thrown by hand. Neither engine needed the degradation this item allowed for.
   Only the Chrome half is in the tool; the WebKit half was a one-off.
6. ✅ **From several page shapes** — at both widths, because the up button is a
   phone control: above 31rem the stylesheet hides it and the breadcrumb is the
   way up. Every crumb's page really links to the one below it (each fetched,
   each 200), the up button is the parent, the deepest crumb is clickable, and
   the climb reaches `/` from every shape. On `/` the emblem points at `/` as
   it does everywhere; what the landing shape promises is that nothing sits
   above it.
7. ✅ **No text in two files.** The longest unbroken run of body text from pages
   sampled by a fixed stride across the corpus, looked for in every other
   output file. Two outcomes are not failures: the canon repeats stock formulas
   across unrelated suttas, and that is the source's doing. What fails is a
   phrase on a page *and* on an ancestor or descendant of it — a run printed
   both whole and in pieces — or body text reaching the search index or the
   sitemap.

---

## 3. Deploy

1. **Dev first** — `./scripts/static_site/deploy.sh --dev`: `sammaditthi-test`
   in the dev account, its production branch `main`. Kept out of the index by
   the generated `_headers`, which noindexes every `*.pages.dev` host.
2. **Prod** — `./scripts/static_site/deploy.sh --prod --yes`.

After every upload `deploy.sh` checks the live `/`: it answers 200, noindex on
dev and indexable on prod, with exactly the Content-Security-Policy the build
generated (backlog C2).

Both project names are in `scripts/config/targets.env`; `secrets.env` is credentials only.
If a deploy dies with `Error: {})` and no message, the real cause is only in
`~/Library/Preferences/.wrangler/logs/`. Never run two deploys at once — there is
no lock, and the second wipes `build/` mid-upload.

---

## 4. After the first prod deploy

**Walked 2026-10-25, the day of the first `--prod`.** One item failed, and it
is the one nobody could have caught from a header.

- [x] **404, not 200.** Two different missing paths both answered `404` with
      `no-store`. Owed from backlog A1: the soft-404 fix had shipped but had
      never been checked against live Pages, and it is the one defect that
      silently told Google every missing URL was the front page.
- [x] **Caching tiers.** `/assets/site.css` → `max-age=31536000, immutable`; a
      reading page → `max-age=0, must-revalidate`. The preview server does not
      apply `_headers` (backlog C4), so this was the first honest test.
- [x] **Origin baked right.** The canonical, the `og:url` and the sitemap
      `<loc>`s all name `sammaditthi.net`.
- [x] **`robots.txt` is exactly the generated file**, `Sitemap:` line and all,
      with nothing prepended by the zone — which also settles the managed-
      `robots.txt` question for good.
- [x] **`www` → apex**, `301`, path preserved.
- [ ] ❌ **DevTools console on a reading page: no `Refused to` line.** This one
      **fails.** The zone injects Cloudflare's JavaScript Detections script into
      every page and the CSP refuses it. Found without a browser, by hashing the
      live page's inline script and comparing it to the CSP's hash — `deploy.sh`
      compares the *header*, so the pipeline is blind to it. Full finding and
      the fix (Bot Fight Mode off; no CSP-side fix exists for a static site) in
      [`things-to-consider-before-going-live.md`](../../general/things-to-consider-before-going-live.md),
      blocker 2. Re-check this item once that switch is off.
- [ ] Search Console **and** Bing Webmaster Tools: submit `sitemap.xml`. Copilot,
      and partly ChatGPT search, read Bing's index rather than Google's.
- [x] **Research Worker released**, and its CORS list carries
      `app.sammaditthi.net`: that `Origin` now gets itself back, where before
      the release it got `allowed[0]`. A question asked in the prod app is still
      owed — the preflight is not the round trip.
- [ ] Start watching the 404 logs — they are the trigger for backlog **D3**
      (stub files vs Bulk Redirects). Decide from traffic, not projection.
- [x] **Every `*.pages.dev` host is `noindex`** — all four, prod and `-test`,
      site and app. `app-sammaditthi.pages.dev` is reachable and cannot be
      withdrawn (Pages has no switch for it, unlike `workers.dev`); Research is
      CORS-blocked there, accepted, with a Bulk Redirect as the fix if the URL
      ever surfaces.

---

## 5. CI

**Moved here from backlog C7, 2026-09-11** — it is release plumbing, so it lives
with the release. `.github/workflows/` is empty; every test is run by hand today.

**A workflow calls the project's scripts and holds no logic of its own** — plan
in [`test-all-and-release-all.md`](../../done/ops/test-all-and-release-all.md). Each
product's `scripts/<product>/test.sh` is its release gate and its `deploy.sh`
runs that first, so what was decided here now lives inside those scripts —
don't re-derive it:

- **`static_site/test.sh` runs from `static_site_generator/`.** Two paths in the
  suite are CWD-relative, and the root pubspec has no `test` dev_dependency.
- **The wiring guard runs ahead of the corpus run**, not beside it. A markup ⇄
  stylesheet disagreement should stop a deploy before the full build is
  generated.
- **`--quick` is the checkout-only half**; the corpus rows ride the release job,
  which checks the corpus out to generate the site anyway.
- **The release job calls `deploy.sh --prod --yes`**, not a raw wrangler action —
  every *automatic* gate in §2 lives in that script. The three tools under §2's
  second list do not, yet; that is the open item below.
- **Repo secrets use the names in `scripts/config/secrets.env`**, so a script
  reads the environment in CI and the file on a workstation.

| job | runs |
|---|---|
| every push / PR | `scripts/test_all.sh --quick` |
| release | `scripts/static_site/deploy.sh --prod --yes` — full `static_site/test.sh`, build, `check_links.dart`, `check_markup.dart`, upload, the live checks (§3) |
| integration (optional, macOS runner) | build the databases (`tools/`), then `scripts/app/test.sh` |

The push/PR job is the half that catches the silent failures. Build it first,
once the product scripts exist; it does not wait on the release job.

**⬜ Open: wire §2's three tools in.** They exist and pass; nothing runs them,
so the checks they replaced are still only as good as somebody remembering to
type three commands. All three need a full `build/`, so none of them belongs in
`--quick`:

- `check_no_js.dart` and `check_unique_text.dart` are plain passes over the
  output, like `check_links.dart` — they go in `deploy.sh` beside it, which
  puts them in the release job for free.
- `check_in_browser.dart` wants a Chrome on the runner, which nothing else here
  needs, and a failure in it is a reason not to ship rather than a reason to
  fail a push. Decide whether it earns a job of its own or stays the one step a
  release runs by hand.

---

## 6. Flutter web — dev live, prod ready to release

**Dev is live since 2026-09-27.** `./scripts/app/web/deploy.sh --dev` uploads
each new database version to R2 in the ops account (`db.sammaditthi.net`), then
the app to the `app-sammaditthi-test` Pages project in the dev account.
`--prod` (2026-10-18) does the same into `app-sammaditthi` in ops, at
`app.sammaditthi.net`, from a clean `main`. What it does, the one-time setup
and rollback are in
[`scripts/app/web/README.md`](../../../scripts/app/web/README.md).

**Release it with the static site, not before or after.** A prod static build
points "read in the app" at `app.sammaditthi.net`, and the app's link card and
shared links point at the apex.

**Three targets**, all in `scripts/app/web/`
([`test-all-and-release-all.md`](../../done/ops/test-all-and-release-all.md)):

| target | command | today |
|---|---|---|
| local | `run_mac.sh` | works: `flutter run -d web-server`, with the databases downloaded into the browser |
| dev | `deploy.sh --dev` | live |
| prod | `deploy.sh --prod` | ready; the Pages project and its domain are made by hand first |

Project names, the bucket and origins are in `scripts/config/targets.env`,
credentials in `scripts/config/secrets.env` — never in the deploy script.

[`move-web-onto-drift.md`](../../done/retiring-dart-server/move-web-onto-drift.md)
owns the app's half: the browser downloads `bjt.db` and `dict.db` into its own
file system and reads them through Drift, the way native reads its copies. The
host's half, all in place for dev:

- **COOP/COEP on every file** — `web/_headers`:
  `Cross-Origin-Opener-Policy: same-origin` and
  `Cross-Origin-Embedder-Policy: require-corp`. Not just the page: Drift starts
  its worker from `drift_worker.js`. Without them Chrome can't use OPFS, and the
  app shows its unsupported-browser message.
- **CanvasKit needs no flag.** Under `require-corp` a cross-origin subresource
  has to send `Cross-Origin-Resource-Policy`, and Google's CDN, where Flutter
  loads CanvasKit from by default, sends `cross-origin` (settled 2026-09-21,
  `move-web-onto-drift.md` step 8).
- **The build carries no `.db`.** The deploy takes both out and keeps
  `manifest.json`, which names each version the app downloads.
- **No `immutable` rule on the app's `/assets/*`**, unlike the static site.
  Flutter's asset URLs carry no hash, so a cached old manifest would pair a new
  app with an old database, and a cached old `tree.json` or `sc-to-bjt.json`
  would outlive the build that changed it. Pages' default (revalidate) is
  right, with the zone's Browser Cache TTL on *Respect Existing Headers*
  (README one-time setup, step 7).
- **One R2 file per database version**, never overwritten, old ones kept until
  deleted by hand — a tab on an older build may still be downloading one.
- **CORS for any origin**: the bucket's rule, plus a response-header rule on
  `db.sammaditthi.net` for requests without `Origin`. Cloudflare caches each
  file with the CORS header of the first request, so a list of origins would
  lock out all but the first.

Still open:

- **One test run against the bucket**, once the installer tests exist
  ([`web-database-installer-tests.md`](../retiring-dart-server/web-database-installer-tests.md)):
  run its file 1 with `--dart-define=DATABASE_BASE_URL=https://db.sammaditthi.net`.
  Every other run downloads the app's own asset copy, so this is the only
  automated check of the gzip and the cross-origin download. Its fetch spy
  counts URLs ending `.db`; from the bucket they end `.db.gz`, so widen it first.
- **Later:** `require-corp` blocks media from another host unless it sends
  `Cross-Origin-Resource-Policy` (e.g. recordings for the TTS plan), and COOP
  `same-origin` breaks popup sign-in. Nothing in the app today.

**Banked for prod** — cheap, and currently wrong:

- **A connection lost mid-download shows the error icon, not the offline one.**
  In `_download` (`web_database_installer.dart`) a `fetch` that throws or a
  `reader.read()` that fails reaches `_asFailure` and becomes `other`. Wrap
  each in its own `try` that throws `DatabaseInstallFailure(download, …)`;
  leave `sink.write` and `sink.close` to `_asFailure`, so a full disk stays
  `outOfSpace`. Step 4.2 of the installer tests can then check the kind.
- AASA / assetlinks on **both** origins. Both name the app's ID (AASA as
  `<Team ID>.<bundle id>`), so they wait on **App ID** in
  [`first-ios-release.md`](../mobile-release/first-ios-release.md);
  assetlinks also needs the Android release key's SHA-256 fingerprint.
- **Links between the two products.** Site → app is built on sutta and chapter
  pages (`deep-linking-and-shareable-urls.md`, first task §A) but missing from
  `/` and the TOC pages, and the site never names the app: "Sammaditthi" appears
  only in the domain. `/` should introduce it, under the BJT site name — the app
  CTA `static-web-hosting.md` gives `/`. Store badges and the iOS Smart App
  Banner come with the native release. App → site: §B there.
