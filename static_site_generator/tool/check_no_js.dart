import 'dart:io';

import 'src/cli.dart';

/// Fails if any built page would need JavaScript to read or to navigate.
///
/// `check_in_browser.dart` proves a handful of pages behave with script
/// execution off; this proves every other page is built the same way, which no
/// browser run can cover at corpus size. Exits 1 on any finding.
///
///     dart run static_site_generator/tool/check_no_js.dart
///     dart run static_site_generator/tool/check_no_js.dart --build <dir>
Future<void> main(List<String> args) async {
  final options = parseArgs(args, const {'--build'});
  if (options == null) {
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

  final pages = Directory(rootPath)
      .listSync(recursive: true)
      .whereType<File>()
      .map((f) => f.path.substring(rootPath.length + 1))
      .where((p) => p.endsWith('.html'))
      .toList()
    ..sort();
  if (pages.isEmpty) {
    stdout.writeln('\nFAIL — found no .html files at all, so nothing was '
        'checked. Treated as a failure.');
    exitCode = 1;
    return;
  }

  // Finding → the pages carrying it, first few kept for the report.
  final findings = <String, List<String>>{};
  void flag(String what, String page) =>
      findings.putIfAbsent(what, () => []).add(page);

  for (final page in pages) {
    final html = File('$rootPath/$page').readAsStringSync();

    if (_inlineHandler.hasMatch(html)) flag('inline event handler', page);
    if (html.contains('javascript:')) flag('javascript: URL', page);
    if (html.contains('<noscript')) flag('relies on <noscript>', page);
    if (!html.contains('<main')) flag('no <main>', page);

    // An anchor with no destination is a click handler waiting for a script.
    for (final link in _anchor.allMatches(html)) {
      final href = link.group(1)!.trim();
      if (href.isEmpty || href == '#') {
        flag('link with no destination', page);
        break;
      }
    }

    // Only two scripts may ship: the inline layout restorer and site.js.
    // Anything else is a dependency this check exists to refuse.
    for (final tag in _script.allMatches(html).map((m) => m.group(0)!)) {
      if (tag.contains('application/ld+json')) continue;
      if (tag == '<script>') continue;
      if (!tag.contains(_siteScript)) {
        flag('unexpected script tag', page);
      } else {
        if (!tag.contains('defer')) flag('site.js not deferred', page);
        if (!tag.contains('$_siteScript?v=')) flag('site.js without ?v=', page);
      }
    }

    // The search button is the one control that genuinely needs script, so it
    // ships hidden and site.js unhides it. Shipped visible it would be a dead
    // button for every reader without JS.
    final trigger = _searchTrigger.firstMatch(html);
    if (trigger != null && !trigger.group(0)!.contains(' hidden')) {
      flag('search button not hidden', page);
    }

    // Navigation that is not the landing page's own.
    if (page != 'index.html' &&
        page != '404.html' &&
        !html.contains('class="breadcrumb"')) {
      flag('no breadcrumb to navigate by', page);
    }
  }

  stdout.writeln('pages   ${pages.length} checked');
  if (findings.isEmpty) {
    stdout.writeln('\nPASS — no page depends on JavaScript for its text or '
        'its navigation.');
    return;
  }

  stdout.writeln('');
  for (final entry in findings.entries) {
    final where = entry.value.take(3).join(', ');
    final more = entry.value.length > 3 ? ', …' : '';
    stdout.writeln('FAIL — ${entry.key}: ${entry.value.length} page(s)');
    stdout.writeln('       $where$more');
  }
  exitCode = 1;
}

const String _siteScript = '/assets/site.js';

final RegExp _inlineHandler = RegExp(r'\son(?:click|change|input|submit|load|'
    r'mousedown|mouseup|keydown|keyup|focus|blur)\s*=');
final RegExp _anchor = RegExp('<a [^>]*href="([^"]*)"');
final RegExp _script = RegExp('<script[^>]*>');
final RegExp _searchTrigger = RegExp('<button[^>]*id="search-open"[^>]*>');
