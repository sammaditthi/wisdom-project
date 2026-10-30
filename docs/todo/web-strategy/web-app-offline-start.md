# Web app: start with no connection

Once a visit has installed both databases, reloading the app offline should
open it. Today it can't. Two steps, done together: **B** makes a missing start-up
file show an error instead of "Getting ready…" forever, and **A** stores the
app's own files so a reload doesn't need the network.

## What was found (2026-10-28)

Checked against `app.sammaditthi.net` in headless Chrome 156, loading the page
once per file with that one file blocked.

- **Nothing stores the app's files.** The databases are in OPFS, but the page,
  `main.dart.js`, fonts and the manifests live only in the browser's HTTP cache.
  The build's `flutter_service_worker.js` is Flutter's stub that only
  unregisters itself. In headless Chrome an offline reload fails at
  `index.html` (`ERR_INTERNET_DISCONNECTED`), because Pages sends it
  `max-age=0, must-revalidate`. The reported case, in desktop Chrome, got as
  far as `#boot`. How Chrome served the page there is unexplained, and with
  this plan it no longer matters.
- **Two missing files leave "Getting ready…" up forever.** Every other missing
  file shows the error lines or lets Flutter paint.
  - `flutter_bootstrap.js`: the handlers that show the error live inside it.
  - `canvaskit.wasm`: `flutter.js` starts fetching and compiling it as soon as
    CanvasKit starts loading. `instantiateWasm` awaits that inside a callback
    nothing watches and returns `{}`, so a failure never calls Emscripten
    back. Emscripten waits forever and `initializeEngine()` never settles. It
    surfaces only as an `unhandledrejection`.
- **CanvasKit stays on Google's CDN.** Its URL carries the engine revision
  (`www.gstatic.com/flutter-canvaskit/<rev>/…`), so a Flutter upgrade is a new
  URL and the year-long cache can never serve a wrong version. A local
  `canvaskit/` (`--no-web-resources-cdn`) has no version in its URL. Keep the
  CDN.

## Checked against the source (2026-10-29) — don't recheck

Flutter 3.44.1, drift 2.35.0, and the live headers. Recheck only after
upgrading either one. Flutter 3.47.0 still fills the token the same way and
still drops a failed `canvaskit.wasm` the same way, so that upgrade changes
nothing here.

- **Flutter's worker would replace ours.** With `serviceWorkerSettings`,
  `flutter.js` (`service_worker_loader.js`) calls `getRegistration()`. If
  anything is registered, it registers `flutter_service_worker.js?v=…` and
  waits up to 4 s for it before loading anything else. That stub unregisters
  itself on activate and reloads every open tab.
- **`serviceWorkerVersion`.** `flutter build web` fills it with a random number,
  because the default `--pwa-strategy` is offline-first. `flutter run` fills
  `null` in every mode, `--release` included (`resident_web_runner.dart` passes
  `ServiceWorkerStrategy.none`), and so does `flutter drive`. So the worker
  never registers under `run_mac.sh` or the web integration tests. To try it
  locally, serve a `flutter build web` output with COOP/COEP. Otherwise use
  the dev deploy.
- **Fonts.** The engine catches a failed font download
  (`canvaskit/fonts.dart`), so Step 1's listener never fires on one. The app
  bundles no Roboto, so the engine fetches it from `fonts.gstatic.com` on
  every start.
- **Headers.** Every app file is `max-age=0, must-revalidate` with COOP/COEP.
  CanvasKit (`…/<rev>/chromium/canvaskit.{js,wasm}`) and Roboto are
  `max-age=31536000`, `Access-Control-Allow-Origin: *`,
  `Cross-Origin-Resource-Policy: cross-origin`.
- **Pages never sends a 404.** A missing path gets `index.html` as
  `200 text/html` (`/offline_worker.js` does today).
- **Cloudflare's injected script** (`__CF$cv$params`) loads `/cdn-cgi/…` inside
  a hidden iframe, so its failure never reaches the bootstrap's script-error
  handler.
