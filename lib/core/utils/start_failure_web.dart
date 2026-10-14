import 'package:web/web.dart' as web;

/// Switches the loader in web/index.html to its error lines.
/// web/flutter_bootstrap.js listens for this event.
void reportStartFailure() =>
    web.window.dispatchEvent(web.Event('app-start-failed'));
