import 'dart:convert';
import 'dart:io';

import 'src/cdp.dart';
import 'src/cli.dart';

/// Runs the four by-hand release checks that only a browser can answer:
/// JavaScript off, webfonts off, Back/Forward across `#anchors`, and the
/// breadcrumb and toolbar from every page shape. Exits 1 on any failure.
///
/// Serves the build and drives headless Chrome itself, so it is one command:
///
///     dart run static_site_generator/tool/check_in_browser.dart
///     dart run static_site_generator/tool/check_in_browser.dart --shots /tmp/s
///     dart run static_site_generator/tool/check_in_browser.dart --checks 5
///
/// It asks the page through CDP's DOM and CSS domains, never through injected
/// script, because what half of it checks is the page with script execution
/// off. The pages it uses are found in the build by shape rather than named,
/// so an upstream re-sync that moves node keys does not silently narrow it to
/// nothing — a shape it cannot find is a failure.
Future<void> main(List<String> args) async {
  final options = parseArgs(args, const {
    '--build',
    '--origin',
    '--port',
    '--chrome',
    '--shots',
    '--checks',
  });
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

  final shapes = _discover(rootPath);
  if (shapes == null) {
    stdout.writeln('\nFAIL — could not find one page of every shape in the '
        'build, so there was nothing to check. Treated as a failure.');
    exitCode = 1;
    return;
  }
  stdout.writeln('pages   leaf ${shapes.leaf}, chapter ${shapes.chapter}, '
      'container ${shapes.containerToc}, top ${shapes.topToc}');

  if (options['--shots'] != null) {
    shots = Directory(options['--shots']!)..createSync(recursive: true);
  }
  final wanted = (options['--checks'] ?? '3,4,5,6')
      .split(',')
      .map((check) => check.trim())
      .toSet();

  Process? server;
  Process? chrome;
  Directory? profile;
  try {
    if (options['--origin'] != null) {
      origin = options['--origin']!;
    } else {
      final port = int.tryParse(options['--port'] ?? '8084');
      if (port == null) {
        stderr.writeln('--port needs a number.');
        exitCode = 1;
        return;
      }
      origin = 'http://localhost:$port';
      server = await _serve(rootPath, port);
    }
    stdout.writeln('origin  $origin');

    profile = Directory.systemTemp.createTempSync('wisdom-check-chrome');
    final chromePath = options['--chrome'] ?? _findChrome();
    if (chromePath == null) {
      stderr.writeln('no Chrome found. Pass --chrome <path> or set '
          'CHROME_PATH.');
      exitCode = 1;
      return;
    }
    chrome = await Process.start(chromePath, [
      '--headless=new',
      '--remote-debugging-port=0',
      '--user-data-dir=${profile.path}',
      '--window-size=${wide.w},${wide.h}',
      '--hide-scrollbars',
      '--force-device-scale-factor=1',
      '--no-first-run',
      '--no-default-browser-check',
      '--disable-extensions',
      'about:blank',
    ]);
    _connection = await Cdp.connect(await _pageEndpoint(profile));

    await cdp.call('Page.enable');
    await cdp.call('DOM.enable');
    await cdp.call('CSS.enable');
    await cdp.call('Network.enable');
    await setViewport(wide.w, wide.h);

    if (wanted.contains('3')) await _checkScriptOff(shapes);
    if (wanted.contains('4')) await _checkWebfontOff(shapes);
    if (wanted.contains('5')) await _checkAnchorHistory(shapes);
    if (wanted.contains('6')) await _checkPageShapes(shapes);
  } finally {
    await _connection?.close();
    chrome?.kill();
    server?.kill();
    _http.close(force: true);
    // Chrome may still be letting go of its profile; the directory is the
    // system's temp either way.
    try {
      profile?.deleteSync(recursive: true);
    } on FileSystemException {
      // left for the system to sweep
    }
  }

  stdout.writeln('');
  if (_failed.isEmpty) {
    stdout.writeln('PASS — the site behaves with script off, with webfonts '
        'off, across history, and from every page shape.');
    return;
  }
  for (final failure in _failed) {
    stdout.writeln('FAIL — $failure');
  }
  exitCode = 1;
}

