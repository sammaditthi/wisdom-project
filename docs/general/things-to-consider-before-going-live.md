# Things to Consider Before Going Live

The cross-product items that have to hold before the first public `--prod`, and
the ones deliberately accepted. Nothing here is a deploy procedure: the release
itself is [`web-release.md`](../todo/web-strategy/web-release.md), and the
version-and-tag mechanics are [`how-to-release.md`](./how-to-release.md).

Swept 2026-10-22 against the tree and against the live hosts. **The first
`--prod` went out 2026-10-25** (`v1.0.0`), and everything below was re-checked
against prod that day. Measurements are dated because they are measurements,
not rules.

---

## Blockers

### 1. Attribution and licence notices

**The app side shipped 2026-10-24**: Settings > Anumodanā names the canon
source, both dictionary groups and the DPD licence. The site carries no credit,
and that half is now [`static-site-backlog.md`](../todo/web-strategy/static-site-backlog.md)
**D5** — an email to Path Nirvana, not code, since only they can say whether the
app's credit covers a separate distribution. The site went live without one, a
decision taken knowingly on 2026-10-24.

What the two licences require:

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

The answer also settles what covers the Sinhala translation and the
aṭṭhakathā, which the same email has to ask about.

### 2. Cloudflare injects a script the CSP refuses

**Found 2026-10-25, after the release, and still live.** Every HTML response on
the `sammaditthi.net` zone — apex and `app.` alike — carries an inline
`window.__CF$cv$params` script pointing at
`/cdn-cgi/challenge-platform/scripts/jsd/main.js`. That is **JavaScript
Detections**, and under Bot Fight Mode Cloudflare's docs say it *"is
automatically enabled and cannot be disabled"*: the only lever is Bot Fight
Mode itself, under Security → Settings → filter Bot traffic.

The apex CSP is `script-src 'self' 'sha256-…'`, so the browser refuses it, and
every page logs a refusal. No hash can ever cover it — its body carries a
per-request ray id and timestamp. Cloudflare's own answer is a **nonce**, which
a static site cannot mint, so there is no CSP-side fix here by construction.
`app.` sends no CSP, so there the script simply runs.

It was found by hashing the live page's inline script and comparing it to the
header, not in a browser: `deploy.sh` compares the CSP *header*, never the body,
so the pipeline cannot see this. The injection also ends "what we serve is what
we built" — the uploaded files are untouched, so build determinism and upload
dedup are unaffected, but a live page no longer byte-matches its build.

Two further reasons it should go: Bot Fight Mode challenges traffic it judges
automated, which cuts against letting AI crawlers in, and a permanent console
error is noise in the one diagnostic channel the products have.

    for u in https://sammaditthi.net/ https://app.sammaditthi.net/; do
      curl -s "$u" | grep -c '__CF\$cv\$params'   # want 0
    done

---

## Settled — do not re-open

- **Caching and content hashing.** Pages answers every file
  `public, max-age=0, must-revalidate` and revalidates at the edge; the static
  site adds one `immutable` tier for `/assets/*` and `/fonts/*`, keyed by the
  build-computed `?v=` hash. The app's `/assets/*` is deliberately left
  revalidating — Flutter's asset URLs carry no hash, so an `immutable` manifest
  would pair a new app with an old database (`web-release.md` §6). There is
  nothing to hash by hand and no header work left. This holds only with the
  zone's Browser Cache TTL on **Respect Existing Headers**, set 2026-10-28:
  until then the zone gave `.js`, fonts and images 4 hours, so for 4 hours
  after a deploy a returning visitor could run the old `main.dart.js` against
  the new `manifest.json`.
- **CORS allow-list.** Pinned to local, dev and prod web in
  `RESEARCH_CORS_ORIGINS` — exact origin match, no trailing slash. Deployed and
  verified 2026-10-25: `Origin: https://app.sammaditthi.net` now answers with
  that same origin, where before the release it fell back to `allowed[0]`
  (`http://localhost:8080`), Hono's behaviour on a miss.
- **The apex `robots.txt` is ours — the zone is not touching it.** The
  comment-only content-signals text live at `sammaditthi.net/robots.txt`
  (checked 2026-10-25) is Cloudflare's free-plan placeholder for a domain with
  no `robots.txt` of its own: legend comments, no `User-agent` line and no
  `Content-Signal` values, so it asserts nothing and blocks no crawler. The
  managed-`robots.txt` switch — renamed **Bot Preference Sync**, under Security
  → Settings → filter Bot traffic → Configure AI bot policies — is **off**,
  which is why there is no switch to find. Were it on, the managed block is
  *prepended* to a 200 from the origin, so the generated `Sitemap:` line would
  survive either way. Confirmed against prod on 2026-10-25: `/robots.txt` is
  exactly the generated file, `Sitemap:` line and all, with nothing prepended.
  There is no AI Crawl Control section on this zone to set either way; blocking
  a crawler would mean writing a rule, and none exists. GPTBot, ClaudeBot,
  CCBot and Googlebot user-agents each got a 200 the same day — which proves no
  UA-based rule, not how a verified crawler from its own IP is treated.
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
- **The apex is attached** to the `sammaditthi` Pages project, and serving the
  real site since 2026-10-25.
- **Every `*.pages.dev` host is `noindex`.** Checked 2026-10-25 on all four —
  `sammaditthi.pages.dev`, `app-sammaditthi.pages.dev` and both `-test` hosts.
  The app's `web/_headers` noindexes `/*` on every host it is served from, and
  the site's generated `_headers` noindexes every `*.pages.dev`, so a default
  domain is crawlable and never indexed. Pages has no switch to withdraw one:
  unlike `workers.dev`, `<project>.pages.dev` cannot be turned off.
