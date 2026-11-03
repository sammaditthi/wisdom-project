# Pinch to zoom in the reader — plan

Not started. Paper spike 2026-10-28 (no prototype); decisions settled with the owner 2026-11-02; reviewed against the code 2026-11-03.

**Goal:** a reader scrolling through a sutta pinches to make the text bigger or smaller, keeps their place, and has no mode to get out of.

## Decisions

- **Pinch changes the reading text size. It does not magnify.** The text re-wraps to the column, so reading stays a vertical scroll and never pans sideways.
- **No zoom mode, so nothing to come back from.** The size sticks. It is the A-/A+ slider's setting (`fontScaleProvider`), saved the same way. To go back, pinch back; it snaps at the platform default.
- **One setting for the whole app**, as the slider does today (2026-11-02). After a pinch the tabs, menus and navigator resize too, except what is left on Material's default text styles (`docs/todo/theme/material-defaults-ignore-the-font-scale.md`). A reader-only size, with the rest of the UI following the OS text size, waits for user feedback. It would still be one slider, and pairs with perf A1 (`docs/todo/performance/perf-top10-killers.md`).
- **Range stays 0.7×–1.5×** (2026-11-02). See *Is 150% too big?* below.
- **No magnifier** for inspecting a single glyph (2026-11-02). Revisit only if readers ask.

| Rejected | Why |
|---|---|
| Magnifier: pan around the enlarged page | Sideways panning on every line; clashes with word taps and selection |
| Springs back on release | You can't read while holding a pinch |
| Temporary zoom with an exit chip, or auto-revert | Text changes size under you mid-read; a second "size" beside the slider |

## Interaction

- The line between your fingers stays under your fingers.
- A small "125%" label while pinching, fading about a second after release.
- Snap plus a haptic tick at the platform default (`platformDefault`: 100% native, 90% web) and at the limits. Past a limit the text stretches a little and springs back.
- A pinch never opens the dictionary, clears a highlight or starts a selection, even when one finger stays still and lifts.
- Desktop: trackpad pinch, Ctrl/Cmd + scroll wheel, Ctrl/Cmd + `=` / `-` / `0`.
- The slider stays. Pinch is not discoverable and not usable by everyone.

## How it works: preview, then commit

- **During the pinch** the reader pane is scaled on the GPU around the focal point. No relayout, no theme rebuild, no provider write. Only the transform widget rebuilds per frame (a `ValueNotifier`).
- **On release** the size is rounded to 0.05 and set once, and the entry that was under the fingers lands at the same height on screen.
- **The cost:** zooming in, lines run past the pane edges until release, then settle into the new width. Judge it on a device in Phase 0.
- **The catch: the theme animates the new size** (see *What exists today*). Released as is, the preview snaps back to the old size, then grows over 200 ms, and Phase 1 would measure text still changing size. Pick one in Phase 0: hold the preview until the animation ends; turn the theme animation off (`themeAnimationStyle: AnimationStyle.noAnimation`, which also drops the fade between themes); or fix A1 first, which takes the size out of `ThemeData`. The preview itself does not need A1.
- **Rejected for now: live re-wrap at each 0.05 step.** Every step would rebuild the app-wide theme (perf A1) and re-anchor, with jank risk on web. It is the fallback if the settle feels wrong.

## What exists today (checked 2026-11-03)

- `fontScaleProvider` / `FontScaleNotifier` (`lib/core/theme/theme_notifier.dart`): 0.7–1.5, saved to SharedPreferences, applied app-wide through `currentThemeDataProvider` → `AppTypography` and `TextEntryTheme`.
- The slider, `_FontSizeSelector` (`reader_settings_menu_button.dart`), rounds to 0.05 itself and calls `setScale` on every drag tick. Its Reset button (`FontScaleNotifier.reset`) is the only other caller.
- **Size changes animate.** `MaterialApp` (`lib/main.dart`) keeps the default 200 ms theme animation, and `TextEntryTheme.lerp` / `AppTypography.lerp` blend font sizes, so each change re-wraps the text on every frame for 200 ms. Headings (`headingStyles`, `centeredStyles`) are not blended and jump at the end. The slider does this on every step.
- **The slider loses your place** (read from the code, not yet seen on a device). Layout switches re-anchor through `EntryKeyRegistry.findTopVisibleEntry` and `_anchorAt` (`multi_pane_reader_widget.dart`), but nothing listens to `fontScaleProvider`. The pixel offset stays while the text re-wraps, so the further from the anchor row, the further the reader drifts.
- **Hidden tabs drift too.** On switch-away a tab saves a pixel offset from its anchor row (`_saveScrollPosition`). A size change makes it wrong, and the tab isn't mounted to re-anchor.
- Gestures already in play on the text: a `TapGestureRecognizer` per word (`text_entry_widget.dart`), `SelectionArea`, the scroll view's drag, and the raw `Listener`s in `_clearOnTap` and `DualColumnPane`. The word's `onTap` clears the search highlight and sets the dictionary highlight *before* it calls `onWordTap` → `_handleWordTap`.
- No pane or `AnchoredPageList` sets scroll physics; they take the ambient `ScrollConfiguration`.
- Mobile web: Flutter web turns the browser's own pinch off. The engine sets `user-scalable=no` on the viewport and `touch-action: none` on the host (`full_page_embedding_strategy.dart`, Flutter 3.44.1). The slider is the only way to enlarge text there.

## Is 150% too big? (checked 2026-11-02)

Not a bug. The 0.05 steps are right (16 divisions over 0.7–1.5), and the scale is applied once.