// --- the checks -------------------------------------------------------------

/// JS off: every page still renders, navigates and switches layout, and the
/// search button never appears.
Future<void> _checkScriptOff(_Shapes shapes) async {
  stdout.writeln('\n3. script execution off');
  await cdp.call('Emulation.setScriptExecutionDisabled', {'value': true});

  for (final shape in {...shapes.all, 'landing': '/'}.entries) {
    await go(shape.value);
    final main = await query('main.content');
    final tall = main == null ? 0.0 : await heightOf(main);
    final links = await queryAll('main.content a[href^="/"]');
    _expect(
        main != null && tall > 200 && links.isNotEmpty,
        '${shape.key} renders with script off',
        'main ${tall}px, ${links.length} internal links');

    // site.js is the only thing that unhides the search button, so a button
    // still hidden is also the proof that no script ran.
    final trigger = await query('#search-open');
    if (trigger != null) {
      final hidden = (await attributesOf(trigger)).containsKey('hidden');
      _expect(hidden && await displayOf(trigger) == 'none',
          '${shape.key}: search button never appears', 'hidden=$hidden');
    }
  }

  // The layout switcher is four CSS radios, so clicking a label is the whole
  // mechanism. `.pali` and `.si` either hide or do not.
  await go(shapes.chapter);
  const expected = {
    'L-si': ('none', 'block'),
    'L-pali': ('block', 'none'),
    'L-sbs': ('block', 'block'),
  };
  for (final layout in expected.entries) {
    final label = await query('label[for="${layout.key}"]');
    if (label == null) {
      _fail('layout ${layout.key}: no label to click');
      continue;
    }
    await click(label);
    await _settleStyles();
    final pali = await query('.sutta .row .pali');
    final si = await query('.sutta .row .si');
    final paliShown = pali == null ? 'missing' : await displayOf(pali);
    final siShown = si == null ? 'missing' : await displayOf(si);
    _expect(
        paliShown == layout.value.$1 && siShown == layout.value.$2,
        'layout ${layout.key} applies with script off',
        '.pali=$paliShown .si=$siShown');
    await shot('script-off-${layout.key}');
  }

  // Navigation, by real clicks: the breadcrumb on a wide screen…
  await go(shapes.leaf);
  final crumbs = await queryAll('nav.breadcrumb a[href^="/tipitaka/"]');
  if (crumbs.isEmpty) {
    _fail('the leaf page carries no breadcrumb link to click');
  } else {
    final parent = (await attributesOf(crumbs.last))['href'];
    await clickAndWait(crumbs.last);
    _expect(await currentUrl() == '$origin$parent',
        'breadcrumb link navigates with script off', await currentUrl());
  }

  // …and the up button, which the stylesheet shows at phone width only.
  await setViewport(phone.w, phone.h);
  await go(shapes.leaf);
  final up = await query('a.up');
  if (up == null) {
    _fail('no up button at phone width');
  } else {
    final parent = (await attributesOf(up))['href'];
    await clickAndWait(up);
    _expect(await currentUrl() == '$origin$parent',
        'up button navigates with script off', await currentUrl());
  }
  await shot('script-off-phone');
  await setViewport(wide.w, wide.h);

  await cdp.call('Emulation.setScriptExecutionDisabled', {'value': false});
}

