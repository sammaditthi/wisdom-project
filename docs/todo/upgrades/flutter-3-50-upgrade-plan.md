# Flutter 3.50 upgrade

> **Status 2026-11-25: done on branch `chore/flutter-3-50`, not merged.**
> Left: the Impeller check by eye (step 2.3). After that, move this doc to
> `docs/done/upgrades/`.
>
> The plan was written for 3.47 (2026-10-08). By the time it ran, 3.50.1 was
> the stable release, so the upgrade went straight there and took in the
> `material_ui` move that 3.50 asks for.

## Versions

| | Before | After |
| --- | --- | --- |
| Flutter | 3.44.1 | 3.50.1 (2026-11-20) |
| Dart | 3.12.1 | 3.14.0 |
| `sdk:` in the app, `wisdom_shared`, `static_site_generator` | `>=3.5.2` / `>=3.0.0` | `^3.13.0` |
| freezed / freezed_annotation | 2.5.8 / 2.4.4 | 4.0.3 / 3.1.0 |
| json_serializable / json_annotation | 6.9.5 / 4.9.0 | 6.15.2 / 4.12.0 |
| build_runner | 2.5.4 | 2.16.2 |
| mockito | 5.4.6 | 5.8.1 |
| material_ui (cupertino_ui comes with it) | — | 1.11.1 (1.1.7) |
| flutter_gen, cupertino_icons | in `pubspec.yaml`, unused | removed |
| Minimum macOS | 10.15 | 12 |

`^3.13.0` is the real floor: freezed 4 and material_ui need Dart 3.13.

## Steps

| Step | What | Status |
| --- | --- | --- |
| 1 | Flutter 3.50.1 and the code generators | Done, `0a337ba` |
| 2 | Check the app: tests, builds, rendering | Done except 2.3 (by eye) |
| 3 | Raise `sdk:` and reformat | Done, `d7775d3` |
| 4 | Clean-ups | Partly done, `81a92fe` `3bd605f` |
| 5 | Move to `material_ui` | Done, `7075895` |

Step 5 ran before step 3: the analyze gate fails on the 3.50 deprecations,
and the format commit should hold nothing but formatting.

### 1. SDK and code generators

- freezed 2's analyzer 7 can't read the dot shorthands in Flutter's own code,
  so `build_runner` crashed. freezed 4 fixes it. It needs `abstract` on the 26
  single-variant `@freezed` classes and `sealed` on `Failure`.
- build_runner stays on 2.16: mockito 5.8.1 caps `build` below 5, and
  build_runner 2.17 needs `build` 5. Try 2.17 again when mockito moves.
- build_runner 2.16 ignores `--delete-conflicting-outputs`. It's gone from
  `scripts/app/test.sh`, `CLAUDE.md` and the agent and doc files.
- `flutter pub get` added the `build/` and platform excludes to
  `analysis_options.yaml` by itself.
- Generated files are bigger: freezed 4 writes more code per class.

### 2. Checks

| Check | Result |
| --- | --- |
| `scripts/app/test.sh` (format, generated code, analyze, unit + widget, wisdom_shared, databases, macOS and Chrome integration) | 9 of 9 steps pass, first run. Same unit and widget test count as on 3.44.1. |
| Chrome, first visit (`test_chrome.sh --first-visit`, one file) | Passes: the databases download and install into a fresh profile |
| `flutter build web --release` | Builds. `serviceWorkerVersion` is still filled, so `deploy.sh`'s check passes. |
| `flutter build macos --release` | Builds; it raised the minimum macOS to 12 |
| Static site, Dart 3.12.1 vs 3.14.0 | Byte-identical |
| Static site, before vs after step 3 | Byte-identical |
| 2.3 Impeller vs Skia on macOS, by eye | **Not done (you)** |

**2.3, by eye (you).** Impeller is the macOS renderer from 3.47 on (Skia
before). Compare a sutta with conjuncts such as ඤ්ජ and ණ්ඩ, footnotes,
search highlights, and the Today card's sky:

```bash
flutter run -d macos                       # Impeller (the default now)
flutter run -d macos --no-enable-impeller  # Skia, for comparison
```

If Sinhala looks wrong under Impeller, opt out in `macos/Runner/Info.plist`
and say why in a comment (Flutter will remove the opt-out in a later release):

```xml
<key>FLTEnableImpeller</key>
<false/>
```

Impeller has no raster cache, so the sky's `isComplex` hint no longer caches
it as a bitmap. Watch the Today card for dropped frames.

### 3. SDK floor and reformat

- `dart migrate --apply --target-sdk=3.13.0` (new in Dart 3.14) raised the
  floor one minor at a time. Its only code change is Dart 3.13's private named
  parameters (`required this._baseUrl`) in four constructors. Callers still
  pass `baseUrl:`.
- Language 3.13 selects the tall format style: 323 of 491 files changed, plus
  the regenerated code.
- json_serializable's language-version warning is gone.

### 4. Clean-ups

Done:

- Removed `flutter_gen` and `cupertino_icons`. Nothing used them; flutter_gen
  alone pulled 13 more packages into the lock.
- `Failure.userMessage` and `apiType` are switch expressions over the sealed
  variants, so a new variant that isn't handled is a compile error.
- `_` instead of `__` and `___` for unused closure parameters in `lib/`.

Not done, on purpose:

