import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/presentation/widgets/reader/toolbar_auto_hide.dart';

void main() {
  const end = 2000.0;
  const reveal = ToolbarAutoHide.revealDistance;

  // [pixels] into a unit that ends at [end].
  ScrollMetrics at(double pixels) => FixedScrollMetrics(
        minScrollExtent: 0,
        maxScrollExtent: end,
        pixels: pixels,
        viewportDimension: 600,
        axisDirection: AxisDirection.down,
        devicePixelRatio: 1,
      );

  test('reading on hides it mid-unit, not at the top or the end', () {
    final toolbar = ToolbarAutoHide();

    expect(toolbar.userScrolled(20, at(ToolbarAutoHide.topZone)), isFalse,
        reason: 'still in the top zone');
    expect(toolbar.userScrolled(20, at(end)), isFalse, reason: 'at the end');
    expect(toolbar.userScrolled(20, at(end + 30)), isFalse,
        reason: 'bouncing past the end');
    expect(toolbar.shown, isTrue);

    expect(toolbar.userScrolled(20, at(500)), isTrue);
    expect(toolbar.shown, isFalse);
  });

  test('scrolling back shows it once it has come back revealDistance', () {
    final toolbar = ToolbarAutoHide()..userScrolled(20, at(500));

    expect(toolbar.userScrolled(-reveal / 2, at(450)), isFalse);
    // A move down starts the count again.
    toolbar.userScrolled(1, at(451));
    expect(toolbar.userScrolled(-reveal * 0.6, at(391)), isFalse);
    expect(toolbar.shown, isFalse);

    // Separate moves add up.
    expect(toolbar.userScrolled(-reveal * 0.4, at(351)), isTrue);
    expect(toolbar.shown, isTrue);
  });

  test('landing at the top or the end shows it; mid-unit leaves it', () {
    final toolbar = ToolbarAutoHide()..userScrolled(20, at(500));

    expect(toolbar.scrolledTo(at(800)), isFalse);
    expect(toolbar.shown, isFalse);
    expect(toolbar.scrolledTo(at(end)), isTrue);
    // Scrolling back up from the end keeps it.
    expect(toolbar.userScrolled(-30, at(end - 30)), isFalse);
    expect(toolbar.shown, isTrue);

    toolbar.userScrolled(20, at(500));
    expect(toolbar.scrolledTo(at(0)), isTrue);
    expect(toolbar.shown, isTrue);
  });
}
