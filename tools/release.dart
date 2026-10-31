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
      ? 'next       notes under "$_unreleased" in $_changelogPath, then\n'
          '           ./scripts/release.sh patch|minor|major'
      : 'next       ./scripts/deploy.sh --prod   (v${version.name} is not '
          'tagged yet)');
  return 0;
}

/// Raises the version, dates the `## Unreleased` notes, regenerates, commits.
/// Every check runs before anything is written. No tag: `scripts/deploy.sh`
/// makes it once every test passes, so a red test costs no version.
int _cut(Directory root, String part) {
  _requireCleanTree(root);

  final pubspec = _pubspecText(root);
  final before = _readVersion(pubspec);
  if (!_tagExists(root, 'v${before.name}')) {
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
  final changelog = _changelogText(root);
  final heading = _entryHeading.firstMatch(changelog);
  if (heading == null || heading[0]!.trim() != _unreleased) {
    throw _Fail(
      'write the notes under "$_unreleased" at the top of $_changelogPath'
      '${_newest(heading)}.',
    );
  }
  _requireNotes(changelog, heading);
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
  _requireNotes(changelog, heading);
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
/// one exception: its notes are written just before `cut`. `--porcelain` so
/// untracked files count. Not trimmed in front: that would eat the first line's
/// status column.
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

/// Checks the entry below [heading], up to the next one: every note in a
/// `### ` group, at most five a group, 500 characters in all.
void _requireNotes(String text, Match heading) {
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
  stdout.writeln('changelog  $notes notes, ${entry.length} characters');
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
