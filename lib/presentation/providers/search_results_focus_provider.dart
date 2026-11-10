import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Owns the focus node around the search results, so the ↓ / ↑ / Tab
/// shortcuts can find the results from the always-mounted shortcut handler.
///
/// `SearchResultsPanel` borrows it, as `InPageSearchBar` borrows
/// `inPageSearchFocusNodeProvider`'s. It takes no focus itself; it only
/// tells whether a result has it.
final searchResultsFocusNodeProvider = Provider<FocusNode>((ref) {
  final node = FocusNode(
    debugLabel: 'Search results',
    canRequestFocus: false,
    skipTraversal: true,
  );
  ref.onDispose(node.dispose);
  return node;
});
