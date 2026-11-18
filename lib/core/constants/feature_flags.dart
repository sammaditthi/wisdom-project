import 'package:flutter/foundation.dart';

/// Home, with its Today card, and the Time tab in Settings: shown only in
/// the macOS app while the feature is built. Web is ruled out first because
/// a browser on a Mac reports macOS too.
// TODO(vinaya-times): delete this flag, and every check on it, when Home
// ships.
bool get kEnableHome =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
