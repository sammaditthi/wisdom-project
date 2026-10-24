/// The Settings pages' shared pieces: [SettingsSection], [SettingsRow] and
/// [SettingsTile].
///
/// Covered on their own because they are about to get more callers — the plan
/// moves the refine dialogs and the dictionary sheet onto them, at which point
/// they graduate from `widgets/settings/` to `widgets/common/`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/core/theme/app_theme.dart';
import 'package:the_wisdom_project/presentation/widgets/settings/settings_row.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpApp(
        child,
        theme: AppTheme.light(),
      );

  group('SettingsRow', () {
    testWidgets('a label alone, with the divider under it', (tester) async {
      await pump(tester, const SettingsRow(label: 'Theme'));

      expect(find.text('Theme'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
      // Material's minimum tap target, whatever the row holds.
      expect(tester.getSize(find.byType(SettingsRow)).height,
          greaterThanOrEqualTo(48));
    });

    testWidgets('the last row in a group drops its divider', (tester) async {
      await pump(
        tester,
        const SettingsRow(label: 'Version', showDivider: false),
      );
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('hint, leading and trailing all show', (tester) async {
      await pump(
        tester,
        const SettingsRow(
          label: 'App language',
          hint: 'Menus, buttons and messages.',
          leading: SettingsTile(icon: Icons.translate),
          trailing: Text('English'),
        ),
      );

      expect(find.text('App language'), findsOneWidget);
      expect(find.text('Menus, buttons and messages.'), findsOneWidget);
      expect(find.byIcon(Icons.translate), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('onTap given makes the whole row tappable; absent it is not',
        (tester) async {
      var taps = 0;
      await pump(
        tester,
        SettingsRow(label: 'Open', onTap: () => taps++),
      );

      expect(find.byType(InkWell), findsOneWidget);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(taps, 1);

      // A row that only holds a control leaves onTap null and lets the
      // control take the tap.
      await pump(tester, const SettingsRow(label: 'Switch only'));
      expect(find.byType(InkWell), findsNothing);
    });
  });

  group('SettingsRow semantics', () {
    testWidgets('merged by default, so the switch is announced with its label',
        (tester) async {
      // Disposed inline, not in a tear-down: the framework checks for a live
      // handle before tear-downs run.
      final handle = tester.ensureSemantics();

      await pump(
        tester,
        SettingsRow(
          label: 'Touching letters',
          trailing: Switch(value: true, onChanged: (_) {}),
        ),
      );

      // One node for the row: without the merge a screen reader reaches a
      // nameless switch and has to look elsewhere for what it toggles.
      // Read off the MergeSemantics, which is where the node is — the row
      // element itself has none, so `getSemantics` there walks up to the root.
      expect(
        tester.getSemantics(find.byType(MergeSemantics)),
        isSemantics(
          label: 'Touching letters',
          hasToggledState: true,
          isToggled: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('mergeSemantics off leaves several controls reachable',
        (tester) async {
      await pump(
        tester,
        const SettingsRow(
          label: 'Theme',
          mergeSemantics: false,
          trailing: Text('Light'),
        ),
      );

      // Off for a trailing control that is several at once (a SegmentedButton):
      // merging runs their labels together, merges their conflicting selected
      // states and leaves only the first segment able to take a semantic tap.
      expect(find.byType(MergeSemantics), findsNothing);
    });
  });

  group('SettingsSection', () {
    testWidgets('title, optional hint, then its rows', (tester) async {
      await pump(
        tester,
        const SettingsSection(
          title: 'Pali letters',
          hint: 'How joined Pali letters are shown.',
          children: [SettingsRow(label: 'Standard ligatures')],
        ),
      );

      expect(find.text('Pali letters'), findsOneWidget);
      expect(find.text('How joined Pali letters are shown.'), findsOneWidget);

      double y(String text) => tester.getTopLeft(find.text(text)).dy;
      expect(
          y('Pali letters'), lessThan(y('How joined Pali letters are shown.')));
      expect(y('How joined Pali letters are shown.'),
          lessThan(y('Standard ligatures')));
    });

    testWidgets('isFirst closes the gap that separates later groups',
        (tester) async {
      double titleTop() => tester.getTopLeft(find.text('Appearance')).dy;

      await pump(
        tester,
        const SettingsSection(
          title: 'Appearance',
          isFirst: true,
          children: [SettingsRow(label: 'Theme')],
        ),
      );
      final first = titleTop();

      await pump(
        tester,
        const SettingsSection(
          title: 'Appearance',
          children: [SettingsRow(label: 'Theme')],
        ),
      );
      final later = titleTop();

      // The first group on a page must not start with a hole under the
      // dialog header.
      expect(first, lessThan(later));
    });
  });

  group('SettingsTile', () {
    testWidgets('an icon, an abbreviation or a logo — one square either way',
        (tester) async {
      await pump(
        tester,
        const Column(
          children: [
            SettingsTile(icon: Icons.text_fields_outlined),
            SettingsTile(text: 'DPD'),
          ],
        ),
      );

      expect(find.byIcon(Icons.text_fields_outlined), findsOneWidget);
      expect(find.text('DPD'), findsOneWidget);
      // Both are the same square, so a mixed list keeps one left edge.
      expect(find.byType(SettingsTile), findsNWidgets(2));
      for (var i = 0; i < 2; i++) {
        expect(tester.getSize(find.byType(SettingsTile).at(i)),
            const Size(36, 36));
      }
    });

    testWidgets('a long abbreviation shrinks instead of widening the tile',
        (tester) async {
      await pump(tester, const SettingsTile(text: 'DPDC'));

      // The tile is a fixed square but the abbreviation follows the font-size
      // slider, so at 1.5x a four-letter one is wider than the tile. It is
      // scaled down rather than pushing one row's label out of line.
      expect(find.byType(FittedBox), findsOneWidget);
      expect(
        tester.widget<FittedBox>(find.byType(FittedBox)).fit,
        BoxFit.scaleDown,
      );
      expect(tester.getSize(find.byType(SettingsTile)), const Size(36, 36));
    });

    testWidgets('a logo stands on the page, unrecoloured and undecorated',
        (tester) async {
      await pump(
        tester,
        const SettingsTile(imageAsset: 'assets/icons/emblem.webp'),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, 'assets/icons/emblem.webp');
      // No tile behind it: a logo carries its own shape and colour.
      expect(
        find.descendant(
          of: find.byType(SettingsTile),
          matching: find.byType(DecoratedBox),
        ),
        findsNothing,
      );
      expect(image.excludeFromSemantics, isTrue);
    });
  });
}
