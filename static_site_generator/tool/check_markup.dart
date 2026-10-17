import 'dart:io';
import 'dart:isolate';

import 'package:html/parser.dart';

/// Parses every built page as a browser does and fails on any HTML5 parse
/// error: an unclosed or misnested element, a stray end tag, a duplicate
/// attribute, a `<head>` closed early by something that does not belong in it.
/// Exits 1 on any error, so it can gate a deploy (backlog C9).
///
/// A parser, not a full validator: content-model and attribute rules (which
/// child each element allows, ARIA, `alt`) are vnu's job and not checked here.
///
///     dart run static_site_generator/tool/check_markup.dart
///     dart run static_site_generator/tool/check_markup.dart --build <dir>
Future<void> main(List<String> args) async {
  final options = _parseArgs(args);
  if (options == null) {
    exitCode = 1;
    return;
  }

  final rootPath = _normalize(options.build ?? '$_packageRoot/build');
  if (!Directory(rootPath).existsSync()) {
    stderr.writeln('no build directory at $rootPath. Generate one first, or '
        'pass --build <dir>.');
    exitCode = 1;
    return;
  }
  stdout.writeln('build   $rootPath');

  final pages = Directory(rootPath)
      .listSync(recursive: true)
      .whereType<File>()
      .map((f) => f.path.substring(rootPath.length + 1))
      .where((p) => p.endsWith('.html'))
      .toList()
    ..sort();

  // Round-robin, so each worker gets a share of the corpus's few huge pages.
  final workers =
      Platform.numberOfProcessors.clamp(1, pages.length.clamp(1, 64));
  final shares = [
    for (var w = 0; w < workers; w++)
      [for (var i = w; i < pages.length; i += workers) pages[i]],
  ];
  final found = await Future.wait(
      shares.map((share) => Isolate.run(() => _parse(rootPath, share))));

  // Message → every page it occurs on, first location kept per page.
  final byMessage = <String, Map<String, String>>{};
  for (final error in found.expand((e) => e)) {
    byMessage
        .putIfAbsent(error.message, () => {})
        .putIfAbsent(error.page, () => error.at);
  }

  stdout.writeln('pages   ${pages.length} parsed');
  if (pages.isEmpty) {
    stdout.writeln('\nFAIL — found no .html files at all, so nothing was '
        'checked. Treated as a failure.');
    exitCode = 1;
    return;
  }
  if (byMessage.isEmpty) {
    stdout.writeln('\nPASS — every page parses with no HTML5 parse errors.');
    return;
  }

  // Most widespread first: a template defect is on every page and is the one
  // to read first. Ties by message, so two runs print the same report.
  final messages = byMessage.keys.toList()
    ..sort((a, b) {
      final byCount = byMessage[b]!.length.compareTo(byMessage[a]!.length);
      return byCount != 0 ? byCount : a.compareTo(b);
    });
  for (final message in messages.take(_maxMessagesShown)) {
    final onPages = byMessage[message]!;
    final first = (onPages.keys.toList()..sort()).first;
    stdout.writeln('\n$message');
    stdout.writeln(
        '  on ${onPages.length} page${onPages.length == 1 ? '' : 's'}, '
        'first $first:${onPages[first]}');
  }
  final rest = messages.length - _maxMessagesShown;
  if (rest > 0) stdout.writeln('\n… and $rest more kinds');

  final pagesHit = byMessage.values.expand((p) => p.keys).toSet().length;
  stdout.writeln('\nFAIL — ${messages.length} kinds of parse error, on '
      '$pagesHit of ${pages.length} pages.');
  exitCode = 1;
}

const int _maxMessagesShown = 10;

class _ParseError {
  const _ParseError(this.page, this.at, this.message);
  final String page;
  final String at;
  final String message;
}

List<_ParseError> _parse(String rootPath, List<String> pages) {
  final errors = <_ParseError>[];
  for (final page in pages) {
    final parser = HtmlParser(File('$rootPath/$page').readAsStringSync(),
        generateSpans: true);
    parser.parse();
    for (final error in parser.errors) {
      final start = error.span?.start;
      final at = start == null ? '?' : '${start.line + 1}:${start.column + 1}';
      errors.add(_ParseError(page, at, error.message));
    }
  }
  return errors;
}

/// Read off `Platform.script`, as `check_links.dart` does, so the default
/// build directory is the package's own whatever the working directory.
final String _packageRoot = File.fromUri(Platform.script).parent.parent.path;

/// Null after printing why the arguments were refused. An unknown flag is
/// refused rather than ignored, so a typo cannot pass the gate over the default
/// build.
({String? build})? _parseArgs(List<String> args) {
  String? build;
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg.startsWith('--build=')) {
      build = arg.substring('--build='.length);
    } else if (arg == '--build' && i + 1 < args.length) {
      build = args[++i];
    } else {
      stderr.writeln(arg == '--build'
          ? '--build needs a value.'
          : 'unknown option: $arg\nknown options: --build');
      return null;
    }
  }
  return (build: build);
}

String _normalize(String path) {
  var absolute = Directory(path).absolute.path;
  while (absolute.length > 1 && absolute.endsWith(Platform.pathSeparator)) {
    absolute = absolute.substring(0, absolute.length - 1);
  }
  return absolute;
}