/// Webfont off: system Sinhala is readable.
Future<void> _checkWebfontOff(_Shapes shapes) async {
  stdout.writeln('\n4. webfonts off');
  await cdp.call('Network.setCacheDisabled', {'cacheDisabled': true});

  await cdp.call('Network.setBlockedURLs', {'urls': <String>[]});
  await go(shapes.leaf);
  final withFonts = await _fontsUsed('.sutta .row .pali p');
  stdout.writeln('   on   ${_describe(withFonts)}');
  _expect(withFonts.keys.any((font) => font.endsWith(_webfontMark)),
      'the self-hosted face is what renders normally', _describe(withFonts));

  await cdp.call('Network.setBlockedURLs', {
    'urls': ['*.woff2', '*.woff', '*/fonts/*'],
  });
  await go(shapes.leaf);
  final pali = await _fontsUsed('.sutta .row .pali p');
  final sinhala = await _fontsUsed('.sutta .row .si p');
  final crumb = await _fontsUsed('nav.breadcrumb span.leaf', take: 1);
  stdout.writeln('   off  pali ${_describe(pali)}');
  stdout.writeln('   off  si   ${_describe(sinhala)}');
  stdout.writeln('   off  ui   ${_describe(crumb)}');
  await shot('webfonts-off');

  _expect(
      !pali.keys.any((font) => font.endsWith(_webfontMark)) &&
          !sinhala.keys.any((font) => font.endsWith(_webfontMark)),
      'no self-hosted face survives the block',
      '${_describe(pali)} | ${_describe(sinhala)}');

  for (final column in {'pali': pali, 'si': sinhala, 'ui': crumb}.entries) {
    // `ui` is one breadcrumb crumb, so it paints a handful of glyphs where a
    // paragraph paints dozens.
    final least = column.key == 'ui' ? 8 : 20;
    _expect(
        _readsSinhala(column.value, least) && !_tofu(column.value),
        '${column.key} falls back to a system Sinhala face',
        _describe(column.value));
  }

  final body = await query('body');
  _expect(body != null && await heightOf(body) > 500,
      'the page still lays out with no webfont', 'body height');

  await setViewport(phone.w, phone.h);
  await go(shapes.leaf);
  final onPhone = await _fontsUsed('.sutta .row .si p');
  _expect(_readsSinhala(onPhone, 20) && !_tofu(onPhone),
      'phone width falls back the same way', _describe(onPhone));
  await shot('webfonts-off-phone');
  await setViewport(wide.w, wide.h);

  await cdp.call('Network.setBlockedURLs', {'urls': <String>[]});
  await cdp.call('Network.setCacheDisabled', {'cacheDisabled': false});
}

/// Back/Forward across `#anchors`: the `:has(:target)` filter re-evaluates.
Future<void> _checkAnchorHistory(_Shapes shapes) async {
  stdout.writeln('\n5. Back/Forward across #anchors');
  await go(shapes.chapter);

  final ids = <String>[];
  for (final section in await queryAll('section.sutta')) {
    final id = (await attributesOf(section))['id'];
    if (id != null) ids.add(id);
  }
  if (ids.length < 3) {
    _fail('the chapter page has fewer than three sections to filter between');
    return;
  }
  final first = ids.first;
  final third = ids[2];

  Future<List<String>> shown() async {
    final visible = <String>[];
    for (final section in await queryAll('section.sutta')) {
      if (await displayOf(section) != 'none') {
        visible.add((await attributesOf(section))['id'] ?? '?');
      }
    }
    return visible;
  }

  Future<bool> barShown() async {
    final bar = await query('.chapter-bar');
    return bar != null && await displayOf(bar) != 'none';
  }

  _expect((await shown()).length == ids.length,
      'the bare URL shows the whole run', '${(await shown()).length}');
  _expect(!await barShown(), 'no chapter bar on the bare URL');

  await go('${shapes.chapter}#$first');
  _expect((await shown()).join(',') == first, 'the first anchor filters to it',
      '${await shown()}');
  _expect(await barShown(), 'the chapter bar appears in the filtered view');
  await shot('anchor-first');

  await go('${shapes.chapter}#$third');
  _expect((await shown()).join(',') == third, 'the third anchor filters to it',
      '${await shown()}');

  await history(-1);
  _expect((await shown()).join(',') == first, 'Back re-evaluates the filter',
      '${await shown()}');

  await history(-1);
  _expect((await shown()).length == ids.length,
      'Back again re-evaluates to the whole run', '${(await shown()).length}');
  _expect(!await barShown(), 'the chapter bar goes away again');

  await history(1);
  _expect((await shown()).join(',') == first, 'Forward re-evaluates the filter',
      '${await shown()}');

  await history(1);
  _expect((await shown()).join(',') == third,
      'Forward again re-evaluates the filter', '${await shown()}');
  await shot('anchor-forward');

  // The pager swap rides on the same gate: filtered, the page's own pager
  // gives way to the targeted section's.
  final pagePager = await query('.chapter ~ .pager');
  if (pagePager != null) {
    _expect(await displayOf(pagePager) == 'none',
        "the page's own pager hides in the filtered view");
  }
}

