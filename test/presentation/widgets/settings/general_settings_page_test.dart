/// Settings → General, the page the reader menu's app-wide controls moved to
/// (`docs/todo/settings/app-settings-dialog.md`).
///
/// Three of these cases came from `reader_settings_menu_button_test.dart` with
/// the selectors they drive: the content selector's provider writes, its
/// clamped value, and the version in both app languages.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/core/localization/app_language.dart';
import 'package:the_wisdom_project/core/localization/l10n/app_localizations.dart';
import 'package:the_wisdom_project/core/storage/key_value_store_provider.dart';
import 'package:the_wisdom_project/core/storage/storage_keys.dart';
import 'package:the_wisdom_project/core/theme/app_theme.dart';
import 'package:the_wisdom_project/core/theme/theme_notifier.dart';
import 'package:the_wisdom_project/core/version/app_version.gen.dart';
import 'package:the_wisdom_project/domain/entities/content/content_language.dart';
import 'package:the_wisdom_project/domain/entities/content/edition.dart';
import 'package:the_wisdom_project/presentation/providers/app_language_provider.dart';
import 'package:the_wisdom_project/presentation/providers/content_language_provider.dart';
import 'package:the_wisdom_project/presentation/providers/pali_letter_options_provider.dart';
import 'package:the_wisdom_project/presentation/widgets/settings/general_settings_page.dart';
import 'package:wisdom_shared/wisdom_shared.dart'
    show PaliLetterOptions, beautifyPaliText;

import '../../../helpers/fake_key_value_store.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/test_view.dart';

/// The page's own sample line, duplicated rather than read off the widget —
/// the const is private and stays that way.
const _sample = 'තත්රාභිරතිමිච්ඡෙය්ය හිත්වා කාමෙ අකිඤ්චනො';

/// The three switches' shipped defaults (standard on, special off, touching
/// on), as `pali_letter_options_provider.dart` declares them.
const _defaultOptions = PaliLetterOptions(
  standardLigatures: true,
  specialConjuncts: false,
  touching: true,
);

