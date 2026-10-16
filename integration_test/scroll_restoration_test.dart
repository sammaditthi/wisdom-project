import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_wisdom_project/presentation/models/reader_tab.dart';
import 'package:the_wisdom_project/presentation/providers/tab_lifecycle_provider.dart';
import 'package:the_wisdom_project/presentation/providers/tab_provider.dart';
import 'package:the_wisdom_project/presentation/providers/document_provider.dart';

import 'test_overrides.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Scroll position now lives on the [ReaderTab] entity itself
  // (`tab.scrollOffset`) — the standalone scroll-position providers
  // were removed in commit 264b79d. These helpers read/write the
  // offset through the canonical [tabsProvider] surface so each test
  // touches the same state path the production widget uses.
  double readScrollOffset(ProviderContainer container, int tabIndex) {
    final tabs = container.read(tabsProvider);
    if (tabIndex < 0 || tabIndex >= tabs.length) return 0.0;
    return tabs[tabIndex].scrollOffset;
  }

  void writeScrollOffset(
    ProviderContainer container,
    int tabIndex,
    double offset,
  ) {
    container
        .read(tabsProvider.notifier)
        .updateTabScrollOffset(tabIndex, offset);
  }

  group('Scroll Restoration Integration Tests', () {
    testWidgets(
      'should restore scroll position when switching between tabs via UI',
      (tester) async {
        // ARRANGE - Create test app with real providers
        final container = await pumpReaderApp(tester);

        // Two tabs on real node keys — a tab is a node now, and a key the
        // tree does not hold resolves to no unit and renders nothing to
        // scroll.
        //
        // The two deliberately live in DIFFERENT content files: dn-1-1 reads
        // dn-1, dn-1-11 reads dn-1-11. Switching between two suttas of one
        // file never reloads the document, so a restore that only works while
        // the text stays put would pass — the reload is half of what this
        // covers.
        const tabA = ReaderTab(
          label: 'DN 1',
          fullName: 'Brahmajāla Sutta',
          nodeKey: 'dn-1-1',
          paliName: 'Brahmajāla Sutta',
          sinhalaName: 'බ්‍රහ්මජාල සූත්‍රය',
        );

        const tabB = ReaderTab(
          label: 'DN 11',
          fullName: 'Kevaṭṭa Sutta',
          nodeKey: 'dn-1-11',
          paliName: 'Kevaṭṭa Sutta',
          sinhalaName: 'කේවට්ට සූත්‍රය',
        );

        // Add both tabs and activate Tab A
        // Content file ID is now derived automatically from the active tab
        container.read(tabsProvider.notifier).addTab(tabA);
        container.read(tabsProvider.notifier).addTab(tabB);
        container.read(activeTabIndexProvider.notifier).state = 0;

        await pumpForSettle(tester);

        expect(container.read(activeContentFileIdProvider), 'dn-1',
            reason: 'Tab A reads the dn-1 file');

        // STEP 1: Scroll Tab A to 300 using the controller
        readerScrollController(tester).jumpTo(300);
        await pumpForSettle(tester);

        // STEP 2: Tap Tab B to switch (simulating real user action).
        // Tab labels follow the Content Language (default Sinhala), so the tab
        // displays tabB.sinhalaName — not its 'DN 2' label.
        await tester.tap(find.text(tabB.sinhalaName!));
        await pumpForSettle(tester);

        // Verify Tab A's position was saved when we switched away
        final tabAPositionAfterSwitch = readScrollOffset(container, 0);
        expect(tabAPositionAfterSwitch, greaterThan(0),
            reason:
                'Tab A scroll position should be saved when switching away');

        // Verify Tab B is now active
        expect(container.read(activeTabIndexProvider), 1,
            reason: 'Tab B should now be active');
        expect(container.read(activeContentFileIdProvider), 'dn-1-11',
            reason: 'Tab B reads a different file, so switching to it reloads '
                'the document — the path a same-file pair would skip');

        // STEP 3: Scroll Tab B to 600
        readerScrollController(tester).jumpTo(600);
        await pumpForSettle(tester);

        // STEP 4: Tap Tab A to switch back (simulating real user action)
        await tester.tap(find.text(tabA.sinhalaName!));
        await pumpForSettle(tester);

        // ASSERT - Each tab should have its own scroll position preserved
        final tabAPosition = readScrollOffset(container, 0);
        final tabBPosition = readScrollOffset(container, 1);

        expect(tabAPosition, greaterThan(0),
            reason: 'Tab A should have a non-zero position');
        expect(tabBPosition, greaterThan(0),
            reason: 'Tab B should have a non-zero position');

        // Tab B was scrolled further than Tab A
        expect(tabBPosition, greaterThan(tabAPosition),
            reason: 'Tab B should have larger scroll position than Tab A');

        // STEP 5: Tap Tab B again to verify its position is also preserved
        await tester.tap(find.text(tabB.sinhalaName!));
        await pumpForSettle(tester);

        // Verify Tab B's scroll position is still preserved
        final tabBPositionAfterReturn = readScrollOffset(container, 1);
        expect(tabBPositionAfterReturn, greaterThan(0),
            reason:
                'Tab B scroll position should be preserved after switching back');
      },
    );

    testWidgets(
      'should not inherit scroll position when closing active tab',
      (tester) async {
        // This tests the bug: Open Tab A, Open Tab B, Go to Tab A and scroll,
        // Close Tab A -> Tab B should NOT inherit Tab A's scroll position

        final container = await pumpReaderApp(tester);

        // Create two tabs
        const tabA = ReaderTab(
          label: 'Tab A',
          fullName: 'Tab A Full',
          nodeKey: 'dn-1-1',
          paliName: 'Tab A',
          sinhalaName: 'Tab A',
        );

        const tabB = ReaderTab(
          label: 'Tab B',
          fullName: 'Tab B Full',
          nodeKey: 'dn-1-2',
          paliName: 'Tab B',
          sinhalaName: 'Tab B',
        );

        // STEP 1: Open Tab A
        // Content file ID is now derived automatically from the active tab
        container.read(tabsProvider.notifier).addTab(tabA);
        container.read(activeTabIndexProvider.notifier).state = 0;
        await pumpForSettle(tester);

        // STEP 2: Open Tab B (tap to switch)
        container.read(tabsProvider.notifier).addTab(tabB);
        await pumpForSettle(tester);
        await tester.tap(find.text('Tab B'));
        await pumpForSettle(tester);

        // Verify Tab B is active and at scroll position 0
        expect(container.read(activeTabIndexProvider), 1);
        expect(readScrollOffset(container, 1), 0.0,
            reason: 'Tab B should start at scroll position 0');

        // STEP 3: Go back to Tab A and scroll down
        await tester.tap(find.text('Tab A'));
        await pumpForSettle(tester);

        // Scroll Tab A down
        readerScrollController(tester).jumpTo(500);
        await pumpForSettle(tester);

        // STEP 4: Close Tab A (tap close button on Tab A)
        // Find the close button in Tab A's tab item
        final closeButtons = find.byIcon(Icons.close);
        expect(closeButtons, findsNWidgets(2),
            reason: 'Should find 2 close buttons (one for each tab)');
        await tester.tap(closeButtons.first); // Close Tab A
        await pumpForSettle(tester);

        // ASSERT: Tab B should now be the only tab and at index 0
        expect(container.read(tabsProvider).length, 1);
        expect(container.read(activeTabIndexProvider), 0);

        // CRITICAL: Tab B should still be at scroll position 0, NOT 500
        final tabBScrollPosition = readScrollOffset(container, 0);
        expect(tabBScrollPosition, 0.0,
            reason:
                'Tab B should NOT inherit Tab A\'s scroll position after Tab A is closed');
      },
    );

    testWidgets(
      'closing a tab left of the active one keeps every other tab\'s position',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // [A, B, C]. Closing A shifts B and C down an index while B stays
        // active, so the reader's save on the index change must still land
        // on B — not on whichever tab now sits at B's old index, which is C.
        for (final nodeKey in ['dn-1-1', 'dn-1-2', 'dn-1-3']) {
          await openTab(tester, container, tabFromNode(container, nodeKey));
        }
        container.read(switchTabProvider)(1);
        await pumpForSettle(tester);

        // C's own place, set after the switch away from it, which saved C.
        writeScrollOffset(container, 2, 900);
        readerScrollController(tester).jumpTo(400);
        await pumpForSettle(tester);

        // ACT: close A
        container.read(closeTabProvider)(0);
        await pumpForSettle(tester);

        // ASSERT
        final tabs = container.read(tabsProvider);
        expect(tabs.map((t) => t.nodeKey), ['dn-1-2', 'dn-1-3']);
        expect(container.read(activeTabIndexProvider), 0,
            reason: 'B stays active, one index down');
        expect(tabs[1].scrollOffset, 900,
            reason: 'C must keep its own position, not take B\'s');
        expect(tabs[0].scrollOffset, 400,
            reason: 'B\'s position is saved to B');
      },
    );

    testWidgets(
      'should start with scroll position 0 for new tabs',
      (tester) async {
        // ARRANGE
        final container = await pumpReaderApp(tester);

        // Create and add a new tab
        const tab = ReaderTab(
          label: 'New Tab',
          fullName: 'New Tab Full',
          nodeKey: 'dn-1-1',
          paliName: 'New Tab',
          sinhalaName: 'New Tab',
        );

        // Content file ID is now derived automatically from the active tab
        container.read(tabsProvider.notifier).addTab(tab);
        container.read(activeTabIndexProvider.notifier).state = 0;

        await pumpForSettle(tester);

        // ASSERT - New tab should start with scroll position 0
        final scrollPosition = readScrollOffset(container, 0);
        expect(scrollPosition, 0.0,
            reason: 'New tabs should start with scroll position 0');
      },
    );

    testWidgets(
      'should clear scroll position when tab is closed',
      (tester) async {
        // ARRANGE
        final container = await pumpReaderApp(tester);

        // Create and add a tab
        const tab = ReaderTab(
          label: 'Tab to Close',
          fullName: 'Tab to Close Full',
          nodeKey: 'dn-1-1',
          paliName: 'Tab to Close',
          sinhalaName: 'Tab to Close',
        );

        // Content file ID is now derived automatically from the active tab
        container.read(tabsProvider.notifier).addTab(tab);
        container.read(activeTabIndexProvider.notifier).state = 0;

        await pumpForSettle(tester);

        // Scroll and save position
        readerScrollController(tester).jumpTo(250);
        await pumpForSettle(tester);
        writeScrollOffset(container, 0, 250.0);

        // Verify it was saved
        expect(readScrollOffset(container, 0), 250.0);

        // Close the tab by tapping the close button
        await tester.tap(find.byIcon(Icons.close));
        await pumpForSettle(tester);

        // ASSERT — closing the only tab leaves an empty list. Scroll offset
        // is stored on the tab entity itself, so removing the tab is the
        // clear; there's no separate "scroll positions" map any more.
        expect(container.read(tabsProvider), isEmpty,
            reason: 'Closing the only tab should leave no tabs');
      },
    );
  });
}