/// From every page shape, the breadcrumb climbs and the toolbar reaches home.
Future<void> _checkPageShapes(_Shapes shapes) async {
  stdout.writeln('\n6. page shapes');
  await cdp.call('Emulation.setScriptExecutionDisabled', {'value': true});

  for (final shape in {...shapes.all, 'landing': '/'}.entries) {
    await go(shape.value);
    final home = await query('nav.breadcrumb a.home');
    final crumbNodes = await queryAll('nav.breadcrumb a[href^="/tipitaka/"]');
    final crumbs = [
      for (final node in crumbNodes) (await attributesOf(node))['href']!,
    ];

    if (shape.value == '/') {
      // The emblem is the brand mark and points here from here; what the
      // landing shape promises is that there is nothing above it to climb.
      final emblem = home == null ? null : (await attributesOf(home))['href'];
      _expect(crumbs.isEmpty && await query('a.up') == null && emblem == '/',
          'landing has nothing above it', 'crumbs=$crumbs emblem=$emblem');
      _expect((await queryAll('main a[href^="/tipitaka/"]')).isNotEmpty,
          'landing links into the corpus');
      await shot('shape-landing');
      continue;
    }

    _expect(home != null, '${shape.key}: breadcrumb starts at home');
    _expect(await query('nav.breadcrumb span.leaf') != null,
        '${shape.key}: breadcrumb ends in this page, not a link');

    // Each crumb is really the parent of the next: the page it names has to
    // link to the one below it, or the trail is decoration.
    var climbs = true;
    var why = '';
    for (var i = 0; i < crumbs.length && climbs; i++) {
      final page = await _fetch(crumbs[i]);
      final next = i + 1 < crumbs.length ? crumbs[i + 1] : shape.value;
      if (page.status != 200) {
        climbs = false;
        why = '${crumbs[i]} answered ${page.status}';
      } else if (!page.body.contains('href="$next"')) {
        climbs = false;
        why = '${crumbs[i]} does not link to $next';
      }
    }
    _expect(
        climbs, '${shape.key}: breadcrumb climbs a real ancestor chain', why);

    final up = await query('a.up');
    final upHref = up == null ? null : (await attributesOf(up))['href'];
    final parent = crumbs.isEmpty ? null : crumbs.last;
    _expect(upHref == parent, '${shape.key}: up button points at the parent',
        'up=$upHref parent=$parent');

    if (crumbNodes.isNotEmpty) {
      final target = (await attributesOf(crumbNodes.last))['href'];
      await clickAndWait(crumbNodes.last);
      _expect(await currentUrl() == '$origin$target',
          '${shape.key}: the deepest crumb is clickable', await currentUrl());
    }
    await shot('shape-${shape.key}');

    // The up button is the phone path home, so climb it at phone width.
    await setViewport(phone.w, phone.h);
    await go(shape.value);
    var steps = 0;
    while (steps < _maxClimb) {
      final step = await query('a.up');
      if (step == null) break;
      await clickAndWait(step);
      steps++;
      if (await currentUrl() == '$origin/') break;
    }
    if (await currentUrl() != '$origin/') {
      // The top of the corpus has no parent; the emblem is its way home.
      final emblem = await query('nav.breadcrumb a.home');
      if (emblem != null) {
        await clickAndWait(emblem);
        steps++;
      }
    }
    _expect(
        await currentUrl() == '$origin/',
        '${shape.key}: the toolbar reaches home in $steps step(s)',
        await currentUrl());
    await setViewport(wide.w, wide.h);
  }

  await cdp.call('Emulation.setScriptExecutionDisabled', {'value': false});
}

