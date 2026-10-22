// Conditional export: on web, tells the loader in web/index.html that the app
// failed to start; elsewhere there is no loader, so a no-op. The
// `dart.library.js_interop` flag is the canonical way to detect the web compile
// target — same pattern as `data/database/local_database_executor.dart`.
export 'start_failure_stub.dart'
    if (dart.library.js_interop) 'start_failure_web.dart';