void main() {
  /// Pumps the page tall enough that every section is built, so a finder that
  /// comes back empty means "absent", not "below the fold".
  Future<ProviderContainer> pumpPage(
    WidgetTester tester, {
    List<Override> overrides = const [],
    Locale locale = const Locale('en'),
    Size window = const Size(760, 1600),
  }) async {
    tester.useWindow(window);

    final container = createTestContainer(overrides: [
      // Pinned: the default resolves from the host's locales, which would make
      // the App Language selector's starting segment machine-dependent.
      deviceLocalesProvider.overrideWithValue(const [Locale('en')]),
      ...overrides,
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: locale,
          // The real theme, so the segmented buttons carry the app's shape and
          // the typography extensions are the shipped ones.
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: GeneralSettingsPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  /// A segment of [T]'s selector, by the label or icon inside it.
  Finder segment<T>(Finder inner) => find.descendant(
        of: find.byType(SegmentedButton<T>),
        matching: inner,
      );

  group('GeneralSettingsPage structure', () {
    testWidgets('four sections, each setting under its own heading',
        (tester) async {
      await pumpPage(tester);

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Pali letters'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('App language'), findsOneWidget);
      expect(find.text('Content language'), findsOneWidget);
      expect(find.text('Version'), findsOneWidget);

      // The hints that say what each axis actually changes — the reason the
      // two language rows are tellable apart.
      expect(find.text('Menus, buttons and messages.'), findsOneWidget);
      expect(
        find.text('Names of books and suttas in the navigator, tabs, '
            'breadcrumbs and search.'),
        findsOneWidget,
      );
      expect(find.text('How joined Pali letters are shown.'), findsOneWidget);

      // Font size and Hide navigation bar stayed in the reader's menu.
      expect(find.text('Font size'), findsNothing);
      expect(find.text('Hide navigation bar'), findsNothing);
    });

    testWidgets('nothing overflows at a phone width or a narrow dialog',
        (tester) async {
      for (final width in const [390.0, 760.0]) {
        await pumpPage(tester, window: Size(width, 1600));
        expect(tester.takeException(), isNull, reason: '$width px');
      }
    });
  });

  group('GeneralSettingsPage theme', () {
    testWidgets('Light and Dark are icons with their names as tooltips',
        (tester) async {
      final container = await pumpPage(tester);

      final selector = tester.widget<SegmentedButton<AppThemeMode>>(
        find.byType(SegmentedButton<AppThemeMode>),
      );
      expect(
        selector.segments.map((s) => s.value).toList(),
        equals(const [AppThemeMode.light, AppThemeMode.dark]),
      );
      // Icon-only: the name is the tooltip, which is what a screen reader
      // announces for the segment. So neither word is on screen as text.
      expect(find.text('Light'), findsNothing);
      expect(find.text('Dark'), findsNothing);
      expect(selector.segments.map((s) => s.tooltip).toList(),
          equals(const ['Light', 'Dark']));

      expect(
          selector.selected, equals({container.read(themeNotifierProvider)}));
      expect(selector.selected, equals({AppThemeMode.light}));
    });

    testWidgets('Dark is disabled and says so, and a tap cannot select it',
        (tester) async {
      final container = await pumpPage(tester);

      final selector = tester.widget<SegmentedButton<AppThemeMode>>(
        find.byType(SegmentedButton<AppThemeMode>),
      );
      expect(selector.segments.first.enabled, isTrue);
      expect(selector.segments.last.enabled, isFalse);
      // The row carries the reason, so the dead segment is not a mystery.
      expect(find.text('A dark theme is coming soon.'), findsOneWidget);

      await tester.tap(
        segment<AppThemeMode>(find.byIcon(Icons.dark_mode_outlined)),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(container.read(themeNotifierProvider), AppThemeMode.light,
          reason: 'enabled: false must hold, or the near-black theme ships');
    });
  });

  group('GeneralSettingsPage language', () {
    testWidgets('App language is self-labelled, and a tap writes it',
        (tester) async {
      final store = InMemoryKeyValueStore();
      final container = await pumpPage(tester, overrides: [
        keyValueStoreProvider.overrideWithValue(store),
      ]);

      expect(segment<AppLanguage>(find.text('English')), findsOneWidget);
      expect(segment<AppLanguage>(find.text('සිංහල')), findsOneWidget);
      expect(container.read(appLanguageProvider), AppLanguage.english);

      await tester.tap(segment<AppLanguage>(find.text('සිංහල')));
      await tester.pumpAndSettle();

      expect(container.read(appLanguageProvider), AppLanguage.sinhala);
      expect(store.getString(StorageKeys.appLanguage), 'sinhala');
    });

    testWidgets('Content language reads Pāli | සිංහල, and a tap writes it',
        (tester) async {
      final container = await pumpPage(tester);

      // Self-labelled like App language, from the two keys the search Refine
      // dialog shares. Was 'Pali' | 'Sinhala' before the review round.
      expect(segment<ContentLanguage>(find.text('Pāli')), findsOneWidget);
      expect(segment<ContentLanguage>(find.text('සිංහල')), findsOneWidget);

      await tester.tap(segment<ContentLanguage>(find.text('Pāli')));
      await tester.pumpAndSettle();
      expect(container.read(contentLanguageProvider), ContentLanguage.pali);

      await tester.tap(segment<ContentLanguage>(find.text('සිංහල')));
      await tester.pumpAndSettle();
      expect(container.read(contentLanguageProvider), ContentLanguage.sinhala);
    });

    testWidgets('සිංහල labels two different selectors, so finders must scope',
        (tester) async {
      await pumpPage(tester);

      // App language's own-language label and Content language's Sinhala
      // label are the same string. An unscoped find.text would be ambiguous
      // and a tap on it would throw — hence `segment<T>` above.
      expect(find.text('සිංහල'), findsNWidgets(2));
    });

    testWidgets('the content selector shows the effective (clamped) value',
        (tester) async {
      // Saved raw = Pali, but this edition only offers Sinhala.
      const sinhalaOnlyEdition = Edition(
        editionId: 'stub-si',
        displayName: 'Sinhala Only',
        abbreviation: 'SI',
        type: EditionType.local,
        availableLanguages: ['si'],
      );
      final container = await pumpPage(tester, overrides: [
        keyValueStoreProvider.overrideWithValue(
          InMemoryKeyValueStore({StorageKeys.contentLanguage: 'pali'}),
        ),
        currentEditionProvider.overrideWithValue(sinhalaOnlyEdition),
      ]);

      final selector = tester.widget<SegmentedButton<ContentLanguage>>(
        find.byType(SegmentedButton<ContentLanguage>),
      );
      // Segments are exactly the edition's available languages...
      expect(
        selector.segments.map((s) => s.value).toList(),
        equals(const [ContentLanguage.sinhala]),
      );
      // ...and the highlight is the clamped effective value, NOT the raw Pali.
      expect(selector.selected, equals({ContentLanguage.sinhala}));
      // Sanity: the raw saved preference really is the unsupported Pali.
      expect(container.read(contentLanguageProvider), ContentLanguage.pali);
    });
  });

  group('GeneralSettingsPage Pali letters', () {
    testWidgets('the sample is transformed, never the raw line',
        (tester) async {
      await pumpPage(tester);

      // All eight switch combinations render this line differently, and the
      // shipped defaults are not the identity — so the raw string on screen
      // would mean the transformer was bypassed.
      expect(find.text(_sample), findsNothing);
      expect(
        find.text(beautifyPaliText(_sample, _defaultOptions)),
        findsOneWidget,
      );
    });

    testWidgets('the sample follows a switch the instant it flips',
        (tester) async {
      final container = await pumpPage(tester);

      final before = beautifyPaliText(_sample, _defaultOptions);
      expect(find.text(before), findsOneWidget);

      // The middle switch: Special Pali letters, the one shipped off.
      await tester.tap(find.byType(Switch).at(1));
      await tester.pumpAndSettle();

      final after = beautifyPaliText(
        _sample,
        container.read(paliLetterOptionsProvider),
      );
      expect(after, isNot(before), reason: 'the flip must change the line');
      expect(find.text(before), findsNothing);
      expect(find.text(after), findsOneWidget);
    });

    testWidgets('the three switches drive the three providers', (tester) async {
      final container = await pumpPage(tester);

      expect(find.text('Standard ligatures'), findsOneWidget);
      expect(find.text('Special Pali letters'), findsOneWidget);
      expect(find.text('Touching letters'), findsOneWidget);

      // In page order, matching the providers' shipped defaults.
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(3));
      expect(container.read(standardLigaturesProvider), isTrue);
      expect(container.read(specialConjunctsProvider), isFalse);
      expect(container.read(touchingProvider), isTrue);

      for (final (index, read) in [
        (0, () => container.read(standardLigaturesProvider)),
        (1, () => container.read(specialConjunctsProvider)),
        (2, () => container.read(touchingProvider)),
      ]) {
        final before = read();
        await tester.tap(switches.at(index));
        await tester.pumpAndSettle();
        expect(read(), !before, reason: 'switch $index did not flip');
      }
    });
  });

  group('GeneralSettingsPage about', () {
    testWidgets('shows the running version, in each app language',
        (tester) async {
      // The version comes from AppVersion.display, not a literal: a literal
      // turns every release into a red suite, and the deploy gate runs this.
      // The display rule itself is pinned in test/core/version. What is
      // asserted here is the localized label beside it — two widgets now, not
      // the one 'Version {version}' string the reader menu's footnote used.
      for (final (locale, label) in const [
        (Locale('en'), 'Version'),
        (Locale('si'), 'අනුවාදය'),
      ]) {
        await pumpPage(tester, locale: locale);

        expect(find.text(label), findsOneWidget);
        expect(find.text(AppVersion.display), findsOneWidget);
      }
    });
  });
}