// --- what the build offers --------------------------------------------------

typedef _Shapes = ({
  String leaf,
  String chapter,
  String containerToc,
  String topToc,
});

extension on _Shapes {
  /// Every shape but the landing page, which has no node key.
  Map<String, String> get all => {
        'sutta leaf': leaf,
        'grouped chapter': chapter,
        'container TOC': containerToc,
        'top TOC': topToc,
      };
}

/// Finds one page of every shape by reading the build, so no node key is
/// written down here to go stale when upstream moves one.
_Shapes? _discover(String rootPath) {
  final dir = Directory('$rootPath/tipitaka');
  if (!dir.existsSync()) return null;
  final pages = dir
      .listSync()
      .whereType<File>()
      .map((file) => file.path.split(Platform.pathSeparator).last)
      .where((name) => name.endsWith('.html'))
      .toList()
    ..sort();

  String? leaf, chapter, containerToc, topToc;
  for (final page in pages) {
    if (leaf != null &&
        chapter != null &&
        containerToc != null &&
        topToc != null) {
      break;
    }
    final html = File('$rootPath/tipitaka/$page').readAsStringSync();
    final sections = '<section class="sutta"'.allMatches(html).length;
    final navEnd = html.indexOf('</nav>');
    final crumbs = navEnd == -1
        ? 0
        : '<a href="/tipitaka/'.allMatches(html.substring(0, navEnd)).length;
    final url = '/tipitaka/${page.substring(0, page.length - 5)}';

    // A list of children is what makes a page a TOC. Counting sections alone
    // is not enough: a reading page whose single unit is not wrapped in a
    // `.sutta` has none either, and reads as a TOC to any test that only
    // counts.
    final isToc = html.contains('<ul class="toc">');
    if (sections >= 3) {
      chapter ??= url;
    } else if (sections == 1 && crumbs >= 3) {
      leaf ??= url;
    } else if (isToc && crumbs >= 1) {
      containerToc ??= url;
    } else if (isToc && crumbs == 0) {
      topToc ??= url;
    }
  }
  if (leaf == null ||
      chapter == null ||
      containerToc == null ||
      topToc == null) {
    return null;
  }
  return (
    leaf: leaf,
    chapter: chapter,
    containerToc: containerToc,
    topToc: topToc,
  );
}

// --- processes --------------------------------------------------------------

