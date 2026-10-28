import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_wisdom_project/presentation/models/in_page_search_state.dart';
import 'package:the_wisdom_project/presentation/providers/document_provider.dart';
import 'package:the_wisdom_project/presentation/providers/in_page_search_provider.dart';
import 'package:the_wisdom_project/presentation/providers/navigate_to_sutta_provider.dart';
import 'package:the_wisdom_project/presentation/providers/navigation_tree_provider.dart';
import 'package:the_wisdom_project/presentation/providers/tab_provider.dart';
import 'package:the_wisdom_project/presentation/widgets/reader/in_page_search_bar.dart';
import 'package:the_wisdom_project/presentation/widgets/navigation/tab_bar_widget.dart';
import 'package:the_wisdom_project/presentation/widgets/search/singlish_preview.dart';

import 'test_overrides.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('In-Page Search Integration Tests', () {
    // ---------------------------------------------------------------
    // Shared helpers
    // ---------------------------------------------------------------

    /// Opens the in-page search bar.
    ///
    /// In production this is wired to the `Symbols.find_in_page_sharp` button in
    /// [ReaderActionToolbar], but that button is gated on the reader
    /// having visible content AND the toolbar not being hidden by scrolling
    /// — all wrapped in an [IgnorePointer] / [AnimatedOpacity] pair. Under
    /// integration-test timing (cold-load, content fetched off the bundle,
    /// opacity animation) the icon is not reliably hit-testable on the first
    /// frame after [openTab] settles, which made finding it by icon flake
    /// with "0 widgets".
    ///
    /// The other integration tests (e.g. layout_switch_test) already open
    /// search by driving the notifier directly. Mirror that pattern — it's
    /// what `onSearchTap` ultimately calls anyway, so we exercise the same
    /// state transition without depending on the floating-UI visibility
    /// chain.
    Future<void> openSearchBar(
      WidgetTester tester,
      ProviderContainer container,
    ) async {
      container.read(inPageSearchStatesProvider.notifier).openSearch();
      await pumpForSettle(tester);
    }

    /// Types [query] into the in-page search TextField and waits for the
    /// 300 ms debounce + match computation to complete.
    Future<void> enterSearchQuery(
      WidgetTester tester,
      String query,
    ) async {
      final textField = find.descendant(
        of: find.byType(InPageSearchBar),
        matching: find.byType(TextField),
      );
      await typeText(tester, textField, query);
      await tester.pump(); // Trigger onChanged
      await tester.pump(const Duration(milliseconds: 400)); // Debounce
      await pumpForSettle(tester);
    }

    /// Reads the in-page search state for [tabIndex] from the provider.
    InPageSearchState readSearchState(
      ProviderContainer container,
      int tabIndex,
    ) {
      final states = container.read(inPageSearchStatesProvider);
      return states[tabIndex] ?? InPageSearchState();
    }

    // ---------------------------------------------------------------
    // Test 1: Open search, Sinhala query, match count, navigate up/down
    // ---------------------------------------------------------------
    testWidgets(
      '1. Tap search icon → type Sinhala query → matches found → navigate',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // Open DN 1 sutta (Brahmajāla Sutta)
        final tab = tabFromNode(container, 'dn-1-1');
        await openTab(tester, container, tab);

        // Tap search icon → search bar should appear
        await openSearchBar(tester, container);
        expect(find.byType(InPageSearchBar), findsOneWidget,
            reason: 'Search bar should appear after tapping search icon');

        // Type Sinhala query "එවං" (evam) — appears at the start of most suttas
        await enterSearchQuery(tester, 'එවං');

        // Verify matches found
        final state = readSearchState(container, 0);
        expect(state.matches, isNotEmpty,
            reason: 'Should find matches for "එවං" in DN 1');
        expect(state.currentMatchIndex, 0,
            reason: 'First match should be selected initially');

        // Verify match counter text: "1 / N"
        final matchCount = state.matchCount;
        expect(find.text('1 / $matchCount'), findsOneWidget,
            reason: 'Match counter should display "1 / $matchCount"');

        // Navigate NEXT → index becomes 1
        await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
        await pumpForSettle(tester);
        expect(readSearchState(container, 0).currentMatchIndex, 1,
            reason: 'Next should advance to match index 1');

        // Navigate PREVIOUS → back to index 0
        await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
        await pumpForSettle(tester);
        expect(readSearchState(container, 0).currentMatchIndex, 0,
            reason: 'Previous should go back to match index 0');

        // Navigate PREVIOUS from 0 → wraps to last match
        await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
        await pumpForSettle(tester);
        expect(
          readSearchState(container, 0).currentMatchIndex,
          matchCount - 1,
          reason: 'Previous from 0 should wrap to last match',
        );
      },
    );

    // ---------------------------------------------------------------
    // Test 2: Singlish query converts and finds matches
    // ---------------------------------------------------------------
    testWidgets(
      '2. Singlish query converts to Sinhala and finds matches',
      (tester) async {
        final container = await pumpReaderApp(tester);

        final tab = tabFromNode(container, 'dn-1-1');
        await openTab(tester, container, tab);

        await openSearchBar(tester, container);
        await enterSearchQuery(tester, 'bhikkhu');

        final state = readSearchState(container, 0);

        // Raw query stays as typed
        expect(state.rawQuery, 'bhikkhu');

        // Effective query should be non-empty (converted Sinhala text)
        expect(state.effectiveQuery, isNotEmpty,
            reason: 'Effective query should contain converted Sinhala');

        // Matches should be found ("bhikkhu" is very common in DN 1)
        expect(state.matches, isNotEmpty,
            reason: 'Should find matches for converted "bhikkhu"');

        // The bar previews the Sinhala. Compared with the text itself, not
        // effectiveQuery: the preview keeps joiners that search drops.
        expect(
          find.descendant(
            of: find.byType(SinglishPreview),
            matching: find.text('භික්ඛු'),
          ),
          findsOneWidget,
          reason: 'Singlish conversion preview should be visible',
        );
      },
    );

    // ---------------------------------------------------------------
    // Test 3: Per-tab search state isolation across tab switches
    // ---------------------------------------------------------------
    testWidgets(
      '3. Each tab preserves its own search state when switching',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // Open Tab A (Brahmajāla Sutta)
        final tabA = tabFromNode(container, 'dn-1-1');
        await openTab(tester, container, tabA);

        // Search in Tab A
        await openSearchBar(tester, container);
        await enterSearchQuery(tester, 'එවං');

        final stateA = readSearchState(container, 0);
        expect(stateA.matches, isNotEmpty, reason: 'Tab A should have matches');
        final tabAMatchCount = stateA.matchCount;

        // Open Tab B (Sāmaññaphala Sutta — second sutta in same vagga)
        final tabB = tabFromNode(container, 'dn-1-2');
        await openTab(tester, container, tabB);

        // Search in Tab B with a different query
        await openSearchBar(tester, container);
        await enterSearchQuery(tester, 'භික්ඛවෙ');

        final stateB = readSearchState(container, 1);
        expect(stateB.matches, isNotEmpty, reason: 'Tab B should have matches');
        expect(stateB.rawQuery, 'භික්ඛවෙ');

        // Switch back to Tab A
        container.read(activeTabIndexProvider.notifier).state = 0;
        await pumpForSettle(tester);

        // Tab A's state should be fully preserved
        final stateARestored = readSearchState(container, 0);
        expect(stateARestored.rawQuery, 'එවං',
            reason: 'Tab A query should be preserved');
        expect(stateARestored.matchCount, tabAMatchCount,
            reason: 'Tab A match count should be preserved');
        expect(stateARestored.isVisible, isTrue,
            reason: 'Tab A search bar should still be visible');
        expect(find.byType(InPageSearchBar), findsOneWidget,
            reason: 'Search bar widget should be rendered for Tab A');

        // Switch to Tab B
        container.read(activeTabIndexProvider.notifier).state = 1;
        await pumpForSettle(tester);

        // Tab B's state should be fully preserved
        final stateBRestored = readSearchState(container, 1);
        expect(stateBRestored.rawQuery, 'භික්ඛවෙ',
            reason: 'Tab B query should be preserved');
        expect(stateBRestored.isVisible, isTrue,
            reason: 'Tab B search bar should still be visible');
      },
    );

    // ---------------------------------------------------------------
    // Test 3b: Scrolling to current match works when navigating
    // ---------------------------------------------------------------
    testWidgets(
      '3b. Navigating matches scrolls view and tracks current highlight',
      (tester) async {
        final container = await pumpReaderApp(tester);

        final tab = tabFromNode(container, 'dn-1-1');
        await openTab(tester, container, tab);

        await openSearchBar(tester, container);
        await enterSearchQuery(tester, 'එවං');

        final matchCount = readSearchState(container, 0).matchCount;
        expect(matchCount, greaterThan(4),
            reason: 'Need several matches to test scroll-to-match — and the '
                'wrap assertion at the end needs the last match to lie past '
                'the 4th, which is as far as the forward steps below go');

        // Every step must bring the match's row on screen. Offsets can't
        // say that: a match too far to be built is anchored at, which moves
        // offset 0 to it.
        void expectCurrentMatchOnScreen(String when) {
          final match = readSearchState(container, 0).currentMatch!;
          expect(
            isEntryOnScreen(tester, match.pageIndex, match.entryIndex),
            isTrue,
            reason: '$when, the row holding the current match '
                '(${match.pageIndex}, ${match.entryIndex}) must be on '
                'screen — a match index that advances while the viewport '
                'stays put is the bug this guards',
          );
        }

        // Step through a few matches forward — verify index tracks correctly
        // AND that the viewport follows each match.
        for (var i = 1; i <= 3; i++) {
          await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
          await pumpForSettle(tester);
          expect(readSearchState(container, 0).currentMatchIndex, i,
              reason: 'After $i next-taps, currentMatchIndex should be $i');
          expectCurrentMatchOnScreen('After $i next-taps');
        }

        // Verify the match counter text updates in the UI
        expect(
          find.text('4 / $matchCount'),
          findsOneWidget,
          reason: 'Counter should show "4 / $matchCount" after 3 next-taps',
        );

        // Navigate back to match 0 — the viewport must follow it up.
        for (var i = 0; i < 3; i++) {
          await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
          await pumpForSettle(tester);
        }
        expect(readSearchState(container, 0).currentMatchIndex, 0);
        expectCurrentMatchOnScreen('Back at the first match');

        // Wrap to the LAST match (previous from 0 → last match at end of sutta)
        await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
        await pumpForSettle(tester);

        // Verify we reached the last match
        expect(readSearchState(container, 0).currentMatchIndex, matchCount - 1,
            reason: 'Previous from 0 should wrap to last match');

        // The last match sits near the end of the sutta, far below anything
        // built so far, so the reader anchors at its row rather than laying
        // out every row in between.
        expectCurrentMatchOnScreen('After wrapping to the last match');

        // Match counter should show the last position
        expect(
          find.text('$matchCount / $matchCount'),
          findsOneWidget,
          reason: 'Counter should show "$matchCount / $matchCount"',
        );
      },
    );

    // ---------------------------------------------------------------
    // Test 3c: A new query scrolls to its first hit, even at the same index
    // ---------------------------------------------------------------
    testWidgets(
      '3c. A new query scrolls to its first hit even when the index stays 0',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // Mahānidāna Sutta: "jaa" (ජා) has hits from the top of the sutta,
        // "jaaye" (ජායෙ) has a single hit pages further down.
        final tab = tabFromNode(container, 'dn-2-2');
        await openTab(tester, container, tab);

        await openSearchBar(tester, container);
        await enterSearchQuery(tester, 'jaa');
        final first = readSearchState(container, 0).currentMatch!;
        expect(
            isEntryOnScreen(tester, first.pageIndex, first.entryIndex), isTrue,
            reason: '"jaa" should land on its first hit');

        // Typed in one go, so the debounce never searches "jaay" in between:
        // its zero hits would reset the cursor and hide the bug.
        await enterSearchQuery(tester, 'jaaye');
        final state = readSearchState(container, 0);
        expect(state.currentMatchIndex, 0,
            reason: 'The cursor is on the first hit for both queries');
        final hit = state.currentMatch!;
        expect(isEntryOnScreen(tester, hit.pageIndex, hit.entryIndex), isTrue,
            reason: 'The cursor index never changed, but the view must still '
                'move to the new hit');
        expect(
            isEntryOnScreen(tester, first.pageIndex, first.entryIndex), isFalse,
            reason: 'The two hits must not share a screen, or the check above '
                'would pass without any scroll');

        // And back up: "jaa"'s first hit is again index 0.
        await enterSearchQuery(tester, 'jaa');
        expect(
            isEntryOnScreen(tester, first.pageIndex, first.entryIndex), isTrue,
            reason: 'Returning to "jaa" should scroll back to its first hit');
      },
    );

    // ---------------------------------------------------------------
    // Test 3d: With one match, next brings it back after scrolling away
    // ---------------------------------------------------------------
    testWidgets(
      '3d. Next on a single match scrolls back to it',
      (tester) async {
        final container = await pumpReaderApp(tester);

        final tab = tabFromNode(container, 'dn-2-2');
        await openTab(tester, container, tab);
        await openSearchBar(tester, container);
        await enterSearchQuery(tester, 'jaaye');
        final state = readSearchState(container, 0);
        expect(state.matchCount, 1,
            reason: 'Needs a word with exactly one hit — if the text was '
                'rebuilt, pick another');
        final only = state.currentMatch!;

        // Read on, away from the match.
        final controller = readerScrollController(tester);
        controller.jumpTo(
            controller.offset + controller.position.viewportDimension * 2);
        await pumpForSettle(tester);
        expect(
            isEntryOnScreen(tester, only.pageIndex, only.entryIndex), isFalse,
            reason: 'The match must be off screen before pressing next');

        await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
        await pumpForSettle(tester);
        expect(find.text('1 / 1'), findsOneWidget);
        expect(isEntryOnScreen(tester, only.pageIndex, only.entryIndex), isTrue,
            reason: 'Next stays on "1 / 1" but must still bring it into view');
      },
    );

    // ---------------------------------------------------------------
    // Test 3e: Switching tabs keeps the tab's place, not its current match
    // ---------------------------------------------------------------
    testWidgets(
      '3e. Switching to a tab with a search restores its scroll position',
      (tester) async {
        final container = await pumpReaderApp(tester);

        final tabA = tabFromNode(container, 'dn-1-1');
        await openTab(tester, container, tabA);
        await openSearchBar(tester, container);
        await enterSearchQuery(tester, 'එවං');
        // On match 3, so tab A's match number differs from tab B's too.
        for (var i = 0; i < 2; i++) {
          await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
          await pumpForSettle(tester);
        }
        final matchA = readSearchState(container, 0).currentMatch!;

        // Read on, away from the match.
        readerScrollController(tester).jumpTo(3000);
        await pumpForSettle(tester);
        expect(isEntryOnScreen(tester, matchA.pageIndex, matchA.entryIndex),
            isFalse,
            reason: 'Tab A must be scrolled past its current match');
        final tabABefore = container.read(tabsProvider)[0];
        final offsetBefore = readerScrollController(tester).offset;

        // Tab B's current match is "1 / N", somewhere else.
        final tabB = tabFromNode(container, 'dn-1-2');
        await openTab(tester, container, tabB);
        await openSearchBar(tester, container);
        await enterSearchQuery(tester, 'එවං');
        expect(readSearchState(container, 1).currentMatch, isNot(matchA),
            reason: 'The two tabs need current matches in different places');

        container.read(activeTabIndexProvider.notifier).state = 0;
        await pumpForSettle(tester);

        final tabAAfter = container.read(tabsProvider)[0];
        expect(
          (tabAAfter.anchorPageIndex, tabAAfter.anchorEntryIndex),
          (tabABefore.anchorPageIndex, tabABefore.anchorEntryIndex),
          reason: 'A tab switch must not re-anchor Tab A at its match',
        );
        expect(
            readerScrollController(tester).offset, closeTo(offsetBefore, 1.0),
            reason: 'Tab A should come back where it was left');
        expect(isEntryOnScreen(tester, matchA.pageIndex, matchA.entryIndex),
            isFalse,
            reason: 'Switching back must not jump to Tab A\'s match');
      },
    );

    // ---------------------------------------------------------------
    // Test 3f: A new query scrolls back even to the same first hit
    // ---------------------------------------------------------------
    testWidgets(
      '3f. A new query scrolls to its first hit even when it has not moved',
      (tester) async {
        final container = await pumpReaderApp(tester);

        final tab = tabFromNode(container, 'dn-1-1');
        await openTab(tester, container, tab);
        await openSearchBar(tester, container);
        await enterSearchQuery(tester, 'එවං');
        final first = readSearchState(container, 0).currentMatch!;

        // Read on, away from the match.
        final controller = readerScrollController(tester);
        controller.jumpTo(
            controller.offset + controller.position.viewportDimension * 2);
        await pumpForSettle(tester);
        expect(
            isEntryOnScreen(tester, first.pageIndex, first.entryIndex), isFalse,
            reason: 'The match must be off screen before the new query');

        await enterSearchQuery(tester, 'එවං මෙ');
        expect(readSearchState(container, 0).currentMatch, first,
            reason: 'Both queries must start on the same hit');
        expect(
            isEntryOnScreen(tester, first.pageIndex, first.entryIndex), isTrue,
            reason: 'Nothing about the match changed, but a new query must '
                'still bring its first hit into view');
      },
      // Fails on an older reveal bug: docs/todo/reader/app-reader-backlog.md R3.
      skip: true,
    );

    // ---------------------------------------------------------------
    // Test 4: Close search bar hides it but retains query/matches
    // ---------------------------------------------------------------
    testWidgets(
      '4. Close search bar → hidden but query and matches retained',
      (tester) async {
        final container = await pumpReaderApp(tester);

        final tab = tabFromNode(container, 'dn-1-1');
        await openTab(tester, container, tab);

        // Search and verify matches exist
        await openSearchBar(tester, container);
        await enterSearchQuery(tester, 'එවං');
        expect(readSearchState(container, 0).hasMatches, isTrue);

        // Close via the close button inside the search bar
        final closeBtn = find.descendant(
          of: find.byType(InPageSearchBar),
          matching: find.byIcon(Icons.close),
        );
        await tester.tap(closeBtn);
        await pumpForSettle(tester);

        // Search bar widget should be gone
        expect(find.byType(InPageSearchBar), findsNothing,
            reason: 'Search bar should be hidden after close');

        // But state should retain query and matches
        final state = readSearchState(container, 0);
        expect(state.isVisible, isFalse);
        expect(state.rawQuery, 'එවං',
            reason: 'Query should be retained after closing');
        expect(state.hasMatches, isTrue,
            reason: 'Matches should be retained after closing');
      },
    );

    // ---------------------------------------------------------------
    // Test 5: Reopen selects the query, Backspace clears it, bar stays open
    // ---------------------------------------------------------------
    testWidgets(
      '5. Reopen selects the whole query → Backspace clears it, bar stays open',
      (tester) async {
        final container = await pumpReaderApp(tester);

        final tab = tabFromNode(container, 'dn-1-1');
        await openTab(tester, container, tab);

        await openSearchBar(tester, container);
        await enterSearchQuery(tester, 'එවං');
        expect(readSearchState(container, 0).hasMatches, isTrue);

        // Close and reopen: the restored query comes back fully selected,
        // like Chrome's find bar
        container.read(inPageSearchStatesProvider.notifier).closeSearch();
        await pumpForSettle(tester);
        await openSearchBar(tester, container);

        TextEditingController fieldController() => tester
            .widget<TextField>(find.descendant(
              of: find.byType(InPageSearchBar),
              matching: find.byType(TextField),
            ))
            .controller!;
        expect(
          fieldController().selection,
          const TextSelection(baseOffset: 0, extentOffset: 'එවං'.length),
          reason: 'Reopening should select the whole restored query',
        );

        // One Backspace replaces the selection with nothing. On macOS the
        // framework lets the key fall through and the OS answers with the
        // `deleteBackward:` selector, so a simulated key event deletes
        // nothing — send the selector the OS would have sent.
        tester
            .state<EditableTextState>(find.descendant(
              of: find.byType(InPageSearchBar),
              matching: find.byType(EditableText),
            ))
            .performSelector('deleteBackward:');
        await pumpForSettle(tester);
        expect(fieldController().text, isEmpty,
            reason: 'Backspace should delete the selected query');

        // Query and matches should be cleared
        final state = readSearchState(container, 0);
        expect(state.rawQuery, isEmpty,
            reason: 'Query should be empty after clearing');
        expect(state.matches, isEmpty,
            reason: 'Matches should be empty after clearing');

        // Search bar should remain visible
        expect(state.isVisible, isTrue);
        expect(find.byType(InPageSearchBar), findsOneWidget,
            reason: 'Search bar should stay open after clearing');
      },
    );

    // ---------------------------------------------------------------
    // Test 6: Closing a tab clears its state, other tabs unaffected
    // ---------------------------------------------------------------
    testWidgets(
      '6. Close tab → its search state removed, other tab preserved',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // Open Tab A and search
        final tabA = tabFromNode(container, 'dn-1-1');
        await openTab(tester, container, tabA);

        await openSearchBar(tester, container);
        await enterSearchQuery(tester, 'එවං');
        expect(readSearchState(container, 0).hasMatches, isTrue);

        // Close the search bar so Icons.close only appears in tab bar
        container.read(inPageSearchStatesProvider.notifier).closeSearch();
        await pumpForSettle(tester);

        // Open Tab B (no search on this tab)
        final tabB = tabFromNode(container, 'dn-1-2');
        await openTab(tester, container, tabB);

        // Close Tab B via its close button in the tab bar
        final tabCloseButtons = find.descendant(
          of: find.byType(TabBarWidget),
          matching: find.byIcon(Icons.close),
        );
        expect(tabCloseButtons, findsNWidgets(2),
            reason: 'Should find 2 tab close buttons');
        await tester.tap(tabCloseButtons.last); // Close Tab B (rightmost)
        await pumpForSettle(tester);

        // Only Tab A should remain
        expect(container.read(tabsProvider).length, 1);

        // Tab A's search state should still be intact
        final stateA = readSearchState(container, 0);
        expect(stateA.rawQuery, 'එවං',
            reason: 'Tab A search state should survive after Tab B closed');
        expect(stateA.hasMatches, isTrue);
      },
    );

    // ---------------------------------------------------------------
    // Test 7: Closing all tabs clears all search state
    // ---------------------------------------------------------------
    testWidgets(
      '7. Close all tabs → all search state cleared',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // Open a tab and search
        final tab = tabFromNode(container, 'dn-1-1');
        await openTab(tester, container, tab);

        await openSearchBar(tester, container);
        await enterSearchQuery(tester, 'එවං');
        expect(readSearchState(container, 0).hasMatches, isTrue);

        // Close the search bar so Icons.close only appears in tab bar
        container.read(inPageSearchStatesProvider.notifier).closeSearch();
        await pumpForSettle(tester);

        // Close the only tab
        final tabCloseBtn = find.descendant(
          of: find.byType(TabBarWidget),
          matching: find.byIcon(Icons.close),
        );
        await tester.tap(tabCloseBtn);
        await pumpForSettle(tester);

        // All search state should be cleared
        final allStates = container.read(inPageSearchStatesProvider);
        expect(allStates, isEmpty,
            reason: 'All search state should be cleared when no tabs remain');
      },
    );

    // ---------------------------------------------------------------
    // Test 8: Stepping to the next sutta drops the old sutta's matches
    // ---------------------------------------------------------------
    testWidgets(
      '8. Reopening search after stepping finds the new sutta\'s matches',
      (tester) async {
        final container = await pumpReaderApp(tester);

        final tab = tabFromNode(container, 'dn-1-1');
        await openTab(tester, container, tab);
        await openSearchBar(tester, container);
        await enterSearchQuery(tester, 'එවං');
        expect(readSearchState(container, 0).hasMatches, isTrue);

        // What the reader's next-sutta button calls. It closes the bar.
        container.read(navigateToSuttaProvider)(
          container.read(nodeByKeyProvider('dn-1-2'))!,
        );
        await pumpForSettle(tester);
        await openSearchBar(tester, container);

        final state = readSearchState(container, 0);
        expect(state.rawQuery, 'එවං', reason: 'The query is kept');
        expect(state.hasMatches, isTrue);
        final slice = container.read(activeDocumentSliceProvider)!;
        final end = slice.absolutePageStart + slice.pages.length;
        for (final match in state.matches) {
          expect(
              match.pageIndex,
              allOf(
                  greaterThanOrEqualTo(slice.absolutePageStart), lessThan(end)),
              reason: 'Every match must be in dn-1-2, not left over from '
                  'dn-1-1');
        }
      },
    );
  });
}
