import 'package:flutter/widgets.dart';

/// Everything inside [results] that takes focus — the reference row, result
/// rows, See all and Show more — top to bottom, then left to right. The same
/// stops Tab visits, so the arrow keys skip nothing.
List<FocusNode> searchResultStops(FocusNode results) {
  final stops = [
    for (final node in results.traversalDescendants)
      if (node is! FocusScopeNode && node.context != null) node,
  ];
  stops.sort((a, b) {
    final byTop = a.rect.top.compareTo(b.rect.top);
    return byTop != 0 ? byTop : a.rect.left.compareTo(b.rect.left);
  });
  return stops;
}
