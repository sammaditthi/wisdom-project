/// Settings → Anumodanā: the app's attribution surface.
///
/// This page is where the text and dictionary licences are satisfied
/// (`docs/general/things-to-consider-before-going-live.md`, blocker 1), so the
/// load-bearing test is that every bundled dictionary reaches it: the page
/// hardcodes a Sinhala group and an English group, and a dictionary added with
/// any third `targetLanguage` would be credited nowhere.
///
/// The prose is asserted through [AppLocalizations], not as literals — the
/// copy on this page is still under review (plan Decisions 5 and 7), and what
/// has to hold is that the right key lands on the right row. The two
/// exceptions are spelled out where they appear: a licence that mandates its
/// own citation form, and the font names that must be the bundled faces.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/core/localization/l10n/app_localizations.dart';
import 'package:the_wisdom_project/core/theme/app_theme.dart';
import 'package:the_wisdom_project/domain/entities/dictionary/dictionary_info.dart';
import 'package:the_wisdom_project/presentation/widgets/settings/anumodana_page.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_view.dart';

void main() {
  /// Pumps the page in a window tall enough to build every section, so an
  /// empty finder means "absent" and not "below the fold".
  Future<AppLocalizations> pumpPage(
    WidgetTester tester, {
    Size window = const Size(760, 2800),
  }) async {
    tester.useWindow(window);
    await tester.pumpApp(
      const AnumodanaPage(),
      // The real theme: the tiles and links take their colours from it.
      theme: AppTheme.light(),
    );
    await tester.pumpAndSettle();
    return AppLocalizations.of(tester.element(find.byType(AnumodanaPage)));
  }

  group('AnumodanaPage sections', () {
    testWidgets('four headings, in order', (tester) async {
      final l10n = await pumpPage(tester);

      for (final heading in [
        l10n.anumodanaTextSources,
        l10n.anumodanaDictionaries,
        l10n.anumodanaContributors,
        l10n.anumodanaLicences,
      ]) {
        expect(find.text(heading), findsOneWidget);
      }

      // The Bhāṇaka lineage is written but commented out, waiting on its
      // wording. It returns as the FIRST section, so Text sources is first
      // only until then.
      expect(find.text(l10n.anumodanaLineage), findsNothing);

      double y(String label) => tester.getTopLeft(find.text(label)).dy;
      expect(y(l10n.anumodanaTextSources),
          lessThan(y(l10n.anumodanaDictionaries)));
      expect(y(l10n.anumodanaDictionaries),
          lessThan(y(l10n.anumodanaContributors)));
      expect(
          y(l10n.anumodanaContributors), lessThan(y(l10n.anumodanaLicences)));
    });

    testWidgets('each text source names itself, its use and its way out',
        (tester) async {
      final l10n = await pumpPage(tester);

      // Proper names are never translated, so these two are literals.
      expect(find.text('tipitaka.lk'), findsOneWidget);
      expect(find.text(l10n.anumodanaTipitakaLkUse), findsOneWidget);
      expect(find.byTooltip(l10n.openLinkTo('tipitaka.lk')), findsOneWidget);

      expect(find.text('SuttaCentral'), findsOneWidget);
      expect(find.text(l10n.anumodanaSuttaCentralUse), findsOneWidget);
      expect(find.byTooltip(l10n.openLinkTo('SuttaCentral')), findsOneWidget);
    });

    testWidgets('the sources carry their own logos, drawn as decoration',
        (tester) async {
      await pumpPage(tester);

      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      expect(
        images.map((i) => (i.image as AssetImage).assetName).toList(),
        containsAll(const [
          'assets/icons/sources/tipitaka_lk.webp',
          'assets/icons/sources/suttacentral.webp',
        ]),
      );
      // The row already names the source, so the logo says nothing twice.
      for (final image in images) {
        expect(image.excludeFromSemantics, isTrue);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('Those who contributed is a statement, not a labelled setting',
        (tester) async {
      final l10n = await pumpPage(tester);
      expect(find.text(l10n.anumodanaContributorsBody), findsOneWidget);
    });

    testWidgets('the bundled faces and the open-source list are reachable',
        (tester) async {
      final l10n = await pumpPage(tester);

      // Named, not localized: these are the four faces pubspec declares, and
      // assets/fonts/OFL.txt is registered for them in main.dart.
      expect(
        find.text('Noto Sans, Noto Serif, Noto Sans Sinhala, '
            'Noto Serif Sinhala'),
        findsOneWidget,
      );
      expect(find.text('SIL Open Font License 1.1'), findsOneWidget);
      expect(find.text(l10n.openSourceLicences), findsOneWidget);
    });

    testWidgets('Open-source licences opens the licence page', (tester) async {
      final l10n = await pumpPage(tester);

      await tester.tap(find.text(l10n.openSourceLicences));
      // Not pumpAndSettle: LicensePage keeps a spinner up while it reads the
      // registry, which never settles in a test.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(LicensePage), findsOneWidget);
    });
  });

  group('AnumodanaPage dictionaries', () {
    /// One of the page's two groups, in the order it shows them.
    List<DictionaryInfo> group(String targetLanguage) => [
          for (final d in DictionaryInfo.all.values)
            if (d.targetLanguage == targetLanguage) d,
        ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    testWidgets('every DictionaryInfo.all entry is credited', (tester) async {
      final l10n = await pumpPage(tester);

      expect(find.text(l10n.anumodanaDictGroupSinhala), findsOneWidget);
      expect(find.text(l10n.anumodanaDictGroupEnglish), findsOneWidget);

      // The two groups must account for the whole map: a dictionary with a
      // third targetLanguage would be in neither, and credited nowhere.
      expect(
        group('si').length + group('en').length,
        DictionaryInfo.all.length,
        reason: 'a dictionary targets a language the page does not group',
      );

      for (final d in DictionaryInfo.all.values) {
        expect(find.text(d.name), findsOneWidget, reason: '${d.id} name');
        expect(find.text(d.abbreviation), findsOneWidget,
            reason: '${d.id} tile');
      }
    });

    testWidgets('each group is alphabetical, as its hint promises',
        (tester) async {
      final l10n = await pumpPage(tester);
      expect(find.text(l10n.anumodanaDictionariesHint), findsOneWidget);

      for (final targetLanguage in const ['si', 'en']) {
        final tops = [
          for (final d in group(targetLanguage))
            tester.getTopLeft(find.text(d.name)).dy,
        ];
        expect(tops, orderedEquals([...tops]..sort()),
            reason: '$targetLanguage is out of alphabetical order on screen');
      }
    });

    testWidgets('DPD alone carries its citation and its link', (tester) async {
      final l10n = await pumpPage(tester);
      final dpd = DictionaryInfo.all['DPD']!;

      // Its licence asks to be cited where it is used, in this exact form, so
      // the literal is the point. The version in it is recorded nowhere else
      // in the repo — re-check it when the dictionary refreshes
      // (`docs/todo/dictionary/dpd-provenance-and-refresh.md`).
      expect(
        l10n.anumodanaDpdLicence,
        'Bodhirasa Bhikkhu, Digital Pāḷi Dictionary v0.2.20250709. '
        'CC BY-NC-SA 4.0.',
      );
      expect(find.text(l10n.anumodanaDpdLicence), findsOneWidget);
      expect(find.byTooltip(l10n.openLinkTo(dpd.name)), findsOneWidget);

      // Three links in all: the two sources and DPD. No other dictionary has
      // one, so the open-link buttons are exactly those.
      expect(find.byIcon(Icons.open_in_new), findsNWidgets(3));
    });
  });

  testWidgets('nothing overflows at a phone width', (tester) async {
    await pumpPage(tester, window: const Size(390, 2800));
    expect(tester.takeException(), isNull);
  });
}
