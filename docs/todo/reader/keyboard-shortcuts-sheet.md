# Keyboard shortcuts — design

Started 2026-10-11. Designed with the user 2026-11-10. Built 2026-11-10 on
`feat/keyboard-shortcuts` (plan: `keyboard-shortcuts-build-plan.md`); the
checks below that need a person are still open.

**Goal:** new shortcuts for reading with the keyboard, and a **Keyboard
shortcuts** tab in Settings that lists every shortcut with the keys of the
platform it runs on. Desktop only: macOS, Windows and Linux, as an app or in
a browser.

**Why:** reading needs tab, layout, text-size and scroll keys, and nothing in
the app tells people shortcuts exist. The search box's hint was removed on
2026-10-09 because it showed on touch tablets (`search-pane-redesign-plan.md`,
Task 9).

Design board: the Keyboard shortcuts board on the
[App settings dialog canvas](https://claude.ai/artifact/Kd5nkzPuL2PdCmtyQLGjXn)
(`RefTabs.dc.html`, phone: `PhoneShortcuts.dc.html`). It shows only the five
old keys; the rows below replace them.

## The keys

Same keys on desktop and web. "Windows" also means Linux.

| Group | Does | Mac | Windows | |
| --- | --- | --- | --- | --- |
| Search | Find in page | ⌘F | Ctrl+F | exists |
| | Search | ⇧⌘F | Ctrl+Shift+F | exists |
| | Go to results or recent searches | ↓ | ↓ | new |
| Reader | Previous tab | ⌥⌘[ | Ctrl+Alt+[ | new |
| | Next tab | ⌥⌘] | Ctrl+Alt+] | new |
| | Close tab | ⌥⌘W | Ctrl+Alt+W | exists |
| | Previous text | ⌥⌘< | Ctrl+Alt+< | new |
| | Next text | ⌥⌘> | Ctrl+Alt+> | new |
| | Show/hide navigator | ⌘B | Ctrl+B | new |
| | Increase font size | ⌘+ | Ctrl++ | new |
| | Decrease font size | ⌘− | Ctrl+− | new |
| | Reset font size | ⌘0 | Ctrl+0 | new |
| | Scroll | ↑ ↓ | ↑ ↓ | new |
| | Scroll a page | PgUp PgDn or fn↑ fn↓ | PgUp PgDn | new |
| Layout | Pali only | ⌥⌘1 | Ctrl+Alt+1 | new |
| | Sinhala only | ⌥⌘2 | Ctrl+Alt+2 | new |
| | Side by side | ⌥⌘3 | Ctrl+Alt+3 | new |
| | Stacked | ⌥⌘4 | Ctrl+Alt+4 | new |
| App | Settings | ⌘, | Ctrl+, | new |
| | Keyboard shortcuts | ⌘/ | Ctrl+/ | new |
| | Copy | ⌘C | Ctrl+C | exists |
| | Close menu, panel or dialog | Esc | Esc | exists |

## How the keys were chosen

- **The browser's own key when it means the same thing:** ⌘F, ⌘+ / ⌘−, ⌘,.
- **Add ⌥ when the browser keeps the key, or uses it for something else.**
  Chrome never passes its close-tab and next/previous-tab keys to the page
  (⌘W, ⌥⌘←/→, ⇧⌘[ ], Ctrl+Tab, Ctrl+PgUp/PgDn). ⌘1–4 is the browser's "go to
  tab 1–4". So the reader-tab keys are ⌥⌘: W closes, [ ] move, 1–4 set the
  layout, in the toolbar's left-to-right order (`ReaderLayout.values`), and
  < > step to the previous or next text, pointing the way the toolbar's
  ⏮ ⏭ buttons do. Plain ← → (as in Kindle and Apple Books) was turned down: a
  stray press leaves a long sutta, and coming back starts it at the top.
- **⇧ makes the same key reach further:** ⌘F finds in the page, ⇧⌘F searches
  everywhere (as in VS Code, Xcode, JetBrains). ⇧ is not used for the tab keys
  because it is taken: ⇧⌘W closes the browser window, ⇧⌘[ ] is the browser's
  tab switch, ⇧⌘3/4 take a macOS screenshot, ⇧⌘B is Chrome's bookmarks bar.
- **⌘B** is the side-panel toggle in VS Code and many others. **⌘/** opens the
  shortcut list in Google Docs and Slack, and works while typing, which `?`
  can't.
- Accepted trade-off: on the web, ⌘+ / ⌘− change the reading text size
  instead of zooming the page. The browser's zoom menu still works.

## Rules

1. **One list.** Every shortcut is one entry in `keyboard_bindings.dart`: its
   key, its modifiers, its intent, its group and its label. `AppShortcuts`
   builds its key map from the list, and the Settings tab builds its rows from
   it, so a shortcut can't be missing from the tab. No key combo is spelled
   anywhere else in `lib/`. Adding a shortcut = one entry + its action + a
   label in `app_en.arb` and `app_si.arb`.
2. **One modifier per platform.** The list says "primary" and the platform
   picks it from `defaultTargetPlatform` (on the web, the browser's OS): ⌘ on
   macOS and iOS, Ctrl elsewhere. Only that one is registered. No `kIsWeb`
   branch. This changes today's keys, which register both, so ⌃F stops
   opening find on a Mac (in Mac text boxes it moves the cursor). It applies
   on Android and iOS too: the existing five keys stay there, Ctrl on
   Android, ⌘ on iOS.
3. **Desktop only.** New keys and the Settings tab exist only when
   `defaultTargetPlatform` is macOS, Windows or Linux, app or browser
   *(my call)*. One check, no `kIsWeb`. Phone and tablet browsers get neither:
   Flutter web reports an iPad as iOS even when it asks for the desktop site
   (`browser_detection.dart`, `maxTouchPoints`).
4. **Typing comes first.** While a text box has focus, these do nothing of
   ours and the key goes to the box: arrows, PgUp/PgDn, ⌘C, and every
   ⌥⌘ / Ctrl+Alt key, close-tab included. Ctrl+Alt is the AltGr key on
   Windows and Linux, and on many layouts AltGr plus a key types a character
   (German AltGr+2 = ²). This changes close-tab, which today fires while
   typing *(my call)*. Same pattern as today: `isEnabled` returns false and
   the key passes on. The search box's ↓ / Tab is the one exception, below.
5. **Reader keys need the Reader.** Tab, layout, navigator and scroll keys act
   only while the Reader section shows (as `OpenMainSearchAction` checks), and
   not while a dialog or the search results panel is open. An open in-page
   find bar does not block them; its text box does, by rule 4.

## How each one behaves

- **Next / previous tab:** wraps from the last tab to the first, as Chrome
  does *(my call)*. Nothing with fewer than two tabs. Through
  `switchTabProvider`, so the navigator follows.
- **Layout 1–4:** top row or keypad. Through `updateActiveTabLayoutProvider`,
  so the choice is also remembered for new tabs. The toolbar offers all four
  at every width, so there is no width check. Nothing with no tab open.
- **Previous / next text:** does exactly what the toolbar's ⏮ ⏭ buttons do,
  through the same code. Today that code is inside the reader widget
  (`_navigateToSutta` in `multi_pane_reader_widget.dart`, which also resets
  the scroll anchor, so it needs the widget). The mounted reader attaches
  itself to `readerKeyboardBridgeProvider`, and the keys call
  `_navigateToSutta` through it: buttons and keys end in the same method.
  Nothing at the first or last sutta, where the button is left out. The keys
  are the , and . keys; they answer with or without ⇧, and the Settings tab
  shows them as < and >.
- **Navigator:** flips `navigatorVisibleProvider`, as the app-bar button does.
- **Text size:** ⌘+ and ⌘− move `fontScaleProvider` by 0.1, two slider steps
  *(my call)*, inside the notifier's limits. ⌘+ also answers ⌘= and the keypad
  +. ⌘0 calls `FontScaleNotifier.reset()`. App-wide, so it works in every
  section.
- **Scroll:** moves the active tab's reader. Each tab has one scroll
  controller for every layout, so side by side scrolls as one. Only when
  focus is in the reader or on nothing. On a navigator row, a tab or a button
  the arrows keep their usual job of moving focus *(my call)*.
- **Go to results or recent searches:** with the main search box focused
  and results showing, ↓ moves to the first stop in the visible results tab.
  The stops are everything there that takes focus, in order: the reference
  row (e.g. "SN 15.3"), result rows, "See all" and "Show N more", so nothing
  is skipped *(my call)*. ↓ / ↑ step through them, and ↑ from the first goes
  back to the box. Enter opens a row (already works). With no results, ↓
  works as today. Matches the static site's search dialog (`site.js`): the
  arrows are a shortcut, Tab stays Tab.
  - **Recent searches** (the box is empty): ↓ / ↑ step through the rows
    only, as in a browser's address bar; on "Show more" or "Clear all" they
    do nothing. Tab walks everything in order — each row, its ✕, then "Show
    more" and "Clear all" — then leaves the card, as it leaves the panel.
    Tab from the box goes to the first row, Shift+Tab from it back to the
    box. Enter runs a row, Esc closes the list.
  - **After picking a recent search, or Enter in the box,** focus leaves the
    box. ↓ with focus on nothing still goes to the first result; Tab doesn't.
    Not while a dialog or menu is open.
- **Tab in the panel** is not a shortcut, so it isn't listed: it walks the
  panel in the order it shows (WCAG 2.4.3, as VS Code's search sidebar
  does): match options, chips, results tabs, then the results. Two keys are
  bound only because the panel is drawn over the reader and plain Tab would
  leave the box for the app bar and the reader behind: Tab from the box goes
  to the match options button, and Shift+Tab from that button back to the
  box. The box's clear button is skipped, as a macOS search field's is.
  With the list scrolled, Tab still goes chips → tabs → results, and the
  result it lands on is scrolled into view, as in a browser.
- **Settings:** opens on General. Works with the rail hidden, which
  closes `app-settings-dialog.md` Decision 7. If Settings is already open,
  nothing happens *(my call)*.
- **Keyboard shortcuts:** opens Settings on the Keyboard shortcuts tab. Same
  rule when Settings is already open.

## The Settings tab

- `SettingsTab.shortcuts`, between General and Anumodanā, as on the board.
  Icon: a keyboard. Label: "Keyboard shortcuts".
- Read-only. One `SettingsSection` per group above, one `SettingsRow` per
  entry, keys on the right as key caps, styled like the board.
- **Mac:** symbols in Apple's order, ⌃ ⌥ ⇧ ⌘, then the key: `⌥ ⌘ W`.
  **Windows:** words: `Ctrl Alt W`. One key cap per key, as on the board.
- **"or"** joins two ways to press the same keys: on a Mac, PgUp or fn ↑
  (Mac laptops have no Page Up). Keys side by side without it are a pair:
  ↑ ↓. Each way takes its own line (PgUp PgDn, then or fn ↑ fn ↓), so the
  row stays narrow.
- **Labels** (English and Sinhala reviewed with the user 2026-11-11): short,
  no "the", and the app's own words. "Text", not "sutta": the keys also step
  through commentaries. "Search", as on the search box: it searches the
  commentaries too, so not "Tipitaka". "Font size", as on the reader menu's
  slider. Previous before next, as the toolbar's ⏮ ⏭. Settings, Keyboard
  shortcuts and the layout rows reuse the strings already in the ARB files.

## Not in this round

- Changing keys from the app.
- New keys on the static site. Its ⇧⌘F stays as it is.
- Phones and tablets.
- Showing shortcuts in button tooltips.

## Must never happen

- A key that types into, or takes over an editing key from, a text box.
- A key that does nothing on the web because the browser keeps it.

## Check while building

Done 2026-11-10: the full unit suite, and on macOS
`integration_test/search_mode_test.dart` (now presses the platform's own
modifier, and checks the other one does nothing) and `reader_panes_test.dart`.
Open — each needs someone at the keyboard:

1. **Safari and ⌘,.** If Safari keeps it for its own settings, stop and ask
   the user before choosing another key.
2. Every new key reaches the page in Chrome, Safari and Firefox on macOS and
   in Chrome and Edge on Windows.
3. ⌘+ / ⌘− / ⌘0 change the text size, not the page zoom, in each of those.
4. **macOS menu:** `MainMenu.xib` has "Preferences…" on ⌘, with no action.
   Wire it to Settings or drop its key, so the menu never swallows ⌘,.
5. **Sinhala keyboard layout on:** [ ] , . / and the digits still match.
   Flutter falls back to US keys for these; the static site needed its own
   fallback for letters (`site.js`), so confirm it on each platform.
6. **Sinhala IME composing:** with a candidate list open in the search box,
   ↓ and Tab go to the candidates, not into the results panel.

## Left to the builder

- How an action opens the dialog: `AppShortcuts` sits in
  `MaterialApp.builder`, above the `Navigator`, so it needs a context below
  it.
- How the scroll action reaches the active tab's scroll controller, and how
  far a press scrolls.
- How search → results moves focus (a binding that is enabled only in the
  search box, or traversal order), within rule 1.
- The key-cap widget and the ARB key names.

## Tests (bare minimum)

- **Unit:** on macOS the list gives only ⌘ keys, on Windows only Ctrl.
  Every entry has a label in English and Sinhala.
- **Widget, one per new key:** next/previous tab (with wrap), next/previous
  sutta (with and without ⇧, nothing at the last sutta), a layout key,
  ⌘B, ⌘+ / ⌘− / ⌘0, ⌘, and ⌘/ open Settings on the right tab, ↓ from the
  search box lands on the first stop, arrows and a ⌥⌘ key do nothing while a
  text box has focus, ↓ on a navigator row doesn't scroll the reader.
- **Widget, Settings tab:** ⌘ symbols with the platform set to macOS, Ctrl
  words with Windows, no tab on Android and iOS.
- **Update:** `settings_dialog_test.dart` (tab list), and check
  `integration_test/search_mode_test.dart` (⇧⌘F) still passes.

## Done when

- [ ] Every key in the table works on macOS desktop and the web, and on
      Windows desktop.
- [ ] The Settings tab lists every entry, in English and Sinhala, with the
      platform's keys.
- [ ] The *Check while building* list is done.
- [ ] The tests above pass.
