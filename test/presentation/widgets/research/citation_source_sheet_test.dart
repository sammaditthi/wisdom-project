import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/domain/entities/research/citation.dart';
import 'package:the_wisdom_project/presentation/providers/deep_link_provider.dart';
import 'package:the_wisdom_project/presentation/providers/navigation_tree_provider.dart';
import 'package:the_wisdom_project/presentation/providers/suttacentral_provider.dart';
import 'package:the_wisdom_project/presentation/widgets/research/citation_source_sheet.dart';
import 'package:wisdom_shared/wisdom_shared.dart';

import '../../../helpers/pump_app.dart';

// A research citation opens the way a typed reference does: the exact uid, else
// the range holding it (`docs/todo/search/sutta-references-plan.md`, step 5).
void main() {
  const resolver = SuttaCentralRefResolver({
    'dhp1-20': 'kn-dhp-1',
    'an1.1-10': 'an-1-1',
  });

  /// Opens the sheet for [citation] as an answer's chip does. Returns the node
  /// keys "Open in reader" asks for.
  Future<List<String>> showSheet(
    WidgetTester tester,
    Citation citation,
  ) async {
    final opened = <String>[];
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => CitationSourceSheet.show(context, citation),
          child: const Text('chip'),
        ),
      ),
      overrides: [
        suttaCentralRefResolverProvider.overrideWith((ref) => resolver),
        // No tree: the Sinhala preview stays empty and loads no page.
        nodeIndexProvider.overrideWithValue(const {}),
        openTipitakaLinkProvider.overrideWithValue(
          (TipitakaLink link, {bool isPortraitMode = false}) async {
            opened.add(link.nodeKey);
            return true;
          },
        ),
      ],
    );
    await tester.tap(find.text('chip'));
    await tester.pumpAndSettle();
    return opened;
  }

  testWidgets('"AN 1.1" from the answer opens AN 1.1-10, and names it',
      (tester) async {
    // The model wrote "AN 1.1"; SuttaCentral has only the range.
    final opened = await showSheet(
      tester,
      const Citation(uid: 'an1.1', ref: 'AN 1.1'),
    );

    expect(find.text('AN 1.1-10'), findsOneWidget);
    await tester.tap(find.text('Open in reader'));
    await tester.pumpAndSettle();
    expect(opened, ['an-1-1']);
  });

  testWidgets('a citation with its own uid keeps the ref as sent',
      (tester) async {
    // Upper case as the Worker sent it, so a rewrite would show.
    final opened = await showSheet(
      tester,
      const Citation(uid: 'dhp1-20', ref: 'DHP 1-20', title: 'Pairs'),
    );

    expect(find.text('DHP 1-20 · Pairs'), findsOneWidget);
    await tester.tap(find.text('Open in reader'));
    await tester.pumpAndSettle();
    expect(opened, ['kn-dhp-1']);
  });

  testWidgets('a uid with no BJT text says so, and offers nothing to open',
      (tester) async {
    await showSheet(
      tester,
      const Citation(uid: 'pli-tv-bu-pm', ref: 'pli-tv-bu-pm'),
    );

    expect(find.text('pli-tv-bu-pm'), findsOneWidget);
    expect(
      find.text("This source isn't linked to this edition yet."),
      findsOneWidget,
    );
    expect(find.text('Open in reader'), findsNothing);
  });
}
