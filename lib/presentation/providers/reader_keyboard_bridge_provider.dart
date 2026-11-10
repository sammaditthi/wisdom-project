import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'reader_unit_provider.dart' show ReaderStep;

/// What the mounted reader lets keyboard shortcuts do.
abstract interface class ReaderKeyboardHandle {
  /// A neighbouring sutta exists in [step]'s direction.
  bool canStep(ReaderStep step);

  /// Goes to the neighbouring sutta, exactly as the toolbar's ⏮ ⏭ do.
  void step(ReaderStep step);

  /// Scrolls the active tab's text.
  void scroll(AxisDirection direction, ScrollIncrementType type);

  /// Focus is on something inside the reader's text.
  bool get hasFocus;
}

/// Where the mounted reader attaches itself while it is on screen.
///
/// Owned here and borrowed by `MultiPaneReaderWidget`, which attaches in
/// `initState` and detaches in `dispose` — no provider state is written from
/// a widget's lifecycle (see `in_page_search_focus_provider.dart`).
class ReaderKeyboardBridge {
  ReaderKeyboardHandle? _handle;

  /// The mounted reader, or null.
  ReaderKeyboardHandle? get handle => _handle;

  void attach(ReaderKeyboardHandle handle) => _handle = handle;

  /// Detaches [handle] only if it is the one attached, so an old reader's
  /// dispose can't detach the new one.
  void detach(ReaderKeyboardHandle handle) {
    if (identical(_handle, handle)) _handle = null;
  }
}

final readerKeyboardBridgeProvider =
    Provider<ReaderKeyboardBridge>((ref) => ReaderKeyboardBridge());
