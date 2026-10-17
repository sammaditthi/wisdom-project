# Reader toolbar auto-hide — plan

Started 2026-10-17. Plan ready, not started. Branch `feat/reader-toolbar-auto-hide`.
Design: [Reader toolbar · ways back canvas](https://claude.ai/artifact/1qPRDahEtzfvDJdDqtpwsw), the "Step 1" row. The rows above it are the options considered.

**Goal:** one toolbar and no FAB. The toolbar gets out of the way while the reader reads and comes back when they scroll up.

**Builds on** the toolbar of [`reader-toolbar-merge.md`](reader-toolbar-merge.md), built on branch `claude/eager-rubin-1lmr5a`. That branch becomes this branch's first commit, squashed, and is then deleted. Keep `ReaderActionToolbar`, `DismissibleMenuAnchor` and `AppMenuTheme`. Its scrolled menu (`ReaderActionMenuFab`) and its shared action list (`reader_actions.dart`) go.

## Decided (2026-10-17)

1. **No FAB, no scrolled menu.** The toolbar hides while reading and returns on a deliberate scroll up (quick return, as in Chrome, Safari and Matter).
2. **Step 1: one rule on every platform** (phone, tablet, desktop, web). Only the toolbar hides. The app bar, tab bar, bottom nav and rail stay as they are.
3. **Revealing needs room.** Readers scroll back to re-read and to compare Pali with Sinhala, so any upward pixel is not enough: it takes upward travel past a threshold.
4. **Go to beginning joins the toolbar**, shown only mid-sutta.
5. **The planned focus mode is dropped** (it was never built). "Hide navigation bar" stays as shipped.
6. **Step 2 comes later**, phones only: see below.
7. **Nothing freezes the rule.** An open menu closes when the toolbar hides. A freeze on a text selection or the dictionary sheet would leave the toolbar stuck hidden: on desktop a selection lasts until the next click, and the sheet stays open while reading.
8. **Keyboard scrolling never moves the toolbar.** Flutter runs Page Up/Down, Space and the arrows as an animated jump, reported like a search jump (no user scroll direction). No code needed.
9. **No shared action list.** With the FAB gone the toolbar is the only reader of `reader_actions.dart`, so the toolbar lists its own buttons.

## What the reader sees

- **Top of a sutta:** the toolbar, as today.
  `[Layout ▾] [Find] | [Commentary] [Previous] [Next] | [Share ▾]`
- **Scrolling down past the top:** it slides up and fades out.
- **Scrolling up a few lines:** it slides back in the same place, now with Go to beginning.
  `[Layout ▾] [Find] | [Commentary] [Previous] [Next] | [Go to beginning] [Share ▾]`
- **Scrolling down again:** it hides.
- **End of a sutta:** it shows by itself, since Previous / Next is what the reader wants there. It stays while they scroll back up from the end.

Known cost: shown mid-sutta, the toolbar covers the top of the text (about 64px), which is where lines arrive when scrolling up. Step 1 keeps its position; step 2 deals in insets.

## Rules

**Hides** on a user scroll down mid-unit: past the top (`extentBefore > 60`, the threshold used today) and not at the end (`extentAfter >= 1`).

**Shows**
- After upward user travel past a threshold. Start at 100px (three to four lines at body size) and tune on a phone, a trackpad and a mouse wheel. Only a move down resets the count, not a pause: a mouse-wheel notch reports start, move, stop, so a reset on stop would never let a wheel past one notch.
- At the top (`extentBefore <= 60`) and the end (`extentAfter < 1`), however the reader got there. Both turn it on rather than show it only while there: otherwise scrolling up one line from the end would hide it. A bounce past the end (iOS, macOS) is not a scroll down.
- After opening a sutta, Previous / Next, a tab switch, returning to the Reader section and closing find.

**Only the reader's own scrolling hides or reveals it.** In-page search jumps, `_anchorAt`, scroll restores, Go to beginning and keyboard scrolling never do, apart from landing at the top or the end.
- Read from a listener around the pane: `UserScrollNotification` says whether the user is scrolling (direction not idle), and `ScrollUpdateNotification.scrollDelta` gives the travel. Only `depth == 0`, the pane's own scroll view.
- The dictionary sheet sits beside the pane in the `Stack`, so its list never reaches that listener. The panes have no scroll views inside (`SelectionArea`, not `SelectableText`).
- Not from the controller listener behind `_syncScrollState`: that also fires for programmatic jumps. It feeds only the top and end rules.
- Touch, trackpad and mouse wheel all count, and a fling carries on the user's scroll.

**Find** hides the toolbar, as today.
**Pinned visible** while `MediaQuery.accessibleNavigation` is on. Android turns off its own hide-on-scroll under TalkBack for the same reason.
**Motion:** the existing 200ms fade plus a short slide up (-0.3 of its height). No change to the toolbar's position.
**Focus:** a hidden toolbar takes no keyboard focus, so Tab cannot land on an invisible button.

## Go to beginning

- Last group, before Share. Only while `_isScrolledDown` (`extentBefore > 60`), which now just means "mid-sutta". Same action as the old FAB, `_scrollToBeginning`.
- **Width:** 346px with it, against 302px without (11px less with the P / S glyph). The toolbar gets the pane's width less 32px, so it fits a phone from about 378px. Narrower, the existing `FittedBox` scales it: about 1% on a 375px phone, about 5% on a 360px one (touch targets about 42px), the trade already accepted for 320px phones.
- The pill changes width when it crosses the 60px line while visible: wrap it in `AnimatedSize`, aligned to the end, so it does not jump.

## How to build

### Branch

`feat/reader-toolbar-auto-hide`, from main:
1. `git merge --squash claude/eager-rubin-1lmr5a`, committed as the toolbar merge.
2. This plan on top.

### `widgets/reader/toolbar_auto_hide.dart` (new)

The rules above in one plain Dart class, fed `ScrollMetrics` and deltas, so step 2 moves it into a provider unchanged.
- `shown`.
- `userScrolled(delta, metrics)`: the reader's own scroll. Hides it, or counts toward the reveal.
- `scrolledTo(metrics)`: any scroll. The top and the end turn it on.
- `show()`: the events (opening, tab switch, …).
- Each returns whether `shown` changed, so the widget calls `setState` only on a flip.
- `topZone = 60` (moved out of `_syncScrollState`, shared with `_isScrolledDown`) and `revealDistance = 100`.

### `multi_pane_reader_widget.dart`

- Delete the FAB's `Positioned` and `showMode2`. `showMode1` becomes `showToolbar = hasContent && !searchState.isVisible && (accessibleNavigation || autoHide.shown)`.
- A `NotificationListener<ScrollNotification>` in `_buildContentLayout`, around the pane, feeding `userScrolled`.
- `_syncScrollState` calls `scrolledTo`.
- `show()` from:
  - the `activeTabIndexProvider` listener: opening a sutta always opens a tab, and a tab switch;
  - a new `activeNodeKeyProvider` listener: Previous / Next change the tab in place;
  - a new `selectedAppSectionProvider` listener, on Reader: the `IndexedStack` keeps the reader mounted, so nothing else fires;
  - the in-page search listener, when find closes.
- Pass `onScrollToBeginning: _isScrolledDown ? _scrollToBeginning : null`.
- `AnimatedSlide` next to the `AnimatedOpacity`, and `ExcludeFocus` while hidden.
- Comments that name the FAB: the `Positioned` keys stay, since the search bar still comes and goes above the toolbar.

### `reader_action_buttons.dart`

- Delete `ReaderActionMenuFab`, `_LayoutRow`, `_submenuHoverDelay`, `_MenuRow.command` and the menu row's caption.
- `ReaderActionToolbar` lists its buttons in three groups, with a divider between two non-empty groups: Layout ▾, Find | Commentary, Previous, Next | Go to beginning, Share ▾. Visibility as `buildReaderActions` has it: Commentary only with a parallel text, flipping to Root text; Previous / Next absent at the corpus edge; Open as web page in the Share menu, web only.
- New `onScrollToBeginning` parameter. `ReaderStepTarget` moves here.

### Deleted

- `reader_actions.dart`.
- `DismissibleMenuAnchor.gap`: only the FAB passed one.
- Strings `previousSutta`, `nextSutta` (the FAB's captions) and `layout` (the FAB's row of layouts), in `app_en.arb` and `app_si.arb`. `appLayout` and `currentLayout` stay. No new strings.

### Docs

- `reader-toolbar-merge.md`: delete the scrolled-menu and action-list text.
- `docs/todo/web-strategy/deep-linking-and-shareable-urls.md` § B: the Entry point and `MenuAnchor` rows still name the scrolled menu's Share ›.
- `focus-mode.md`: focus mode dropped; keep the shipped "Hide navigation bar" record, and move it to `docs/done/reader/`.

## Step 2 (later, phones only)

Everything is shown at the top. While reading, the app bar, tab bar, bottom nav and toolbar hide together, and they return together on the same scroll-up rule. Reader section only. Desktop keeps the step 1 rule.

- **Overlays that slide, not collapsing heights** (decided). The cost is insets:
  - content padding at the top and bottom equal to the chrome;
  - the toolbar and find bar positions;
  - anchor landings (search hit, deep link, restore) offset by the visible chrome, since `AnchoredPageList` puts the anchor row at the very top of the viewport.
- Keep the status bar and home indicator areas reserved and painted in the page colour.
- One provider, watched by `AppShell` (bottom nav), `ReaderScreen` (app bar, tabs) and the reader widget. It holds step 1's class. Flip on state changes only, never per pixel.
- **"Phone" means `shortestSide < 600`**, not `isMobile` (width < 768). A landscape phone is wider than 768 but has the least height, and it needs this most.
- `SliverAppBar(floating, snap)` does not fit: the app bar and tabs sit outside the reader's scroll view, which is a centre-keyed `CustomScrollView`.

## Tests

Not written as part of this (project rule).
- **Deleted** (decided 2026-10-17), as they test widgets that no longer exist: `test/presentation/widgets/reader/reader_action_button_group_test.dart`, `test/presentation/widgets/reader/reader_expandable_fab_test.dart`.
- **Broken, for the test writer:** `integration_test/sutta_step_navigation_test.dart` reaches Go to beginning through the FAB (`Icons.more_vert`). `in_page_search_test.dart` and `layout_switch_test.dart` name old widgets in comments.

Worth covering:
- `ToolbarAutoHide` on its own: hides on a scroll down mid-unit but not at the top or the end; no reveal under the threshold, a reveal past it; a pause keeps the count, a move down resets it; the end stays on while scrolling back up.
- The reader: search jumps, anchoring and restores never toggle it; it shows on opening, Previous / Next, a tab switch, a return to Reader and closing find; Go to beginning only mid-sutta; an open menu closes when the toolbar hides; pinned while `accessibleNavigation` is on.
- The toolbar: Copy link; Open as web page only on the web; Previous / Next absent at the corpus edge.

## Done when

- [ ] No FAB on any platform, and no `reader_actions.dart`.
- [ ] The toolbar hides on scrolling down, returns past the threshold, and shows at the top and the end.
- [ ] Search jumps, anchoring, restores and keyboard scrolling never toggle it.
- [ ] Go to beginning shows only mid-sutta and works.
- [ ] Every action behaves as before; a menu closes when the toolbar hides, on find, a tab switch, an outside tap and Esc.
- [ ] Threshold tuned on a phone, a trackpad and a mouse wheel.
- [ ] `reader-toolbar-merge.md`, the deep-linking doc § B and `focus-mode.md` updated.
