# Focus mode — design

Started 2026-10-14. **Focus mode dropped 2026-10-17**, never built: the reader toolbar now hides while reading ([`reader-toolbar-auto-hide.md`](../../todo/reader/reader-toolbar-auto-hide.md)), and that plan's step 2 hides the rest of the chrome on phones. "Hide navigation bar" stays as shipped.

**Goal (was):** a way to read with nothing on screen but the text.

## Shipped: Hide navigation bar

A switch that hides only the navigation rail (the Reader / Research icons). Tablet and desktop only, since phones have no rail. **Shipped 2026-10-14**: `navigationRailHiddenProvider`, under the "App layout" section in `settings_menu_button.dart`. It only takes effect while the Reader shows: other sections have no settings menu to bring the rail back. Saved since 2026-10-15, like the tree navigator's collapse state.

## Dropped: focus mode

A switch in the same section, and Ctrl/Cmd+Alt+Z, hiding everything except the text: the rail, the tree navigator, the tab bar and the app bar; on phones, the bottom bar too.

Not covered by its replacement: real full screen (OS title bar and browser bar gone too). Each platform does it differently: a package on desktop, the browser's Fullscreen API on web.
