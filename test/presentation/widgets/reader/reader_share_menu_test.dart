import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/core/localization/l10n/app_localizations.dart';
import 'package:the_wisdom_project/data/datasources/suttacentral_concordance_datasource.dart';
import 'package:the_wisdom_project/presentation/providers/parallel_text_provider.dart';
import 'package:the_wisdom_project/presentation/providers/suttacentral_provider.dart';
import 'package:the_wisdom_project/presentation/providers/tab_provider.dart';
import 'package:the_wisdom_project/presentation/widgets/reader/reader_action_buttons.dart';
import 'package:wisdom_shared/wisdom_shared.dart';

import '../../../helpers/pump_app.dart';

void main() {
  /// Pumps the toolbar on [nodeKey] and opens its Share menu. [resolver]
  /// defaults to a concordance of one sutta.
  Future<void> openShareMenu(
    WidgetTester tester,
    String nodeKey, {
    SuttaCentralRefResolver resolver = const SuttaCentralRefResolver(
      {'dn1': 'dn-1-1'},
      nodeToSc: {'dn-1-1': 'dn1'},
    ),
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...defaultTestOverrides(),
          activeNodeKeyProvider.overrideWithValue(nodeKey),
          // No parallel-text tree: keeps the toolbar from loading one.
          parallelTextNodeProvider.overrideWithValue(null),
          suttaCentralRefResolverProvider.overrideWith((ref) => resolver),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: ReaderActionToolbar(onSearchTap: () {})),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Share'));
    await tester.pumpAndSettle();
  }

  group('Reader Share menu', () {
    testWidgets('offers "Open on SuttaCentral" on a sutta with a counterpart',
        (tester) async {
      await openShareMenu(tester, 'dn-1-1');

      expect(find.text('Open on SuttaCentral'), findsOneWidget);
    });

    testWidgets('hides "Open on SuttaCentral" on a commentary', (tester) async {
      await openShareMenu(tester, 'atta-dn-1-1');

      expect(find.text('Copy link'), findsOneWidget);
      expect(find.text('Open on SuttaCentral'), findsNothing);
    });

    // A rebuilt concordance may bring a translator the app has no name for.
    testWidgets('names no one for a translator without a name', (tester) async {
      await openShareMenu(
        tester,
        'dn-1-1',
        resolver: const SuttaCentralRefResolver(
          {'dn1': 'dn-1-1'},
          nodeToSc: {'dn-1-1': 'dn1'},
          translators: {'dn1': 'thanissaro'},
        ),
      );

      expect(find.text('Open on SuttaCentral'), findsOneWidget);
      expect(find.textContaining('Ven.'), findsNothing);
      expect(find.textContaining('thanissaro'), findsNothing);
    });
  });

  // The bundled concordance, so each node really opens what it claims.
  // Loaded outside the widget tests' fake clock, where the large asset's
  // off-thread decode would never finish.
  group('Open on SuttaCentral translator line', () {
    late SuttaCentralRefResolver concordance;

    setUpAll(() async {
      concordance = await SuttaCentralConcordanceDataSourceImpl().load();
    });

    for (final (nodeKey, translator) in [
      ('dn-1-1', 'Ven. Bodhi'),
      ('an-1-1', 'Ven. Sujato'),
      ('vp-prj-1', 'Ven. Brahmali'), // the Vinaya
    ]) {
      testWidgets('$nodeKey shows $translator', (tester) async {
        await openShareMenu(tester, nodeKey, resolver: concordance);

        expect(find.text('Open on SuttaCentral'), findsOneWidget);
        expect(find.text(translator), findsOneWidget);
      });
    }

    // These open SuttaCentral's division page, which is no one's translation.
    for (final nodeKey in [
      'dn-1', // Sīlakkhandhavagga
      'vp-prj-3', // the Vinaya's Saṅghādisesa chapter
    ]) {
      testWidgets('$nodeKey shows no translator', (tester) async {
        await openShareMenu(tester, nodeKey, resolver: concordance);

        expect(find.text('Open on SuttaCentral'), findsOneWidget);
        expect(find.textContaining('Ven.'), findsNothing);
      });
    }

    testWidgets('a screen reader hears the translator with the label',
        (tester) async {
      // Disposed inline: the framework checks for a live handle before
      // tear-downs run.
      final handle = tester.ensureSemantics();

      await openShareMenu(tester, 'dn-1-1', resolver: concordance);

      expect(
        find.bySemanticsLabel(RegExp(r'Open on SuttaCentral\s+Ven\. Bodhi')),
        findsOneWidget,
      );

      handle.dispose();
    });
  });
}
