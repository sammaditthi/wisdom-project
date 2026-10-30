{{flutter_js}}
{{flutter_build_config}}

// Flutter's default bootstrap, plus the #boot loader in index.html: removed
// once Flutter has painted, or switched to its error lines if Flutter fails to
// start, so a failure never looks like a slow start. Then it registers
// offline_worker.js, so a reload with no connection still opens the app.
const boot = document.getElementById('boot');
const fail = () => boot?.classList.add('failed');

// flutter.js drops a failed canvaskit.wasm without rejecting anything we
// await; it shows only as an unhandled rejection. Removed once the engine is
// up, so a later stray rejection can't put the error over a working app.
window.addEventListener('unhandledrejection', fail);

// main.dart reports its own start-up failure this way: Flutter doesn't wait
// for main(), so the error never reaches runApp below.
window.addEventListener('app-start-failed', fail);

// The loader reports nothing when main.dart.js fails to load in callback mode;
// a failed <script> reaches window only in the capture phase.
window.addEventListener('error', (event) => {
  if (event.target instanceof HTMLScriptElement) fail();
}, true);

// Filled by `flutter build web`; null under `flutter run` and `flutter drive`,
// so the worker never registers there. A deprecated Flutter token, so
// scripts/app/web/deploy.sh stops if the built file has no number here.
const serviceWorkerVersion = {{flutter_service_worker_version}};

// No worker served this page: a first visit, or a hard reload. Reading
// navigator.serviceWorker throws in a sandboxed frame, and a throw here would
// stop this file before Flutter loads.
let uncontrolled = false;
try {
  uncontrolled = !navigator.serviceWorker?.controller;
} catch {}

const registerOfflineWorker = () => {
  // Missing on insecure pages and in Firefox private windows.
  if (!serviceWorkerVersion || !('serviceWorker' in navigator)) return;
  // Offline, the update check fails; the worker already in place carries on.
  navigator.serviceWorker.register('offline_worker.js').catch(() => {});
  if (!uncontrolled) return;
  // What this page loaded without the worker, for it to store: the page, and
  // the files Drift's workers load themselves.
  navigator.serviceWorker.ready.then((registration) => {
    const post = (urls) => registration.active?.postMessage(urls);
    post(['./', 'drift_worker.js', 'sqlite3.wasm']
      .map((path) => new URL(path, document.baseURI).href));
    // Every file loaded without the worker, as each finishes, so one still
    // loading when the worker took over is caught too.
    new PerformanceObserver((list) => post(list.getEntries()
      .filter((entry) => entry.workerStart === 0)
      .map((entry) => entry.name)))
      .observe({ type: 'resource', buffered: true });
  });
};

// No serviceWorkerSettings: with them, flutter.js registers its own stub over
// offline_worker.js, and the stub unregisters itself.
_flutter.loader.load({
  onEntrypointLoaded: async (engineInitializer) => {
    try {
      const appRunner = await engineInitializer.initializeEngine();
      window.removeEventListener('unhandledrejection', fail);
      // Flutter's view sits above #boot and is see-through until it paints.
      // Its first frame reaches the screen a moment after this event, so #boot
      // goes two frames later. Scheduled first, so nothing below can keep it.
      window.addEventListener('flutter-first-frame', () => {
        requestAnimationFrame(() => requestAnimationFrame(() => boot?.remove()));
        registerOfflineWorker();
      }, { once: true });
      await appRunner.runApp();
    } catch (error) {
      fail();
      throw error;
    }
  },
}).catch(fail);
