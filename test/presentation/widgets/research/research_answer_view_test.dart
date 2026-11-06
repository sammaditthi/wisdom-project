import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/presentation/widgets/research/research_answer_view.dart';

import '../../../helpers/pump_app.dart';

// The fixture is shared with the Worker's paragraphs.test.ts.
void main() {
  final cases = (jsonDecode(
    File('test/fixtures/research_answer_paragraphs.json').readAsStringSync(),
  ) as List)
      .cast<Map<String, dynamic>>();

  group('ResearchAnswerView paragraphs', () {
    for (final c in cases) {
      testWidgets(c['name'] as String, (tester) async {
        await tester.pumpApp(
          ResearchAnswerView(answer: c['text'] as String, citations: const []),
        );

        final shown = tester
            .widgetList<RichText>(
              find.descendant(
                of: find.byType(ResearchAnswerView),
                matching: find.byType(RichText),
              ),
            )
            .map((r) => r.text.toPlainText())
            .toList();

        expect(shown, (c['paragraphs'] as List).cast<String>());
      });
    }
  });
}
