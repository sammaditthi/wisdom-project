import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/core/localization/l10n/app_localizations.dart';
import 'package:the_wisdom_project/presentation/providers/parallel_text_provider.dart';
import 'package:the_wisdom_project/presentation/providers/suttacentral_provider.dart';
import 'package:the_wisdom_project/presentation/providers/tab_provider.dart';
import 'package:the_wisdom_project/presentation/widgets/reader/reader_action_buttons.dart';
import 'package:wisdom_shared/wisdom_shared.dart';

import '../../../helpers/pump_app.dart';

void main() {
  /// Pumps the toolbar on [nodeKey] and opens its Share menu.
  Future<void> openShareMenu(WidgetTester tester, String nodeKey) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...defaultTestOverrides(),
          activeNodeKeyProvider.overrideWithValue(nodeKey),
          // No parallel-text tree: keeps the toolbar from loading one.
          parallelTextNodeProvider.overrideWithValue(null),
          suttaCentralRefResolverProvider.overrideWith(
            (ref) => const SuttaCentralRefResolver(
              {'dn1': 'dn-1-1'},
              nodeToSc: {'dn-1-1': 'dn1'},
            ),
          ),
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
  });
}
