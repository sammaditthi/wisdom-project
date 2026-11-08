import 'dart:convert';
import 'dart:io';

/// The repo's one version command. The `version:` line of `pubspec.yaml` is the
/// source; `lib/core/version/app_version.gen.dart` comes from it, and
/// `scripts/deploy.sh` tags the release once every test passes.
///
///     dart run tools/release.dart status
///     dart run tools/release.dart cut major|minor|patch
///     dart run tools/release.dart check
///
/// `scripts/release.sh` is the one you type; it runs `status` or `cut`.
void main(List<String> args) {
  final root = File.fromUri(Platform.script).parent.parent;
  try {
    exit(switch (args.isEmpty ? '' : args.first) {
      'status' => _status(root),
      'cut' => _cut(root, args.length > 1 ? args[1] : ''),
      'check' => _check(root),
      final given => _usage(given),
    });
  } on _Fail catch (failure) {
    stderr.writeln('error: ${failure.message}');
    exit(1);
  }
}

const _pubspecPath = 'pubspec.yaml';
const _generatedPath = 'lib/core/version/app_version.gen.dart';
const _changelogPath = 'CHANGELOG.md';

/// The only paths a release writes, and so the only ones its commit carries.
const _releasePaths = [_pubspecPath, _generatedPath, _changelogPath];

/// Where the notes collect until `cut` dates them (Keep a Changelog).
const _unreleased = '## Unreleased';

/// The newest changelog entry pastes into a store's "What's new" as written:
/// Google Play takes 500 characters. Five notes a group keeps it a summary.
const _maxEntryLength = 500;
const _maxNotesPerGroup = 5;

/// The notes' rules, given to Claude as written so they live in one place.
const _guidePath = 'docs/general/how-to-release.md';

/// Commits no app reader sees, kept from Claude: docs, tests and CI by type,
/// the website and release tooling by scope. It judges the rest (a `refactor`
/// can rename a menu item, a `style` change an icon, a `chore` the app name).
final _unseenCommit =
    RegExp(r'^((docs|test|ci)[(:!]|\w+\((static-site|site|release|ops)\))');

/// How a drifted version file is found: by hand, since it was edited by hand.
const _findHandEdit =
    'git diff, or git log -p -- $_pubspecPath $_generatedPath';

// ============================================
// Commands
// ============================================

int _status(Directory root) {
  final version = _readVersion(_pubspecText(root));
  stdout.writeln('version    $version  → shows as ${_display(version)}');

  final tag = _lastTag(root);
  if (tag == null) {
    stdout.writeln('tag        none yet');
  } else {
    stdout.writeln('tag        $tag at ${_gitOut(root, [
          'rev-parse',
          '--short',
          tag,
        ])}');
    stdout.writeln('commits    ${_gitOut(root, [
          'rev-list',
          '--count',
          '$tag..HEAD',
        ])} since $tag');
  }

  if (_generatedText(root) == _render(version)) {
    stdout.writeln('generated  up to date');
  } else {
    stdout.writeln('generated  DRIFTED — undo the hand edit, then commit. Find '
        'it with\n           $_findHandEdit');
  }
  stdout.writeln(_tagExists(root, 'v${version.name}')
      ? 'next       ./scripts/release.sh patch|minor|major (Claude drafts '
          'the notes\n           under "$_unreleased" if there are none)'
      : 'next       ./scripts/deploy.sh --prod   (v${version.name} is not '
          'tagged yet)');
  return 0;
}

