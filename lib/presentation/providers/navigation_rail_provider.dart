import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the user has hidden the navigation rail (the "Hide navigation
/// bar" switch in settings). Deliberately not persisted: a restart always
/// shows the rail.
final navigationRailHiddenProvider = StateProvider<bool>((ref) => false);
