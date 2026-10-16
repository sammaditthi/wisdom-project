# Reader toolbar merge — plan

Started 2026-10-16. Built 2026-10-16; checked in a web preview build, not yet in the full app.
Design: [Reader toolbar merge canvas](https://claude.ai/artifact/4W4A57wzXDm2dXLuE2Wi8z), the four "Proposal · …" boards.

**Goal:** one toolbar at the top of a sutta and one menu once scrolled, both drawn from one list of actions. The two can no longer drift apart (today the FAB has no Previous/Next and the pill has no Go to beginning), and a new action is added in one place.

**UI only.** No business logic changes: every action calls what it calls today. Open as web page stays web-only (decided 2026-10-05, re-confirmed 2026-10-16).

## What the reader sees

**Top of a sutta.** The two pills become one:

`[Layout ▾] [Find] | [Commentary] [Previous] [Next] | [Share ▾]`

- **Layout ▾** shows the current layout's icon (or P / S) and opens the four layouts, with a ✓ on the current one.
- **Share ▾** opens Copy link and, on the web, Open as web page. Upcoming items (Share via, …) join this menu.
- One row on a phone; no more wrapping to two rows.

**Scrolled.** The FAB opens one menu card instead of floating chips, with the same groups:

- Layout › (shows the current one) · Find in page
- Commentary · Previous + sutta name · Next + sutta name
- Go to beginning · Share › (Copy link; Open as web page on the web)

**Unchanged:** what each button does; when it shows (Commentary only with a parallel text, its label flipping to Root text; Previous/Next hidden at the corpus edge; Open as web page on the web only); the switch from toolbar to FAB once scrolled past the first viewport. Icons and colours stay as today, and Commentary stays icon-only.

## Interaction changes (decided 2026-10-16)

1. **Layout takes two taps.** Accepted, because more choices will join these menus.
2. **Previous / Next are in the scrolled menu too**, named by destination. Same navigation as the toolbar's buttons.
3. **Share replaces the boards' ⋯.** Share sits in the toolbar and opens its own menu: Copy link today, Share via and more as they arrive. Copy link stays two taps, as today, on every platform.
4. **Open as web page moves into the Share menu** (web only, as before). As its own button it would widen the pill past a 360px phone browser. It is not sharing, which is why it was its own button (2026-10-05); one row wins.

## How to build

### One action list

New `widgets/reader/reader_actions.dart`:

- A sealed `ReaderAction` with three kinds: `ReaderCommand` (icon, label, optional caption, `onSelected`), `ReaderLayoutChoice` (current layout, `onChanged`) and `ReaderActionMenu` (icon, label, child commands; Share). Layout is a choice, not a command, so it gets its own kind.
- Each action has a `ReaderActionGroup`: `view` (layout, find), `reading` (commentary, previous, next), `outward` (go to beginning, share). Share carries its own items: Copy link, and on the web Open as web page. Dividers go between groups.
- One builder, `buildReaderActions(...)`, owns the order and the visibility rules that `ReaderActionButtonGroup` and `ReaderExpandableFab` each held, `kIsWeb` included. Inputs: the step targets, `onSearch`, and `onScrollToBeginning`, which only the FAB passes (Go to beginning is scrolled-only). It reads `parallelTextNodeProvider`, `isCommentaryProvider` and `activeReaderLayoutProvider`, as before.

### Two presenters

- **`ReaderActionToolbar`** (top): the pill. Every group inline; Share is a `MenuAnchor` button.
- **`ReaderActionMenuFab`** (scrolled): the FAB and one menu holding every group.
- Both use `MenuAnchor` / `MenuItemButton` / `SubmenuButton`, as `match_options_menu.dart` already does. Keyboard navigation, focus, outside-tap and Esc close, and screen-reader roles come with it. In the FAB, Layout › and Share › are `SubmenuButton`s.
- An open menu closes when its presenter hides (scrolling across the first viewport, find opening) via `MenuController.close()`, replacing the old FAB's `visible` auto-collapse. An outside tap (a tab switch is one) and Esc close it too; each menu sits on the overlay stack while open, as `match_options_menu.dart`'s does.
- The Share menu and the scrolled menu are a fixed 280px wide, right-aligned with their button. The width is a `SizedBox`, not `MenuStyle` sizes: compact density (desktop, web) shrinks a menu's minimum width, which put them 8px off.
- Submenus open after the mouse rests 300ms. Flutter's default opens on hover at once, so a click straight after closed the submenu again.
- Extract the layout glyph (`_layoutIcons` + `shortLabel`) into one small widget, used by the Layout ▾ button and the menu rows.
- Delete `ReaderActionButtonGroup`, `ReaderLayoutPill`, `ReaderExpandableFab`, `_FabLayoutSelector`, `_FabActionItem`, `_LayoutOptionButton`.
- `multi_pane_reader_widget.dart`: the `Wrap` of two pills becomes the toolbar, and `previous` / `next` are passed to the FAB too.

### Share

Today `showShareMenu` opens a popup under a measured rect, because the FAB item is gone once the FAB closes. As a `MenuAnchor` (toolbar) or `SubmenuButton` (FAB) the menu lives with its button, so `showShareMenu`, `globalRectOf`, `_below` and the `showMenu` path go; the Copy link action itself (`copyTipitakaLinkProvider` + `linkCopied` SnackBar) stays. Share via (the OS share sheet) and later items join this menu. The update to `docs/todo/web-strategy/deep-linking-and-shareable-urls.md` § B (the "`showMenu`, not `MenuAnchor`" row) goes in with the code.

### Step targets

`ReaderStepTarget` carries the destination's name instead of a finished tooltip: `({String name, VoidCallback onTap})`. Toolbar tooltip = `goToSutta(name)`, as today; FAB row = caption + name.

### Open as web page

Same action as today: web only, `openAsWebPage` → `UrlLauncherUtils.launchInAppBrowser`, which opens a new tab on the web. It now sits in the Share menu, and its `kIsWeb` check moves into the builder.

### Strings

Already in the ARB files: `layout`, `layoutPaliOnly` / `layoutSinhalaOnly` / `layoutSideBySide` / `layoutStacked`, `findInPage`, `commentary`, `rootText`, `goToSutta`, `scrollToBeginning`, `share`, `copyLink`, `openAsWebPage`.
New: `previousSutta` / `nextSutta` ("Previous" / "Next") for the FAB captions, in `app_en.arb` and `app_si.arb`.

## Later, not part of this

- Very narrow phones. The pill is about 300px wide: it fits a 360px-wide phone with 16px gutters, but not a 320px one (iPhone SE, first generation).

## Tests

Not written as part of this (project rule). These two no longer compile, since the widgets they test are gone, and need replacing with tests of `ReaderActionToolbar` and `ReaderActionMenuFab`:
`test/presentation/widgets/reader/reader_action_button_group_test.dart`,
`test/presentation/widgets/reader/reader_expandable_fab_test.dart`.
`integration_test/layout_switch_test.dart` and `integration_test/in_page_search_test.dart` drive the providers directly, so they are unaffected; the latter names `ReaderActionButtonGroup` in a comment.

Worth covering: Copy link from both presenters; Open as web page only on the web; Previous/Next absent at the corpus edge; Go to beginning only in the FAB; a menu closing when its presenter hides.

## Done when

- [x] The top of a sutta shows one pill, as on the "layout menu open" board with Share in place of ⋯, in one row on a phone.
- [x] The scrolled FAB opens one menu, as on the "scrolled, same groups in the FAB" board.
- [ ] Every action behaves as before, and Previous / Next work from the scrolled menu.
- [ ] Menus close on scrolling past the first viewport, find, a tab switch, an outside tap and Esc. (Esc checked in the preview.)
- [x] Deep-linking doc § B updated: Share as a menu button / submenu, Open as web page inside it.
- [x] New strings in `app_en.arb` and `app_si.arb`.
