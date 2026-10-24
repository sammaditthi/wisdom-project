import 'dart:io';

import 'src/cli.dart';

/// Fails if a page's own text is also printed somewhere else in the build.
///
/// Takes one unbroken run of body text out of pages sampled across the corpus
/// and looks for it in every other output file. The rule it guards is the
/// site's hard one: the same text never lives in two files, because a reader
/// who finds a sutta twice has two URLs for it and so does a crawler.
///
/// Two outcomes are not failures. The canon repeats stock formulas across
/// unrelated suttas, which is the source's doing, not the build's. And a
/// phrase short enough to be a turn of phrase proves nothing either way, so
/// sampling takes long runs only. What fails is a phrase on a page *and* on an
/// ancestor or descendant of it — the real duplication, a run printed both
/// whole and in pieces — or body text reaching the search index or sitemap.
///
///     dart run static_site_generator/tool/check_unique_text.dart
///     dart run static_site_generator/tool/check_unique_text.dart --sample 40
Future<void> main(List<String> args) async {
  final options = parseArgs(args, const {'--build', '--sample'});
  if (options == null) {
    exitCode = 1;
    return;
  }

  final sampleSize = int.tryParse(options['--sample'] ?? '24');
  if (sampleSize == null || sampleSize < 1) {
    stderr.writeln('--sample needs a positive number.');
    exitCode = 1;
    return;
  }

  final rootPath = normalizeDir(options['--build'] ?? '$packageRoot/build');
  if (!Directory(rootPath).existsSync()) {
    stderr.writeln('no build directory at $rootPath. Generate one first, or '
        'pass --build <dir>.');
    exitCode = 1;
    return;
  }
  stdout.writeln('build   $rootPath');

  final files = Directory(rootPath)
      .listSync(recursive: true)
      .whereType<File>()
      .map((f) => f.path.substring(rootPath.length + 1))
      .where((p) =>
          p.endsWith('.html') || p.endsWith('.json') || p.endsWith('.xml'))
      .toList()
    ..sort();
  final pages = files.where((p) => p.endsWith('.html')).toList();

  // A stride rather than a random draw: the same build samples the same pages
  // every run, so a finding can be reproduced and a clean run means something.
  // A slot whose page carries no body text — a TOC — walks forward to the next
  // page that does, so the sample size is about the corpus, not about where
  // the stride happened to land.
  final phrases = <_Phrase>[];
  final stride = (pages.length / sampleSize).ceil().clamp(1, pages.length);
  for (var slot = 0; slot < sampleSize; slot++) {
    for (var i = slot * stride;
        i < (slot + 1) * stride && i < pages.length;
        i++) {
      final text =
          _longestRun(File('$rootPath/${pages[i]}').readAsStringSync());
      if (text != null) {
        phrases.add(_Phrase(pages[i], text));
        break;
      }
    }
  }
  if (phrases.isEmpty) {
    stdout.writeln('\nFAIL — sampled no body text at all, so nothing was '
        'checked. Treated as a failure.');
    exitCode = 1;
    return;
  }

  for (final file in files) {
    final body = File('$rootPath/$file').readAsStringSync();
    for (final phrase in phrases) {
      if (body.contains(phrase.text)) phrase.found.add(file);
    }
  }

  stdout.writeln('sample  ${phrases.length} phrases, '
      'one per page, scanned against ${files.length} files');

  final failures = <String>[];
  final shared = <_Phrase>[];
  for (final phrase in phrases) {
    final elsewhere = phrase.found.where((f) => f != phrase.page).toList();
    if (elsewhere.isEmpty) continue;

    final leaked = elsewhere.where((f) => !f.endsWith('.html')).toList();
    if (leaked.isNotEmpty) {
      failures.add('${phrase.page}: body text also in ${leaked.join(', ')}');
      continue;
    }
    final related = elsewhere.where((f) => _sameLine(phrase.page, f)).toList();
    if (related.isNotEmpty) {
      failures.add('${phrase.page}: same text on its own '
          'ancestor/descendant ${related.join(', ')}');
      continue;
    }
    shared.add(phrase);
  }

  for (final phrase in shared) {
    final others = phrase.found.where((f) => f != phrase.page).toList();
    final named = others.take(2).join(', ');
    final rest = others.length > 2 ? ' and ${others.length - 2} more' : '';
    stdout.writeln('note    ${phrase.page}: wording also on $named$rest — '
        'unrelated pages, so the canon repeating itself, not the build');
  }

  if (failures.isEmpty) {
    stdout.writeln('\nPASS — no page\'s text is printed anywhere else.');
    return;
  }
  stdout.writeln('');
  for (final failure in failures) {
    stdout.writeln('FAIL — $failure');
  }
  exitCode = 1;
}

class _Phrase {
  _Phrase(this.page, this.text);

  final String page;
  final String text;
  final List<String> found = [];
}

/// Long enough that two pages carrying it is a fact about the build rather
/// than about the language.
const int _minRunChars = 70;

final RegExp _paragraph = RegExp('<p class="e-paragraph">(.*?)</p>');
final RegExp _tag = RegExp('<[^>]*>');

/// The page's longest run of body text with no markup and no entity inside it,
/// so the sampled string is also the page's literal bytes.
///
/// The longest rather than the first: a page's first paragraph is usually the
/// opening formula every sutta shares, which says nothing about this build.
String? _longestRun(String html) {
  String? longest;
  for (final paragraph in _paragraph.allMatches(html)) {
    for (final run in paragraph.group(1)!.split(_tag)) {
      final text = run.trim();
      if (text.contains('&')) continue;
      if (text.length >= _minRunChars && text.length > (longest?.length ?? 0)) {
        longest = text;
      }
    }
  }
  return longest?.substring(0, _minRunChars);
}

/// True when one page sits above the other in the tree — `an-1-1` and
/// `an-1-1-3` — which is the pair that may never share text.
bool _sameLine(String a, String b) {
  final one = _key(a);
  final other = _key(b);
  return one.startsWith('$other-') || other.startsWith('$one-');
}

String _key(String path) =>
    path.split('/').last.replaceAll(RegExp(r'\.html$'), '');