- **Drift's workers load two files themselves.** `drift_worker.js` starts when
  the installer probes, around the first frame. `sqlite3.wasm` is fetched
  inside that worker when a database opens (`wasm_setup/shared.dart`). The
  page fetches neither, so neither need appear in the page's
  `performance.getEntriesByType('resource')`.
- **The installer** downloads with `cache: 'no-store'` and asks
  `navigator.storage.persist()` on every start. On a reload with both
  databases in, it shows the app before the probe.
- **No `deferred as` imports**, so there are no lazily loaded code files to go
  stale offline.

## Step 1 — B: an error, never an endless "Getting ready…" (built)

Files: `web/index.html`, `web/flutter_bootstrap.js`.

1. **The bootstrap itself.** In `index.html`, give the script tag an
   `onerror` that adds `failed` to `#boot`. Also move the button's reload into
   the HTML (`onclick="location.reload()"`), and drop the
   `addEventListener('click', …)` from the bootstrap: if the bootstrap never
   loads, nothing would wire the button. `onerror` catches a failed download
   only, not a bootstrap that loads but can't run (see the token in Step 2).

   ```html
   <script src="flutter_bootstrap.js" async
     onerror="document.getElementById('boot')?.classList.add('failed')"></script>
   ```

2. **CanvasKit.** In `flutter_bootstrap.js`, listen for `unhandledrejection`
   from the top of the file until `initializeEngine()` resolves, and call
   `fail()` on one. While the engine starts, an unhandled rejection is the
   swallowed CanvasKit failure. Remove the listener once the engine is up, so
   a later stray rejection can't put the error over a working app.

   ```js
   // flutter.js drops a failed canvaskit.wasm without rejecting anything we
   // await; it shows only as an unhandled rejection.
   window.addEventListener('unhandledrejection', fail);
   // … in onEntrypointLoaded, right after initializeEngine() resolves:
   window.removeEventListener('unhandledrejection', fail);
   ```

**Check:** in Chrome DevTools, open *Network request blocking*, then reload once
per pattern:

| Blocked | Want |
|---|---|
| `flutter_bootstrap.js` | error lines; *Try again* reloads |
| `canvaskit.wasm` | error lines |
| `*.ttf` | the app still paints (no false error) |
| nothing | the app paints, console clean |

## Step 2 — A: our own service worker (built)

Files: new `web/offline_worker.js`; `web/flutter_bootstrap.js`;
`scripts/app/web/README.md` (Rollback: the kill switch below).

### Rule

**Network first; the stored copy only when the network fails.** Online, every
load is the newest deploy, exactly as today. Offline, each file comes from the
copy stored the last time it loaded.