/// Raises the version, dates the `## Unreleased` notes, regenerates, commits.
/// At a terminal it first has Claude draft missing notes and waits for your
/// yes. No tag: `scripts/deploy.sh` makes it once every test passes, so a red
/// test costs no version.
int _cut(Directory root, String part) {
  _requireCleanTree(root);

  final pubspec = _pubspecText(root);
  final before = _readVersion(pubspec);
  final since = 'v${before.name}';
  if (!_tagExists(root, since)) {
    throw _Fail(
      '${before.name} was never released (no tag v${before.name}), and a '
      'second bump would skip it. Release it: ./scripts/deploy.sh --prod',
    );
  }
  final after = switch (part) {
    'major' => _Version(before.major + 1, 0, 0, before.build + 1),
    'minor' => _Version(before.major, before.minor + 1, 0, before.build + 1),
    'patch' => _Version(
        before.major,
        before.minor,
        before.patch + 1,
        before.build + 1,
      ),
    _ => throw _Fail('cut takes major, minor or patch (got "$part").'),
  };
  // Without a terminal (automation) nobody can approve a draft, so the notes
  // must already be written.
  if (_atTerminal()) {
    if (_entryHeading.firstMatch(_changelogText(root))?[0]?.trim() !=
        _unreleased) {
      try {
        _writeDraft(root, since);
      } on _Fail catch (failure) {
        throw _Fail('${failure.message}.\n       Write the notes under '
            '"$_unreleased" in $_changelogPath by hand, then run this again.');
      }
    }
    _review(root, since);
    // It waited on you: anything else edited meanwhile would ride along.
    _requireCleanTree(root);
  }
  final changelog = _changelogText(root);
  final heading = _unreleasedHeading(changelog);
  stdout.writeln('changelog  ${_requireNotes(changelog, heading)}');
  final generated = _generatedText(root);

  final today = DateTime.now().toIso8601String().substring(0, 10);
  final dated = '## ${after.name} - $today';
  final tag = 'v${after.name}';
  try {
    // The one line, rewritten in place: a YAML round-trip would strip the
    // pubspec's comments.
    _pubspecFile(root).writeAsStringSync(
        pubspec.replaceFirst(_versionLine, 'version: $after'));
    stdout.writeln('pubspec    $before → $after');
    _changelogFile(root).writeAsStringSync(
        changelog.replaceRange(heading.start, heading.end, dated));
    stdout.writeln('changelog  $_unreleased → $dated');
    _writeGenerated(root, after);
    // Exactly the release paths, leaving anything else staged alone.
    _run(root, 'git', [
      'commit',
      '-m',
      'chore(release): $tag',
      '--',
      ..._releasePaths,
    ]);
  } catch (_) {
    // A hook or a signing error can refuse the commit. Put all three back, so
    // a re-run starts where this one did and no note is lost.
    _pubspecFile(root).writeAsStringSync(pubspec);
    _changelogFile(root).writeAsStringSync(changelog);
    _generatedFile(root).writeAsStringSync(generated);
    stdout.writeln('undone     the three files are back as they were');
    rethrow;
  }
  stdout.writeln('commit     chore(release): $tag');
  stdout.writeln('next       ./scripts/deploy.sh --prod');
  return 0;
}

/// Fails on a drifted version file, or when the newest `CHANGELOG.md` entry is
/// not this version's (`cut` checked the notes, but they can be edited after).
/// Success ends with the tag name, so `require_release_tree` gets every fact it
/// needs from one VM start. The `tag` label is how the guard finds the line.
int _check(Directory root) {
  final version = _readVersion(_pubspecText(root));
  if (_generatedText(root) != _render(version)) {
    stderr.writeln('error: $_generatedPath does not match pubspec $version.');
    stderr
        .writeln('       The version moves only through ./scripts/release.sh.');
    stderr.writeln('       Undo the hand edit, then commit. Find it with');
    stderr.writeln('       $_findHandEdit');
    return 1;
  }
  stdout.writeln('check      $_generatedPath matches $version');

  final changelog = _changelogText(root);
  final heading = _entryHeading.firstMatch(changelog);
  if (heading == null || !heading[0]!.startsWith('## ${version.name} - ')) {
    throw _Fail(
      '$_changelogPath has no "## ${version.name} - <date>" entry on top'
      '${_newest(heading)}. Notes under "$_unreleased" get their version '
      'from ./scripts/release.sh.',
    );
  }
  stdout.writeln('changelog  ${_requireNotes(changelog, heading)}');
  stdout.writeln('tag        v${version.name}');
  return 0;
}

int _usage(String given) {
  if (given.isNotEmpty) stderr.writeln('unknown command: $given\n');
  stderr.writeln('''
usage: dart run tools/release.dart <command>   (you type ./scripts/release.sh)

  status   the version, the last tag, the commits since it, and what's next
  cut      major | minor | patch — raises that part and the build by one,
           dates the "$_unreleased" notes in $_changelogPath, commits.
           At a terminal, Claude drafts missing notes and asks you first.
           No tag: ./scripts/deploy.sh --prod tags once every test passes
  check    exit 1 if $_generatedPath drifted or $_changelogPath has no
           valid entry for this version; else print the tag''');
  return 1;
}

// ============================================
// The version
// ============================================

/// `1.4.0+128`. Three parts are not optional — pub rejects `1.4+128` — and the
/// build number is what both stores compare on upload.
class _Version {
  const _Version(this.major, this.minor, this.patch, this.build);

