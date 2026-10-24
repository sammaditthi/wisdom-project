import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the test window to a logical size, for widgets that branch on width.
extension TestView on WidgetTester {
  /// Lays the test out in a [size]-logical-pixel window for this test only.
  ///
  /// `devicePixelRatio: 1` so the size given is the size the widgets see, and
  /// the tear-down puts the 800x600 default back — a leaked size would silently
  /// change every test that runs after it in the same file.
  void useWindow(Size size) {
    view.physicalSize = size;
    view.devicePixelRatio = 1;
    addTearDown(view.reset);
  }
}