- **Stored:** GETs to our own origin (not `/cdn-cgi/`, which is Cloudflare's),
  CanvasKit from `https://www.gstatic.com/flutter-canvaskit/`, and fonts from
  `https://fonts.gstatic.com/` (Roboto on every start, Flutter's fallback
  fonts when a glyph needs one).
- **Never stored:** a database, any URL ending `.db`, by either path. A build
  without `DATABASE_BASE_URL`, such as a local `flutter build web`, downloads
  them from our own origin, and locally the download can finish before the
  worker takes over, putting it on the first-visit list (below). Other hosts
  are never touched: the R2 databases and the research Worker.
- **Page loads:** every navigation, deep links included, is `index.html` (the
  Pages SPA fallback), stored under one key, the site root. Don't store a
  `redirected` response: Chrome refuses one as the answer to a navigation.
- **Only a `200`, and `text/html` exactly when it is a page load.** A missing
  file also answers 200 with `index.html`, which must not be stored as that
  file. The other way round, `main.dart.js` opened in a tab is a page load and
  must not be stored as the page. Fall back only when `fetch` rejects. An HTTP
  error goes through as it is.
- **Keys are URLs**, the same from both paths (a page's requests, and the
  first-visit list), so a stored `Vary` can't keep a copy from matching.
- **Not written again when unchanged.** Pages sends an ETag for every app
  file but the page (checked on dev, 2026-10-30), so a stored copy with the
  same ETag stays. CanvasKit and fonts never change at a URL, so a stored one
  always stays. Otherwise every online load would write `main.dart.js` and
  `canvaskit.wasm` again, several MB each.
- **No stored copy:** rethrow, so the page sees the same network error as
  today, and B's error lines show.
- **CanvasKit housekeeping:** when a CanvasKit file is stored, delete stored
  CanvasKit entries under any other engine revision. Each upgrade would
  otherwise leave several MB behind.
- `skipWaiting()` on install, `clients.claim()` on activate. Old and new
  workers follow the same rule, so a switch mid-session is safe.
- **No navigation preload.** Each online page load waits for the worker to
  start, tens of ms. Accepted. `registration.navigationPreload` is the
  standard fix if it ever shows.

The code is `web/offline_worker.js`.

### Registering it

In `flutter_bootstrap.js`:

1. **Stop passing `serviceWorkerSettings` to `_flutter.loader.load()`.** With
   settings, `flutter.js` finds ours and registers its own stub over it at the
   same scope. The stub then unregisters itself, ours with it, and reloads
   the tab. Dropping the settings also drops the wait of up to 4 s.
2. **Register `offline_worker.js` on `flutter-first-frame`**, so it doesn't
   compete with start-up, and only when `serviceWorkerVersion` is set (a
   `flutter build web`; `null` under `flutter run` and `flutter drive`).
   - Guard `'serviceWorker' in navigator`. It is missing on insecure pages and
     in Firefox private windows.
   - In the existing first-frame listener, schedule the `#boot` removal
     first, so a throw here can't leave `#boot` up.
   - Catch a rejected `register()`: offline, its update fetch fails.
   - The token is Flutter's deprecated one, and neither way it can go is loud.
     If Flutter drops it, `{{flutter_service_worker_version}}` stays in the
     file as a syntax error: the bootstrap never runs and "Getting ready…"
     stays up, which Step 1's `onerror` can't see. If Flutter always fills
     `null` instead, the worker silently stops registering. `deploy.sh`
     (dry runs too) stops when the built `flutter_bootstrap.js` has no number
     there.
3. **First visit: store what already loaded.** If
   `navigator.serviceWorker.controller` was `null` when the page started (a
   first visit, or a hard reload), then once `ready` resolves, post the root
   URL and `drift_worker.js` and `sqlite3.wasm` by name. Drift's workers load
   those two (see "Checked against the source"), and for anyone who already
   has the databases they load before the worker is in place. Without them,
   every current user's first offline reload after the deploy fails to open
   the databases. Then a `PerformanceObserver` (`buffered`) posts every
   resource that loaded without the worker (`workerStart === 0`) as it
   finishes. One list taken at `ready` is not enough: the local check found
   the databases' `manifest.json` still loading at that moment, so neither
   path stored it, and an offline reload after a first visit would have
   failed. The worker fetches what is `storable`, mostly from the HTTP cache
   as 304s.

### Known limits (accepted)

- **The first visit must finish online.** Offline works once the databases
  are installed and the app has opened them. `tree.json` loads only after the
  download.
- **Some files load only on some screens**, such as an emblem at another
  density, the licences page, or `sc-to-bjt.json` (reference search; a start
  with the databases in didn't load it). Offline, they're the copy from the
  last time they loaded, which may be an older build. A file never loaded is
  missing.
- **"Connected but no internet"** waits for the network to give up before
  the stored copy is used.
- **A failing connection right after a deploy** can mix new files with stored
  ones. Today that load fails outright.
- **Chrome may evict the whole site's storage** when the disk runs low, unless
  it granted the installer's `persist()`. Safari deletes it after seven days
  of Safari use without a visit to the site, unless the app was added to the
  Home Screen. The databases, stored files and worker go together, silently.
  Online, the next start downloads them again. Offline, it shows the install
  error. See "Repeated installs" below.
- **A hard reload** (Shift+Cmd+R) bypasses the worker by design.
- **A stray unhandled rejection while the engine starts**, from a script an
  extension put in the page, say, shows Step 1's error lines early. They go
  when the app paints. Revisit only if someone reports it.
- **A change to `web/_headers` alone** doesn't reach stored copies of
  unchanged files: the ETag covers the file, not its headers. Offline, they
  keep the old headers until the file changes. The page is always stored
  again, so its COOP/COEP are always current.

### Kill switch

In `scripts/app/web/README.md`, under Rollback. Deleting `offline_worker.js`
does **not** remove installed workers: Pages answers the update check with
`index.html` (200, `text/html`), the update fails on the type, and the old
worker stays. The kill switch is a worker that deletes the stored files and
unregisters, with no reload: while the bootstrap still registered it, a
reload would loop.

A Pages rollback to a build from before the worker **removes** it. That
build still passes `serviceWorkerSettings`, so its `flutter.js` finds our
registration and installs Flutter's stub over it, which unregisters and
reloads each open tab once.

### Check (dev target first: `deploy.sh --dev`)

1. Online visit in a fresh Chrome profile. Wait for the databases. Then in
   DevTools → *Application*:
   - *Service workers* shows `offline_worker.js` activated.
   - *Cache storage → app* holds `/`, `flutter_bootstrap.js`, `main.dart.js`,
     `assets/FontManifest.json`, `assets/AssetManifest.bin.json`, the fonts,
     `assets/assets/databases/manifest.json`, `assets/assets/data/tree.json`,
     `assets/assets/data/sc-to-bjt.json`, `manifest.json`, `drift_worker.js`,
     `sqlite3.wasm`, the CanvasKit pair and Roboto. No `.db` file.
2. *Network* → *Offline*, then reload. The app opens. A sutta opens, search
   and the dictionary answer, and `crossOriginIsolated` in the console is
   `true` (stored responses keep their COOP/COEP).
3. The same with Wi-Fi off, not DevTools. Then a deep link
   (`/tipitaka/<nodeKey>`) offline.
4. **A current user's first day.** A profile that installed the databases
   before the worker was deployed: one online visit, then Wi-Fi off and
   reload. The app opens.
5. Deploy again with a visible change, then reload online. The new build shows
   with no hard reload.
6. Rerun Step 1's check with the worker in place, after deleting *Cache
   storage → app* (keep the worker). The blocked files behave as listed. With
   a stored copy, a blocked file is served from it and the app paints, which
   is correct. CanvasKit and Roboto also sit in Chrome's HTTP cache for a
   year, so a missing `canvaskit.wasm` shows the error lines only once
   Chrome's cached files are cleared too.
7. **Safari**, on an iPhone or iPad: one online visit, wait for the
   databases, then airplane mode and reload. The app opens and a sutta shows
   its text.

No automated tests in this plan: the worker never registers under
`flutter drive`. A web integration test for the offline reload can follow
separately.

### Checked locally (2026-10-29)

A `flutter build web --release` (no defines, so the databases came from its
own origin) served Pages-style: COOP/COEP, `max-age=0, must-revalidate`,
`index.html` for any missing path. Headless Chrome 156 through chromedriver.
Offline meant the server stopped and
`--host-resolver-rules="MAP * ~NOTFOUND"`, so every host failed.

- Step 1's table: all four rows as wanted, *Try again* reloads with the
  bootstrap blocked, console clean.
- Check 1: the stored list as above, no `.db`.
- Check 2: the app opens offline, isolated. A deep link (`/tipitaka/dn-1-2`)
  opens the sutta from the database.
- Check 4: worker and stored files removed, one online visit with the
  databases in (page confirmed uncontrolled), then offline: the deep link
  opens.
- Check 5: a changed `index.html` shows on a normal online reload, and the
  stored page is the new one.
- Check 6, offline instead of blocked: with its stored copy deleted,
  `flutter_bootstrap.js` shows the error lines. So does `canvaskit.wasm`,
  once the HTTP cache is cleared too.

### Checked locally (2026-10-30), after the review changes

The same setup, the server now also sending an ETag (304 on a match) for
every file but the page, as Pages does.

- Checks 1, 2, 4 and 5 as before: 39 stored, no `.db`, the deep link opens
  offline.
- A first visit writes each file once. A reload with nothing changed writes
  only the page. After a change to `flutter_bootstrap.js` it writes the page
  and that file, and the stored copy is the new one. Counted with a logging
  copy of the worker in the build, not the repo's.
- Check 7, in part, in the iOS 26.2 simulator (iPhone 17). After one online
  visit, with the server stopped, a deep link never loaded online opens the
  app, so the worker served it. Not shown: that the database opened (on a
  phone the navigator covers the reader). CanvasKit still came over the
  network. An iPad run failed because the Mac's disk was full.

Still owed on the dev deploy: Cloudflare's real headers and injected script,
desktop Chrome with Wi-Fi off (check 3), check 4 with a profile that really
installed the databases before the deploy, and Safari with the network
really off (check 7).

## Repeated installs: a tester's report (2026-10-29, open)

A tester saw the databases install three times in one day, on a slower Windows
laptop. They keep tabs open, and the laptop sleeps overnight. The developer's
MacBook Pro, used the same way, has never done it.

Ruled out:

- **A new database version.** Prod and dev serve the same database
  `manifest.json` as the local build, unchanged since 2026-10-19. If the three
  installs were on 2026-10-19, that day's canon sync explains them.
- **The installer.** Unchanged since 2026-09-27. A start downloads only when
  the stamp for this build's version is missing, and it deletes only other
  versions that no tab holds.
- **Open tabs and sleep.** A tab holds its versions' locks for as long as it
  lives, sleep included. A tab Chrome discarded reloads, finds the stamp and
  downloads nothing.

So a download never finished, the copy was really gone, or the tester was on
another site. Suspects, and the tester's check for each:

1. **A cut download starts over.** A download cut part-way keeps nothing, and
   *Try again* starts that database from zero. The cut can be the laptop
   sleeping, Wi-Fi dropping, or Chrome putting a background tab to sleep or
   closing it to save memory. A slow machine on a slow link stays open to
   this for a long time; a fast one finishes first. Check: did "The download
   did not finish" appear? `chrome://discards` shows whether Chrome discarded
   the tab.
2. **Another address.** Every Pages deployment also gets its own URL
   (`<hash>.app-sammaditthi-test.pages.dev`, which wrangler prints). Each one
   is a separate site with its own copy, and dev and prod are separate too.
   Check `chrome://settings/content/all` for `sammaditthi` and `pages.dev`:
   more than one entry holding a database's worth of storage.
3. **Chrome evicted it.** The installer asks `persist()`, but Chrome only says
   yes to sites it rates important, such as ones used a lot or installed as an
   app. On a near-full disk it can loop: install, disk low, evicted, install.
   Check `chrome://quota-internals` (eviction statistics, which reset when
   Chrome restarts, and free space) and `await navigator.storage.persisted()`
   in the app's console.
4. **Site data cleared.** Chrome's "Delete data sites have saved to your
   device when you close all windows", or a cleaner app or extension.

Also ask whether the screen showed the MB count (a real download) or only
"Getting ready…".

## When done

- `docs/general/things-to-consider-before-going-live.md`: move *The app can't
  start offline* from "Open, not blocking" to "Settled", rewritten as shipped.
- Move this file to `docs/done/web/`, where finished web-strategy plans go.

## Handover notes

- 2026-10-29: plan reviewed against the Flutter, drift and app source and the
  live headers. Corrections folded in above.
- 2026-10-29: Steps 1 and 2 built and checked locally (above). The local
  check changed two things: the first-visit list became a
  `PerformanceObserver`, and it skips `.db`. Rechecking the source also
  corrected the rollback: it removes the worker rather than leaving it.
  **Next:** `deploy.sh --dev` and the checks still owed, then "When done".
- 2026-10-30: review round. An unchanged file is no longer written again on
  every load (ETag), the database rule is one URL check in `storable`, and
  the fallback looks only in the `app` cache. Rechecked locally in Chrome,
  and in Safari in part (above). Safari's seven-day deletion added to the
  known limits, and check 7 added. **Next:** unchanged.
- 2026-10-30: second review, from the visitor's side (first visit, current
  users, offline, rollback, slow Windows laptops). One fix: the bootstrap's
  top-level `navigator.serviceWorker` read is in a `try`, since a throw there
  would leave "Getting ready…" up forever. **Next:** unchanged.
- Repeated installs: waiting on the tester's checks.
