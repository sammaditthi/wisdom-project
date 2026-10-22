import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/core/version/app_version.gen.dart';

/// Guards the one rule the generated file cannot state about itself: it must
/// still say what `pubspec.yaml` says. `dart run tools/release.dart check`
/// covers the same ground from the deploy side; this covers it from the test
/// side, where a hand-edit gets caught before a release is ever attempted.
void main() {
  test('AppVersion matches the pubspec version line', () {
    // Duplicated rather than imported: a shared regex would let one typo pass
    // both the generator and its guard.
    final line = RegExp(
      r'^version:[ \t]*(\d+\.\d+\.\d+)\+(\d+)[ \t]*$',
      multiLine: true,
    );
    final match = line.firstMatch(File('pubspec.yaml').readAsStringSync());

    expect(
      match,
      isNotNull,
      reason: 'pubspec.yaml has no `version: MAJOR.MINOR.PATCH+BUILD` line. '
          'pub rejects a two-part version and the stores compare the build '
          'number, so both parts are required.',
    );

    expect(
      [AppVersion.name, AppVersion.build],
      [match![1], int.parse(match[2]!)],
      reason: 'lib/core/version/app_version.gen.dart has drifted from '
          'pubspec.yaml. It is generated and must never be hand-edited: '
          'dart run tools/release.dart finish',
    );
  });

  test('display is the name and build in the shown form', () {
    expect(AppVersion.display, '${AppVersion.name} (${AppVersion.build})');
  });
}
