import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show LogicalKeyboardKey, PhysicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:the_wisdom_project/presentation/models/reader_layout.dart';
import 'package:the_wisdom_project/presentation/providers/last_selected_text_provider.dart';
import 'package:the_wisdom_project/presentation/providers/tab_provider.dart';

import 'test_overrides.dart';

/// What the reader panes draw around the anchor row, and how a selection
/// behaves in them.
///
/// Rows used, all in බ්රහ්මජාලසුත්තං (dn-1-1), file dn-1, page 3:
///   entry 3 → paragraph 15, “බීජගාමභූතගාමසමාරම්භා …
///   entry 4 → centered චුල්ලසීලං නිට්ඨිතං., not the page's first row
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Room for two columns and their margins. The test window's own size
  // varies, and narrow it drops the side-by-side margins this file clicks in.
  void pinDesktopWindow(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets(
    'stacked: a heading keeps its gap above it when it is the anchor row',
    (tester) async {
      pinDesktopWindow(tester);
      final container = await pumpReaderApp(tester);

      // Anchored on the paragraph, so the heading after it is an ordinary row
      // of the list below the anchor.
      await openTab(
        tester,
        container,
        tabFromNode(container, 'dn-1-1').copyWith(
          layout: ReaderLayout.stacked,
          anchorPageIndex: 3,
          anchorEntryIndex: 3,
        ),
      );

      double gapAboveHeading() =>
          tester.getRect(readerRow(3, 4)).top -
          tester.getRect(readerRow(3, 3)).bottom;

      final inTheList = gapAboveHeading();
      expect(inTheList, greaterThan(0),
          reason: 'A heading that is not its page\'s first row takes a gap '
              'above it — the reference this test compares against');

      // Now the heading is the anchor row: the first row of the part below
      // the anchor, with the paragraph in the part above. Nothing about the
      // page changed, so neither may its spacing.
      container.read(tabsProvider.notifier).setTabAnchor(0, (3, 4));
      await pumpForSettle(tester);

      expect(gapAboveHeading(), inTheList,
          reason: 'Splitting the page at the anchor must not drop the '
              'heading\'s gap: it is still not the page\'s first row');
    },
  );

  // The column gate's select-all branch leans on how Flutter's scroll-view
  // selection container handles select-all (see `_ColumnGate`). This is the
  // check that catches a Flutter upgrade changing that.
  testWidgets(
    'side-by-side: Cmd+A selects only the column the click landed in',
    (tester) async {
      pinDesktopWindow(tester);
      final container = await pumpReaderApp(tester);

      // Anchored, so select-all walks both slivers: the rows above the anchor
      // as well as the ones below it.
      await openTab(
        tester,
        container,
        tabFromNode(container, 'dn-1-1').copyWith(
          layout: ReaderLayout.sideBySide,
          anchorPageIndex: 3,
          anchorEntryIndex: 3,
        ),
      );

      // From the anchor row, the first row on screen. Neither has a
      // conjunct, so the Pali display text spells them as the source does.
      const pali = 'පටිවිරතො සමණො ගොතමො';
      const sinhala = 'බීජසමූහ';

      Future<String> selectAllAfterClickAt(Offset position) async {
        await tester.tapAt(position, kind: PointerDeviceKind.mouse);
        // Long enough that the next click is not taken as a double-click.
        await tester.pump(const Duration(milliseconds: 600));
        // The physical keys are named because a web release build can't
        // infer them: the simulator matches keys by their debug names.
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft,
            physicalKey: PhysicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA,
            physicalKey: PhysicalKeyboardKey.keyA);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft,
            physicalKey: PhysicalKeyboardKey.metaLeft);
        await pumpForSettle(tester);
        // The Pali display text joins conjuncts with ZWJ; compare letters.
        return (container.read(lastSelectedTextProvider) ?? '')
            .replaceAll('\u200D', '')
            .replaceAll(RegExp(r'\s+'), ' ');
      }

      final reader = tester.getRect(readerScrollView);
      final row = tester.getRect(readerRow(3, 3));

      // Pali: a click in the left margin beside the row. A click on Pali
      // text would look the word up instead.
      final paliSelection =
          await selectAllAfterClickAt(Offset(reader.left + 12, row.top + 10));
      expect(paliSelection, contains(pali),
          reason: 'Cmd+A after a click in the Pali column selects its rows');
      expect(paliSelection, isNot(contains(sinhala)),
          reason: 'and none of the Sinhala column');

      // Sinhala: a click on its text, three quarters across the row. Sinhala
      // words take no dictionary tap, so the selection gets the click.
      final sinhalaSelection = await selectAllAfterClickAt(
          Offset(row.left + row.width * 0.75, row.top + 10));
      expect(sinhalaSelection, contains(sinhala),
          reason: 'Cmd+A after a click in the Sinhala column selects its rows');
      expect(sinhalaSelection, isNot(contains(pali)),
          reason: 'and none of the Pali column');
    },
  );
}