  final int major;
  final int minor;
  final int patch;
  final int build;

  String get name => '$major.$minor.$patch';

  @override
  String toString() => '$name+$build';
}

final _versionLine = RegExp(
  r'^version:[ \t]*(\d+)\.(\d+)\.(\d+)\+(\d+)[ \t]*$',
  multiLine: true,
);

_Version _readVersion(String pubspec) {
  final match = _versionLine.firstMatch(pubspec);
  if (match == null) {
    throw const _Fail(
      'pubspec.yaml has no `version: MAJOR.MINOR.PATCH+BUILD` line.',
    );
  }
  return _Version(
    int.parse(match[1]!),
    int.parse(match[2]!),
    int.parse(match[3]!),
    int.parse(match[4]!),
  );
}

/// `1.4.0 (128)` — the one display rule, mirrored by `AppVersion.display`.
String _display(_Version version) => '${version.name} (${version.build})';

String _render(_Version version) => '''
// GENERATED by tools/release.dart — do not edit.
// Source: the `version:` line of pubspec.yaml.

class AppVersion {
  const AppVersion._();

  static const String name = '${version.name}';
  static const int build = ${version.build};

  /// `${_display(version)}` — what the settings menu shows.
  static const String display = '\$name (\$build)';
}
''';

// ============================================
// Steps
// ============================================

/// Writes the generated file. No formatter runs on it: `_render` already emits
/// what `dart format` produces, and `scripts/app/test.sh` fails the release
/// gate if that ever stops being true. Shelling out to the formatter was the
/// one step here that could fail for reasons unrelated to releasing.
void _writeGenerated(Directory root, _Version version) {
  final file = _generatedFile(root);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(_render(version));
  stdout.writeln('generated  $_generatedPath');
}

/// The release commit takes `pubspec.yaml` whole, so any other edit in it would
/// ride along; and the deploy refuses a dirty tree anyway. The changelog is the
/// one exception: its notes are written just before or during `cut`.
/// `--porcelain` so untracked files count. Not trimmed in front: that would eat
/// the first line's status column.
void _requireCleanTree(Directory root) {
  final dirty = (_run(root, 'git', [
    'status',
    '--porcelain',
    '--',
    '.',
    ':(exclude)$_changelogPath',
  ]).stdout as String)
      .trimRight();
  if (dirty.isEmpty) return;
  throw _Fail(
    'working tree is dirty — commit or stash first; only $_changelogPath may '
    'be:\n       ${dirty.split('\n').join('\n       ')}',
  );
}

/// Any `## ` line starts an entry (`### ` group lines do not match).
final _entryHeading = RegExp(r'^## .*$', multiLine: true);

/// `' (the newest is "…")'`, for a refusal that names the wrong heading.
String _newest(Match? heading) => heading == null
    ? ' (it has no "## " entry)'
    : ' (the newest is "${heading[0]!.trim()}")';

/// The `## Unreleased` heading, or a refusal naming the newest one.
Match _unreleasedHeading(String changelog) {
  final heading = _entryHeading.firstMatch(changelog);
  if (heading == null || heading[0]!.trim() != _unreleased) {
    throw _Fail(
      'write the notes under "$_unreleased" at the top of $_changelogPath'
      '${_newest(heading)}.',
    );
  }
  return heading;
}

/// Checks the entry below [heading], up to the next one: every note in a
/// `### ` group, at most five a group, 500 characters in all. Returns
/// "N notes, M characters".
String _requireNotes(String text, Match heading) {
  final next = text.indexOf(_entryHeading, heading.end);
  // A CRLF checkout counts as LF: the store counts the text, not line endings.
  final entry = text
      .substring(heading.end, next < 0 ? text.length : next)
      .replaceAll('\r\n', '\n')
      .trim();
  final title = heading[0]!.trim();
  var notes = 0;
  var group = '';
  var inGroup = 0;
  for (final line in entry.split('\n').map((line) => line.trim())) {
    if (line.startsWith('### ')) {
      group = line.substring(4);
      inGroup = 0;
    } else if (line.startsWith('- ')) {
      if (group.isEmpty) {
        throw _Fail(
          'a note under "$title" sits above every group: "$line". Put it '
          'under ### New, ### Improved or ### Fixed.',
        );
      }
      notes++;
      if (++inGroup > _maxNotesPerGroup) {
        throw _Fail(
          '"$group" under "$title" has more than $_maxNotesPerGroup notes. '
          'Merge similar ones.',
        );
      }
    }
  }
  if (notes == 0) {
    throw _Fail('"$title" in $_changelogPath has no notes.');
  }
  if (entry.length > _maxEntryLength) {
    throw _Fail(
      '"$title" is ${entry.length} characters; a store takes '
      '$_maxEntryLength. Merge or cut notes.',
    );
  }
  return '$notes notes, ${entry.length} characters';
}

