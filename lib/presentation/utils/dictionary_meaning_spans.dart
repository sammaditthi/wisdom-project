import 'package:flutter/material.dart';

/// Turns a dictionary meaning's simple HTML (`<b>`, `<i>`, `<br>`, entities)
/// into styled spans. With [dropLinkText], link text is left out: DPD's only
/// link is its trailing "Read more", which `DpdWebsiteLink` replaces.
/// Other dictionaries (PN) link words mid-sentence, so their text stays.
List<InlineSpan> dictionaryMeaningSpans(
  String html, {
  required bool dropLinkText,
}) {
  final spans = <InlineSpan>[];

  // Replace <br> and <br/> with newlines, decode HTML entities
  var text = html
      .replaceAll(RegExp(r'<br\s*/?>'), '\n')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"');

  // Process text with basic tag handling
  final buffer = StringBuffer();
  var isBold = false;
  var isItalic = false;
  var isInsideLink = false;

  int i = 0;
  while (i < text.length) {
    if (text[i] == '<') {
      // Found a tag - flush buffer first
      if (buffer.isNotEmpty) {
        spans.add(_styledSpan(buffer.toString(), isBold, isItalic));
        buffer.clear();
      }

      // Find end of tag
      final tagEnd = text.indexOf('>', i);
      if (tagEnd == -1) {
        buffer.write(text[i]);
        i++;
        continue;
      }

      final tag = text.substring(i + 1, tagEnd).toLowerCase().trim();
      i = tagEnd + 1;

      // Handle tags
      if (tag == 'b' || tag == 'strong') {
        isBold = true;
      } else if (tag == '/b' || tag == '/strong') {
        isBold = false;
      } else if (tag == 'i' || tag == 'em') {
        isItalic = true;
      } else if (tag == '/i' || tag == '/em') {
        isItalic = false;
      } else if (tag.startsWith('a ')) {
        // Skip link content — rendered as a separate widget
        isInsideLink = dropLinkText;
      } else if (tag == '/a') {
        isInsideLink = false;
      } else if (tag.startsWith('r ') || tag == 'r') {
        // Custom <r> tags used in Sinhala dictionaries
        // Just render the content without special styling
      } else if (tag == '/r') {
        // End of <r> tag
      }
      // Ignore other tags
    } else {
      if (!isInsideLink) {
        buffer.write(text[i]);
      }
      i++;
    }
  }

  // Flush remaining buffer
  if (buffer.isNotEmpty) {
    spans.add(_styledSpan(buffer.toString(), isBold, isItalic));
  }

  // Trim trailing whitespace/newlines from the last span (e.g. a <br>
  // before a stripped <a> tag would leave a dangling newline).
  if (spans.isNotEmpty && spans.last is TextSpan) {
    final last = spans.last as TextSpan;
    if (last.text != null) {
      final trimmed = last.text!.trimRight();
      if (trimmed != last.text) {
        spans[spans.length - 1] = TextSpan(
          text: trimmed,
          style: last.style,
        );
      }
    }
  }

  return spans.isEmpty ? [const TextSpan(text: '')] : spans;
}

TextSpan _styledSpan(String text, bool isBold, bool isItalic) {
  return TextSpan(
    text: text,
    style: TextStyle(
      fontWeight: isBold ? FontWeight.bold : null,
      fontStyle: isItalic ? FontStyle.italic : null,
    ),
  );
}
