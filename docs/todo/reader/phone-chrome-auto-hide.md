# Phone chrome auto-hide — plan

Not started. Step 2 of [`reader-toolbar-auto-hide.md`](../../done/reader/reader-toolbar-auto-hide.md), split out on 2026-10-17. Step 1, built 2026-10-17, hides only the reader toolbar.
Design: [Reader toolbar · ways back canvas](https://claude.ai/artifact/1qPRDahEtzfvDJdDqtpwsw).

**Goal:** more of a phone's screen for the text. Everything shows at the top. While reading, the app bar, tab bar, bottom nav and toolbar hide together, and they come back together on step 1's scroll-up rule. Reader section only. Tablets and desktop keep step 1.

Also fixes step 1's known cost: shown mid-sutta, the toolbar covers the top of the text (about 64px), which is where lines arrive when scrolling up.

## Plan

- **Overlays that slide, not collapsing heights** (decided 2026-10-17). The cost is insets:
  - content padding at the top and bottom equal to the chrome;
  - the toolbar and find bar positions;
  - anchor landings (search hit, deep link, restore) offset by the visible chrome, since `AnchoredPageList` puts the anchor row at the very top of the viewport.
- Keep the status bar and home indicator areas reserved and painted in the page colour.
- One provider, watched by `AppShell` (bottom nav), `ReaderScreen` (app bar, tabs) and the reader widget. It holds step 1's `ToolbarAutoHide` unchanged. Flip on state changes only, never per pixel.
- **"Phone" means `shortestSide < 600`**, not `isMobile` (width < 768). A landscape phone is wider than 768 but has the least height, and it needs this most.
- `SliverAppBar(floating, snap)` does not fit: the app bar and tabs sit outside the reader's scroll view, which is a centre-keyed `CustomScrollView`.
- Check step 1's 100px reveal threshold on a phone first (deferred there).
