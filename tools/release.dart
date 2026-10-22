import 'dart:io';

/// The repo's one version command. The `version:` line of `pubspec.yaml` is the
/// source; `lib/core/version/app_version.gen.dart` and the git tag come from it.
///
///     dart run tools/release.dart status
///     dart run tools/release.dart bump major|minor|patch
///     dart run tools/release.dart finish
///     dart run tools/release.dart check
///     dart run tools/release.dart tag
///
/// Each command is a short sequence of named steps so another step can be
/// slotted in — the changelog work extends these rather than replacing them.
void main(List<String> args) {
  final root = File.fromUri(Platform.script).parent.parent;
  try {
    exit(switch (args.isEmpty ? '' : args.first) {
      'status' => _status(root),
      'bump' => _bump(root, args.length > 1 ? args[1] : ''),
      'finish' => _finish(root),
      'check' => _check(root),
      'tag' => _tag(root),
      final given => _usage(given),
    });
  } on _Fail catch (failure) {
    stderr.writeln('error: ${failure.message}');
    exit(1);
  }
}

const _pubspecPath = 'pubspec.yaml';
const _generatedPath = 'lib/core/version/app_version.gen.dart';

/// The only two paths a release writes, and so the only two a release commit
/// carries — and the only two `_requireCleanTree` tolerates as dirty. A
/// `CHANGELOG.md` edited between `bump` and `finish` belongs in this list; add
/// it when the changelog plan lands, or `finish` will refuse the entry.
const _releasePaths = [_pubspecPath, _generatedPath];

/// The branch every product releases from: the `*_PROD_BRANCH` values in
/// `scripts/config/targets.env`, which all say `main`. A tag cut anywhere else
/// stops being at the branch's HEAD the moment it merges, which is precisely
/// what the deploy guard refuses.
const _releaseBranch = 'main';

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

  final drifted = _generatedText(root) != _render(version);
  stdout
      .writeln('generated  ${drifted ? 'DRIFTED — run finish' : 'up to date'}');
  return 0;
}

int _bump(Directory root, String part) {
  final text = _pubspecText(root);
  final before = _readVersion(text);
  final after = switch (part) {
    'major' => _Version(before.major + 1, 0, 0, before.build + 1),
    'minor' => _Version(before.major, before.minor + 1, 0, before.build + 1),
    'patch' => _Version(
        before.major,
        before.minor,
        before.patch + 1,
        before.build + 1,
      ),
    _ => throw _Fail('bump takes major, minor or patch (got "$part").'),
  };

  // The one line, rewritten in place: a YAML round-trip would strip the
  // pubspec's comments.
  _pubspecFile(root)
      .writeAsStringSync(text.replaceFirst(_versionLine, 'version: $after'));

  stdout.writeln('pubspec    $before → $after');
  stdout.writeln('next       dart run tools/release.dart finish');
  return 0;
}

int _finish(Directory root) {
  // The same two preconditions the deploy guard applies. Checked here because
  // the only way out of a tag on the wrong commit is to burn a version: the
  // guard would reject the dirty tree, committing the rest would move HEAD off
  // the tag, and then the guard would reject the missing tag.
  _requireReleaseBranch(root);
  _requireCleanTree(root);

  final version = _readVersion(_pubspecText(root));
  final tag = 'v${version.name}';
  if (_tagExists(root, tag)) {
    throw _Fail(
      'tag $tag already exists. Bump a part first, or delete the tag if the '
      'release was never pushed.',
    );
  }

  _writeGenerated(root, version);

  stdout.writeln(_commitRelease(root, tag)
      ? 'commit     chore(release): $tag'
      : 'commit     skipped — both files already match HEAD');

  _run(root, 'git', ['tag', '-a', tag, '-m', 'Release $version']);
  stdout.writeln('tag        $tag');
  stdout.writeln('next       git push && git push --tags');
  return 0;
}

/// Success ends with the tag name, so `require_release_commit` gets both facts
/// it needs — no drift, and what the tag must be called — from one VM start.
/// The `tag` label is how the guard finds the line; the changelog work will add
/// lines here, so it must not be found by position.
int _check(Directory root) {
  final version = _readVersion(_pubspecText(root));
  if (_generatedText(root) == _render(version)) {
    stdout.writeln('check      $_generatedPath matches $version');
    stdout.writeln('tag        v${version.name}');
    return 0;
  }
  stderr.writeln('error: $_generatedPath does not match pubspec $version.');
  stderr.writeln('       It is generated and must never be hand-edited:');
  stderr.writeln('       dart run tools/release.dart finish');
  return 1;
}

/// The tag name on its own, for a script that wants it without `check`'s drift
/// gate. The shell cannot read YAML safely — a trailing comment or a two-part
/// version both slip past `sed`. The deploy guard takes the name from `check`
/// instead, so a deploy pays one VM start rather than two.
int _tag(Directory root) {
  stdout.writeln('v${_readVersion(_pubspecText(root)).name}');
  return 0;
}

int _usage(String given) {
  if (given.isNotEmpty) stderr.writeln('unknown command: $given\n');
  stderr.writeln('''
usage: dart run tools/release.dart <command>

  status   the version, the last tag, and the commits since it
  bump     major | minor | patch — raises that part, and the build by one
  finish   regenerate, commit, and tag v<version>. Does not push
  check    exit 1 if $_generatedPath drifted; else print the tag
  tag      print the tag name for the current version, and nothing else''');
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

void _requireReleaseBranch(Directory root) {
  final branch = _gitOut(root, ['rev-parse', '--abbrev-ref', 'HEAD']);
  if (branch != _releaseBranch) {
    throw _Fail(
      'a release must be cut from $_releaseBranch (on "$branch"). Merge '
      'first: a tag made here would not be at $_releaseBranch\'s HEAD.',
    );
  }
}

/// Anything dirty beyond the two release paths would be left out of the release
/// commit, so the tag would name a tree that was never built. `bump` has
/// already made the pubspec dirty by design, so the two are excluded by
/// pathspec — git does the matching, rather than this slicing porcelain
/// columns. `--porcelain` so untracked files count: a never-added file is
/// invisible to `git diff` yet part of the build.
void _requireCleanTree(Directory root) {
  final dirty = _gitOut(root, [
    'status',
    '--porcelain',
    '--',
    '.',
    for (final path in _releasePaths) ':(exclude)$path',
  ]);
  if (dirty.isEmpty) return;
  throw _Fail(
    'working tree is dirty — commit or stash first, or the tag will name a '
    'tree nobody can rebuild:\n       ${dirty.split('\n').join('\n       ')}',
  );
}

/// Commits exactly the two release paths, leaving anything else staged or dirty
/// alone. False when neither differs from HEAD: the first release, where the
/// pubspec already carries the version being tagged.
bool _commitRelease(Directory root, String tag) {
  if (_gitOut(root, ['status', '--porcelain', '--', ..._releasePaths])
      .isEmpty) {
    return false;
  }
  // `add` first — a pathspec commit cannot name a file git has never seen,
  // which is what the generated file is on the first release.
  _run(root, 'git', ['add', ..._releasePaths]);
  _run(root, 'git', [
    'commit',
    '-m',
    'chore(release): $tag',
    '--',
    ..._releasePaths,
  ]);
  return true;
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
