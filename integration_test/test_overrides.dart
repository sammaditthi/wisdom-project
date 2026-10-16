/// Shared Riverpod overrides and pump helpers for integration tests.
///
/// The reader-side providers (tabs, active tab index, navigator visibility)
/// hydrate from [KeyValueStore] on construction and throw if no override is
/// provided — main.dart wires the production SharedPreferences-backed
/// implementation. Tests need a quick stand-in so they don't have to spin up
/// SharedPreferences just to satisfy a hydration call.
///
/// [InMemoryKeyValueStore] stores everything in a single map. Each test that
/// uses [keyValueStoreOverride] gets a fresh instance, so state never leaks
/// between tests.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/core/localization/l10n/app_localizations.dart';
import 'package:the_wisdom_project/core/storage/key_value_store.dart';
import 'package:the_wisdom_project/core/storage/key_value_store_provider.dart';
import 'package:the_wisdom_project/data/datasources/bjt_document_local_datasource.dart';
import 'package:the_wisdom_project/presentation/models/reader_tab.dart';
import 'package:the_wisdom_project/presentation/providers/document_provider.dart';
import 'package:the_wisdom_project/presentation/providers/navigation_tree_provider.dart';
import 'package:the_wisdom_project/presentation/providers/tab_provider.dart';
import 'package:the_wisdom_project/presentation/widgets/navigation/tab_bar_widget.dart';
import 'package:the_wisdom_project/presentation/widgets/reader/multi_pane_reader_widget.dart';

class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, Object> _values = {};

  @override
  String? getString(String key) => _values[key] as String?;

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }

  @override
  int? getInt(String key) => _values[key] as int?;

  @override
  Future<void> setInt(String key, int value) async {
    _values[key] = value;
  }

  @override
  bool? getBool(String key) => _values[key] as bool?;

  @override
  Future<void> setBool(String key, bool value) async {
    _values[key] = value;
  }

  @override
  Map<String, dynamic>? getJsonObject(String key) {
    final raw = _values[key] as String?;
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      // Wrong shape — drop it so we mirror production's self-heal behaviour
      // and don't keep failing on the same garbage.
      _values.remove(key);
      return null;
    } on FormatException {
      _values.remove(key);
      return null;
    }
  }

  @override
  List<dynamic>? getJsonList(String key) {
    final raw = _values[key] as String?;
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded;
      _values.remove(key);
      return null;
    } on FormatException {
      _values.remove(key);
      return null;
    }
  }

  @override
  Future<void> setJson(String key, Object value) async {
    _values[key] = jsonEncode(value);
  }

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }
}

/// Returns a fresh [keyValueStoreProvider] override backed by an in-memory
/// store. Add this to the `overrides` list of any [ProviderScope] that builds
/// widgets transitively touching tabs / navigator visibility.
Override keyValueStoreOverride() => keyValueStoreProvider.overrideWithValue(
      InMemoryKeyValueStore(),
    );

/// How long [pumpForSettle] waits before giving up. Comfortably longer than the
/// ~10-second database-lock window we observe in the combined suite — so a
/// transient lock still lets the test finish and PASS — but far shorter than
/// pumpAndSettle's 10-minute default that otherwise hangs the whole run.
const _settleTimeout = Duration(seconds: 15);

/// A bounded, non-throwing stand-in for [WidgetTester.pumpAndSettle].
///
/// `pumpAndSettle` pumps frames until the framework stops scheduling them, but
/// THROWS if frames are still scheduled after its timeout (10 minutes by
/// default). In this integration suite, when the shared SQLite database is
/// under contention, a perpetual [CircularProgressIndicator] (the dictionary
/// sheet's loading state) or the reader's self-rescheduling page-load loop can
/// keep scheduling frames indefinitely — so the real `pumpAndSettle` hangs for
/// the full 10 minutes and then fails the run with a confusing
/// "pumpAndSettle timed out".
///
/// This wrapper behaves IDENTICALLY to `pumpAndSettle` when the tree settles
/// normally: it forwards [step] unchanged, so debounce timers (e.g. the
/// dictionary edit's 300 ms debounce, crossed by a 1-second step) still fire.
/// It only differs in the stuck case — it caps the wait at [_settleTimeout]
/// and SWALLOWS the timeout instead of throwing. Tests assert on
/// provider/widget state immediately afterwards, so a genuine stall surfaces
/// as a fast, readable assertion failure rather than a 10-minute hang.
///
/// Pass [step] exactly as you would the first positional argument to
/// `pumpAndSettle` (defaults to 100 ms, matching `pumpAndSettle`'s default).
Future<void> pumpForSettle(
  WidgetTester tester, [
  Duration step = const Duration(milliseconds: 100),
]) async {
  try {
    await tester.pumpAndSettle(
      step,
      EnginePhase.sendSemanticsUpdate,
      _settleTimeout,
    );
  } on FlutterError catch (error) {
    // Only swallow the settle timeout. Real build/layout errors are also
    // FlutterErrors, so rethrow anything that isn't the timeout — otherwise we
    // would hide genuine failures.
    if (!error.message.contains('pumpAndSettle timed out')) rethrow;
  }
}

