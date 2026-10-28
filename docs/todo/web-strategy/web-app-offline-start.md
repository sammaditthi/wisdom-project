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
  - `canvaskit.wasm`: `flutter.js` compiles it inside `instantiateWasm` with
    an async callback whose rejection nothing awaits. Emscripten waits forever
    and `initializeEngine()` never settles. It surfaces only as an
    `unhandledrejection`.
- **CanvasKit stays on Google's CDN.** Its URL carries the engine revision
  (`www.gstatic.com/flutter-canvaskit/<rev>/…`), so a Flutter upgrade is a new
  URL and the year-long cache can never serve a wrong version. A local
  `canvaskit/` (`--no-web-resources-cdn`) has no version in its URL. Keep the
  CDN.

## Step 1 — B: an error, never an endless "Getting ready…"

Files: `web/index.html`, `web/flutter_bootstrap.js`.

1. **The bootstrap itself.** In `index.html`, give the script tag an
   `onerror` that adds `failed` to `#boot`. Also move the button's reload into
   the HTML (`onclick="location.reload()"`), and drop the
   `addEventListener('click', …)` from the bootstrap: if the bootstrap never
   loads, nothing would wire the button.

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

## Step 2 — A: our own service worker

Files: new `web/offline_worker.js`; `web/flutter_bootstrap.js`.

### Rule

**Network first; the stored copy only when the network fails.** Online, every
load is the newest deploy, exactly as today. Offline, each file comes from the
copy stored the last time it loaded.

- **Stored:** GETs to our own origin (not `/cdn-cgi/`, which is Cloudflare's),
  CanvasKit from `https://www.gstatic.com/flutter-canvaskit/`, and Flutter's
  fallback fonts from `https://fonts.gstatic.com/`.
- **Never touched:** the R2 database downloads (another host, already in OPFS,
  fetched `no-store`) and the research Worker.
- **Page loads:** every navigation, deep links included, is `index.html` (the
  Pages SPA fallback), stored under one key, the site root. Don't store a
  `redirected` response: Chrome refuses one as the answer to a navigation.
- **Only `response.ok`.** Fall back only when `fetch` rejects. An HTTP error
  goes through as it is.
- **No stored copy:** rethrow, so the page sees the same network error as
  today, and B's error lines show.
- **CanvasKit housekeeping:** when a CanvasKit file is stored, delete stored
  CanvasKit entries under any other engine revision. Each upgrade would
  otherwise leave several MB behind.
- `skipWaiting()` on install, `clients.claim()` on activate. Old and new
  workers follow the same rule, so a switch mid-session is safe.

```js
// web/offline_worker.js — sketch.
const ROOT = new URL('./', self.location).href;

self.addEventListener('fetch', (event) => {
  const { request } = event;
  if (request.method !== 'GET' || !storable(request.url)) return;
  const key = request.mode === 'navigate' ? ROOT : request;
  event.respondWith(
    fetch(request)
      .then((response) => {
        if (response.ok && !response.redirected) {
          const copy = response.clone();
          event.waitUntil(caches.open('app').then((c) => c.put(key, copy)));
        }
        return response;
      })
      .catch(async (error) => (await caches.match(key)) ?? Promise.reject(error)),
  );
});
```

### Registering it

In `flutter_bootstrap.js`:

1. **Stop passing `serviceWorkerSettings` to `_flutter.loader.load()`.** With
   settings, `flutter.js` calls `getRegistration()` and, finding ours,
   registers its own `flutter_service_worker.js?v=…` over it at the same
   scope. That stub then unregisters itself, and ours with it.
2. **Register `offline_worker.js` on `flutter-first-frame`**, so it doesn't
   compete with start-up. Do it only when `serviceWorkerVersion` is set:
   release builds fill it, debug runs leave it `null`. Note it's Flutter's
   deprecated token. When Flutter drops it, the unreplaced `{{…}}` breaks the
   bootstrap loudly, and this gate needs a new signal.
   - Check what `flutter run -d web-server --release` (`run_mac.sh`) fills in.
     Network first makes a registered worker harmless locally either way.
   - Catch a rejected `register()`: offline, its update fetch fails.
3. **First visit: store what already loaded.** The worker wasn't there when
   `index.html`, `main.dart.js`, CanvasKit and the fonts arrived. If
   `navigator.serviceWorker.controller` was `null` when the page started (a
   first visit, or a hard reload), then once `ready` resolves, post the root
   URL plus every `performance.getEntriesByType('resource')` URL. The worker
   fetches each one that is `storable` and stores it. They come from the HTTP
   cache as 304s, so this is cheap.

### Known limits (accepted)

- **The first visit must finish online.** Offline works once the worker has
  stored that visit's files, seconds after first paint.
- **Some files load only on some screens**, such as an emblem at another
  density or the licences page. Offline, they're the copy from the last time
  they loaded, which may be an older build. A file never loaded is missing.
- **"Connected but no internet"** waits for the network to give up before
  the stored copy is used.
- **A failing connection right after a deploy** can mix new files with stored
  ones. Today that load fails outright.
- **Chrome may evict the whole site's storage** under disk pressure: databases
  and stored files together, silently. Online, the next start downloads them
  again. Offline, it shows the install error.
- **A hard reload** (Shift+Cmd+R) bypasses the worker by design.

### Kill switch

Deleting `offline_worker.js` does **not** remove installed workers: when an
update check gets a 404, the old worker stays. To retire it, deploy an
`offline_worker.js` that unregisters itself, like Flutter's stub. Keep that
version in place for months.

### Check (dev target first: `deploy.sh --dev`)

1. Online visit in a fresh Chrome profile. Wait for the databases. Then in
   DevTools → *Application*:
   - *Service workers* shows `offline_worker.js` activated.
   - *Cache storage → app* holds `/`, `main.dart.js`, the fonts, both
     manifests, `sqlite3.wasm`, `drift_worker.js` and the CanvasKit pair.
2. *Network* → *Offline*, then reload. The app opens. A sutta opens, search
   and the dictionary answer, and `crossOriginIsolated` in the console is
   `true` (stored responses keep their COOP/COEP).
3. The same with Wi-Fi off, not DevTools. Then a deep link
   (`/tipitaka/<nodeKey>`) offline.
4. Deploy again with a visible change, then reload online. The new build shows
   with no hard reload.
5. Rerun Step 1's check: with the worker in place, the blocked files still
   behave as listed.

No automated tests in this plan. A web integration test for the offline reload
can follow separately.

## When done

- `docs/general/things-to-consider-before-going-live.md`: move *The app can't
  start offline* from "Open, not blocking" to "Settled", rewritten as shipped.
- Move this file to `docs/done/web-strategy/`.

## Handover notes

_Nothing started yet._
