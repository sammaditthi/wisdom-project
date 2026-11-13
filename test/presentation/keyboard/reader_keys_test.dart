import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/presentation/providers/reader_keyboard_bridge_provider.dart';
import 'package:the_wisdom_project/presentation/providers/reader_unit_provider.dart';

import 'shortcut_test_host.dart';

/// Keys that act on the mounted reader through its bridge: ⌥⌘< > step a
/// sutta, ↑ ↓ PgUp PgDn scroll — only from the reader or from nowhere, never
/// from a button or a text box (`docs/done/reader/keyboard-shortcuts-sheet.md`).
void main() {
  final mac = TargetPlatformVariant.only(TargetPlatform.macOS);

  Future<_FakeHandle> pumpWithFake(
    WidgetTester tester, {
    Widget home = const Scaffold(),
    bool canStep = true,
  }) async {
    final c = await pumpShortcutHost(tester, home: home);
    final fake = _FakeHandle(canStepTo: canStep);
    c.read(readerKeyboardBridgeProvider).attach(fake);
    await tester.pump();
    return fake;
  }

  testWidgets('⌥⌘> and ⇧⌥⌘> step to the next sutta', (tester) async {
    final fake = await pumpWithFake(tester);

    await pressKeys(tester, LogicalKeyboardKey.period,
        primary: true, alt: true);
    await pressKeys(tester, LogicalKeyboardKey.period,
        primary: true, alt: true, shift: true);
    await pressKeys(tester, LogicalKeyboardKey.comma, primary: true, alt: true);

    expect(fake.steps, [ReaderStep.next, ReaderStep.next, ReaderStep.previous]);
  }, variant: mac);

  // A browser names ⇧, and ⇧. by the characters they type.
  testWidgets('⇧ with the keys from a browser, as < and >, steps too',
      (tester) async {
    final fake = await pumpWithFake(tester);

    await pressKeys(tester, LogicalKeyboardKey.greater,
        primary: true,
        alt: true,
        shift: true,
        physicalKey: PhysicalKeyboardKey.period);
    await pressKeys(tester, LogicalKeyboardKey.less,
        primary: true,
        alt: true,
        shift: true,
        physicalKey: PhysicalKeyboardKey.comma);

    expect(fake.steps, [ReaderStep.next, ReaderStep.previous]);
  }, variant: mac);

  testWidgets('⌥⌘> at the last sutta does nothing', (tester) async {
    final fake = await pumpWithFake(tester, canStep: false);

    await pressKeys(tester, LogicalKeyboardKey.period,
        primary: true, alt: true);
    expect(fake.steps, isEmpty);
  }, variant: mac);

  testWidgets('↓ with nothing focused scrolls a line, PgDn a page',
      (tester) async {
    final fake = await pumpWithFake(tester);

    await pressKeys(tester, LogicalKeyboardKey.arrowDown);
    await pressKeys(tester, LogicalKeyboardKey.pageDown);

    expect(fake.scrolls, [
      (AxisDirection.down, ScrollIncrementType.line),
      (AxisDirection.down, ScrollIncrementType.page),
    ]);
  }, variant: mac);

  testWidgets('↓ on a focused button outside the reader does not scroll',
      (tester) async {
    final fake = await pumpWithFake(
      tester,
      home: Scaffold(
        body: TextButton(
          autofocus: true,
          onPressed: () {},
          child: const Text('button'),
        ),
      ),
    );

    await pressKeys(tester, LogicalKeyboardKey.arrowDown);
    expect(fake.scrolls, isEmpty);
  }, variant: mac);

  testWidgets('↓ with a popup menu open does not scroll the reader',
      (tester) async {
    // The reader menu is a plain PopupMenuButton: a route, not on the
    // overlay stack. Its scope takes focus, and ↓ must stay with the menu.
    final fake = await pumpWithFake(
      tester,
      home: Scaffold(
        body: PopupMenuButton<int>(
          itemBuilder: (_) => const [
            PopupMenuItem(value: 1, child: Text('one')),
          ],
          child: const Text('menu'),
        ),
      ),
    );
    await tester.tap(find.text('menu'));
    await tester.pumpAndSettle();

    await pressKeys(tester, LogicalKeyboardKey.arrowDown);
    expect(fake.scrolls, isEmpty);
  }, variant: mac);

  testWidgets('↓ in a text box does not scroll', (tester) async {
    final fake = await pumpWithFake(
      tester,
      home: const Scaffold(body: TextField(autofocus: true)),
    );

    await pressKeys(tester, LogicalKeyboardKey.arrowDown);
    expect(fake.scrolls, isEmpty);
  }, variant: mac);
}

/// Records what the keys asked the reader to do.
class _FakeHandle implements ReaderKeyboardHandle {
  _FakeHandle({required this.canStepTo});

  final bool canStepTo;
  final steps = <ReaderStep>[];
  final scrolls = <(AxisDirection, ScrollIncrementType)>[];

  @override
  bool get hasFocus => false;

  @override
  bool canStep(ReaderStep step) => canStepTo;

  @override
  void step(ReaderStep step) => steps.add(step);

  @override
  void scroll(AxisDirection direction, ScrollIncrementType type) =>
      scrolls.add((direction, type));
}
