# Web app: no "Getting ready…" on a reload

Found 2026-11-01 on dev, while checking the offline work
([`web-app-offline-start.md`](../../done/web/web-app-offline-start.md)).
Not started.

## What happens

A normal reload of a deep link, filmed frame by frame in headless Chrome 156
on dev, databases installed. One run, so the times are a guide:

| Time | Shows |
|---|---|
| 0 – 0.15 s | blank page |
| 0.15 – 0.7 s | `#boot`, the HTML loader in `web/index.html` (emblem from 0.3 s) |
| 0.7 – 0.8 s | Flutter's install screen, phase `checking` |
| 0.8 s | the app (the sutta's text at about 1.4 s) |

Two loaders, one after the other:

- **`#boot`** covers Flutter's start (engine and `main.dart.js`). It shows at
  once, however short the wait.
- **Flutter's `checking` screen.** `flutter_bootstrap.js` removes `#boot` on
  Flutter's first frame, but that frame is `DatabaseInstallGate` in
  `checking`. On a reload, `_run` (`web_database_installer.dart`) reads the
  manifest and checks OPFS before it emits `ready`, and both are async. The
  screen copies `#boot`, but not exactly: Flutter hasn't loaded the emblem
  yet, the font differs, and the bar starts over. That jump is what looks
  like a second page.

## Fix (proposed, not decided)

- **A. `#boot` fades in after about 1 s.** CSS only, in `web/index.html`. A
  reload that's ready sooner shows the background, then the app. `.failed`
  shows at once. The standard: no looping indicator for a wait under 1 s
  (Nielsen Norman Group, *Progress Indicators Make a Slow System Less
  Insufferable*).
- **B. One handover.** `#boot` stays above Flutter's view until the gate
  leaves `checking` (ready, downloading or failed). Dart then dispatches an
  event, and the bootstrap removes `#boot` on it instead of on
  `flutter-first-frame` (`app-start-failed` already goes Dart → bootstrap the
  same way). The worker registration stays on `flutter-first-frame`.

With both, a reload goes from the background straight to the app, and a first
visit goes background → `#boot` after 1 s → the download screen.

Limits:

- A start that takes just over 1 s still shows `#boot` briefly. A minimum
  display time would fix that, at more code. Leave it unless someone sees it.
- With B, a gate stuck in `checking` keeps `#boot` up, as Flutter's
  `checking` screen does today.

## Check

Film a reload on dev before and after (CDP `Page.startScreencast`, as in the
offline checks). Want: no "Getting ready…" frame on a reload; a first visit
still shows the loader, then the download progress; Step 1's blocked-file
table in the offline plan still holds.
