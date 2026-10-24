/// The way into app Settings: a gear at the foot of the navigation rail.
///
/// The build left this unverified — "AppShell is too heavy to pump" — but with
/// the tree data source and SharedPreferences stood in for, it pumps. This
/// file covers the entry point itself and pins the two gaps the plan accepts
/// knowingly (Decisions 4 and 7), so neither is forgotten: a phone cannot
/// reach Settings at all, and a hidden rail takes the gear with it.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_wisdom_project/core/localization/l10n/app_localizations.dart';
import 'package:the_wisdom_project/core/theme/app_theme.dart';
import 'package:the_wisdom_project/presentation/providers/app_section_provider.dart';
import 'package:the_wisdom_project/presentation/providers/navigation_rail_provider.dart';
import 'package:the_wisdom_project/presentation/screens/app_shell.dart';
import 'package:the_wisdom_project/presentation/widgets/settings/settings_dialog.dart';

import '../../helpers/mocks.mocks.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_data.dart';
import '../../helpers/test_view.dart';

/// Wide enough for the rail (`mobileBreakpoint` is 768).
const _desktop = Size(1280, 900);

/// Below it, where the shell shows a bottom bar and no rail.
const _phone = Size(390, 844);

void main() {
  /// Pumps the whole shell. Only two seams need standing in for: the tree
  /// data source the reader loads from, and SharedPreferences, which the
  /// recent-searches repository reads at construction.
  Future<ProviderContainer> pumpShell(
    WidgetTester tester, {
    Size window = _desktop,
    List<Override> overrides = const [],
  }) async {
    tester.useWindow(window);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final dataSource = MockTreeLocalDataSource();
    when(dataSource.loadNavigationTree())
        .thenAnswer((_) async => TestData.sampleTree);

    final container = createTestContainer(overrides: [
      TestProviderOverrides.treeDataSource(dataSource),
      TestProviderOverrides.sharedPreferences(prefs),
      ...overrides,
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AppShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  /// The rail's gear. Scoped to the rail because the dialog's own General tab
  /// carries the same icon once it is open.
  final railGear = find.descendant(
    of: find.byType(NavigationRail),
    matching: find.byIcon(Icons.settings_outlined),
  );

  group('AppShell settings gear', () {
    testWidgets('sits at the foot of the rail, and is not a destination',
        (tester) async {
      await pumpShell(tester);

      expect(railGear, findsOneWidget);
      expect(find.byTooltip('Settings'), findsOneWidget);

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      // Reader and Research. Settings opens a dialog over whichever is
      // showing, so it is trailing, not a fifth destination.
      expect(rail.destinations.length, 2);
      expect(rail.trailingAtBottom, isTrue);
      expect(rail.trailing, isNotNull);

      // Below the last destination on screen, which is what "at the foot"
      // has to mean for the user.
      expect(
        tester.getTopLeft(railGear).dy,
        greaterThan(
            tester.getBottomLeft(find.byIcon(Icons.auto_awesome_outlined)).dy),
      );
    });

    testWidgets('opens the Settings dialog on General', (tester) async {
      await pumpShell(tester);

      expect(find.byType(SettingsDialog), findsNothing);

      await tester.tap(railGear);
      await tester.pumpAndSettle();

      expect(find.byType(SettingsDialog), findsOneWidget);
      // General's own content, so this is the page and not just its label.
      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('opens over whatever section is showing', (tester) async {
      final container = await pumpShell(tester);

      container.read(selectedAppSectionProvider.notifier).state =
          AppSection.research;
      await tester.pumpAndSettle();

      await tester.tap(railGear);
      await tester.pumpAndSettle();

      expect(find.byType(SettingsDialog), findsOneWidget);
      expect(
        container.read(selectedAppSectionProvider),
        AppSection.research,
        reason: 'opening Settings must not navigate away',
      );
    });
  });

  group('AppShell settings gear — the accepted gaps', () {
    testWidgets('a phone has no way in at all (Decisions 4)', (tester) async {
      await pumpShell(tester, window: _phone);

      // No rail below the breakpoint, so no gear — and the bottom bar has
      // only the two sections. Until the bottom bar gains a Settings item
      // (`docs/todo/reader/phone-chrome-auto-hide.md`), a phone cannot reach
      // Theme, App language, Content language or Pali letters at all. This
      // test is the reminder, and it flips when that lands.
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byIcon(Icons.settings_outlined), findsNothing);

      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.destinations.length, 2);
    });

    testWidgets('a hidden rail takes the gear with it (Decisions 7)',
        (tester) async {
      final container = await pumpShell(tester);
      expect(railGear, findsOneWidget);

      // Hide navigation bar, the switch that stays in the reader's own menu.
      container.read(navigationRailHiddenProvider.notifier).state = true;
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byIcon(Icons.settings_outlined), findsNothing,
          reason: 'parked: a Ctrl/Cmd+, shortcut would cover this');

      // The reader menu is still the way back, and brings the gear with it.
      container.read(navigationRailHiddenProvider.notifier).state = false;
      await tester.pumpAndSettle();
      expect(railGear, findsOneWidget);
    });
  });
}
