// Conditional export: on web, tells the loader in web/index.html that the app
// failed to start; elsewhere there is no loader, so a no-op. Same pattern as
// `core/version/web_reload.dart`.
export 'start_failure_stub.dart'
    if (dart.library.js_interop) 'start_failure_web.dart';
