# First iOS Release

> **Status 2026-09-18: not started.** iOS and Android have not been built since
> the app moved to Drift. Nothing ships to a phone until sections 1–4 are done.
> This Mac has no iOS signing, so all of it needs another machine, or this one
> set up.

This doc also holds what both phones share. Android's own items are in
[`first-android-release.md`](first-android-release.md), with the same section
numbers (split 2026-10-12).

Background: [`reduce-mobile-size-and-move-to-drift.md`](../retiring-dart-server/reduce-mobile-size-and-move-to-drift.md).
Section 2 was its step 10.

## 1. Build

- The first iOS and Android builds since Drift. They are also the first to
  fetch `package:sqlite3`'s native binaries.
- **Signing.** iOS needs a signed export.
- **Store upload** isn't scripted: the mobile `deploy.sh` scripts are
  placeholders in [`test-all-and-release-all.md`](../../done/ops/test-all-and-release-all.md).
- **App names** are still `flutter create` leftovers. Use the name the app
  shows (`appTitle`), and a short one under the home-screen icon, where only
  about 12 characters fit. The web app uses "The Wisdom Project" and "Wisdom".
  - iOS: `CFBundleDisplayName` in `ios/Runner/Info.plist` is "The Wisdom
    Project", too long for the home screen. `CFBundleName` is
    `the_wisdom_project`.
  - macOS, same fix: `PRODUCT_NAME` in `macos/Runner/Configs/AppInfo.xcconfig`
    is `the_wisdom_project` and shows in the menu bar.
- **App ID.** Choose it before the first store upload: neither store lets an
  app change it afterwards. Today it is `lk.tipitaka.theWisdomProject` (iOS,
  macOS) and `lk.tipitaka.the_wisdom_project` (Android, Linux), a
  `flutter create` leftover built on tipitaka.lk's domain, which their own
  iOS app uses (`lk.tipitaka.ios`). Use our domain reversed, the same on every
  platform, e.g. `net.sammaditthi.app`.
  - Change it now, while it costs nothing: no one has the app installed. After
    the first release it is frozen (**Do not rename** in
    [`product-names-checklist.md`](../../General/product-names-checklist.md)).
  - iOS: `PRODUCT_BUNDLE_IDENTIFIER` in `ios/Runner.xcodeproj/project.pbxproj`,
    for the app and `.RunnerTests`. macOS: the same key in `AppInfo.xcconfig`,
    and `.RunnerTests` in `macos/Runner.xcodeproj/project.pbxproj`. Android:
    **App ID** in the Android doc.
  - In the same pass, the other places that still say `lk.tipitaka`:
    `APPLICATION_ID` in `linux/CMakeLists.txt`, `CompanyName` and the copyright
    in `windows/runner/Runner.rc`, `PRODUCT_COPYRIGHT` in `AppInfo.xcconfig`.
  - On this Mac the app then starts fresh: its sandbox folder is named after
    the ID (`~/Library/Containers/<id>/`), so the database copy and settings
    start over.
  - Register the ID in the Apple developer account. The deep-link files name
    it (AASA in [`web-release.md`](../web-strategy/web-release.md)).
- **App icons** are still the Flutter logo on Android, iOS and macOS. The
  web app's icons come from `assets/icons/app_logo.png`: the
  disc as is, and a maskable version with the disc inside the safe zone on
  `LightThemeColors.primary`. Do the same for the native icons. iOS needs the
  version with a background: the App Store rejects icons with transparency.

## 2. Check on a real device

On both platforms:
- Reading and search snippets work with no network.
- Time the first-launch copy. `openLocalExecutor` copies each bundled
  database into `databases/`, so the file lives twice on disk from then on.
- Install over an older build. The database must copy again (plan step 7).
- Search on a phone: tap the search icon, type, pick a result, go back.
  Checked only at phone width on macOS, 2026-10-09 (search pane redesign,
  Task 9).

**Full phone.** Fill the device's storage, then search. The partial copy in
`databases/` must be gone afterwards, and the app must stay usable. The failed-copy path has never run: a full disk can't be
reproduced on the Mac.

## 3. Decide from what section 2 shows

- **What search shows on a full phone.** Today a failed copy reaches the screen
  as "no results", like any database that won't open. Should it say "free up
  space" instead?
- **Whether a failed copy keeps retrying.** Every search retries: the debounce
  is 300 ms, and a failed open is forgotten so the next search opens again. On
  Android each try unpacks the whole asset again. Should it stop until the app
  restarts?

## 4. Measure the real artifacts

Every size figure so far is either a macOS bundle or a per-file deflate
estimate. None came out of an APK or IPA.
- Download and installed size from a real IPA and APK. Compare them with the
  plan's estimates in **Size — the bonus, on two axes** and its step 4, where
  the download rose from 92 to 114 MB.
- Optional: time a search and a reader open on the phone. The speed-up was
  measured on the two code paths (plan step 2), never in the running app.

## Later: not costed

- **Download the databases instead of bundling them.** Every figure assumes the
  databases ship inside the APK/IPA. Two ways would take the install to a few
  megabytes, with a first-run fetch from R2, where egress is free:
  - the web's installer
    ([`move-web-onto-drift.md`](../../done/retiring-dart-server/move-web-onto-drift.md)):
    the build's manifest names each database, fetched once from R2
  - the store-native options, Play Asset Delivery and iOS On-Demand Resources

  Either way, a fresh install no longer works offline, which is why this is
  listed, not proposed.