// ============================================
// Drafting the notes
// ============================================

/// Shows the `## Unreleased` notes until you answer: yes once they keep the
/// rules, r for a fresh draft, anything else stops and keeps them.
void _review(Directory root, String since) {
  while (true) {
    final shown = _changelogText(root);
    final heading = _unreleasedHeading(shown);
    final next = shown.indexOf(_entryHeading, heading.end);
    stdout.writeln(
        '\n${shown.substring(heading.start, next < 0 ? null : next).trim()}\n');
    try {
      stdout.writeln('rules      kept: ${_requireNotes(shown, heading)}');
    } on _Fail catch (failure) {
      stdout.writeln('rules      BROKEN: ${failure.message}');
    }
    stdout.write('Edit $_changelogPath now if you like. Release with these '
        'notes? [y]es / [r]egenerate / [N]o ');
    switch ((stdin.readLineSync() ?? '').trim().toLowerCase()) {
      case 'y' || 'yes':
        final edited = _changelogText(root);
        try {
          _requireNotes(edited, _unreleasedHeading(edited));
          return;
        } on _Fail {
          // Shown again, with what broke.
        }
      case 'r':
        try {
          _writeDraft(root, since);
        } on _Fail catch (failure) {
          stdout.writeln('draft      ${failure.message}; notes unchanged');
        }
      default:
        throw const _Fail('stopped. The notes stay in $_changelogPath: edit '
            'them, then run this again.');
    }
  }
}

/// Not `stdin.hasTerminal`: it also says yes to `/dev/null`, the stdin CI
/// gives a job. Only a real terminal has an echo mode; reading it throws on
/// anything else.
bool _atTerminal() {
  try {
    stdin.echoMode;
    return true;
  } on StdinException {
    return false;
  }
}

/// Puts Claude's draft at the top of the changelog, replacing any notes under
/// `## Unreleased`.
void _writeDraft(Directory root, String since) {
  final notes = _draft(root, since);
  final changelog = _changelogText(root);
  final heading = _entryHeading.firstMatch(changelog);
  final start = heading?.start ?? changelog.length;
  var end = start;
  if (heading != null && heading[0]!.trim() == _unreleased) {
    final next = changelog.indexOf(_entryHeading, heading.end);
    end = next < 0 ? changelog.length : next;
  }
  _changelogFile(root)
      .writeAsStringSync(changelog.replaceRange(start, end, '$notes\n'));
}

