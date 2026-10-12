# First Android Release

> **Status 2026-10-12: not started.** Android has not been built since the app
> moved to Drift, and Flutter 3.44.1 already refuses its build setup. This Mac
> has no Android SDK.

Only Android's own items. What both phones share is in
[`first-ios-release.md`](first-ios-release.md): do those too. The section
numbers match.

## 1. Build

- **Build tools.** Gradle, the Android Gradle Plugin, Kotlin and Java are
  older than Flutter accepts, so the first build fails until they are raised:
  "Already broken: Android" in
  [`flutter-3-47-upgrade-plan.md`](../flutter-3-47-upgrade-plan.md).
- **Signing.** Release builds still use the debug key
  (`android/app/build.gradle`).
- **App name.** `android:label` in `android/app/src/main/AndroidManifest.xml`
  is `the_wisdom_project`. Which name to use: **App names** in the iOS doc.

## 2. Check on a real device

- Time the first search after install on a low-end phone. The engine inflates
  the whole asset on the UI thread.
- Clear the app's cache. Nothing may copy again, because on Android the copy
  lives in the files folder, not the cache.
- Auto Backup must leave `files/databases/` out:
  `adb shell bmgr backupnow <package>` succeeds.
- **Full phone** (iOS doc, section 2): check the partial copy is gone with
  `adb shell run-as <package> ls files/databases`.
- System back closes search: search mode on a phone, and the side panel under
  the search box at 768px and up (tablets, and most phones turned sideways).
  It used to leave the app there. Checked only on macOS (search pane redesign,
  Tasks 4 and 12).

## 3. Decide from what section 2 shows

- **`noCompress` for `.db`.** It skips the inflate but costs about 190 MB
  installed: deflate takes `bjt.db` from 170 to 113 MB and `dict.db` from 163
  to 28 MB (measured 2026-09-17). Decide once the first search has been timed.

## 4. Measure the real artifacts

- `flutter build apk --analyze-size` gives the APK's size breakdown.
