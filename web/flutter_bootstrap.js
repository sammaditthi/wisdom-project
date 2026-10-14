{{flutter_js}}
{{flutter_build_config}}

// Flutter's default bootstrap, plus the #boot loader in index.html: removed
// once Flutter has painted, or switched to its error lines if Flutter fails to
// start, so a failure never looks like a slow start.
const boot = document.getElementById('boot');
const fail = () => boot?.classList.add('failed');

boot?.querySelector('button')?.addEventListener('click', () => location.reload());

// main.dart reports its own start-up failure this way: Flutter doesn't wait
// for main(), so the error never reaches runApp below.
window.addEventListener('app-start-failed', fail);

// The loader reports nothing when main.dart.js fails to load in callback mode;
// a failed <script> reaches window only in the capture phase.
window.addEventListener('error', (event) => {
  if (event.target instanceof HTMLScriptElement) fail();
}, true);

// null in debug runs, where the default template passes no settings at all.
const serviceWorkerVersion = {{flutter_service_worker_version}};

_flutter.loader.load({
  serviceWorkerSettings: serviceWorkerVersion ? { serviceWorkerVersion } : undefined,
  onEntrypointLoaded: async (engineInitializer) => {
    try {
      const appRunner = await engineInitializer.initializeEngine();
      // Flutter's view sits above #boot and is see-through until it paints.
      // Its first frame reaches the screen a moment after this event, so #boot
      // goes two frames later.
      window.addEventListener('flutter-first-frame', () => {
        requestAnimationFrame(() => requestAnimationFrame(() => boot?.remove()));
      }, { once: true });
      await appRunner.runApp();
    } catch (error) {
      fail();
      throw error;
    }
  },
}).catch(fail);
