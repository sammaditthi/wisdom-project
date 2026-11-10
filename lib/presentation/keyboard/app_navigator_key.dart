import 'package:flutter/widgets.dart';

/// The app's root navigator. `AppShortcuts` sits above it (in
/// `MaterialApp.builder`), so a shortcut that opens a dialog needs this to
/// reach a context below the `Navigator`.
final appNavigatorKey = GlobalKey<NavigatorState>();