/// Claude Sonnet's notes for the commits since [since], as a `## Unreleased`
/// entry. It gets no tools: all it reads is in the prompt, and it replies
/// with JSON, so this script alone writes the Markdown.
String _draft(Directory root, String since) {
  final commits = _gitOut(root, [
    'log',
    '--no-merges',
    '--format=%s%n%b%x1e',
    '$since..HEAD',
  ])
      .split('\x1e')
      .map((commit) => commit.trim())
      .where((commit) => commit.isNotEmpty && !_unseenCommit.hasMatch(commit))
      .map((commit) => commit
          .split('\n')
          .where((line) => !line.startsWith('Co-Authored-By:'))
          .join('\n')
          .trim())
      .join('\n\n');
  if (commits.isEmpty) {
    throw _Fail('no commits since $since that an app reader would notice');
  }

  // The whole guide, not its rules section alone: that section's example has a
  // "## Unreleased" line, so cutting at the next "## " loses the rules.
  final guide = File('${root.path}/$_guidePath').readAsStringSync().trim();

  // The two newest released entries, for the style.
  final changelog = _changelogText(root);
  final released = _entryHeading
      .allMatches(changelog)
      .where((heading) => heading[0]!.trim() != _unreleased)
      .toList();
  final recent = released.isEmpty
      ? ''
      : changelog
          .substring(released.first.start,
              released.length > 2 ? released[2].start : null)
          .trim();

  final prompt = '''
Draft the release notes for the next version of an app from the commits below.

Reply with only this JSON, nothing before or after it:
{"new": ["..."], "improved": ["..."], "fixed": ["..."]}
Each item is one note in plain text: no leading "- ", no Markdown. Leave a list empty when nothing fits it.

Hard limits, checked before release: at most $_maxNotesPerGroup notes in a list, and $_maxEntryLength characters for the whole entry including its ### headings. So aim for about six notes in all, each under 70 characters: pick what an app reader would notice most, merge related changes into one note ("Search: ..."), and drop small polish.

Follow "The CHANGELOG entry" in <guide>; the rest of it is how a release runs, for context. Leave out refactors and other technical work, and anything only on the website. Write like the entries in <recent>: short, plain, no detail a reader doesn't need.

<guide>
$guide
</guide>

<recent>
$recent
</recent>

<commits>
$commits
</commits>
''';

  stdout.writeln('draft      Claude Sonnet is reading the commits since '
      '$since...');
  final ProcessResult result;
  try {
    // Run from the temp folder so this repo's CLAUDE.md and memory stay out.
    // The prompt goes before --tools, which would take it as a tool name.
    result = Process.runSync(
      'claude',
      [
        '-p',
        prompt,
        '--model',
        'sonnet',
        '--tools',
        '',
        '--no-session-persistence',
      ],
      workingDirectory: Directory.systemTemp.path,
    );
  } on ProcessException {
    throw const _Fail('Claude Code (the claude command) is not installed');
  }
  final reply = '${result.stdout}'.trim();
  if (result.exitCode != 0) {
    throw _Fail('claude failed: ${'${result.stderr}'.trim()} $reply');
  }

  Object? json;
  final open = reply.indexOf('{');
  final close = reply.lastIndexOf('}');
  if (open >= 0 && close > open) {
    try {
      json = jsonDecode(reply.substring(open, close + 1));
    } on FormatException {
      // Reported below, with the reply.
    }
  }
  if (json is! Map) throw _Fail('Claude replied without the notes: $reply');

  final groups = <String>[];
  for (final (key, title) in const [
    ('new', 'New'),
    ('improved', 'Improved'),
    ('fixed', 'Fixed'),
  ]) {
    final items = json[key];
    final notes = [
      if (items is List)
        for (final item in items)
          if (item is String)
            // One line each, without a bullet of its own.
            item
                .replaceFirst(RegExp(r'^\s*[-*]\s+'), '')
                .replaceAll(RegExp(r'\s+'), ' ')
                .trim(),
    ].where((note) => note.isNotEmpty);
    if (notes.isNotEmpty) {
      groups.add('### $title\n${notes.map((note) => '- $note').join('\n')}');
    }
  }
  if (groups.isEmpty) {
    throw const _Fail('Claude found nothing an app reader would notice');
  }
  return '$_unreleased\n${groups.join('\n\n')}\n';
}

// ============================================
// Plumbing
// ============================================

File _pubspecFile(Directory root) => File('${root.path}/$_pubspecPath');

String _pubspecText(Directory root) => _pubspecFile(root).readAsStringSync();

File _generatedFile(Directory root) => File('${root.path}/$_generatedPath');

/// `''` when the file is absent, which reads as drift.
String _generatedText(Directory root) {
  final file = _generatedFile(root);
  return file.existsSync() ? file.readAsStringSync() : '';
}

File _changelogFile(Directory root) => File('${root.path}/$_changelogPath');

/// `''` when the file is absent, which reads as no entry.
String _changelogText(Directory root) {
  final file = _changelogFile(root);
  return file.existsSync() ? file.readAsStringSync() : '';
}

/// `--match` so a per-product tag (`site-v*`, deferred but planned) could never
/// be reported as the repo's last version.
String? _lastTag(Directory root) {
  final result = Process.runSync(
    'git',
    ['describe', '--tags', '--abbrev=0', '--match', 'v*'],
    workingDirectory: root.path,
  );
  return result.exitCode == 0 ? (result.stdout as String).trim() : null;
}

bool _tagExists(Directory root, String tag) =>
    Process.runSync(
      'git',
      ['rev-parse', '--verify', '--quiet', 'refs/tags/$tag'],
      workingDirectory: root.path,
    ).exitCode ==
    0;

String _gitOut(Directory root, List<String> args) =>
    (_run(root, 'git', args).stdout as String).trim();

ProcessResult _run(Directory root, String executable, List<String> args) {
  final result = Process.runSync(executable, args, workingDirectory: root.path);
  if (result.exitCode != 0) {
    throw _Fail(
      '$executable ${args.join(' ')} failed:\n${result.stderr}${result.stdout}',
    );
  }
  return result;
}

class _Fail implements Exception {
  const _Fail(this.message);

  final String message;
}
