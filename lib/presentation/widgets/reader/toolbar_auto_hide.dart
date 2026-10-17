import 'package:flutter/widgets.dart' show ScrollMetrics;

/// Quick return for the reader toolbar: reading on hides it, a deliberate
/// scroll back brings it back (`docs/done/reader/reader-toolbar-auto-hide.md`).
///
/// [userScrolled] takes only the reader's own scrolling, [scrolledTo] every
/// scroll. Each call returns whether [shown] changed.
class ToolbarAutoHide {
  /// How far into the unit its top reaches. Past it the reader is mid-unit.
  static const double topZone = 60;

  /// Upward travel that brings the toolbar back.
  static const double revealDistance = 100;

  bool _shown = true;

  // Upward travel since the last move down. A pause keeps it: each
  // mouse-wheel notch ends its scroll, so a reset there would stop a wheel
  // at one notch.
  double _upward = 0;

  bool get shown => _shown;

  /// The reader scrolled by [delta]; positive reads on.
  bool userScrolled(double delta, ScrollMetrics metrics) {
    if (delta > 0) {
      _upward = 0;
      // Not at the end either: a bounce past it reads on.
      return _isMidUnit(metrics) && _set(false);
    }
    _upward -= delta;
    return _upward >= revealDistance && show();
  }

  /// The top and the end turn it on, so it stays on while the reader scrolls
  /// back up from the end.
  bool scrolledTo(ScrollMetrics metrics) => !_isMidUnit(metrics) && show();

  bool show() {
    _upward = 0;
    return _set(true);
  }

  static bool _isMidUnit(ScrollMetrics metrics) =>
      metrics.extentBefore > topZone && metrics.extentAfter >= 1;

  bool _set(bool shown) {
    if (_shown == shown) return false;
    _shown = shown;
    return true;
  }
}
