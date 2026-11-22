import 'package:flutter/foundation.dart';

/// Home, with its Today card, and the Time tab in Settings: shown only in
/// the macOS app and in builds made with `--dart-define=ENABLE_HOME=true`
/// (the web dev deploy) while the feature is built. Web is ruled out of the
/// platform check because a browser on a Mac reports macOS too.
// TODO(vinaya-times): delete this flag, every check on it, and the
// ENABLE_HOME define in scripts/app/web/deploy.sh, when Home ships.
bool get kEnableHome =>
    const bool.fromEnvironment('ENABLE_HOME') ||
    (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS);
