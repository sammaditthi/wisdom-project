import 'package:flutter/foundation.dart';

/// macOS, Windows and Linux — as an app or in a browser. Flutter web reports
/// an iPad as iOS, so phones and tablets are never desktop.
bool isDesktopPlatform(TargetPlatform platform) => switch (platform) {
      TargetPlatform.macOS ||
      TargetPlatform.windows ||
      TargetPlatform.linux =>
        true,
      _ => false,
    };

/// Apple platforms use ⌘ where the others use Ctrl.
bool usesCommandKey(TargetPlatform platform) =>
    platform == TargetPlatform.macOS || platform == TargetPlatform.iOS;
