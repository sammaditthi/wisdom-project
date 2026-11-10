import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/core/localization/l10n/app_localizations.dart';
import 'package:the_wisdom_project/core/theme/app_theme.dart';
import 'package:the_wisdom_project/presentation/keyboard/app_shortcuts.dart';

import '../../helpers/pump_app.dart';

/// Pumps [home] under the app's real [AppShortcuts], the way `main.dart`
/// mounts it, and returns the container so a test can read and seed state.
Future<ProviderContainer> pumpShortcutHost(
  WidgetTester tester, {
  required Widget home,
  List<Override> overrides = const [],
}) async {
  final container = createTestContainer(overrides: overrides);
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => AppShortcuts(child: child!),
        home: home,
      ),
    ),
  );
  await tester.pump();
  return container;
}

/// Presses [key] with the given modifiers. `primary` is ⌘ on macOS and iOS,
/// Ctrl elsewhere — read from [defaultTargetPlatform], as the app does.
Future<void> pressKeys(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool primary = false,
  bool alt = false,
  bool shift = false,
}) async {
  final apple = defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.iOS;
  final modifiers = <(LogicalKeyboardKey, PhysicalKeyboardKey)>[
    if (primary)
      apple
          ? (LogicalKeyboardKey.metaLeft, PhysicalKeyboardKey.metaLeft)
          : (LogicalKeyboardKey.controlLeft, PhysicalKeyboardKey.controlLeft),
    if (alt) (LogicalKeyboardKey.altLeft, PhysicalKeyboardKey.altLeft),
    if (shift) (LogicalKeyboardKey.shiftLeft, PhysicalKeyboardKey.shiftLeft),
  ];
  for (final (logical, physical) in modifiers) {
    await tester.sendKeyDownEvent(logical, physicalKey: physical);
  }
  await tester.sendKeyEvent(key);
  for (final (logical, physical) in modifiers.reversed) {
    await tester.sendKeyUpEvent(logical, physicalKey: physical);
  }
  await tester.pump();
}
