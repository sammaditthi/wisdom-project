import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/key_value_store_provider.dart';
import '../../core/storage/storage_keys.dart';

/// Whether the user has hidden the navigation rail (the "Hide navigation
/// bar" switch in settings). Starts from the saved value; shown if none.
final navigationRailHiddenProvider = StateProvider<bool>((ref) {
  final stored = ref
      .read(keyValueStoreProvider)
      .getInt(StorageKeys.navigationRailHidden);
  return stored == 1;
});

/// Saves every change to [navigationRailHiddenProvider]. Read once from
/// main.dart so the listener lives for the whole session.
final navigationRailHiddenPersistenceProvider = Provider<void>((ref) {
  ref.listen<bool>(navigationRailHiddenProvider, (_, hidden) {
    ref
        .read(keyValueStoreProvider)
        .setInt(StorageKeys.navigationRailHidden, hidden ? 1 : 0);
  });
});
