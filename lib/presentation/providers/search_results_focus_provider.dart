import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Owns the focus node around the search results, so the ↓ / ↑ / Tab
/// shortcuts can find the results from the always-mounted shortcut handler.
///
/// `SearchResultsPanel` borrows it, as `InPageSearchBar` borrows
/// `inPageSearchFocusNodeProvider`'s. It takes no focus itself; it only
/// tells whether a result has it.
final searchResultsFocusNodeProvider = Provider<FocusNode>(
  (ref) => _wrapperNode(ref, 'Search results'),
);

/// The node around the whole results panel — chips, tabs and results — so
/// closing search can release focus from anywhere in it.
final searchPanelFocusNodeProvider = Provider<FocusNode>(
  (ref) => _wrapperNode(ref, 'Search panel'),
);

FocusNode _wrapperNode(Ref ref, String label) {
  final node = FocusNode(
    debugLabel: label,
    canRequestFocus: false,
    skipTraversal: true,
  );
  ref.onDispose(node.dispose);
  return node;
}