/// Types [text] into the field found by [finder]. Use this instead of
/// [WidgetTester.enterText], which delivers the text over the platform
/// text-input channel — the harness mocks that channel, and on web the mock
/// never arrives, so the field stays empty and the test fails for no visible
/// reason. Calling the field's own [EditableTextState.updateEditingValue] is
/// the method that channel would have reached, so formatters, the controller
/// and `onChanged` all run exactly as they do today on macOS.
Future<void> typeText(WidgetTester tester, Finder finder, String text) {
  // Guarded like enterText, so a caller that forgets an await is reported as
  // that and not as an unrelated failure further down the test.
  return TestAsyncUtils.guard<void>(() async {
    // Focus first, the same as enterText. showKeyboard resolves [finder] to the
    // field's state and parks it on the binding, so take it from there rather
    // than looking the same widget up a second time under different rules.
    await tester.showKeyboard(finder);
    tester.binding.focusedEditable!.updateEditingValue(
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      ),
    );
    await tester.pump(); // let the onChanged rebuild land
  });
}

/// Pumps the tab bar over the reader, with the real data sources, and waits
/// for the navigation tree to load.
Future<ProviderContainer> pumpReaderApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        bjtDocumentDataSourceProvider.overrideWithValue(
          BJTDocumentLocalDataSourceImpl(),
        ),
        keyValueStoreOverride(),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Column(
            children: [
              TabBarWidget(),
              Expanded(child: MultiPaneReaderWidget()),
            ],
          ),
        ),
      ),
    ),
  );

  final container = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  );
  await container.read(navigationTreeProvider.future);
  await pumpForSettle(tester);
  return container;
}

/// A tab reading the unit rooted at [nodeKey].
///
/// A tab **is** the node: where the unit starts, where it ends and which file
/// it lives in are all resolved from the key, so this passes on the names and
/// nothing else. Shared because six integration files kept their own identical
/// copy, and every one of them had to be edited whenever
/// [ReaderTab.fromNode]'s signature moved.
ReaderTab tabFromNode(ProviderContainer container, String nodeKey) {
  final node = container.read(nodeByKeyProvider(nodeKey));
  if (node == null) throw StateError('Node "$nodeKey" not found in tree');
  return ReaderTab.fromNode(
    nodeKey: node.nodeKey,
    paliName: node.paliName,
    sinhalaName: node.sinhalaName,
  );
}

/// Adds [tab], makes it the active one and waits for its text to load.
Future<void> openTab(
  WidgetTester tester,
  ProviderContainer container,
  ReaderTab tab,
) async {
  container.read(tabsProvider.notifier).addTab(tab);
  container.read(activeTabIndexProvider.notifier).state =
      container.read(tabsProvider).length - 1;
  await pumpForSettle(tester);
}

/// The reader's scroll view: the one vertical [CustomScrollView] on screen
/// (the tab bar's list is horizontal).
final readerScrollView = find.byWidgetPredicate(
  (w) => w is CustomScrollView && w.scrollDirection == Axis.vertical,
);

/// The reader's scroll controller. Fails, saying so, when the reader is not
/// showing text — reading a controller off an empty finder throws an opaque
/// StateError instead.
ScrollController readerScrollController(WidgetTester tester) {
  expect(readerScrollView, findsOneWidget,
      reason: 'The reader must be showing text to have a scroll view');
  return tester.widget<CustomScrollView>(readerScrollView).controller!;
}

/// The reader row `(page, entry)`, found by its registry key, whose label is
/// `entry_<page>_<entry>`. Matches a built row even off screen, in the list's
/// cache area; nothing while it isn't built.
Finder readerRow(int page, int entry) => find.byWidgetPredicate(
      (w) => w is KeyedSubtree && '${w.key}'.endsWith(' entry_${page}_$entry]'),
      skipOffstage: false,
    );

/// Whether the reader row `(page, entry)` is built with its top edge inside
/// the reader's viewport.
bool isEntryOnScreen(WidgetTester tester, int page, int entry) {
  final viewport = tester.getRect(readerScrollView);
  for (final element in readerRow(page, entry).evaluate()) {
    final box = element.renderObject;
    if (box is! RenderBox || !box.attached || !box.hasSize) return false;
    final top = box.localToGlobal(Offset.zero).dy;
    return top >= viewport.top - 1 && top < viewport.bottom;
  }
  return false;
}
