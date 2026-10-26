import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/core/storage/key_value_store_provider.dart';
import 'package:the_wisdom_project/presentation/widgets/search/highlighted_fts_search_text.dart';
import 'package:wisdom_shared/wisdom_shared.dart';

import '../../../helpers/fake_key_value_store.dart';

/// What a search result tile actually rendered.
typedef _Rendered = ({String text, List<String> highlights});

void main() {
  /// Pumps the widget and reads back the rendered snippet and its highlights.
  ///
  /// [rawEntryText] is corpus text as stored, markers and all. It goes through
  /// `stripMarkers` because that is what the tiles do, by reading
  /// `SearchResult.plainMatchedText` — the widget requires marker-free text.
  /// Both halves of that contract are pinned elsewhere: the getter in
  /// test/data/repositories/text_search_repository_impl_test.dart, the tiles'
  /// use of it in test/presentation/widgets/search_results_panel_test.dart.
  ///
  /// Defaults to `sinhala` because the `pali` branch runs the conjunct
  /// transformation, which rewrites characters and would make exact string
  /// expectations depend on the Pali-letter switches rather than on matching.
  Future<_Rendered> render(
    WidgetTester tester, {
    required String rawEntryText,
    required String query,
    String language = 'sinhala',
    bool isPhraseSearch = true,
    bool isExactMatch = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          keyValueStoreProvider.overrideWithValue(InMemoryKeyValueStore()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: HighlightedFtsSearchText(
              matchedText: ContentMarkers.stripMarkers(rawEntryText),
              effectiveQuery: query,
              isPhraseSearch: isPhraseSearch,
              isExactMatch: isExactMatch,
              language: language,
            ),
          ),
        ),
      ),
    );

    final richText = tester.widget<RichText>(
      find.descendant(
        of: find.byType(HighlightedFtsSearchText),
        matching: find.byType(RichText),
      ),
    );

    final highlights = <String>[];
    richText.text.visitChildren((span) {
      if (span is TextSpan && span.style?.backgroundColor != null) {
        highlights.add(span.text ?? '');
      }
      return true;
    });

    return (text: richText.text.toPlainText(), highlights: highlights);
  }

  // ===========================================================================
  // The class of bug: index and UI disagreeing about where a word ends
  // ===========================================================================

  // `cleanTextForIndexing` (tools/bjt-populate.js) removes these before fts5
  // tokenises, so a word they split is ONE token in the index. The UI has to
  // reach the same word or it cannot locate the hit the index just returned —
  // historically a RangeError, now a snippet with no highlight.
  //
  // Duplicated from the JavaScript deliberately: the indexer is not Dart, so
  // this list is the only place the two sides can be compared.
  //
  // This is the subset the indexer removes AND `stripMarkers` removes. The
  // four it removes that `stripMarkers` keeps are pinned separately at the
  // bottom of this file — they are the same bug, unreached only because no
  // corpus entry contains one.
  const word = 'ඡන්දරාගවෙමත්තතාති';
  const head = 'ඡන්දරාගවෙමත්තතා';
  const tail = 'ති';

  const joiners = <String, String>{
    'bold marker': '**',
    'underline marker': '__',
    'numeric footnote': '{12}',
    'lettered footnote': '{ab}',
    'empty footnote': '{}',
    'zero-width joiner': '‍',
  };

  group('a word the index joined is still found when', () {
    joiners.forEach((name, joiner) {
      testWidgets('a $name splits it', (tester) async {
        final rendered = await render(
          tester,
          rawEntryText: 'සියා පන භන්තෙ, පඤ්චසු උපාදානක්ඛන්ධෙසු '
              '$head$joiner$tail? ඉති.',
          query: word,
        );

        expect(tester.takeException(), isNull);
        expect(
          rendered.highlights.map(removeConjunctFormatting),
          [word],
          reason: '$name should not hide the word from the snippet',
        );
      });
    });
  });

  group('HighlightedFtsSearchText', () {
    // The reported crash: searching ඡන්දරාගවෙමත්තතාති blew up the commentary
    // tile with "RangeError (length): Not in inclusive range 0..914: -1".
    // Text is from atta-sn-3 page 47 entry 0, abridged.
    const commentary = 'පඤ්චක්ඛන්ධෙ මුඤ්චිත්වා උපාදානං නත්ථි. '
        '**ඡන්දරාගවෙමත්තතා**ති ඡන්දරාගනානත්තං. **එවං ඛො භික්ඛූ**ති එවං.';

    testWidgets('renders the reported commentary hit without throwing',
        (tester) async {
      final rendered = await render(
        tester,
        rawEntryText: commentary,
        query: 'ඡන්දරාගවෙමත්තතාති',
        language: 'pali',
      );

      expect(tester.takeException(), isNull);
      expect(rendered.highlights, hasLength(1));
    });

    testWidgets('never shows a formatting marker', (tester) async {
      final rendered = await render(
        tester,
        rawEntryText: commentary,
        query: 'ඡන්දරාගවෙමත්තතාති',
      );

      expect(rendered.text, isNot(contains('*')));
      expect(rendered.text, isNot(contains('{')));
    });

    testWidgets('centres the snippet on the match, not the start of the entry',
        (tester) async {
      final rendered = await render(
        tester,
        rawEntryText: '${'ආදි. ' * 60}**ඡන්දරාගවෙමත්තතා**ති අන්තො.',
        query: 'ඡන්දරාගවෙමත්තතාති',
      );

      expect(rendered.text, startsWith('...'));
      expect(rendered.highlights, ['ඡන්දරාගවෙමත්තතාති']);
    });

    testWidgets('leaves the text alone when the query is absent',
        (tester) async {
      final rendered = await render(
        tester,
        rawEntryText: 'එවං මෙ සුතං, එකං සමයං භගවා සාවත්ථියං විහරති.',
        query: 'නිබ්බාන',
      );

      expect(tester.takeException(), isNull);
      expect(rendered.highlights, isEmpty);
    });
  });

  // ===========================================================================
  // The open half, pinned so it cannot be fixed on one side only
  // ===========================================================================

  testWidgets(
    'TRIPWIRE: the elision mark still hides a word from the UI — '
    'see docs/todo/search/word-joining-characters-in-the-fts-index.md',
    (tester) async {
      // `තීණි’මානි` (an-3 page 39 entry 9). U+2019 is a joiner in Pali
      // orthography but a separator to both fts5 and the UI, so the record is
      // neither retrievable by `තීණිමානි` nor highlightable. Fixing the index
      // without also teaching `normalizeSearchText` about `’` leaves the hit
      // unlocatable, so this expectation is meant to fail at that moment.
      final rendered = await render(
        tester,
        rawEntryText: '47. තීණි’මානි භික්ඛවෙ සඞ්ඛතස්ස සඞ්ඛතලක්ඛණානි.',
        query: 'තීණිමානි',
      );

      expect(tester.takeException(), isNull,
          reason: 'an unlocatable hit must degrade, never throw');
      expect(rendered.highlights, isEmpty);
    },
  );

  // `cleanTextForIndexing` deletes these four as well, and `stripMarkers`
  // keeps them — so each is the `**` bug over again, waiting for a corpus
  // that contains one. None sits between two Sinhala letters anywhere in the
  // corpus today (measured 2026-10-26), which is the only reason the fix is
  // complete. The text is re-synced from upstream, so pin them: a sync that
  // introduces one turns these red instead of silently shipping a snippet
  // with no highlight.
  const indexerOnly = <String, String>{
    'a lone asterisk': '*',
    'a lone underscore': '_',
    'a tilde': '~',
    'a dollar sign': r'$',
  };

  group('TRIPWIRE: the indexer removes it but stripMarkers keeps it —', () {
    indexerOnly.forEach((name, joiner) {
      testWidgets('$name still hides the word', (tester) async {
        final rendered = await render(
          tester,
          rawEntryText: 'පඤ්චසු උපාදානක්ඛන්ධෙසු $head$joiner$tail ඉති.',
          query: word,
        );

        expect(tester.takeException(), isNull,
            reason: 'an unlocatable hit must degrade, never throw');
        expect(
          rendered.highlights,
          isEmpty,
          reason: 'if this now highlights, `$joiner` was taught to '
              'stripMarkers or normalizeSearchText — move its row up into '
              '`joiners` rather than deleting it',
        );
      });
    });
  });
}
