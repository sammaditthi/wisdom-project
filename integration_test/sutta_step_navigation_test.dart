import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:the_wisdom_project/presentation/models/reader_tab.dart';
import 'package:the_wisdom_project/presentation/providers/tab_provider.dart';
import 'package:the_wisdom_project/presentation/providers/document_provider.dart';
import 'package:the_wisdom_project/presentation/providers/navigation_tree_provider.dart';
import 'package:the_wisdom_project/presentation/providers/reader_scroll_provider.dart';
import 'package:the_wisdom_project/presentation/providers/reader_unit_provider.dart';
import 'package:the_wisdom_project/presentation/widgets/reader/toolbar_auto_hide.dart';

import 'test_overrides.dart';

/// Integration tests for the reader's step navigation — the previous and next
/// sutta buttons, and Go to beginning, which joins them in the toolbar
/// mid-sutta.
///
/// **The buttons step between leaves, not between readable nodes.** A container
/// is a unit here — tapping සීලක්ඛන්ධවග්ගො renders the whole vagga — so leaving
/// one is a single stop to the sutta on the other side of it, and no tap can
/// land the reader on සුත්තපිටක. `neighbourLeafProvider` is the rule, asked
/// with [ReaderStep.previous] or [ReaderStep.next].
///
/// The two directions are not quite each other's mirror, and the last test
/// here is the asymmetry: previous steps off a unit's *first* leaf, next off
/// the last leaf it actually **rendered**. On the containers whose subtree
/// crosses a content file those are different nodes.
///
/// Leaf order used (the stops, in reading order):
///   dn-1-1     → බ්රහ්මජාලසුත්තං     (fileId: dn-1,    page:[0,4])
///   dn-1-2     → සාමඤ්ඤඵලසුත්තං     (fileId: dn-1,    page:[40,0])
///   dn-1-3     → අම්බට්ඨසුත්තං      (fileId: dn-1-3,  page:[0,0])
///   dn-1-4     → සොණදණ්ඩසුත්තං      (fileId: dn-1-3)
///   ...
///   dn-1-10    → සුභසුත්තං          (fileId: dn-1-6)
///   dn-1-11    → කෙවඩ්ඪසුත්තං       (fileId: dn-1-11, page:[0,0])
///
/// dn-1-1 is the first leaf of the Sutta Pitaka, so the leaf before it is the
/// last one of the Vinaya — which is why the tests that want a neighbour they
/// can name start at dn-1-2 or later.
///
/// First leaf in the entire tree:
///   vp-prj-1   → වෙරඤ්ජකණ්ඩො         (fileId: vp-prj), inside vp විනයපිටක

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Previous Sutta Navigation', () {
    // =================================================================
    // Test 1: FTS mid-sutta
    // =================================================================
    testWidgets(
      '1. FTS mid-sutta: Go to beginning returns to the sutta beginning',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // An FTS hit inside බ්රහ්මජාලසුත්තං. The tab is still the whole
        // sutta, anchored at page 5 entry 3: it opens on that row with the
        // pages above it still to scroll up into, which is what puts Go to
        // beginning in the toolbar.
        final tab = ReaderTab.fromNode(
          nodeKey: 'dn-1-1',
          paliName: 'බ්රහ්මජාලසුත්තං',
          sinhalaName: 'බ්‍රහ්මජාල සූත්‍රය',
          anchorPageIndex: 5,
          anchorEntryIndex: 3,
        );

        await openTab(tester, container, tab);

        final controller = readerScrollController(tester);
        expect(controller.position.extentBefore, greaterThan(0),
            reason: 'The anchor row is pages into the sutta, so the tab '
                'must open with those pages above the viewport');

        // ASSERT: opened mid-sutta, the toolbar shows with Go to beginning.
        // `.hitTestable()`: the toolbar never leaves the tree, kept out of
        // reach by IgnorePointer while hidden.
        expect(
            find.byIcon(Icons.vertical_align_top).hitTestable(), findsOneWidget,
            reason: 'Mid-sutta the toolbar should offer Go to beginning');

        // ACT: Tap Go to beginning
        await tester.tap(find.byIcon(Icons.vertical_align_top));
        await pumpForSettle(tester);

        // ASSERT: back at the unit's own first row. Scroll-to-top drops the
        // anchor rather than scrolling up to the top.
        expect(container.read(activeAnchorProvider), isNull,
            reason: 'Scroll-to-top should drop the anchor');
        expect(controller.offset, 0.0,
            reason: 'Scroll-to-top should return to the top of the unit');
        expect(controller.position.extentBefore, 0.0,
            reason: 'Nothing of the unit may be left above the viewport');
        expect(container.read(activeNodeKeyProvider), 'dn-1-1',
            reason: 'nodeKey should remain the same');
        expect(find.byIcon(Icons.vertical_align_top), findsNothing,
            reason: 'At the beginning Go to beginning has nothing to do');
        expect(find.byIcon(Icons.skip_previous).hitTestable(), findsOneWidget,
            reason: 'At the beginning the toolbar still shows');
      },
    );

    // =================================================================
    // Test 2: At sutta beginning — previous sutta button
    // =================================================================
    testWidgets(
      '2. At sutta beginning: shows skip-previous icon with previous sutta tooltip',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // Open සාමඤ්ඤඵලසුත්තං at its beginning. The leaf before it is
        // බ්රහ්මජාලසුත්තං — a sutta, not the vagga holding them both.
        final tab = tabFromNode(container, 'dn-1-2');
        await openTab(tester, container, tab);

        // ASSERT: skip_previous icon visible (previous sutta mode)
        expect(find.byIcon(Icons.skip_previous), findsOneWidget,
            reason: 'At sutta beginning should show skip-previous icon');
        expect(find.byIcon(Icons.vertical_align_top), findsNothing,
            reason: 'At sutta beginning should NOT show scroll-to-top icon');

        // ASSERT: Tooltip contains the previous sutta's Pali name
        final tooltip = tester.widget<Tooltip>(
          find.ancestor(
            of: find.byIcon(Icons.skip_previous),
            matching: find.byType(Tooltip),
          ),
        );
        expect(tooltip.message, contains('බ්රහ්මජාලසුත්තං'),
            reason: 'Tooltip should name the previous leaf, not its parent');

        // ACT: Tap the button
        await tester.tap(find.byIcon(Icons.skip_previous));
        await pumpForSettle(tester);

        // ASSERT: Now at the previous sutta (dn-1-1)
        expect(container.read(activeNodeKeyProvider), 'dn-1-1',
            reason: 'Should navigate to previous sutta dn-1-1');
      },
    );

    // =================================================================
    // Test 3: Repeated navigation — multiple sequential taps
    // =================================================================
    testWidgets(
      '3. Repeated navigation: sequential backward navigation through suttas',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // Start at සොණදණ්ඩසුත්තං (dn-1-4). Three taps walk back through the
        // suttas of the vagga — never up into the vagga itself, which is the
        // whole difference from the readable-node walk this replaced.
        final tab = tabFromNode(container, 'dn-1-4');
        await openTab(tester, container, tab);

        // --- First tap: dn-1-4 → dn-1-3 ---
        expect(find.byIcon(Icons.skip_previous), findsOneWidget);
        await tester.tap(find.byIcon(Icons.skip_previous));
        await pumpForSettle(tester);
        expect(container.read(activeNodeKeyProvider), 'dn-1-3',
            reason: 'First tap: should navigate to dn-1-3');

        // --- Second tap: dn-1-3 → dn-1-2, and across a content file ---
        expect(find.byIcon(Icons.skip_previous), findsOneWidget);
        await tester.tap(find.byIcon(Icons.skip_previous));
        await pumpForSettle(tester);
        expect(container.read(activeNodeKeyProvider), 'dn-1-2',
            reason: 'Second tap: should navigate to dn-1-2');

        // --- Third tap: dn-1-2 → dn-1-1 ---
        expect(find.byIcon(Icons.skip_previous), findsOneWidget);
        await tester.tap(find.byIcon(Icons.skip_previous));
        await pumpForSettle(tester);
        expect(container.read(activeNodeKeyProvider), 'dn-1-1',
            reason: 'Third tap: should navigate to dn-1-1');
      },
    );

    // =================================================================
    // Test 4: Cross-file navigation
    // =================================================================
    testWidgets(
      '4. Cross-file: navigates to previous sutta in a different content file',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // Open කෙවඩ්ඪසුත්තං (dn-1-11, fileId: dn-1-11)
        // Its previous node in DFS order is dn-1-10 (fileId: dn-1-6) — different file
        final tab = tabFromNode(container, 'dn-1-11');
        await openTab(tester, container, tab);

        // Verify starting state
        expect(container.read(activeContentFileIdProvider), 'dn-1-11',
            reason: 'Should start with contentFileId dn-1-11');

        // ACT: Tap the previous sutta button
        expect(find.byIcon(Icons.skip_previous), findsOneWidget);
        await tester.tap(find.byIcon(Icons.skip_previous));
        await pumpForSettle(tester);

        // ASSERT: Now at dn-1-10, in a different content file (dn-1-6)
        expect(container.read(activeNodeKeyProvider), 'dn-1-10',
            reason: 'Should navigate to dn-1-10');
        expect(container.read(activeContentFileIdProvider), 'dn-1-6',
            reason: 'Content file should change to dn-1-6 (cross-file)');
      },
    );

    // =================================================================
    // Test 5: First sutta in tree — button hidden
    // =================================================================
    testWidgets(
      '5. First sutta in tree: navigation button is hidden',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // Open the very first readable node in the tree: vp (Vinaya Pitaka)
        final tab = tabFromNode(container, 'vp');
        await openTab(tester, container, tab);

        // Guard: the assertions below are both "findsNothing", so they
        // would also pass on a reader showing no text at all.
        expect(
          readerScrollView,
          findsOneWidget,
          reason: 'vp must actually render text for a hidden button to mean '
              'anything',
        );

        // Guard: the provider answers null for "nothing before it" and for
        // "the resolver never loaded" alike, so a key that does have a
        // previous leaf has to separate them first.
        expect(
          container
              .read(neighbourLeafProvider(('dn-1-2', ReaderStep.previous))),
          isNotNull,
          reason: 'The leaf walk must be working for vp\'s null to mean '
              '"first in the corpus" rather than "resolver not loaded"',
        );

        // Verify that the previous leaf really is absent
        final previousNode =
            container.read(neighbourLeafProvider(('vp', ReaderStep.previous)));
        expect(previousNode, isNull,
            reason:
                'vp holds the first leaf in the corpus — nothing before it');

        // ASSERT: Neither navigation icon is visible
        expect(find.byIcon(Icons.skip_previous), findsNothing,
            reason: 'No skip-previous at the very first sutta');
        expect(find.byIcon(Icons.vertical_align_top), findsNothing,
            reason: 'No Go to beginning at the beginning of the first sutta');
      },
    );

    // =================================================================
    // Test 6: Tab label updates after navigating to previous sutta
    // =================================================================
    testWidgets(
      '6. Tab label: updates to previous sutta name after navigation',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // Open සාමඤ්ඤඵලසුත්තං (dn-1-2)
        final tab = tabFromNode(container, 'dn-1-2');
        await openTab(tester, container, tab);

        // Verify starting tab state
        final tabsBefore = container.read(tabsProvider);
        expect(tabsBefore[0].paliName, 'සාමඤ්ඤඵලසුත්තං');

        // ACT: Navigate to previous
        await tester.tap(find.byIcon(Icons.skip_previous));
        await pumpForSettle(tester);

        // ASSERT: Tab entity updated to the previous node's data
        final tabsAfter = container.read(tabsProvider);
        expect(tabsAfter[0].nodeKey, 'dn-1-1',
            reason: 'Tab nodeKey should update to dn-1-1');
        expect(tabsAfter[0].paliName, 'බ්රහ්මජාලසුත්තං',
            reason: 'Tab paliName should update to dn-1-1 pali name');
        expect(tabsAfter[0].sinhalaName, 'බ්‍රහ්මජාල සූත්‍රය',
            reason: 'Tab sinhalaName should update to dn-1-1 sinhala name');
        expect(tabsAfter[0].fullName, 'බ්රහ්මජාලසුත්තං / බ්‍රහ්මජාල සූත්‍රය',
            reason: 'Tab fullName should update');
      },
    );

    // =================================================================
    // Test 7: Navigator sync — tree highlights the new sutta
    // =================================================================
    testWidgets(
      '7. Navigator sync: tree selection updates after navigating to previous',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // Open සාමඤ්ඤඵලසුත්තං (dn-1-2)
        final tab = tabFromNode(container, 'dn-1-2');
        await openTab(tester, container, tab);

        // ACT: Navigate to previous
        await tester.tap(find.byIcon(Icons.skip_previous));
        await pumpForSettle(tester);

        // ASSERT: Navigator selection updated to dn-1-1
        expect(container.read(selectedNodeProvider), 'dn-1-1',
            reason: 'Navigator should select the new sutta (dn-1-1)');

        // ASSERT: Path to dn-1-1 should be expanded in the tree
        final expanded = container.read(expandedNodesProvider);
        expect(expanded, contains('dn-1'),
            reason: 'Parent node "dn-1" should be expanded');
      },
    );

    // =================================================================
    // Test 8: Scrolling hides the toolbar, scrolling back brings it back
    // =================================================================
    testWidgets(
      '8. Scrolling: reading on hides the toolbar, scrolling back past the '
      'threshold brings it back with Go to beginning',
      (tester) async {
        // No screen reader, which pins the toolbar. On web `testWidgets`
        // turns semantics on, and the browser then reports one.
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures();
        addTearDown(
            tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

        final container = await pumpReaderApp(tester);

        // Open බ්රහ්මජාලසුත්තං (dn-1-1) at its beginning. The unit runs to
        // the sutta's end, far more than this test scrolls through.
        final tab = tabFromNode(container, 'dn-1-1');
        await openTab(tester, container, tab);

        // `.hitTestable()` throughout: the toolbar never leaves the tree, so
        // a bare finder would pass whether or not it shows.
        final toolbar = find.byIcon(Icons.skip_previous).hitTestable();
        final goToBeginning =
            find.byIcon(Icons.vertical_align_top).hitTestable();
        expect(toolbar, findsOneWidget,
            reason: 'At the sutta beginning the toolbar shows');
        expect(goToBeginning, findsNothing,
            reason: 'At the beginning Go to beginning has nothing to do');

        final controller = readerScrollController(tester);
        final vpDim = controller.position.viewportDimension;
        expect(controller.position.maxScrollExtent, greaterThan(vpDim * 3),
            reason: 'Content must run well past what this test scrolls '
                '(max=${controller.position.maxScrollExtent}, vp=$vpDim)');

        // ACT: a jump, as a search hit or a restore makes. Not the reader's
        // own scrolling, so the toolbar stays.
        controller.jumpTo(vpDim * 2);
        await tester.pump();
        expect(toolbar, findsOneWidget,
            reason: 'A programmatic jump must not hide the toolbar');
        expect(goToBeginning, findsOneWidget,
            reason: 'More than a screen down, the toolbar offers Go to '
                'beginning');

        // ACT: the reader reads on, with the mouse wheel.
        await _wheel(tester, 300);
        expect(toolbar, findsNothing,
            reason: 'Scrolling down mid-sutta hides the toolbar');

        // ACT: back up by less than the threshold, then past it in total,
        // over two notches: a pause between them keeps the count.
        const reveal = ToolbarAutoHide.revealDistance;
        await _wheel(tester, -reveal * 0.5);
        expect(toolbar, findsNothing,
            reason: 'Scrolling back less than the threshold keeps it hidden');
        await _wheel(tester, -reveal * 0.6);
        expect(toolbar, findsOneWidget,
            reason: 'Scrolling back past the threshold brings it back');
        expect(goToBeginning, findsOneWidget,
            reason: 'Still mid-sutta, so with Go to beginning');

        // ACT: Go to beginning
        await tester.tap(goToBeginning);
        await pumpForSettle(tester);

        // ASSERT: at the top, the toolbar stays and Go to beginning goes.
        expect(controller.position.extentBefore, 0.0,
            reason: 'Nothing of the unit may be left above the viewport');
        expect(find.byIcon(Icons.vertical_align_top), findsNothing,
            reason: 'At the beginning Go to beginning has nothing to do');
        expect(toolbar, findsOneWidget,
            reason: 'At the beginning the toolbar shows');

        // ACT: from the top, read on by less than a screen.
        await _wheel(tester, vpDim / 2);

        // ASSERT: the toolbar hides, and Go to beginning is not added as it
        // leaves.
        expect(toolbar, findsNothing,
            reason: 'Scrolling down past the top hides the toolbar');
        expect(find.byIcon(Icons.vertical_align_top), findsNothing,
            reason: 'Less than a screen down, Go to beginning must not join '
                'the toolbar while it fades out');
      },
    );
  });

  group('Next Sutta Navigation', () {
    // =================================================================
    // Test 1: At sutta beginning — next sutta button
    // =================================================================
    testWidgets(
      '1. At sutta beginning: shows skip-next icon with next sutta tooltip',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // Open බ්රහ්මජාලසුත්තං at its beginning. The leaf after it is
        // සාමඤ්ඤඵලසුත්තං — a sutta, not the vagga holding them both.
        final tab = tabFromNode(container, 'dn-1-1');
        await openTab(tester, container, tab);

        // ASSERT: skip_next icon visible (next sutta available)
        expect(find.byIcon(Icons.skip_next), findsOneWidget,
            reason: 'At sutta beginning should show skip-next icon');
        expect(find.byIcon(Icons.vertical_align_top), findsNothing,
            reason: 'At sutta beginning should NOT show scroll-to-top icon');

        // ASSERT: Tooltip contains the next sutta's Pali name.
        // Both directions share one string — the icon says which way — so
        // this is also what proves the two slots did not swap.
        final tooltip = tester.widget<Tooltip>(
          find.ancestor(
            of: find.byIcon(Icons.skip_next),
            matching: find.byType(Tooltip),
          ),
        );
        expect(tooltip.message, contains('සාමඤ්ඤඵලසුත්තං'),
            reason: 'Tooltip should name the next leaf, not its parent');

        // ACT: Tap the button
        await tester.tap(find.byIcon(Icons.skip_next));
        await pumpForSettle(tester);

        // ASSERT: Now at the next sutta (dn-1-2)
        expect(container.read(activeNodeKeyProvider), 'dn-1-2',
            reason: 'Should navigate to next sutta dn-1-2');
      },
    );

    // =================================================================
    // Test 2: Repeated navigation — multiple sequential taps
    // =================================================================
    testWidgets(
      '2. Repeated navigation: sequential forward navigation through suttas',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // Start at බ්රහ්මජාලසුත්තං (dn-1-1). Three taps walk forward through
        // the suttas of the vagga — never up into the vagga itself.
        final tab = tabFromNode(container, 'dn-1-1');
        await openTab(tester, container, tab);

        // --- First tap: dn-1-1 → dn-1-2 ---
        expect(find.byIcon(Icons.skip_next), findsOneWidget);
        await tester.tap(find.byIcon(Icons.skip_next));
        await pumpForSettle(tester);
        expect(container.read(activeNodeKeyProvider), 'dn-1-2',
            reason: 'First tap: should navigate to dn-1-2');

        // --- Second tap: dn-1-2 → dn-1-3, and across a content file ---
        expect(find.byIcon(Icons.skip_next), findsOneWidget);
        await tester.tap(find.byIcon(Icons.skip_next));
        await pumpForSettle(tester);
        expect(container.read(activeNodeKeyProvider), 'dn-1-3',
            reason: 'Second tap: should navigate to dn-1-3');

        // --- Third tap: dn-1-3 → dn-1-4 ---
        expect(find.byIcon(Icons.skip_next), findsOneWidget);
        await tester.tap(find.byIcon(Icons.skip_next));
        await pumpForSettle(tester);
        expect(container.read(activeNodeKeyProvider), 'dn-1-4',
            reason: 'Third tap: should navigate to dn-1-4');
      },
    );

    // =================================================================
    // Test 3: Cross-file navigation
    // =================================================================
    testWidgets(
      '3. Cross-file: navigates to next sutta in a different content file',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // Open සුභසුත්තං (dn-1-10, fileId: dn-1-6)
        // The leaf after it is dn-1-11 (fileId: dn-1-11) — different file
        final tab = tabFromNode(container, 'dn-1-10');
        await openTab(tester, container, tab);

        // Verify starting state
        expect(container.read(activeContentFileIdProvider), 'dn-1-6',
            reason: 'Should start with contentFileId dn-1-6');

        // ACT: Tap the next sutta button
        expect(find.byIcon(Icons.skip_next), findsOneWidget);
        await tester.tap(find.byIcon(Icons.skip_next));
        await pumpForSettle(tester);

        // ASSERT: Now at dn-1-11, in a different content file (dn-1-11)
        expect(container.read(activeNodeKeyProvider), 'dn-1-11',
            reason: 'Should navigate to dn-1-11');
        expect(container.read(activeContentFileIdProvider), 'dn-1-11',
            reason: 'Content file should change to dn-1-11 (cross-file)');
      },
    );

    // =================================================================
    // Test 4: Last sutta in tree — button hidden
    // =================================================================
    testWidgets(
      '4. Last sutta in tree: navigation button is hidden',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // නිගමනකථා (anya-vm-23-6) is the last leaf in the corpus — the
        // closing words of the Visuddhimagga, and the end of anya.
        final tab = tabFromNode(container, 'anya-vm-23-6');
        await openTab(tester, container, tab);

        // Guard: the assertion below is "findsNothing", so it would also
        // pass on a reader showing no text at all.
        expect(
          readerScrollView,
          findsOneWidget,
          reason: 'anya-vm-23-6 must actually render text for a hidden button '
              'to mean anything',
        );

        // Guard: the provider answers null for "nothing after it" and for
        // "the resolver never loaded" alike, so a key that does have a next
        // leaf has to separate them first.
        expect(
          container.read(neighbourLeafProvider(('dn-1-2', ReaderStep.next))),
          isNotNull,
          reason: 'The leaf walk must be working for anya-vm-23-6\'s null to '
              'mean "last in the corpus" rather than "resolver not loaded"',
        );

        // Verify that the next leaf really is absent
        final nextNode = container
            .read(neighbourLeafProvider(('anya-vm-23-6', ReaderStep.next)));
        expect(nextNode, isNull,
            reason: 'anya-vm-23-6 is the last leaf in the corpus — nothing '
                'after it');

        // ASSERT: the forward button is gone
        expect(find.byIcon(Icons.skip_next), findsNothing,
            reason: 'No skip-next at the very last sutta');

        // Positive control: the toolbar is rendering, and only the forward
        // slot dropped out of it. Without this the assertion above passes on a
        // reader with no action buttons at all.
        expect(find.byIcon(Icons.skip_previous), findsOneWidget,
            reason: 'The last sutta still has a previous one');
      },
    );

    // =================================================================
    // Test 5: Container units step off the last leaf they RENDERED
    // =================================================================
    testWidgets(
      '5. Container: next steps off the last leaf actually rendered',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // සීලක්ඛන්ධවග්ගො (dn-1) is one of the containers whose subtree
        // crosses a content file: dn-1-1 and dn-1-2 live in dn-1, the rest
        // in dn-1-3, dn-1-6 and dn-1-11. The unit renders its own file and
        // stops, so "next" is the leaf after dn-1-2 — not the leaf after the
        // whole vagga, which would skip eleven suttas the reader never saw.
        final tab = tabFromNode(container, 'dn-1');
        await openTab(tester, container, tab);

        expect(container.read(activeContentFileIdProvider), 'dn-1',
            reason: 'The vagga unit is bounded to its own content file');

        // ACT
        expect(find.byIcon(Icons.skip_next), findsOneWidget);
        await tester.tap(find.byIcon(Icons.skip_next));
        await pumpForSettle(tester);

        // ASSERT: dn-1-3, the leaf after the last one the vagga showed.
        // This is where the two directions stop being mirrors: previous from
        // dn-1 steps off its FIRST leaf and leaves the vagga entirely, while
        // next steps off the last leaf rendered and stays inside it.
        expect(container.read(activeNodeKeyProvider), 'dn-1-3',
            reason: 'Next from a multi-file container resumes at the leaf '
                'after the last one it rendered');
      },
    );

    // =================================================================
    // Test 6: From the top of an anchored tab, next opens at the top
    // =================================================================
    testWidgets(
      '6. Anchored tab scrolled to its top: next opens the sutta at its top',
      (tester) async {
        final container = await pumpReaderApp(tester);

        // සාමඤ්ඤඵලසුත්තං first, so its text is already loaded when the step
        // reaches it. Then the reader keeps its scroll view across the step,
        // and nothing reloads to re-read the scroll state for it.
        await openTab(tester, container, tabFromNode(container, 'dn-1-2'));

        // බ්රහ්මජාලසුත්තං anchored mid-sutta, as a search hit opens it.
        await openTab(
          tester,
          container,
          tabFromNode(container, 'dn-1-1')
              .copyWith(anchorPageIndex: 5, anchorEntryIndex: 3),
        );

        // Scroll up to the unit's top. Above the anchor the top is an
        // estimate until those pages are built, so one jump can stop short:
        // jump until nothing is left above.
        final controller = readerScrollController(tester);
        for (var i = 0; i < 20 && controller.position.extentBefore > 0; i++) {
          controller.jumpTo(controller.position.minScrollExtent);
          await tester.pump();
        }
        await pumpForSettle(tester);
        expect(controller.position.extentBefore, 0,
            reason: 'The step must start from the very top of the unit');
        expect(find.byIcon(Icons.skip_next).hitTestable(), findsOneWidget,
            reason: 'At the top, the toolbar shows with its next button');

        // ACT. The anchor row still has pages above it, so a jump to offset 0
        // measured against this layout reads as "scrolled down".
        await tester.tap(find.byIcon(Icons.skip_next));
        await pumpForSettle(tester);

        // ASSERT: the next sutta opens at its own top, and the reader says so.
        expect(container.read(activeNodeKeyProvider), 'dn-1-2');
        expect(container.read(activeAnchorProvider), isNull,
            reason: 'A step opens the sutta at its top, with no anchor');
        expect(controller.position.extentBefore, 0,
            reason: 'Nothing of the new sutta is above the viewport');
        expect(find.byIcon(Icons.vertical_align_top), findsNothing,
            reason: 'At the top of the new sutta the reader must not count '
                'as scrolled down, so no Go to beginning');
        expect(find.byIcon(Icons.skip_previous).hitTestable(), findsOneWidget,
            reason: 'And the toolbar shows');
        expect(container.read(readerScrolledUnderProvider), isFalse,
            reason: 'And the app bar must not be tinted as scrolled under');
      },
    );
  });
}

/// Scrolls the reader by [dy] with one mouse-wheel notch: the reader's own
/// scrolling, unlike a controller jump.
Future<void> _wheel(WidgetTester tester, double dy) async {
  final pointer = TestPointer(1, PointerDeviceKind.mouse)
    ..hover(tester.getCenter(readerScrollView));
  await tester.sendEventToBinding(pointer.scroll(Offset(0, dy)));
  await tester.pump();
}
