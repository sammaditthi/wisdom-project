import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_wisdom_project/presentation/models/in_page_search_state.dart';
import 'package:the_wisdom_project/presentation/models/reader_layout.dart';
import 'package:the_wisdom_project/presentation/providers/in_page_search_provider.dart';
import 'package:the_wisdom_project/presentation/providers/last_reader_layout_provider.dart';
import 'package:the_wisdom_project/presentation/providers/tab_provider.dart';

import 'test_overrides.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Layout Switch Integration Tests', () {
    // The `(page, entry)` of the entry nearest the top of the reader's
    // viewport, or null when nothing is mounted.
    //
    // Read off the same GlobalKeys the reader registers for every entry
    // ([EntryKeyRegistry.keyFor], whose debugLabel is `entry_<page>_<entry>`),
    // by the same rule production uses to pick one: nearest reveal offset,
    // ties going to the entry below the top rather than the one scrolled past.
    // An offset only says that *something* moved; this says which entry the
    // switch put there, which is the thing the listener has to preserve.
    (int, int)? topVisibleEntry(
      WidgetTester tester,
      ScrollController controller,
    ) {
      if (!controller.hasClients) return null;
      final label = RegExp(r'entry_(\d+)_(\d+)');
      (int, int)? best;
      var smallest = double.infinity;
      for (final element in find.byType(KeyedSubtree).evaluate()) {
        final match = label.firstMatch('${element.widget.key}');
        if (match == null) continue;
        final renderObject = element.renderObject;
        if (renderObject == null || !renderObject.attached) continue;
        final viewport = RenderAbstractViewport.maybeOf(renderObject);
        if (viewport == null) continue;
        final diff = controller.offset -
            viewport.getOffsetToReveal(renderObject, 0.0).offset;
        final dist = diff >= 0 ? diff + 0.5 : -diff;
        if (dist < smallest) {
          smallest = dist;
          best = (int.parse(match.group(1)!), int.parse(match.group(2)!));
        }
      }
      return best;
    }

    // Reads the per-tab in-page search state from the provider.
    InPageSearchState readSearchState(
      ProviderContainer container,
      int tabIndex,
    ) {
      final states = container.read(inPageSearchStatesProvider);
      return states[tabIndex] ?? InPageSearchState();
    }

    // ---------------------------------------------------------------
    // Test: the top-visible entry survives a full layout cycle AND is
    // re-read when the user scrolls mid-cycle.
    //
    // The listener under test lives in `multi_pane_reader_widget.dart` at
    // the `ref.listen<ReaderLayout>(activeReaderLayoutProvider, ...)`
    // block. It runs `findTopVisibleEntry` against `EntryKeyRegistry`,
    // then anchors the tab at that entry, so the new layout opens on it.
    //
    // The scroll offset can't show where the viewport sits: it is measured
    // from the anchor, which every switch moves. `extentBefore` — how much
    // of the unit is above the viewport — can, and a switch made at the very
    // top is the reference the rest of the test compares against.
    //
    // Each phase checks two things, because neither is enough alone: WHICH
    // entry ended up at the top (the identity the listener carries across the
    // switch) and WHERE the viewport sits (that the entry was really revealed
    // and not merely mounted somewhere off screen).
    //
    // Story this test tells:
    //   1. Switch at the top → the top-of-unit reference.
    //   2. Scroll → switch. The same entry must be at the top again, with
    //      pages of the unit above it however the new layout spaces them.
    //   3. Cycle on with NO further scrolling. Still that entry.
    //   4. Scroll back to the top, then switch. The unit's first entry again,
    //      back at the reference — which is what proves the listener
    //      re-reads the viewport on every switch rather than freezing on its
    //      first capture.
    //
    // Driving switches through `updateActiveTabLayoutProvider` keeps the
    // test independent of `ReaderLayoutPill` UI — the pill ultimately
    // calls the same provider.
    // ---------------------------------------------------------------
    testWidgets(
      'top-visible entry survives a full layout cycle and updates on re-scroll',
      (tester) async {
        final container = await pumpReaderApp(tester);

        final tab = tabFromNode(container, 'dn-1-1');
        await openTab(tester, container, tab);

        final controller = readerScrollController(tester);

        // Pre-condition: a freshly opened tab defaults to paliOnly.
        expect(
          container.read(tabsProvider)[0].layout,
          ReaderLayout.paliOnly,
          reason: 'New tab should default to paliOnly',
        );

        // Waits for the switch to come to rest instead of pumping a fixed
        // number of settles. `pumpForSettle` swallows its own timeout, so a
        // count cannot tell "it landed" from "it is still moving". An offset
        // that survives a whole settle unchanged is the finished signal; one
        // that never does fails here, with the number in the message.
        Future<void> settleUntilStill() async {
          for (var attempt = 0; attempt < 12; attempt++) {
            final before = controller.offset;
            await pumpForSettle(tester, const Duration(seconds: 1));
            if (controller.offset == before) return;
          }
          fail('The reveal never came to rest: the offset was still moving '
              'after 12 settles, last at ${controller.offset}');
        }

        // Helper — drive the layout provider, wait for the reveal, then read
        // back the resulting state. Returns a record so each assertion can
        // quote the actual values in its `reason:` string for clean failures.
        Future<({double before, ReaderLayout layout, (int, int)? top})>
            switchTo(ReaderLayout layout) async {
          container.read(updateActiveTabLayoutProvider)(layout);
          await settleUntilStill();
          return (
            before: controller.position.extentBefore,
            layout: container.read(tabsProvider)[0].layout,
            top: topVisibleEntry(tester, controller),
          );
        }

        // ---- PHASE 1: the top-of-unit reference ----

        // paliOnly → sideBySide with no scrolling. The top-visible entry is
        // the unit's first, so this is what "a switch made at the top"
        // settles at.
        final atTop = await switchTo(ReaderLayout.sideBySide);
        expect(atTop.layout, ReaderLayout.sideBySide);
        expect(atTop.top, isNotNull,
            reason: 'The reader must have keyed entries mounted for any of '
                'this to be measurable — a null top entry means nothing was '
                'found to compare, not that the switch behaved');

        // ---- PHASE 2: a scrolled position is carried across ----

        // Scroll inside sideBySide so the top-visible entry is no longer
        // the sutta's first entry. Pixel target is intentionally generous
        // so we comfortably cross at least one entry boundary regardless
        // of layout-specific entry heights — Sinhala translation entries
        // can run ~1000px tall for long passages, so we use 1200 to keep
        // headroom even though sideBySide entries are usually shorter.
        controller.jumpTo(1200);
        await pumpForSettle(tester, const Duration(seconds: 1));

        // Precondition guard for the assertion below. `jumpTo` silently
        // clamps to `maxScrollExtent` — if the laid-out list is shorter
        // than 1200px the jump goes nowhere, the top entry is still the
        // first one, and the next expectation would fail blaming the
        // listener, which is innocent.
        expect(
          controller.offset,
          greaterThan(0),
          reason: 'jumpTo(1200) must produce a non-zero offset before a '
              'moved-off-the-top entry can be proved to survive — if the '
              'offset is 0 the laid-out list is shorter than 1200px and '
              'the test setup, not the layout listener, is the problem',
        );

        // The entry the reader is now looking at. Phases 2 and 3 are about
        // *this* entry coming back, not about the viewport merely ending up
        // somewhere below the top.
        final scrolledTo = topVisibleEntry(tester, controller);
        expect(scrolledTo, isNotNull,
            reason: 'A scrolled viewport must still have a top entry');
        expect(scrolledTo, isNot(atTop.top),
            reason: 'jumpTo(1200) has to cross an entry boundary — if the top '
                'entry is still the unit\'s first one there is no reading '
                'position to lose and phases 2-3 prove nothing');

        // sideBySide → stacked. The listener captures sideBySide's top
        // entry and anchors stacked at it — never at the top, because
        // entries precede it.
        final posA = await switchTo(ReaderLayout.stacked);
        expect(posA.layout, ReaderLayout.stacked);
        expect(
          posA.before,
          greaterThan(atTop.before),
          reason: 'The entry at the top of sideBySide is pages into the '
              'unit, so stacked must open on it with the unit above it — '
              '${posA.before}px above vs reference ${atTop.before}. Falling '
              'back to the reference is the old behaviour: the switch reset '
              'to the top and lost the reading position',
        );
        expect(
          posA.top,
          scrolledTo,
          reason: 'The entry at the top of sideBySide must be the entry at '
              'the top of stacked. Revealing the WRONG entry also leaves the '
              'viewport below the reference, so the offset above cannot tell '
              'the two apart — expected $scrolledTo, got ${posA.top}',
        );

        // ---- PHASE 3: it survives a switch with no re-scroll ----

        // stacked → sinhalaOnly, nothing touched in between. The top entry
        // of stacked is the one phase 2 put there, so it is captured again
        // and revealed again.
        final posASurvived = await switchTo(ReaderLayout.sinhalaOnly);
        expect(posASurvived.layout, ReaderLayout.sinhalaOnly);
        expect(
          posASurvived.before,
          greaterThan(atTop.before),
          reason: 'stacked → sinhalaOnly with no re-scroll must keep the '
              'reading position — ${posASurvived.before}px above vs '
              'reference ${atTop.before}',
        );
        expect(
          posASurvived.top,
          scrolledTo,
          reason: 'Still the same entry two layouts on — expected '
              '$scrolledTo, got ${posASurvived.top}',
        );

        // ---- PHASE 4: the viewport is re-read, not remembered ----

        // Scroll back to the very top inside sinhalaOnly. The next switch
        // must now capture the unit's *first* entry — a listener that
        // cached its first capture would still be holding phase 2's. Above
        // the anchor the top is an estimate until those pages are built, so
        // one jump to it can stop short: jump until nothing is left above.
        for (var i = 0; i < 20 && controller.position.extentBefore > 0; i++) {
          controller.jumpTo(controller.position.minScrollExtent);
          await tester.pump();
        }
        await pumpForSettle(tester, const Duration(seconds: 1));
        expect(controller.position.extentBefore, 0,
            reason: 'Phase 4 needs the viewport at the very top of the unit');

        // Deliberately back into sideBySide, the layout phase 1 measured,
        // so this compares like with like.
        final posB = await switchTo(ReaderLayout.sideBySide);
        expect(posB.layout, ReaderLayout.sideBySide);
        expect(
          posB.before,
          closeTo(atTop.before, 1.0),
          reason: 'After scrolling back to the top, the switch must come back '
              'up with it: the unit\'s first entry in sideBySide is where '
              'phase 1 landed, ${atTop.before}px above. ${posB.before}px '
              'means the listener reused an earlier capture (phase 2 left '
              '${posASurvived.before}px above) instead of re-reading the '
              'viewport',
        );
        expect(
          posB.top,
          atTop.top,
          reason: 'And it must be the unit\'s first entry that came back '
              '(${atTop.top}), not the one phase 2 left at the top '
              '($scrolledTo)',
        );
      },
    );

    // ---------------------------------------------------------------
    // Test: layout switch recomputes in-page search matches.
    //
    // The recompute path: when `activeReaderLayoutProvider` changes,
    // `multi_pane_reader_widget.dart` calls
    // `InPageSearchNotifier.recomputeActiveTabMatches`, which re-runs
    // `_findAllMatches` against the NEW layout. Without this, the
    // match count goes stale after a layout switch — e.g. user has
    // 6 matches in sideBySide, switches to paliOnly, count still
    // says 6 but half of them sit in Sinhala entries the new layout
    // doesn't render. Arrow-nav then "jumps" to entries with no
    // visible highlight.
    //
    // Load-bearing assertion: sideBySide matchCount must equal
    // paliOnly + sinhalaOnly. This is a mathematical invariant
    // (sideBySide scans both sections; the single-section layouts
    // scan one each) that doesn't depend on whether 'එවං' happens
    // to appear in the Sinhala translation. It proves the layout
    // filter actually partitions matches per layout, not e.g.
    // returns a stale cached set or ignores layout entirely.
    // ---------------------------------------------------------------
    testWidgets(
      'layout switch recomputes in-page search matches against new layout',
      (tester) async {
        final container = await pumpReaderApp(tester);

        final tab = tabFromNode(container, 'dn-1-1');
        await openTab(tester, container, tab);

        // Pre-condition: a freshly opened tab defaults to paliOnly.
        expect(
          container.read(tabsProvider)[0].layout,
          ReaderLayout.paliOnly,
          reason: 'New tab should default to paliOnly',
        );

        // Drive the query straight through the notifier — this test
        // exercises the recompute pathway, not the InPageSearchBar UI.
        // 'එවං' is Pali "evaṃ" (= "thus") in Sinhala script; appears
        // throughout dn-1-1's Pali source.
        //
        // openSearch() before updateQuery: the layout-switch recompute
        // is gated on `isVisible == true` so that closing the bar +
        // changing layout doesn't leave stale matches misaligned with
        // pagination (see InPageSearchNotifier.recomputeActiveTabMatches).
        // Driving the notifier directly would skip the visibility flip
        // the real UI does — opening the bar restores parity.
        container.read(inPageSearchStatesProvider.notifier).openSearch();
        container.read(inPageSearchStatesProvider.notifier).updateQuery('එවං');
        // 300 ms debounce + buffer, then settle for the match computation.
        await tester.pump(const Duration(milliseconds: 400));
        await pumpForSettle(tester);

        final paliOnlyState = readSearchState(container, 0);
        final paliCount = paliOnlyState.matchCount;
        expect(
          paliCount,
          greaterThan(0),
          reason: '"එවං" should match in dn-1-1 with the paliOnly layout',
        );
        expect(paliOnlyState.currentMatchIndex, 0);
        expect(paliOnlyState.effectiveQuery, isNotEmpty);

        // ACT 1 — switch to sinhalaOnly. Recompute must run against
        // ONLY the Sinhala entries, dropping all Pali matches from the set.
        container.read(updateActiveTabLayoutProvider)(ReaderLayout.sinhalaOnly);
        await pumpForSettle(tester);

        final sinhalaState = readSearchState(container, 0);
        final sinhalaCount = sinhalaState.matchCount;
        // `_computeAndSetMatches` resets currentMatchIndex to 0 (or -1
        // when empty). This locks in current reset-to-0 semantics; when
        // the currentMatchIndex preservation follow-up lands, update
        // this assertion deliberately.
        expect(
          sinhalaState.currentMatchIndex,
          sinhalaCount > 0 ? 0 : -1,
          reason: 'Recompute should reset currentMatchIndex to 0 '
              '(or -1 if the new layout has no matches)',
        );

        // ACT 2 — switch to sideBySide. Both sections scanned, so
        // matchCount must equal paliCount + sinhalaCount. This is the
        // load-bearing assertion (see test header).
        container.read(updateActiveTabLayoutProvider)(ReaderLayout.sideBySide);
        await pumpForSettle(tester);

        final sideBySideState = readSearchState(container, 0);
        expect(
          sideBySideState.matchCount,
          paliCount + sinhalaCount,
          reason: 'sideBySide count must equal paliOnly + sinhalaOnly: '
              '$paliCount + $sinhalaCount, got ${sideBySideState.matchCount}',
        );

        // ROUND-TRIP — back to paliOnly. The original match set must
        // return. Without the recompute being wired up, this would
        // still report sideBySide's count (or whatever was cached).
        container.read(updateActiveTabLayoutProvider)(ReaderLayout.paliOnly);
        await pumpForSettle(tester);

        final restoredState = readSearchState(container, 0);
        expect(
          restoredState.matchCount,
          paliCount,
          reason: 'Returning to paliOnly must restore the original '
              'match count: expected $paliCount, got '
              '${restoredState.matchCount}',
        );
        expect(
          restoredState.currentMatchIndex,
          0,
          reason: 'Recompute resets index to 0 — update this when the '
              'currentMatchIndex preservation follow-up lands',
        );
        expect(
          restoredState.effectiveQuery,
          paliOnlyState.effectiveQuery,
          reason: 'Query should be unchanged across layout switches',
        );
      },
    );

    // ---------------------------------------------------------------
    // Test: in-page search reaches a match past cacheExtent after a
    // layout switch.
    //
    // The repro path:
    //
    //   1. Search "සීල" in sideBySide → 10 matches across dn-1-1.
    //   2. Navigate to the 5th match (mid-sutta).
    //   3. Close search, switch to stacked. The layout listener anchors
    //      stacked at the top-visible entry. Recompute drops matches
    //      (search hidden).
    //   4. Reopen search. `openSearch` recomputes, currentMatchIndex
    //      = 0, and the search-state listener brings match[0] back.
    //   5. Step forward through matches. Matches several pages down are
    //      inside the unit but *outside* the built rows. The bug: the
    //      scroll stopped at the cula-sila entry while currentMatchIndex
    //      kept advancing. User reported: "scrolls down until චුල්ලසීල
    //      නිට්ඨිතං and doesnt scroll any further".
    //
    // Load-bearing assertion: after 5 next-taps, match[5]'s row is on
    // screen. A row that isn't built is anchored at, so this holds however
    // far the match is.
    // ---------------------------------------------------------------
    testWidgets(
      'in-page search scrolls past cacheExtent after a layout switch',
      (tester) async {
        // Constrain the test view to a mobile-portrait size. On macOS the
        // default integration-test viewport is large enough that the entire
        // dn-1-1 "සීල" match range fits in the list's cacheExtent, which
        // masks the bug entirely (every key stays mounted). A mobile viewport
        // puts page 6 well outside the ~250 px cacheExtent from match[0]'s
        // rendered position.
        tester.view.physicalSize = const Size(414, 896);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final container = await pumpReaderApp(tester);

        final tab = tabFromNode(container, 'dn-1-1');
        await openTab(tester, container, tab);

        // Start in sideBySide so "සීල" matches both Pali and Sinhala
        // entries (10 total in dn-1-1).
        container.read(updateActiveTabLayoutProvider)(ReaderLayout.sideBySide);
        await pumpForSettle(tester);

        // Drive search via the notifier (same pattern as the recompute
        // test above). openSearch first so the visibility flag flips
        // before updateQuery — matches the real UI path.
        container.read(inPageSearchStatesProvider.notifier).openSearch();
        container.read(inPageSearchStatesProvider.notifier).updateQuery('සීල');
        await tester.pump(const Duration(milliseconds: 400));
        await pumpForSettle(tester);

        final matchCount = readSearchState(container, 0).matchCount;
        expect(
          matchCount,
          10,
          reason: '"සීල" in dn-1-1 sideBySide should yield 10 matches '
              '(see _findAllMatches: Pali + Sinhala sections scanned). '
              'Got $matchCount — repro depends on this exact count.',
        );

        // Advance to the 5th match (index 4) — mirrors the user's repro
        // ("stop at the 5th match and change the layout").
        for (var i = 0; i < 4; i++) {
          container.read(inPageSearchStatesProvider.notifier).nextMatch();
        }
        await pumpForSettle(tester, const Duration(seconds: 1));
        expect(readSearchState(container, 0).currentMatchIndex, 4);

        // Close search BEFORE switching layout. The layout pill in the
        // UI is gated on !searchState.isVisible, so the real-world path
        // always closes first. This also triggers the
        // recomputeActiveTabMatches drop-matches branch when the layout
        // listener fires next.
        container.read(inPageSearchStatesProvider.notifier).closeSearch();
        await pumpForSettle(tester);

        // Switch to stacked. Listener captures the top entry and anchors
        // stacked at it. Matches dropped (search hidden).
        container.read(updateActiveTabLayoutProvider)(ReaderLayout.stacked);
        await pumpForSettle(tester, const Duration(seconds: 1));

        expect(
          readSearchState(container, 0).matches,
          isEmpty,
          reason: 'Layout switch with search hidden must drop stale '
              'matches — openSearch will recompute on reopen',
        );

        // Reopen search. openSearch sees retained query + empty matches
        // → recomputes against stacked → currentMatchIndex = 0 → search
        // state listener fires _scrollToCurrentMatch, which brings
        // match[0] back near the top of the unit.
        container.read(inPageSearchStatesProvider.notifier).openSearch();
        await pumpForSettle(tester);

        expect(
          readSearchState(container, 0).matchCount,
          10,
          reason: 'Reopen must recompute against stacked (still both '
              'langs scanned) — count unchanged',
        );
        expect(
          readSearchState(container, 0).currentMatchIndex,
          0,
          reason: 'Reopen recompute resets currentMatchIndex to 0',
        );

        final first = readSearchState(container, 0).currentMatch!;
        expect(isEntryOnScreen(tester, first.pageIndex, first.entryIndex),
            isTrue,
            reason: 'Reopening search must bring match[0] on screen');

        // Step forward 5 times — reaches match[5] (page 6 entry 4 si,
        // "මජ්ඣිමසීලය"). This is several pages below match[0]'s position
        // (page 2 entry 1) — well beyond default cacheExtent (~250px).
        for (var i = 0; i < 5; i++) {
          container.read(inPageSearchStatesProvider.notifier).nextMatch();
          await pumpForSettle(tester, const Duration(milliseconds: 500));
        }
        expect(
          readSearchState(container, 0).currentMatchIndex,
          5,
          reason: '5 next-taps should advance currentMatchIndex from 0 to 5',
        );

        // Load-bearing assertion (see test header).
        final fifth = readSearchState(container, 0).currentMatch!;
        expect(
          isEntryOnScreen(tester, fifth.pageIndex, fifth.entryIndex),
          isTrue,
          reason: 'After 5 next-taps past cacheExtent, match[5]\'s row '
              '(${fifth.pageIndex}, ${fifth.entryIndex}) must be on screen. '
              'Off screen means the reveal gave up before reaching the '
              'match — the scroll stopped while the index advanced.',
        );
      },
    );

    // ---------------------------------------------------------------
    // Test: the last-used layout is persisted and seeds newly created
    // tabs, while existing tabs keep their own per-tab layout.
    //
    // Covers the feature in `last_reader_layout_provider.dart`: changing
    // a tab's layout records it as the global "last used" value, and the
    // tab-creation providers seed new tabs from it (falling back to the
    // orientation default only when nothing is saved).
    //
    // We drive a single creation path — `openTabFromNodeKeyProvider` —
    // since the tree, breadcrumb, search, and commentary/root-text paths
    // all read the same `lastReaderLayoutProvider` seed. The chosen
    // layout (sinhalaOnly) is deliberately NOT the default for either
    // orientation (portrait → stacked, landscape → sideBySide), so a new
    // tab landing on it proves the saved value drove the choice rather
    // than the orientation heuristic.
    // ---------------------------------------------------------------
    testWidgets(
      'last-used layout seeds new tabs; existing tabs keep their own',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // Nothing chosen yet → nothing persisted.
        expect(
          container.read(lastReaderLayoutProvider),
          isNull,
          reason: 'No layout has been selected yet',
        );

        // 1. First tab via the real creator with nothing saved → falls
        //    back to the landscape orientation default (sideBySide).
        final idxA = container.read(openTabFromNodeKeyProvider)('dn-1-1');
        await pumpForSettle(tester);
        expect(idxA, isNonNegative, reason: 'dn-1-1 should open');
        expect(
          container.read(tabsProvider)[idxA].layout,
          ReaderLayout.sideBySide,
          reason: 'With nothing saved, a landscape tab seeds to sideBySide',
        );

        // 2. User changes the layout → must update BOTH the active tab and
        //    the global last-used value.
        container.read(updateActiveTabLayoutProvider)(ReaderLayout.sinhalaOnly);
        await pumpForSettle(tester, const Duration(seconds: 1));
        expect(
          container.read(tabsProvider)[idxA].layout,
          ReaderLayout.sinhalaOnly,
          reason: 'Changing layout updates the active tab',
        );
        expect(
          container.read(lastReaderLayoutProvider),
          ReaderLayout.sinhalaOnly,
          reason: 'Changing layout also records the last-used layout',
        );

        // 3. New tabs now seed from the saved layout, and the saved value
        //    wins over the orientation default in BOTH orientations
        //    (sinhalaOnly is neither orientation's default).
        final idxLandscape =
            container.read(openTabFromNodeKeyProvider)('dn-1-1');
        await pumpForSettle(tester);
        expect(
          container.read(tabsProvider)[idxLandscape].layout,
          ReaderLayout.sinhalaOnly,
          reason: 'New landscape tab seeds from saved layout, not sideBySide',
        );

        final idxPortrait = container.read(openTabFromNodeKeyProvider)('dn-1-1',
            isPortraitMode: true);
        await pumpForSettle(tester);
        expect(
          container.read(tabsProvider)[idxPortrait].layout,
          ReaderLayout.sinhalaOnly,
          reason: 'New portrait tab seeds from saved layout, not stacked',
        );

        // 4. Existing tab keeps its own layout — switching never re-seeds.
        //    Simulate a tab saved earlier in a different layout (sideBySide).
        final yesterdayTab = tabFromNode(container, 'dn-1-1')
            .copyWith(layout: ReaderLayout.sideBySide);
        container.read(tabsProvider.notifier).addTab(yesterdayTab);
        final idxYesterday = container.read(tabsProvider).length - 1;

        container.read(switchTabProvider)(idxYesterday);
        await pumpForSettle(tester, const Duration(seconds: 1));

        expect(
          container.read(tabsProvider)[idxYesterday].layout,
          ReaderLayout.sideBySide,
          reason: 'Switching to an existing tab must not change its layout',
        );
        expect(
          container.read(activeReaderLayoutProvider),
          ReaderLayout.sideBySide,
          reason: 'Reader shows the active tab\'s own layout, not the global '
              'last-used value',
        );
        expect(
          container.read(lastReaderLayoutProvider),
          ReaderLayout.sinhalaOnly,
          reason: 'Merely switching tabs must not overwrite the last-used '
              'layout',
        );
      },
    );
  });
}
