# Reader toolbar merge — plan

Started 2026-10-16. Built 2026-10-16. Its scrolled menu was removed again on 2026-10-17 by [`reader-toolbar-auto-hide.md`](reader-toolbar-auto-hide.md), which carries the open checks.
Design: [Reader toolbar merge canvas](https://claude.ai/artifact/4W4A57wzXDm2dXLuE2Wi8z), the "Proposal · …" boards for the top of a sutta.

**Goal:** the two pills at the top of a sutta become one toolbar.

**UI only.** No business logic changes: every action calls what it called before. Open as web page stays web-only (decided 2026-10-05, re-confirmed 2026-10-16).

## What the reader sees

`[Layout ▾] [Find] | [Commentary] [Previous] [Next] | [Share ▾]`

- **Layout ▾** shows the current layout's icon (or P / S) and opens the four layouts, with a ✓ on the current one.
- **Share ▾** opens Copy link and, on the web, Open as web page. Upcoming items (Share via, …) join this menu.
- One row on a phone; no more wrapping to two rows.

**Unchanged:** what each button does; when it shows (Commentary only with a parallel text, its label flipping to Root text; Previous/Next hidden at the corpus edge; Open as web page on the web only). Icons and colours stay, and Commentary stays icon-only.

## Interaction changes (decided 2026-10-16)

1. **Layout takes two taps.** Accepted, because more choices will join these menus. The menu closes after a pick.
2. **Share replaces the boards' ⋯.** Share sits in the toolbar and opens its own menu: Copy link today, Share via and more as they arrive. Copy link stays two taps, as before, on every platform.
3. **Open as web page moves into the Share menu** (web only, as before). As its own button it would widen the pill past a 360px phone browser. It is not sharing, which is why it was its own button (2026-10-05); one row wins.

## How it is built

- **`ReaderActionToolbar`** (`widgets/reader/reader_action_buttons.dart`): the pill, its buttons in three groups (this page, another sutta, outside the app) with a divider between two groups.
- Layout ▾ and Share ▾ are `MenuAnchor` buttons with `MenuItemButton` rows. Keyboard navigation, focus, outside-tap and Esc close, and screen-reader roles come with them.
- Every menu goes through `DismissibleMenuAnchor` (`widgets/common/`), which the search match-options menu uses too: it puts the menu on the overlay stack while open and closes it when its button fades out. Every menu takes its look from `AppMenuTheme` (`core/theme/`), set as `ThemeData.menuTheme`: 12px corners, a 1px outline, the same selected-row tint and divider height.
- An open menu closes when the toolbar hides, on an outside tap (a tab switch is one) and on Esc.
- The Share menu is a fixed 280px wide, right-aligned with its button. The width is a `SizedBox`, not `MenuStyle` sizes: compact density (desktop, web) shrinks a menu's minimum width, which put it 8px off.
- The layout glyph (`_layoutIcons` + `shortLabel`) is one small widget, used by the Layout ▾ button and its menu rows.
- Deleted: `ReaderActionButtonGroup`, `ReaderLayoutPill`, `ReaderExpandableFab`, `_FabLayoutSelector`, `_FabActionItem`, `_LayoutOptionButton`.

### Share

As a `MenuAnchor` the menu lives with its button, so `showShareMenu`, `globalRectOf`, `_below` and the `showMenu` path went: they existed because the old FAB's item vanished as the FAB closed. The Copy link action itself (`copyTipitakaLinkProvider` + `linkCopied` SnackBar) stays, as `copyActiveTabLink`. Share via (the OS share sheet) and later items join this menu.

### Step targets

`ReaderStepTarget` carries the destination's name instead of a finished tooltip: `({String name, VoidCallback onTap})`. The tooltip is `goToSutta(name)`, as before.

### Screen readers

Layout ▾ is labelled with the current layout (`currentLayout`: "Layout: Stacked"), since the button itself shows only P, S or an icon. Layout ▾ and Share report whether their menu is open. Each layout in the menu reads as one choice of four.

### Open as web page

Same action as before: web only, `openAsWebPage` → `UrlLauncherUtils.launchInAppBrowser`, which opens a new tab on the web. It sits in the Share menu, and its `kIsWeb` check is in the toolbar.

### Strings

New: `currentLayout` ("Layout: {name}"), in `app_en.arb` and `app_si.arb`.
"Layout" meant two things, so the Settings section got its own key, `appLayout` ("App layout" / "යෙදුම", decided 2026-10-16). The old `layout` key went.

## Narrow phones

The pill is about 300px wide: it fits a 360px-wide phone with 16px gutters. Below that (a 320px iPhone SE, first generation, or Android at a large display size) a `FittedBox` scales it down a little instead of letting it overflow, so the touch targets shrink from 44px to about 42px.

## Tests

Not written as part of this (project rule). The widget tests of the deleted pills and FAB were deleted on 2026-10-17. What to cover is in [`reader-toolbar-auto-hide.md`](reader-toolbar-auto-hide.md).

## Done when

- [x] The top of a sutta shows one pill, as on the "layout menu open" board with Share in place of ⋯, in one row on a phone.
- [x] Deep-linking doc § B updated: Share as a menu button, Open as web page inside it.
- [x] New strings in `app_en.arb` and `app_si.arb`.
- The open checks (every action as before, menus closing) are in the auto-hide plan.
