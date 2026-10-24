/// The app Settings dialog: how it opens, how it switches pages, how it
/// closes, and the two shapes it takes either side of the mobile breakpoint
/// (`docs/todo/settings/app-settings-dialog.md`).
///
/// Esc was the one thing the build left unverified — the dismiss registration
/// is copied from `RefineSearchDialog.show` but nothing exercised it, so it is
/// covered here against the same `overlayStackProvider` the Esc shortcut reads.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/core/localization/l10n/app_localizations.dart';
import 'package:the_wisdom_project/core/theme/app_theme.dart';
import 'package:the_wisdom_project/presentation/providers/overlay_stack_provider.dart';
import 'package:the_wisdom_project/presentation/widgets/settings/settings_dialog.dart';
import 'package:the_wisdom_project/presentation/widgets/settings/settings_tab.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_view.dart';

/// A window wide enough for the sidebar layout at its full 760 + insets.
const _desktop = Size(1024, 800);

/// Below `ResponsiveUtils.mobileBreakpoint` (768), where the dialog goes full
/// screen with a tab bar.
const _phone = Size(390, 800);

void main() {
  /// Pumps a host with one button that opens the dialog, and returns the
  /// container so a test can read the Esc stack.
  Future<ProviderContainer> pumpHost(
    WidgetTester tester, {
    Size window = _desktop,
    SettingsTab initial = SettingsTab.general,
  }) async {
    tester.useWindow(window);

    final container = createTestContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => SettingsDialog.show(context, initial: initial),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    return container;
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  /// The sidebar lists every tab and the header names the one showing, so the
  /// selected tab's label is on screen twice and the others once.
  void expectShowing(SettingsTab tab) {
    expect(find.byType(SettingsDialog), findsOneWidget);
    expect(find.text('General'),
        tab == SettingsTab.general ? findsNWidgets(2) : findsOneWidget);
    expect(find.text('Anumodanā'),
        tab == SettingsTab.anumodana ? findsNWidgets(2) : findsOneWidget);
  }

  group('SettingsDialog on tablet and desktop', () {
    testWidgets('opens on General, with the sidebar beside it', (tester) async {
      await pumpHost(tester);
      await open(tester);

      expectShowing(SettingsTab.general);
      // General's own content, so this is the page and not just its label.
      expect(find.text('Appearance'), findsOneWidget);
      // The sidebar's own heading, above the tab list.
      expect(find.text('Settings'), findsOneWidget);
      // The narrow shape's tab bar belongs to the other layout.
      expect(find.byType(TabBar), findsNothing);
    });

    testWidgets('opens on the tab it is given', (tester) async {
      await pumpHost(tester, initial: SettingsTab.anumodana);
      await open(tester);

      expectShowing(SettingsTab.anumodana);
      expect(find.text('Text sources'), findsOneWidget);
      expect(find.text('Appearance'), findsNothing);
    });

    testWidgets('the sidebar switches pages, both ways', (tester) async {
      await pumpHost(tester);
      await open(tester);

      // The sidebar entry, not the header title that shares its text.
      Finder sidebarItem(String label) => find.descendant(
            of: find.byType(ListTile),
            matching: find.text(label),
          );

      await tester.tap(sidebarItem('Anumodanā'));
      await tester.pumpAndSettle();
      expectShowing(SettingsTab.anumodana);
      expect(find.text('Appearance'), findsNothing);

      await tester.tap(sidebarItem('General'));
      await tester.pumpAndSettle();
      expectShowing(SettingsTab.general);
      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('the close button, and a tap outside, both close it',
        (tester) async {
      await pumpHost(tester);

      await open(tester);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsDialog), findsNothing);

      await open(tester);
      // The barrier: the dialog is 760 wide and centred in 1024.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsDialog), findsNothing);
    });

    testWidgets('the header title sits over its page, on one gutter',
        (tester) async {
      await pumpHost(tester);
      await open(tester);

      // `settingsGutter` exists because the canvas's left edges disagreed
      // with each other: the header and every page share the one value, so
      // the title and the first heading under it line up exactly.
      // The header's own title, not the sidebar entry that shares its text:
      // the header is the row the close button sits in.
      final headerRow = find
          .ancestor(of: find.byIcon(Icons.close), matching: find.byType(Row))
          .first;
      final title = find.descendant(
        of: headerRow,
        matching: find.text('General'),
      );
      expect(
        tester.getTopLeft(title).dx,
        tester.getTopLeft(find.text('Appearance')).dx,
      );
    });

    testWidgets('nothing overflows, and it clamps to a window under 760+insets',
        (tester) async {
      // The dialog's surface: Dialog's own Material, whose size is the
      // SizedBox the layout asks for. `byType(SettingsDialog)` would be the
      // whole screen, insets and barrier included.
      final surface = find
          .descendant(of: find.byType(Dialog), matching: find.byType(Material))
          .first;

      // 820 is inside the band where the preferred 760 plus Dialog's own
      // 40px-a-side insets does not fit — what the clamp is for.
      for (final (window, expected) in const [
        (_desktop, Size(760, 640)),
        (Size(820, 700), Size(740, 640)),
      ]) {
        await pumpHost(tester, window: window);
        await open(tester);

        expect(tester.takeException(), isNull, reason: '$window');
        expect(tester.getSize(surface), expected, reason: '$window');

        await tester.tap(find.byTooltip('Close'));
        await tester.pumpAndSettle();
      }
    });
  });

  group('SettingsDialog below the mobile breakpoint', () {
    testWidgets('goes full screen with a tab bar instead of the sidebar',
        (tester) async {
      await pumpHost(tester, window: _phone);
      await open(tester);

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsNWidgets(SettingsTab.values.length));
      // The app bar names the dialog; the pages name themselves on the tabs.
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Anumodanā'), findsOneWidget);
      // No sidebar list at this width.
      expect(find.byType(ListTile), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the tab bar switches pages', (tester) async {
      await pumpHost(tester, window: _phone);
      await open(tester);

      expect(find.text('Appearance'), findsOneWidget);

      await tester.tap(find.widgetWithText(Tab, 'Anumodanā'));
      await tester.pumpAndSettle();

      expect(find.text('Text sources'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the close button in the app bar pops it', (tester) async {
      await pumpHost(tester, window: _phone);
      await open(tester);

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsDialog), findsNothing);
    });
  });

  group('SettingsDialog and the Esc stack', () {
    testWidgets('registers while open and is gone once closed', (tester) async {
      final container = await pumpHost(tester);
      List<String> stack() =>
          [for (final o in container.read(overlayStackProvider)) o.id];

      expect(stack(), isEmpty);

      await open(tester);
      expect(stack(), ['settings-dialog']);

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      // The `finally` in `show` removes the entry however the dialog closed.
      expect(stack(), isEmpty);
    });

    testWidgets('Esc closes it — what dismissTop does to the top overlay',
        (tester) async {
      final container = await pumpHost(tester);
      await open(tester);

      expect(
          container.read(overlayStackProvider.notifier).dismissTop(), isTrue);
      await tester.pumpAndSettle();

      expect(find.byType(SettingsDialog), findsNothing);
      expect(container.read(overlayStackProvider), isEmpty);
    });

    testWidgets('a tap outside also clears the registration', (tester) async {
      final container = await pumpHost(tester);
      await open(tester);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsDialog), findsNothing);
      expect(container.read(overlayStackProvider), isEmpty);
    });
  });
}