Future<Process> _serve(String rootPath, int port) async {
  final server = await Process.start(Platform.resolvedExecutable, [
    'run',
    '$packageRoot/tool/serve.dart',
    '--dir',
    rootPath,
    '--port',
    '$port',
  ]);
  // The port is the handshake: poll until it answers rather than sleeping.
  for (var attempt = 0; attempt < 60; attempt++) {
    try {
      final request = await _http.getUrl(Uri.parse('http://localhost:$port/'));
      await (await request.close()).drain<void>();
      return server;
    } on SocketException {
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
  }
  throw StateError('serve.dart never answered on port $port');
}

String? _findChrome() {
  final candidates = [
    if (Platform.environment['CHROME_PATH'] != null)
      Platform.environment['CHROME_PATH']!,
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    '/Applications/Chromium.app/Contents/MacOS/Chromium',
    '/usr/bin/google-chrome',
    '/usr/bin/chromium',
    r'C:\Program Files\Google\Chrome\Application\chrome.exe',
  ];
  for (final candidate in candidates) {
    if (File(candidate).existsSync()) return candidate;
  }
  return null;
}

/// Chrome writes the debugging port it actually took into the profile, which
/// is why it is started with `--remote-debugging-port=0`: a fixed port is one
/// stale Chrome away from connecting to the wrong browser.
Future<String> _pageEndpoint(Directory profile) async {
  final portFile = File('${profile.path}/DevToolsActivePort');
  for (var attempt = 0; attempt < 60; attempt++) {
    if (portFile.existsSync()) {
      final port = portFile.readAsLinesSync().first;
      final request =
          await _http.getUrl(Uri.parse('http://127.0.0.1:$port/json/list'));
      final body = await (await request.close()).transform(utf8.decoder).join();
      final targets = (jsonDecode(body) as List).cast<Map<String, dynamic>>();
      for (final target in targets) {
        if (target['type'] == 'page') {
          return target['webSocketDebuggerUrl'] as String;
        }
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
  throw StateError('Chrome never opened a debuggable page');
}

// --- CDP helpers ------------------------------------------------------------

Cdp? _connection;
Cdp get cdp => _connection!;

late String origin;
Directory? shots;

const wide = (w: 1280, h: 900);

/// Below the stylesheet's 31rem breakpoint, where the crumbs collapse and the
/// up button is the way up.
const phone = (w: 390, h: 844);

/// A breadcrumb has one level per tree depth, and the corpus is nowhere near
/// this deep — a climb that needs more steps is a loop, not a trail.
const int _maxClimb = 12;

const String _webfontMark = ' [self-hosted]';

final HttpClient _http = HttpClient();
final List<String> _failed = [];

void _expect(bool held, String what, [String detail = '']) {
  if (held) {
    stdout.writeln('   ok   $what');
  } else {
    _fail(detail.isEmpty ? what : '$what — $detail');
  }
}

void _fail(String what) {
  stdout.writeln('   FAIL $what');
  _failed.add(what);
}

int? _root;

/// Cached per navigation: a second `DOM.getDocument` invalidates every node id
/// handed out before it, and a node held across two queries then vanishes.
Future<int> documentRoot() async {
  if (_root != null) return _root!;
  final result = await cdp.call('DOM.getDocument', {'depth': 0});
  return _root = (result['root'] as Map)['nodeId'] as int;
}

Future<int?> query(String selector) async {
  final result = await cdp.call('DOM.querySelector',
      {'nodeId': await documentRoot(), 'selector': selector});
  final nodeId = result['nodeId'] as int;
  return nodeId == 0 ? null : nodeId;
}

Future<List<int>> queryAll(String selector) async {
  final result = await cdp.call('DOM.querySelectorAll',
      {'nodeId': await documentRoot(), 'selector': selector});
  return (result['nodeIds'] as List).cast<int>();
}

Future<String> displayOf(int nodeId) async {
  final result =
      await cdp.call('CSS.getComputedStyleForNode', {'nodeId': nodeId});
  for (final property in (result['computedStyle'] as List).cast<Map>()) {
    if (property['name'] == 'display') return property['value'] as String;
  }
  return 'unknown';
}

Future<Map<String, String>> attributesOf(int nodeId) async {
  final result = await cdp.call('DOM.getAttributes', {'nodeId': nodeId});
  final flat = (result['attributes'] as List).cast<String>();
  return {
    for (var i = 0; i + 1 < flat.length; i += 2) flat[i]: flat[i + 1],
  };
}

Future<double> heightOf(int nodeId) async {
  final box = await _boxOf(nodeId);
  return box == null ? 0 : (box['height'] as num).toDouble();
}

Future<Map<String, dynamic>?> _boxOf(int nodeId) async {
  try {
    final result = await cdp.call('DOM.getBoxModel', {'nodeId': nodeId});
    return (result['model'] as Map).cast<String, dynamic>();
  } on StateError {
    return null; // not rendered
  }
}

/// A real mouse press, so a label checks its radio and a link navigates with
/// no script taking any part in it.
Future<void> click(int nodeId) async {
  final box = await _boxOf(nodeId);
  if (box == null) throw StateError('nothing to click at node $nodeId');
  final quad = (box['content'] as List).cast<num>();
  final x = (quad[0] + quad[2]) / 2;
  final y = (quad[1] + quad[5]) / 2;
  for (final type in ['mousePressed', 'mouseReleased']) {
    await cdp.call('Input.dispatchMouseEvent', {
      'type': type,
      'x': x,
      'y': y,
      'button': 'left',
      'buttons': type == 'mousePressed' ? 1 : 0,
      'clickCount': 1,
    });
  }
}

Future<void> clickAndWait(int nodeId) async {
  final navigated = cdp.waitFor(_navigation);
  await click(nodeId);
  await navigated;
  _root = null;
  await _settleStyles();
}

Future<void> go(String path) async {
  final navigated = cdp.waitFor(_navigation);
  await cdp.call('Page.navigate', {'url': '$origin$path'});
  await navigated;
  _root = null;
  await _settleStyles();
}

Future<void> history(int delta) async {
  final result = await cdp.call('Page.getNavigationHistory');
  final entries = (result['entries'] as List).cast<Map>();
  final entry = entries[(result['currentIndex'] as int) + delta];
  final navigated = cdp.waitFor(_navigation);
  await cdp.call('Page.navigateToHistoryEntry', {'entryId': entry['id']});
  await navigated;
  _root = null;
  await _settleStyles();
}

/// A fragment-only change is a same-document navigation and fires no load
/// event, so both are waited on.
const Set<String> _navigation = {
  'Page.loadEventFired',
  'Page.navigatedWithinDocument',
};

Future<void> _settleStyles() =>
    Future<void>.delayed(const Duration(milliseconds: 150));

Future<String> currentUrl() async {
  final result = await cdp.call('Page.getNavigationHistory');
  final entries = (result['entries'] as List).cast<Map>();
  return entries[result['currentIndex'] as int]['url'] as String;
}

Future<void> setViewport(int width, int height) =>
    cdp.call('Emulation.setDeviceMetricsOverride', {
      'width': width,
      'height': height,
      'deviceScaleFactor': 1,
      'mobile': width < 500,
    });

Future<void> shot(String name) async {
  if (shots == null) return;
  final result = await cdp.call('Page.captureScreenshot', {'format': 'png'});
  File('${shots!.path}/$name.png')
      .writeAsBytesSync(base64Decode(result['data'] as String));
}

/// Every platform font that actually painted the first [take] matches of
/// [selector], and how many glyphs each drew.
///
/// Several nodes, because one is not evidence: a page's first Pali paragraph
/// can be a numbered line that a Latin face covers on its own, which says
/// nothing about the Sinhala below it.
Future<Map<String, int>> _fontsUsed(String selector, {int take = 6}) async {
  final totals = <String, int>{};
  for (final node in (await queryAll(selector)).take(take)) {
    final result =
        await cdp.call('CSS.getPlatformFontsForNode', {'nodeId': node});
    for (final font in (result['fonts'] as List).cast<Map>()) {
      final name = font['familyName'] as String;
      final key = font['isCustomFont'] == true ? '$name$_webfontMark' : name;
      totals[key] =
          (totals[key] ?? 0) + ((font['glyphCount'] as num?)?.toInt() ?? 0);
    }
  }
  return totals;
}

String _describe(Map<String, int> fonts) => fonts.isEmpty
    ? 'nothing painted'
    : fonts.entries.map((f) => '${f.key} ${f.value}').join(', ');

bool _readsSinhala(Map<String, int> fonts, int least) => fonts.entries.any(
      (font) =>
          font.value >= least &&
          (font.key.contains('Sinhala') || font.key.contains('Iskoola')),
    );

bool _tofu(Map<String, int> fonts) => fonts.keys.any((font) =>
    font.contains('LastResort') ||
    font.contains('Apple Symbols') ||
    font.trim().isEmpty);

Future<({int status, String body})> _fetch(String path) async {
  final request = await _http.getUrl(Uri.parse('$origin$path'));
  final response = await request.close();
  return (
    status: response.statusCode,
    body: await response.transform(utf8.decoder).join(),
  );
}
