import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/domain/entities/search/recent_search.dart';
import 'package:the_wisdom_project/presentation/providers/search_provider.dart';
import 'package:the_wisdom_project/presentation/providers/search_state.dart';
import 'package:the_wisdom_project/presentation/widgets/search/recent_search_overlay.dart';

import '../../../helpers/fake_search_state_notifier.dart';
import '../../../helpers/pump_app.dart';

void main() {
  // Newest first, as stored. Six: one more than the list shows collapsed.
  const queries = ['සති', 'මෙත්තා', 'ධම්ම', 'සීල', 'පඤ්ඤා', 'සමාධි'];

  final rows = find.byType(ListTile);

  /// Pumps the overlay with [stored] as the recent searches.
  Future<void> pumpOverlay(WidgetTester tester, List<String> stored) async {
    final state = SearchState(recentSearches: [
      for (final query in stored)
        RecentSearch(queryText: query, timestamp: DateTime(2026, 11, 3)),
    ]);
    await tester.pumpApp(
      RecentSearchOverlay(onDismiss: () {}),
      overrides: [
        searchStateProvider
            .overrideWith((ref) => FakeSearchStateNotifier(state)),
      ],
    );
  }

  /// Taps a link that may sit below the card's scroll edge.
  Future<void> tapLink(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pump();
  }

  group('RecentSearchOverlay', () {
    testWidgets('"Show more" opens the older searches, "Show less" folds them',
        (tester) async {
      await pumpOverlay(tester, queries);
      expect(rows, findsNWidgets(5));
      expect(find.text('සමාධි'), findsNothing);

      await tapLink(tester, 'Show more');
      expect(rows, findsNWidgets(6));
      expect(find.text('සමාධි'), findsOneWidget);

      await tapLink(tester, 'Show less');
      expect(rows, findsNWidgets(5));
      expect(find.text('සමාධි'), findsNothing);
    });

    testWidgets('five or fewer: no "Show more", "Clear all" still shown',
        (tester) async {
      await pumpOverlay(tester, queries.take(5).toList());

      expect(rows, findsNWidgets(5));
      expect(find.text('Show more'), findsNothing);
      expect(find.text('Clear all'), findsOneWidget);
    });
  });
}