| | 1.0× | 1.5× |
|---|---|---|
| Reading text (`base × 1.1`) | 17.6px | 26.4px |
| Largest heading (centered level 5, `base × 2.1`) | 33.6px | 50.4px |
| Tree and tab labels | 14px | 21px |
| Pali words per line, ~390px-wide phone | about 4 | about 2–3 |

Why it reads large:

- 100% is already generous: reading text is `baseFontSize × 1.1`, not 16px.
- Sinhala glyphs run larger than Latin at the same size (noted at `AppFonts.resultTitleFontSize`), and Pali words in Sinhala script are wide (per-word width in the `readingColumnMeasureEm` comment).
- The scale is app-wide, so at 1.5× the chrome grows with the text.
- The OS text size multiplies on top. The app does not clamp `MediaQuery.textScaler`, so on a phone with enlarged system text, 1.5× can land near 2×.

If feedback says 1.5× is too big, lower the top of the range or the base size. Leave the steps.

## Plan

### Phase 0 — throwaway prototype on devices (1–2 days)

The gesture arena is the risk. On iOS, Android, a macOS trackpad, Windows, desktop web and mobile web, prove:

- A two-finger pinch inside the scroll view isn't taken over by the scroll. Candidate: a raw `Listener` counts touches (it joins no arena, like `_clearOnTap`). At two touches, put a `ScrollConfiguration` with `NeverScrollableScrollPhysics` over the pane, which should cancel the drag in flight via `Scrollable.setCanDrag`.
- A still pivot finger that lifts doesn't fire a word tap or start a `SelectionArea` selection.
- Ctrl/Cmd + wheel zooms without also scrolling. The `Scrollable` sits deeper and registers with `pointerSignalResolver` first, so it may need the same lock while the modifier is held: physics whose `shouldAcceptUserOffset` is false never register.
- Web: trackpad pinch and Ctrl + wheel reach Flutter (`PointerScaleEvent`) without the browser zooming the page. Same for Ctrl/Cmd + `+`; cf. the Cmd+W note in `shortcut_intents.dart`.
- Pinching in shows a blank band below the built rows. Raise the cache extent during the pinch, or accept it.
- The settle on release feels acceptable, and one fix for the theme animation's snap-back (*How it works*) is chosen.

### Phase 1 — keep the place when the size changes (fixes the slider too)

- `EntryKeyRegistry`: replace `findTopVisibleEntry` with `entryAt(controller, dy)`, returning the entry at a viewport height and the fraction into it. Layout switches call it with 0. Today's method picks the entry whose top is nearest, not the one containing the edge; decide whether layout switches keep that.
- `MultiPaneReaderWidget`: `ref.listen(fontScaleProvider)`. The old layout is still mounted when it fires. Capture the entry and fraction at the focal height (0 for the slider and Reset), clear the registry and anchor at the entry, as the layout listener does. Once the new size has laid out (after the theme animation, if it stays), jump so the fraction lands back at the focal height. It can't be one `setTabAnchor` call: `scrollOffset` is pixels from the anchor row, and the fraction's pixels need the entry's new height.
- Hidden tabs: on switch-away, save the tab as its top entry plus the offset into it (`setTabAnchor`), not a pixel offset from an older anchor. A size change then moves a hidden tab by at most part of one entry.
- Move the 0.05 rounding from `_FontSizeSelector` into `FontScaleNotifier`, so the slider and pinch share it. The Riverpod 3 plan also changes this class (`docs/todo/upgrades/riverpod-3-upgrade.md`).

### Phase 2 — the pinch

- New `lib/presentation/widgets/reader/reader_pinch_zoom.dart`, wrapping the pane inside `_buildContentLayout`. That puts it below the toolbar and dictionary sheet, so pinching on them does nothing.
- Preview state: scale and focal point in a `ValueNotifier`, rendered by a `ValueListenableBuilder` → `ClipRect` + `Transform.scale`.
- Inputs: two touches (span ratio); trackpad `PointerPanZoomUpdateEvent.scale`; `PointerScaleEvent` on web; Ctrl/Cmd + wheel in 0.1 steps, committed after a short idle.
- While pinching: lock the scroll with the `ScrollConfiguration` from Phase 0, so no pane changes. Word taps and `_clearOnTap` ignore input until all pointers are up. The word guard goes in the word's `onTap` (`text_entry_widget.dart`), not `_handleWordTap`, which runs after the highlights have changed.
- Snap, limits, stretch and `HapticFeedback.selectionClick()` as in *Interaction*.
- The percentage label, styled from `AppTypography`, sharing the slider's percent formatting.
- Commit: the stashed focal height for Phase 1's listener, then `setScale`.

### Phase 3 — keyboard

- `ZoomInIntent`, `ZoomOutIntent` and `ResetZoomIntent` in `shortcut_intents.dart` and `shortcut_actions.dart`, bound in `keyboard_bindings.dart` to Ctrl/Cmd + `=` / `-` / `0`. ±0.1, anchored at the top of the screen.
- Also bind Ctrl/Cmd + Shift + `=` (that is, `+`) and the numpad `+` / `-` / `0`: a `SingleActivator` matches its modifiers exactly.
- Add the three to `keyboard-shortcuts-sheet.md`'s table; each intent needs a label in `app_en.arb` / `app_si.arb`.

### Optional

- A tip under the slider: "Pinch the text to resize" (ARB key in `app_en.arb` / `app_si.arb`).

## Tests (for the test-writer agent)

- Pinch keeps the entry under the focal point at the same height.
- The slider and Reset keep the top entry.
- A size change keeps a hidden tab's place.
- A pinch never opens the dictionary or clears highlights, including when a still finger lifts on a word.
- Ctrl + wheel changes the size and does not scroll.
- Snap at the default, clamp at the limits, rounding to 0.05.