- `dart migrate --step=cleanup`'s other edits: `class X;` with no body, and
  enum constructors without `const`. New syntax that fixes nothing.
- Dot shorthands (`.center` for `MainAxisAlignment.center`) across `lib/`. A
  large diff that changes no behaviour. Use them in new code.

### 5. `material_ui`

- `dart fix --apply --code=migrate_design_widgets` rewrote the 133
  `package:flutter/material.dart` imports. It wrote `material_ui: any`, now
  pinned to `^1.11.1`.
- **gen-l10n in 3.50.1 is behind.** The generated
  `AppLocalizations.localizationsDelegates` still uses flutter_localizations'
  delegates. Their `MaterialLocalizations` isn't the type material_ui reads, so
  Sinhala Material strings were missing; a settings widget test caught it.
  `main.dart` and the tests now share `appLocalizationsDelegates`
  (`lib/core/localization/app_localizations_delegates.dart`).
- `l10n.yaml` adds `// ignore_for_file: deprecated_member_use` to the
  generated file, so the analyze gate stays green.
- Fixed upstream in
  [flutter#194500](https://github.com/flutter/flutter/pull/194500)
  (2026-11-23), not yet in stable. When it lands: drop the `header:` line in
  `l10n.yaml`, regenerate, and check that the generated list imports
  material_ui. If it does, `appLocalizationsDelegates` can go.

## Still open

### Android: already broken, now further behind

Not caused by the upgrade: 3.44.1 already refused this setup. Flutter 3.50.1's
floors (`flutter_tools/gradle/.../DependencyVersionChecker.kt`):

| | Repo | 3.50.1 refuses below | 3.50 template |
| --- | --- | --- | --- |
| Gradle (`android/gradle/wrapper/gradle-wrapper.properties:5`) | 8.3 | 9.3.1 | 9.5.0 |
| Android Gradle Plugin (`android/settings.gradle:21`) | 8.1.0 | 9.1.1 | 9.3.1 |
| Kotlin plugin (`android/settings.gradle:22`) | 1.8.22 | 2.4.10 | 2.4.20 |
| Java (`android/app/build.gradle:14`) | 1.8 | 17 | 17 |

Fix it with the first Android build
([first-android-release.md](../mobile-release/first-android-release.md),
section 1). AGP 9 has Kotlin built in, so the `kotlin-android` plugin goes.
Keep the manifest's label and deep-link filters. The default `minSdk` is 24.

### iOS: on the first build

The minimum iOS goes from 13 to 15 (the 3.50 template), and the app moves to
the UIScene lifecycle. Check `ios/Runner.xcodeproj/project.pbxproj` after the
first iOS build. This Mac has Xcode 26.2; 3.50 is the first stable release
after Xcode 27 and iOS 27 shipped.

### Web: things to know

- The build prints that its service worker "is deprecated and will be removed
  in a future Flutter release". `web/flutter_bootstrap.js` reads that token to
  register `offline_worker.js`. When a Flutter release drops it, `deploy.sh`
  stops with an error. The replacement is `--web-content-hash` with
  `precache_manifest.json`.
- `flutter build web` now runs a Wasm dry run, and it passes. `--wasm` is an
  option to try; 3.50.1 fixes a freeze with `--wasm` plus cross-origin
  isolation, which this app uses.

### Separate work, not part of this plan

- **Riverpod 2 → 3**, next
  ([riverpod-3-upgrade.md](riverpod-3-upgrade.md)). On this branch's lock,
  `flutter_riverpod` 3.5.0, `riverpod_generator` 4.0.10 and `riverpod_lint`
  3.2.0 resolve (dry run, 2026-11-25).
- `flutter_lints` 4 → 6.
- `dartz` has had no release since 2021-12-03.
- The Windows Sinhala IME fix (#189968) is in 3.50; a retest on Windows is
  open ([windows-sinhala-ime-bug.md](../../general/windows-sinhala-ime-bug.md)).

## Handover notes

**2026-11-25.**

- `flutter upgrade` runs `flutter precache` for every platform, Android and
  iOS included, and on a slow connection that takes most of an hour. It was
  stopped after the Dart SDK and core engine were in. `flutter precache
  --macos --web --no-android --no-ios` then took 18 minutes. Android and iOS
  download theirs on their first build.
- `flutter drive` on the web now prints "The --pwa-strategy option is
  deprecated" for every file. Flutter sets that itself; `test_chrome.sh`
  doesn't pass it.
- Next: the Impeller check (2.3), then merge, then Riverpod 3.

## Sources

- [What's new in Flutter 3.50](https://flutter.dev/blog/whats-new-in-flutter-3-50)
- [Flutter 3.50.0 release notes](https://docs.flutter.dev/release/release-notes/release-notes-3.50.0)
- [Breaking changes](https://docs.flutter.dev/release/breaking-changes)
- [Flutter stable CHANGELOG (hotfixes)](https://github.com/flutter/flutter/blob/stable/CHANGELOG.md)
- [Dart SDK CHANGELOG](https://github.com/dart-lang/sdk/blob/main/CHANGELOG.md)
- [Migrating to `material_ui` and `cupertino_ui`](https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui)
- [Impeller](https://docs.flutter.dev/perf/impeller)
- [UIScene migration](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate)
- [freezed changelog](https://pub.dev/packages/freezed/changelog)
