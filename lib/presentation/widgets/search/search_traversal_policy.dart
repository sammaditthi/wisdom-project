import 'package:flutter/widgets.dart';

/// Tab order in the search panel and the recent searches: where things sit
/// on screen, and the stop Tab lands on is scrolled into view whichever side
/// it is on, as in a browser. Flutter's own forward Tab only scrolls down, so
/// Tab into a scrolled list would land on a row above it, out of sight.
FocusTraversalPolicy searchTraversalPolicy() =>
    ReadingOrderTraversalPolicy(requestFocusCallback: _focusInView);

void _focusInView(
  FocusNode node, {
  ScrollPositionAlignmentPolicy? alignmentPolicy,
  double? alignment,
  Duration? duration,
  Curve? curve,
}) {
  // Down if it is below the view, then up if it is above: at most one moves.
  FocusTraversalPolicy.defaultTraversalRequestFocusCallback(
    node,
    alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
  );
  Scrollable.ensureVisible(
    node.context!,
    alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
  );
}
