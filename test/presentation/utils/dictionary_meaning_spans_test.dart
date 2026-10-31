import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/presentation/utils/dictionary_meaning_spans.dart';

void main() {
  String plainText(String html, {required bool dropLinkText}) => TextSpan(
          children: dictionaryMeaningSpans(html, dropLinkText: dropLinkText))
      .toPlainText();

  group('dictionaryMeaningSpans', () {
    test('keeps a link\'s text, which PN puts mid-sentence', () {
      expect(
        plainText('the five <a href="http://x">sankhārā</a>, their nature',
            dropLinkText: false),
        'the five sankhārā, their nature',
      );
    });

    test('drops DPD\'s trailing "Read more" when asked', () {
      expect(
        plainText(
            'straight<br><a href="https://www.dpdict.net/?q=a">Read more</a>',
            dropLinkText: true),
        'straight',
      );
    });
  });
}
