import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/domain/entities/search/search_result.dart';
import 'package:the_wisdom_project/domain/entities/search/search_result_type.dart';
import 'package:the_wisdom_project/presentation/providers/search_provider.dart';
import 'package:the_wisdom_project/presentation/providers/search_state.dart';
import 'package:the_wisdom_project/presentation/widgets/search/dictionary_search_result_tile.dart';

import '../../../helpers/fake_search_state_notifier.dart';
import '../../../helpers/pump_app.dart';

void main() {
  // Test data - a dictionary search result
  const testResult = SearchResult(
    id: 'dict-1',
    editionId: 'DPD',
    resultType: SearchResultType.definition,
    title: 'buddha',
    subtitle: 'Digital Pali Dictionary',
    matchedText: '<b>awakened</b>, enlightened, one who has attained bodhi',
    contentFileId: '',
    pageIndex: 0,
    entryIndex: 0,
    nodeKey: '',
    language: 'en',
  );

  /// Pumps the tile with a fake search state, which holds its expanded flag.
  Future<FakeSearchStateNotifier> pumpTile(
    WidgetTester tester,
    SearchResult result,
  ) async {
    final notifier = FakeSearchStateNotifier(const SearchState());
    await tester.pumpApp(
      DictionarySearchResultTile(result: result),
      overrides: [searchStateProvider.overrideWith((ref) => notifier)],
    );
    return notifier;
  }

  group('DictionarySearchResultTile', () {
    testWidgets('renders word, dictionary name, and meaning', (tester) async {
      await pumpTile(tester, testResult);

      // Word (title)
      expect(find.text('buddha'), findsOneWidget);
      // Dictionary name (subtitle)
      expect(find.text('Digital Pali Dictionary'), findsOneWidget);
      // Meaning is shown without its HTML tags
      expect(find.textContaining('awakened'), findsOneWidget);
      expect(find.textContaining('enlightened'), findsOneWidget);
      // It fits in two lines, so there is nothing to expand
      expect(find.text('Show more'), findsNothing);
    });

    testWidgets('shows badge with correct abbreviation', (tester) async {
      await pumpTile(tester, testResult);

      // DPD abbreviation should be shown in badge
      expect(find.text('DPD'), findsOneWidget);

      // The badge container should have the dictionary color
      // (We verify by finding the container with the abbreviation)
      final badgeFinder = find.ancestor(
        of: find.text('DPD'),
        matching: find.byType(Container),
      );
      expect(badgeFinder, findsWidgets);
    });

    testWidgets('"Show more" shows a meaning cut at two lines in full',
        (tester) async {
      // Three lines of meaning, so two lines cut it short.
      final notifier = await pumpTile(
        tester,
        testResult.copyWith(matchedText: 'first<br>second<br>third'),
      );
      int? meaningMaxLines() =>
          tester.widget<Text>(find.textContaining('third')).maxLines;

      expect(meaningMaxLines(), 2);

      await tester.tap(find.text('Show more'));
      await tester.pump();

      expect(notifier.state.expandedDefinitions, {'dict-1'});
      expect(meaningMaxLines(), isNull);
      expect(find.text('Show less'), findsOneWidget);
    });

    testWidgets('a DPD entry links to dpdict.net, not "Read more"',
        (tester) async {
      await pumpTile(
        tester,
        testResult.copyWith(
          matchedText: 'awakened<br>'
              '<a href="https://www.dpdict.net/?q=buddha">Read more</a>',
        ),
      );

      expect(find.text('dpdict.net'), findsOneWidget);
      expect(find.textContaining('Read more'), findsNothing);
    });
  });
}
