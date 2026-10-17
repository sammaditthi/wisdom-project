import 'package:static_site_generator/render/site_assets.dart';

/// One rule of a `_headers` file: the URL pattern Pages matches, and the
/// headers it sets, keyed by lower-cased name.
typedef HeaderRule = ({String pattern, Map<String, String> headers});

/// Reads a `_headers` file the way Pages does: a pattern at column zero, its
/// headers indented below it, `#` lines and blank lines ignored.
List<HeaderRule> parseHeaderRules(String file) {
  final rules = <HeaderRule>[];
  for (final line in file.split('\n')) {
    if (line.trim().isEmpty || line.trimLeft().startsWith('#')) continue;
    if (!line.startsWith(' ')) {
      rules.add((pattern: line.trim(), headers: <String, String>{}));
      continue;
    }
    final colon = line.indexOf(':');
    if (rules.isEmpty || colon < 0) {
      throw FormatException('Not a header under a pattern: "$line"');
    }
    rules.last.headers[line.substring(0, colon).trim().toLowerCase()] =
        line.substring(colon + 1).trim();
  }
  return rules;
}

/// Every URL [assets] holds, by field name.
Map<String, String> assetUrls(SiteAssets assets) => {
      'stylesheet': assets.stylesheet,
      'script': assets.script,
      'searchIndex': assets.searchIndex,
      for (final (i, url) in assets.emblems.indexed) 'emblems[$i]': url,
      'ogCard': assets.ogCard,
      'favicon': assets.favicon,
    };

/// The path of every `/assets/` or `/fonts/` link in [source], query included,
/// origin dropped, in document order. Only text right after a quote, a `(` or
/// a `srcset`'s `, ` counts, so a comment that names
/// `static_site_generator/assets/` is not a link. A stylesheet's `../fonts/…` comes back as `/fonts/…`: `site.css`
/// sits one level down, in `assets/`.
Iterable<String> assetLinksIn(String source) => _assetLink
    .allMatches(source)
    .map((match) => match.group(1)!)
    .map((link) => link.startsWith('../') ? link.substring(2) : link);

final RegExp _assetLink = RegExp(
    r'''(?:["'(]|, )(?:https?://[^/"']+)?((?:\.\.)?/(?:assets|fonts)/[^"'()<>\s]+)''');
