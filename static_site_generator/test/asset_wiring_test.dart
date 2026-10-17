/// Backlog C1 end to end: runs the real generator over two subtrees and checks
/// every asset link against the bytes written beside it.
///
/// `/assets/*` and `/fonts/*` are cached `immutable` for a year
/// (`site_headers.dart`). A link with a missing or stale `?v=` leaves readers
/// on the old file for that year, no purge reaches their disk, and the build,
/// the link checker and the page all still look right.
@Tags(['corpus'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:static_site_generator/domain/theme_tokens.dart';
import 'package:static_site_generator/render/site_assets.dart';
import 'package:static_site_generator/render/site_headers.dart';
import 'package:static_site_generator/render/web_fonts.dart';
import 'package:test/test.dart';

import 'support/asset_contract.dart';

/// A canon root and its commentary: sutta, chapter and TOC pages in under a
/// second.
const String _roots = 'kn-khp,atta-kn-khp';

void main() {
  late Directory out;

  setUpAll(() {
    out = Directory.systemTemp.createTempSync('asset_wiring_');
    final result = Process.runSync(
      // The Dart running this test, as in corpus_tools_test.dart.
      Platform.resolvedExecutable,
      ['run', 'bin/generate.dart', '--root', _roots, '--out', out.path],
    );
    if (result.exitCode != 0) {
      fail('The generator failed. Run `dart test` from the '
          'static_site_generator/ package root.\n'
          '${result.stdout}${result.stderr}');
    }
  });

  tearDownAll(() => out.deleteSync(recursive: true));

  test('every asset link is the URL its own bytes give', () {
    final expected = SiteAssets.forContent(
      css: _text(out, stylesheetOutputPath),
      script: _text(out, siteScriptOutputPath),
      searchIndex: _text(out, searchIndexOutputPath),
      emblem: _bytes(out, emblemOutputPath),
      ogCard: _bytes(out, ogCardOutputPath),
      favicon: _bytes(out, faviconOutputPath),
    );
    // In webFontFaces order, skipping a missing face, as the generator does.
    final faces = [
      for (final face in webFontFaces(_themeTokens()))
        if (File('${out.path}/$fontsOutputDir/${face.relativePath}')
            .existsSync())
          '$fontsOutputDir/${face.relativePath}',
    ];
    final fontToken =
        fontsVersion([for (final face in faces) _bytes(out, face)]);
    final valid = {
      ...assetUrls(expected).values,
      for (final face in faces) '/$face?v=$fontToken',
    };

    final linked = {
      for (final file in out.listSync(recursive: true).whereType<File>())
        if (file.path.endsWith('.html') || file.path.endsWith('.css'))
          ...assetLinksIn(file.readAsStringSync()),
    };

    // Guards against a scan that finds nothing and so passes.
    expect(linked, containsAll([expected.stylesheet, expected.script]));
    expect(linked.where((link) => link.startsWith('/$fontsOutputDir/')),
        isNotEmpty);
    expect(linked.difference(valid), isEmpty,
        reason: 'These links are not the URL SiteAssets derives from the '
            'bytes written beside them: no ?v=, or one for other bytes. The '
            'immutable rule caches them for a year either way.');
  });

  test('every _headers path rule names something the build wrote', () {
    final rules = parseHeaderRules(_text(out, siteHeadersOutputPath));
    expect(rules, isNotEmpty);
    for (final rule in rules) {
      // A host rule names a host, not a file.
      if (!rule.pattern.startsWith('/')) continue;
      if (rule.pattern.endsWith('/*')) {
        final directory = Directory(
            '${out.path}${rule.pattern.substring(0, rule.pattern.length - 2)}');
        expect(
            directory.existsSync() && directory.listSync().isNotEmpty, isTrue,
            reason:
                '${rule.pattern} names a directory the build leaves empty.');
      } else {
        expect(File('${out.path}${rule.pattern}').existsSync(), isTrue,
            reason: '${rule.pattern} names a file the build does not write.');
      }
    }
  });
}

String _text(Directory out, String path) =>
    File('${out.path}/$path').readAsStringSync();

List<int> _bytes(Directory out, String path) =>
    File('${out.path}/$path').readAsBytesSync();

ThemeTokens _themeTokens() =>
    ThemeTokens(jsonDecode(File('assets/theme_tokens.json').readAsStringSync())
        as Map<String, dynamic>);
