import 'package:flutter/widgets.dart';

/// Everything inside [within] that takes focus, sorted by where it sits on
/// screen, as Tab sorts it. [within] is the results node (reference row,
/// result rows, See all, Show more), so the arrow keys skip nothing, or the
/// whole panel's node.
List<FocusNode> searchResultStops(FocusNode within) => [
      ...ReadingOrderTraversalPolicy.sort([
        for (final node in within.traversalDescendants)
          if (node is! FocusScopeNode && node.context != null) node,
      ]),
    ];