- **`www` redirects** to the apex with a 301.
- **Soft-404 and the `immutable` tier work on live Pages**, checked on dev
  2026-10-22 and re-checked on prod 2026-10-25: two different missing paths →
  404 with `no-store`, `/assets/site.css` → `max-age=31536000, immutable`, and a
  page → `max-age=0, must-revalidate`.
- **Rollback** is the Pages dashboard: project → Deployments → the last good one
  → *Rollback to this deployment*. It names its own database versions and those
  are still on R2 (`scripts/app/web/README.md`).

---

## Open, not blocking

- **The app can't start offline.** Reopened 2026-10-28 by a real offline
  requirement. The databases are stored in the browser, but nothing stores the
  app's own files. Release builds carry Flutter's `flutter_service_worker.js`,
  a stub that only unregisters itself, and `flutter.js` registers it only where
  a registration already exists. A missing `flutter_bootstrap.js` or
  `canvaskit.wasm` also leaves "Getting ready…" up forever. Both are fixed in
  [`web-app-offline-start.md`](../todo/web-strategy/web-app-offline-start.md).
- **No error reporting and no analytics.** Nothing in either product. After
  launch the only signal is Cloudflare's request counts — a database install
  that fails on a real network is invisible. The CSP also blocks zone-injected
  scripts (Rocket Loader, Web Analytics), so this is a choice to make
  deliberately. The known-wrong offline-vs-error icon in
  `web_database_installer.dart` (`web-release.md` §6, "banked for prod") is the
  kind of thing we would otherwise never hear about.
- **Logging PII.** The Worker's own lines hold a request id, mode, model,
  status and timings, never the question. The `unhandled:` catch used to hand
  the runtime the whole error object — `cause` and own properties with it, so a
  fetch-shaped provider failure could carry the request, and the question, into
  the log; it now logs chosen scalars (`55ced8d`). Still to check: what Workers
  Logs (`observability` in `wrangler.jsonc`) retains per request.
- **The app origin answers 200 for everything.** An unknown path serves
  `index.html`, which is right for client-side deep links and harmless for
  search because the app is `noindex` on every host. One consequence found
  2026-10-25: `app.sammaditthi.net/robots.txt` is the SPA's `index.html` at 200,
  because there is no `robots.txt` on the app origin at all. Crawl-then-noindex
  still holds — `noindex` is a header on every response — and a file with no
  rules is an allow-all, so this costs nothing today. Worth confirming a bad
  `nodeKey` lands somewhere graceful rather than on a blank reader.
- **Research is CORS-blocked on `app-sammaditthi.pages.dev`.** Accepted
  2026-10-25. `RESEARCH_CORS_ORIGINS` names `app.sammaditthi.net`, not the
  project's default domain, so a reader who lands there gets a working reader
  and a Research feature that fails — the copy that looks fine until you ask a
  question. Nothing links to it and it is `noindex`. The fix, if the URL ever
  surfaces, is **one Bulk Redirect** to the custom domain, Cloudflare's own
  answer for this; ordinary Redirect Rules do not apply to a `pages.dev` host,
  since that zone is not ours. Widening the CORS list instead would make the
  duplicate fully usable, which is backwards. Deliberately deferred, not
  forgotten.
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

## Launch order — walked 2026-10-25

1. ✅ The credits surface, app side. The site half is blocker 1, and it is an
   email now.
2. ✅ The `unhandled:` log line (`55ced8d`).
3. ✅ Dashboard — nothing to set: no AI Crawl Control section on this zone and
   no rule blocking a crawler, see Settled.
4. ✅ `scripts/release_all_dryrun.sh`, run by hand. Its canon heartbeat
   reported up to date, and it was: upstream `master` still stood at the
   `66e39b36` the receipt names.
5. ✅ `dart run tools/release.dart finish` → `v1.0.0`, pushed with its tag.
6. ✅ `scripts/research_server/deploy.sh --prod`, CORS re-checked after it.
7. ✅ `scripts/static_site/deploy.sh --prod`, then
   `scripts/app/web/deploy.sh --prod`.
8. ✅ `web-release.md` §4 walked — every header, redirect, canonical and
   caching check green. It is what surfaced blocker 2.

**Left after launch:** Bot Fight Mode off (blocker 2) · the Path Nirvana email
(blocker 1) · `sitemap.xml` to Search Console **and** Bing Webmaster · start
watching the 404 logs, which are the trigger for backlog D3. The prod app's
database install and a Research question both answered on the day.

**A canon sync is now the first one with consequences.** Upstream pushed six
commits at 2026-10-25T04:11Z, hours after the release, and their own messages
name *"numbering corrections: 105 sutta/section ids in the BJT Mūla text"*, BJT
text corrections, and an atta Pāḷi re-sync with VRI. Section ids are what
`tree.json` nodeKeys are built from, so this is the sync that can move page
URLs — and the URLs are now public, canonicalised and in a submitted sitemap,
where before the release a shifted key cost nothing. Which pages moved can only
be read from the `tree.json` diff inside `sync-regen.sh` (the GitHub compare API
caps its file list at 300 and these six commits exceed it), and a sync that
orphans indexed URLs is what makes backlog **D3** — stubs vs Bulk Redirects —
a decision rather than a deferral. Take the sync deliberately, review that diff,
then `bump patch` and re-release.

Mobile stays gated by `docs/todo/mobile-release/`; the android, ios and macos
`deploy.sh` are placeholders that exit 3.
