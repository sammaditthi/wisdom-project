import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/domain/entities/search/search_result.dart';
import 'package:the_wisdom_project/domain/entities/search/search_result_type.dart';
import 'package:the_wisdom_project/presentation/keyboard/keyboard_bindings.dart';
import 'package:the_wisdom_project/presentation/keyboard/shortcut_intents.dart';
import 'package:the_wisdom_project/presentation/providers/main_search_focus_provider.dart';
import 'package:the_wisdom_project/presentation/providers/search_mode_provider.dart';
import 'package:the_wisdom_project/presentation/providers/search_provider.dart';
import 'package:the_wisdom_project/presentation/providers/search_results_focus_provider.dart';
import 'package:the_wisdom_project/presentation/providers/search_state.dart';
import 'package:the_wisdom_project/presentation/widgets/search/match_options_menu.dart';
import 'package:the_wisdom_project/presentation/widgets/search/scope_filter_chips.dart';
import 'package:the_wisdom_project/presentation/widgets/search/search_results_panel.dart';

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

  testWidgets('↓ goes from the box to the first stop', (tester) async {
    await pumpSearch(tester);

    await pressKeys(tester, LogicalKeyboardKey.arrowDown);
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

  // ── Tab in the real panel ──────────────────────────────────────────────

  /// The search box over the real results panel, so its header is there:
  /// match options, chips and the results tabs. The Titles tab holds 20 rows,
  /// more than fit. Focus starts in the box.
  Future<ProviderContainer> pumpRealPanel(WidgetTester tester) async {
    final c = await pumpShortcutHost(
      tester,
      overrides: [
        searchStateProvider.overrideWith(
          (ref) => FakeSearchStateNotifier(
            SearchState(
              rawQueryText: 'මෙත්ත',
              effectiveQueryText: 'මෙත්ත',
              selectedResultType: SearchResultType.title,
              fullResults: AsyncValue.data([
                for (var i = 1; i <= 20; i++)
                  SearchResult(
                    id: 'title_sn-1-$i',
                    editionId: 'bjt',
                    resultType: SearchResultType.title,
                    title: 'මෙත්තසුත්තං',
                    subtitle: 'සංයුත්තනිකායො',
                    matchedText: '',
                    contentFileId: 'sn-1-$i',
                    pageIndex: 0,
                    entryIndex: 0,
                    nodeKey: 'sn-1-$i',
                    language: 'pali',
                  ),
              ]),
            ),
          ),
        ),
      ],
      home: Scaffold(
        body: Column(
          children: [
            Row(
              children: [
                Expanded(child: TextField(focusNode: box)),
                // Stands in for the app bar and reader behind the panel:
                // Flutter's own Tab from the box would go here.
                TextButton(onPressed: () {}, child: const Text('reader')),
              ],
            ),
            const Expanded(child: SearchResultsPanel()),
          ],
        ),
      ),
    );
    c.read(mainSearchFocusNodeProvider.notifier).state = box;
    box.requestFocus();
    await tester.pump();
    return c;
  }

  /// What the focused stop is in the panel, by the widget it sits in.
  String focusedStop(ProviderContainer c) {
    final node = FocusManager.instance.primaryFocus!;
    final context = node.context!;
    if (node == box) return 'box';
    // Checked before the chips: the button sits inside their row.
    if (context.findAncestorWidgetOfExactType<MatchOptionsButton>() != null) {
      return 'match options';
    }
    if (context.findAncestorWidgetOfExactType<ScopeFilterChips>() != null) {
      return 'chip';
    }
    if (context.findAncestorWidgetOfExactType<TabBar>() != null) return 'tab';
    if (node.ancestors.contains(c.read(searchResultsFocusNodeProvider))) {
      return 'result';
    }
    return 'elsewhere (${node.debugLabel})';
  }

  /// Presses Tab until a result has focus; returns each stop on the way.
  Future<List<String>> tabToResult(
    WidgetTester tester,
    ProviderContainer c,
  ) async {
    final visited = <String>[];
    while (!visited.contains('result') && visited.length < 30) {
      await pressKeys(tester, LogicalKeyboardKey.tab);
      visited.add(focusedStop(c));
    }
    return visited;
  }

  testWidgets('Tab goes from the box to match options; Shift+Tab comes back',
      (tester) async {
    final c = await pumpRealPanel(tester);

    await pressKeys(tester, LogicalKeyboardKey.tab);
    expect(focusedStop(c), 'match options');

    await pressKeys(tester, LogicalKeyboardKey.tab, shift: true);
    expect(focusedStop(c), 'box');
  }, variant: mac);

  // Shift+Tab used to step back as ↑ does, and ↑ from the first result goes
  // to the box.
  testWidgets('Shift+Tab from the first result goes back to the tabs',
      (tester) async {
    final c = await pumpRealPanel(tester);
    await tabToResult(tester, c);
    expect(focusedStop(c), 'result');

    await pressKeys(tester, LogicalKeyboardKey.tab, shift: true);
    expect(focusedStop(c), 'tab');
  }, variant: mac);

  // Rows scrolled up out of view still sit above the header on screen, so
  // they could sort in among the chips; and Flutter's own Tab only scrolls
  // down, so it would land on a row above the view and leave it there.
  testWidgets('scrolled list: Tab walks the panel in order to a row in view',
      (tester) async {
    final c = await pumpRealPanel(tester);
    final list = find.descendant(
      of: find.byType(SearchResultsPanel),
      matching: find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      ),
    );
    final position = tester.state<ScrollableState>(list).position;
    position.jumpTo(300);
    await tester.pump();
    // Without the scroll there is no row above the view to get wrong.
    expect(position.pixels, 300);

    final visited = await tabToResult(tester, c);

    // Each run of one kind as one entry: the order the panel shows.
    final order = [
      for (final (i, stop) in visited.indexed)
        if (i == 0 || visited[i - 1] != stop) stop,
    ];
    expect(order, ['match options', 'chip', 'tab', 'result']);
    // Top results, Titles, Full text, Definitions.
    expect(visited.where((stop) => stop == 'tab'), hasLength(4));

    final row = FocusManager.instance.primaryFocus!.rect;
    final view = tester.getRect(list);
    expect(
      row.top >= view.top && row.bottom <= view.bottom,
      isTrue,
      reason: 'row $row is outside the list $view',
    );
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
