# Focus mode — design

Started 2026-10-14. Design stage, not started.

**Goal:** a way to read with nothing on screen but the text.

## Two controls, both in the reader's settings menu

1. **Hide navigation bar** — a switch that hides only the navigation rail (the Reader / Research icons). Tablet and desktop only, since phones have no rail. **Shipped 2026-10-14**: `navigationRailHiddenProvider`, under a "Layout" section in `settings_menu_button.dart`. It only takes effect while the Reader shows: other sections have no settings menu to bring the rail back.
2. **Focus mode** — in the same "Layout" section. Hides everything except the text: the rail, the tree navigator, the tab bar and the app bar; on phones, the bottom bar too.

## Decided

- "Hide navigation bar" is saved (since 2026-10-15), like the tree navigator's collapse state. Focus mode is not: a restart always leaves it.
- Shortcut for focus mode: **Ctrl/Cmd+Alt+Z**. The shortcut system has no two-step keys, so VS Code's Cmd+K Z is out. Same shape as close-tab (Ctrl/Cmd+Alt+W).

## How to build focus mode

- One `focusModeProvider` (`StateProvider<bool>`, starts `false`), built like `navigatorVisibleProvider` but not saved. `AppShell` and `ReaderScreen` watch it and leave out their chrome. Like the rail switch, it applies only while the Reader shows.
- Shortcut: two entries in `defaultBindings()` (`keyboard_bindings.dart`), Ctrl and Cmd, plus an intent and an action.
- Esc exits: register with the overlay stack (`overlay_stack_provider.dart`). Esc then closes any open popup first, then leaves focus mode.
- **A visible way out.** Touch tablets often have no keyboard, so a hidden app bar must not trap the user. For example a faint exit button in a corner that shows on hover or tap.

## To decide

1. Inline switch below "Hide navigation bar", or a sub-menu? The "Layout" section shows only on tablet and desktop today; phones need focus mode too, so on phones it shows with the focus-mode switch alone.
2. Where the exit button sits, and whether it fades out.
3. Do find-in-page (Ctrl/Cmd+F) and the dictionary sheet still open in focus mode?
4. Check Ctrl/Cmd+Alt+Z is free in every browser, as was done for W.

## Later, not part of this

- Real full screen (OS title bar and browser bar gone too). Each platform does it differently: a package on desktop, the browser's Fullscreen API on web.

## Done when

- [ ] The settings switch and Ctrl/Cmd+Alt+Z both turn focus mode on.
- [ ] Esc, the shortcut and the exit button each turn it off.
- [ ] Open tabs and scroll positions survive turning it on and off.
- [ ] Labels in `app_en.arb` and `app_si.arb`.
