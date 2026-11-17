// Stores the app's files as they load, so a reload with no connection still
// opens the app. Network first: online, every load is the newest deploy;
// offline, each file is the copy stored the last time it loaded. Registered by
// flutter_bootstrap.js. To retire it: scripts/app/web/README.md, Rollback.
'use strict';

// The page, for every navigation: Pages answers each path, deep links
// included, with index.html.
const ROOT = new URL('./', self.location).href;
const OWN = self.location.origin + '/';
const CANVASKIT = 'https://www.gstatic.com/flutter-canvaskit/';
const CACHE = 'app';

// Our own files (not Cloudflare's /cdn-cgi/), CanvasKit, and the fonts the
// engine fetches: Roboto on every start, a fallback when a glyph needs one.
// Other hosts, the databases on R2 and the research Worker, go untouched.
// Never a database: a local build downloads them from our own origin.
const storable = (url) => !url.endsWith('.db') &&
  ((url.startsWith(OWN) && !url.startsWith(OWN + 'cdn-cgi/')) ||
    url.startsWith(CANVASKIT) || url.startsWith('https://fonts.gstatic.com/'));

// A 200, not redirected (Chrome refuses that as the answer to a navigation),
// and HTML exactly when it is a page. Pages answers a missing file with
// index.html, which must not be stored as that file; a file opened in a tab
// must not be stored as the page.
const keepable = (response, isPage) =>
  response.status === 200 && !response.redirected &&
  (response.headers.get('content-type')?.startsWith('text/html') ?? false) === isPage;

const store = async (url, response) => {
  const cache = await caches.open(CACHE);
  // Already stored, so not written again on every load: CanvasKit and font
  // files never change at a URL, and ours are the same while the ETag is.
  // Pages sends none for the page, so it is always written. The unread body
  // is cancelled so the browser doesn't hold it in memory.
  const stored = await cache.match(url);
  const etag = response.headers.get('etag');
  if (stored && (!url.startsWith(OWN) ||
      (etag && stored.headers.get('etag') === etag))) {
    return response.body?.cancel();
  }
  await cache.put(url, response);
  // One engine revision only: each Flutter upgrade would leave several MB.
  if (url.startsWith(CANVASKIT)) {
    const current = CANVASKIT + url.slice(CANVASKIT.length).split('/')[0] + '/';
    const stale = (await cache.keys()).filter(({ url: key }) =>
      key.startsWith(CANVASKIT) && !key.startsWith(current));
    await Promise.all(stale.map((request) => cache.delete(request)));
  }
};

// Old and new workers follow the same rule, so taking over mid-session is safe.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => event.waitUntil(self.clients.claim()));

self.addEventListener('fetch', (event) => {
  const { request } = event;
  if (request.method !== 'GET' || !storable(request.url)) return;
  const isPage = request.mode === 'navigate';
  const key = isPage ? ROOT : request.url;
  event.respondWith((async () => {
    let response;
    try {
      response = await fetch(request);
    } catch (error) {
      // Only when the network fails; an HTTP error goes through as it is.
      // With no stored copy, the page sees the error it would without us.
      const stored = await caches.match(key, { cacheName: CACHE });
      if (stored) return stored;
      throw error;
    }
    if (keepable(response, isPage)) event.waitUntil(store(key, response.clone()));
    return response;
  })());
});

// From a page this worker didn't serve: the URLs it loaded without the
// worker, mostly answered from the HTTP cache. waitUntil, or the browser may
// stop the worker halfway through.
self.addEventListener('message', (event) => {
  if (!Array.isArray(event.data)) return;
  const urls = [...new Set(event.data)].filter(storable);
  event.waitUntil(Promise.allSettled(urls.map(async (url) => {
    const response = await fetch(url);
    if (keepable(response, url === ROOT)) await store(url, response);
  })));
});
