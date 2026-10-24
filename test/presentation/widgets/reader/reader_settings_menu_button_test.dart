/// The reader toolbar's menu, after the app-wide settings moved out of it into
/// the Settings dialog (`docs/todo/settings/app-settings-dialog.md`).
///
/// What is left here is what you change *while reading*: Font size always, and
/// Hide navigation bar only where a navigation rail exists. The controls that
/// moved are asserted ABSENT — this file is the guard against one drifting
/// back in beside its copy on General.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/core/localization/l10n/app_localizations.dart';
import 'package:the_wisdom_project/core/theme/theme_notifier.dart';
import 'package:the_wisdom_project/core/version/app_version.gen.dart';
import 'package:the_wisdom_project/presentation/providers/navigation_rail_provider.dart';
import 'package:the_wisdom_project/presentation/widgets/reader/reader_settings_menu_button.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_view.dart';

void main() {
  /// Pumps the button and returns the container, so a test can read the
  /// providers the menu writes.
  Future<ProviderContainer> pumpMenu(WidgetTester tester) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: ReaderSettingsMenuButton()),
        ),
      ),
    );
    return container;
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
  }

  group('ReaderSettingsMenuButton', () {
    testWidgets('opens under the sliders icon, named "Reader settings"',
        (tester) async {
      await pumpMenu(tester);

      // The gear is the app Settings dialog's now; this menu is sliders.
      expect(find.byIcon(Icons.tune), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsNothing);
      expect(find.byTooltip('Reader settings'), findsOneWidget);

      expect(find.byType(PopupMenuItem<String>), findsNothing);
      await openMenu(tester);
      expect(find.byType(PopupMenuItem<String>), findsWidgets);
    });

    testWidgets('holds Font size and App layout, and nothing app-wide',
        (tester) async {
      await pumpMenu(tester);
      await openMenu(tester);

      // What stays: the two you reach for mid-read. At the default 800px test
      // window this is a tablet, so App layout is shown.
      expect(find.text('Font size'), findsOneWidget);
      expect(find.text('App layout'), findsOneWidget);
      expect(find.text('Hide navigation bar'), findsOneWidget);

      // What moved to Settings → General. Each of these was in this menu
      // before the split; none may come back.
      expect(find.text('Theme'), findsNothing);
      expect(find.text('Light'), findsNothing);
      expect(find.text('App language'), findsNothing);
      expect(find.text('Content language'), findsNothing);
      expect(find.text('Pali letters'), findsNothing);
      // The version footnote went with them, label and value both.
      expect(find.text('Version'), findsNothing);
      expect(find.text(AppVersion.display), findsNothing);
      expect(find.textContaining('Version'), findsNothing);
    });

    testWidgets('on a phone there is no rail, so Font size is alone',
        (tester) async {
      tester.useWindow(const Size(390, 800));
      await pumpMenu(tester);
      await openMenu(tester);

      expect(find.text('Font size'), findsOneWidget);
      // Hide navigation bar is the way back from a hidden rail — on a phone
      // there is no rail to hide, so the whole section is gone.
      expect(find.text('App layout'), findsNothing);
      expect(find.text('Hide navigation bar'), findsNothing);
    });

    testWidgets('the slider writes the font scale, rounded to 0.05',
        (tester) async {
      final container = await pumpMenu(tester);
      await openMenu(tester);

      final notifier = container.read(fontScaleProvider.notifier);
      expect(container.read(fontScaleProvider), notifier.platformDefault);

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.min, FontScaleNotifier.minScale);
      expect(slider.max, FontScaleNotifier.maxScale);

      // The raw slider value is rounded to the nearest 0.05 before it is
      // stored, so the percentage the menu shows is always a whole step.
      slider.onChanged!(1.2376);
      await tester.pumpAndSettle();

      expect(container.read(fontScaleProvider), closeTo(1.25, 1e-9));
      expect(find.text('125%'), findsOneWidget);
    });

    testWidgets('Reset shows only off the default, and restores it',
        (tester) async {
      final container = await pumpMenu(tester);
      await openMenu(tester);

      final notifier = container.read(fontScaleProvider.notifier);
      expect(find.text('Reset'), findsNothing,
          reason: 'nothing to reset at the default scale');

      tester.widget<Slider>(find.byType(Slider)).onChanged!(1.35);
      await tester.pumpAndSettle();
      expect(find.text('Reset'), findsOneWidget);

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(container.read(fontScaleProvider), notifier.platformDefault);
      expect(find.text('Reset'), findsNothing);
    });

    testWidgets('Hide navigation bar toggles the rail provider',
        (tester) async {
      final container = await pumpMenu(tester);
      await openMenu(tester);

      expect(container.read(navigationRailHiddenProvider), isFalse);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(container.read(navigationRailHiddenProvider), isTrue);

      // The row is in a disabled PopupMenuItem, so the menu stays open and
      // the switch can be flipped straight back.
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(container.read(navigationRailHiddenProvider), isFalse);
    });

    testWidgets('every row is disabled, so no tap can select or close',
        (tester) async {
      await pumpMenu(tester);
      await openMenu(tester);

      final items = tester.widgetList<PopupMenuItem<String>>(
          find.byType(PopupMenuItem<String>));
      expect(items, isNotEmpty);
      for (final item in items) {
        expect(item.enabled, isFalse);
      }
    });
  });
}
