import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/presentation/keyboard/keyboard_bindings.dart';
import 'package:the_wisdom_project/presentation/keyboard/shortcut_intents.dart';
import 'package:the_wisdom_project/presentation/providers/main_search_focus_provider.dart';
import 'package:the_wisdom_project/presentation/providers/search_mode_provider.dart';
import 'package:the_wisdom_project/presentation/providers/search_provider.dart';
import 'package:the_wisdom_project/presentation/providers/search_results_focus_provider.dart';
import 'package:the_wisdom_project/presentation/providers/search_state.dart';

import '../../helpers/fake_search_state_notifier.dart';
import 'shortcut_test_host.dart';

/// From the search box into the results and back, as the static site's
/// search dialog does (`docs/todo/reader/keyboard-shortcuts-sheet.md`).
void main() {
  final mac = TargetPlatformVariant.only(TargetPlatform.macOS);

  late FocusNode box;
  late List<FocusNode> stops;

  setUp(() {
    box = FocusNode(debugLabel: 'search box');
    stops = [for (var i = 0; i < 3; i++) FocusNode(debugLabel: 'stop $i')];
  });

  tearDown(() {
    box.dispose();
    for (final node in stops) {
      node.dispose();
    }
  });

  /// A search box and three results, shown as the reader screen shows the
  /// panel: only while it is visible, which it is unless [panelOpen] is
  /// false. [mountedWhileHidden] keeps the results, so a test can check the
  /// keys' own visibility check. Focus starts in the box.
  Future<ProviderContainer> pumpSearch(
    WidgetTester tester, {
    bool panelOpen = true,
    bool mountedWhileHidden = false,
  }) async {
    final c = await pumpShortcutHost(
      tester,
      overrides: [
        searchStateProvider.overrideWith(
          (ref) => FakeSearchStateNotifier(
            SearchState(rawQueryText: panelOpen ? 'බුද්ධ' : ''),
          ),
        ),
      ],
      home: Scaffold(
        body: Column(
          children: [
            TextField(focusNode: box),
            Consumer(
              builder: (context, ref, _) {
                final visible = ref.watch(
                  searchStateProvider.select((s) => s.isResultsPanelVisible),
                );
                if (!visible && !mountedWhileHidden) {
                  return const SizedBox.shrink();
                }
                return Focus(
                  focusNode: ref.watch(searchPanelFocusNodeProvider),
                  child: Focus(
                    focusNode: ref.watch(searchResultsFocusNodeProvider),
                    child: Column(
                      children: [
                        for (final (i, node) in stops.indexed)
                          TextButton(
                            focusNode: node,
                            onPressed: () {},
                            child: Text('result $i'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
    c.read(mainSearchFocusNodeProvider.notifier).state = box;
    box.requestFocus();
    await tester.pump();
    return c;
  }

  testWidgets('↓ and Tab go from the box to the first stop', (tester) async {
    await pumpSearch(tester);

    await pressKeys(tester, LogicalKeyboardKey.arrowDown);
    expect(stops[0].hasPrimaryFocus, isTrue);

    box.requestFocus();
    await tester.pump();
    await pressKeys(tester, LogicalKeyboardKey.tab);
    expect(stops[0].hasPrimaryFocus, isTrue);
  }, variant: mac);

  testWidgets('↓ ↑ step through the stops; ↑ from the first returns to the box',
      (tester) async {
    await pumpSearch(tester);

    await pressKeys(tester, LogicalKeyboardKey.arrowDown);
    await pressKeys(tester, LogicalKeyboardKey.arrowDown);
    expect(stops[1].hasPrimaryFocus, isTrue);
    await pressKeys(tester, LogicalKeyboardKey.arrowUp);
    expect(stops[0].hasPrimaryFocus, isTrue);
    await pressKeys(tester, LogicalKeyboardKey.arrowUp);
    expect(box.hasPrimaryFocus, isTrue);
  }, variant: mac);

  testWidgets('Shift+Tab from the first stop returns to the box',
      (tester) async {
    await pumpSearch(tester);

    await pressKeys(tester, LogicalKeyboardKey.arrowDown);
    await pressKeys(tester, LogicalKeyboardKey.tab, shift: true);
    expect(box.hasPrimaryFocus, isTrue);
  }, variant: mac);

  testWidgets('↓ on the last stop stays there', (tester) async {
    await pumpSearch(tester);
    stops[2].requestFocus();
    await tester.pump();

    await pressKeys(tester, LogicalKeyboardKey.arrowDown);
    expect(stops[2].hasPrimaryFocus, isTrue);
  }, variant: mac);

  // Esc and opening a result both close search this way. Flutter used to
  // hand focus from the closing result back to the box, and the box
  // reopened the panel, so it took a second Esc.
  testWidgets('closing search from a result leaves the box unfocused',
      (tester) async {
    final c = await pumpSearch(tester);
    await pressKeys(tester, LogicalKeyboardKey.arrowDown);
    expect(stops[0].hasPrimaryFocus, isTrue);

    c.read(closeSearchProvider)();
    await tester.pump();

    expect(find.text('result 0'), findsNothing);
    expect(box.hasFocus, isFalse);
  }, variant: mac);

  testWidgets('panel hidden: ↓ leaves focus in the box', (tester) async {
    await pumpSearch(tester, panelOpen: false, mountedWhileHidden: true);

    await pressKeys(tester, LogicalKeyboardKey.arrowDown);
    expect(box.hasPrimaryFocus, isTrue);
  }, variant: mac);

  testWidgets('↑ to a result already in view does not scroll the list',
      (tester) async {
    final list = ScrollController();
    addTearDown(list.dispose);
    final many = [
      for (var i = 0; i < 30; i++) FocusNode(debugLabel: 'row $i'),
    ];
    addTearDown(() {
      for (final node in many) {
        node.dispose();
      }
    });
    await pumpShortcutHost(
      tester,
      home: Scaffold(
        body: SizedBox(
          height: 300,
          child: Consumer(
            builder: (context, ref, _) => Focus(
              focusNode: ref.watch(searchResultsFocusNodeProvider),
              child: ListView(
                controller: list,
                children: [
                  for (final (i, node) in many.indexed)
                    SizedBox(
                      height: 48,
                      child: TextButton(
                        focusNode: node,
                        onPressed: () {},
                        child: Text('row $i'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    list.jumpTo(400); // rows 8–14 in view
    await tester.pump();
    many[12].requestFocus();
    await tester.pump();

    await pressKeys(tester, LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(many[11].hasPrimaryFocus, isTrue);
    expect(list.offset, 400);
  }, variant: mac);

  test('↓ tries results first, then scrolling', () {
    final down = shortcutMap(TargetPlatform.macOS)
        .entries
        .singleWhere((e) {
          final activator = e.key as SingleActivator;
          return activator.trigger == LogicalKeyboardKey.arrowDown &&
              !activator.meta;
        })
        .value as PrioritizedIntents;
    expect(
      down.orderedIntents.map((i) => i.runtimeType),
      [MoveIntoSearchResultsIntent, NextSearchResultIntent, ScrollReaderIntent],
    );
  });
}
