# Keyboard shortcuts sheet — plan

Started 2026-10-11. Not started.

The search box used to show its shortcut (Ctrl+Shift+F). It was removed on 2026-10-09 because it also showed on touch tablets with no keyboard, and it was decided that shortcuts get their own sheet (`search-pane-redesign-plan.md`, Task 9). Today nothing in the app tells people the shortcuts exist.

**Goal:** one sheet that lists every keyboard shortcut, opened from the keyboard and from the app.

## Shortcuts today

All in `defaultBindings()` (`lib/presentation/keyboard/keyboard_bindings.dart`). Ctrl on Windows, Linux, web and Android; Cmd on macOS and iOS.

| Keys | Does |
| --- | --- |
| Esc | Closes the top overlay |
| Ctrl/Cmd+F | Find in page |
| Ctrl/Cmd+Shift+F | Main search |
| Ctrl/Cmd+Alt+W | Closes the reader tab |
| Ctrl/Cmd+C | Copies the selection |

## Rules

- The sheet reads its rows from `defaultBindings()`, so a new shortcut can't be left off. Each intent needs a label in `app_en.arb` and `app_si.arb`.
- It shows only the keys for the platform it runs on: Cmd on Apple platforms, Ctrl elsewhere.

## To decide

1. **The key that opens it.** Common choices: `?` (Gmail, GitHub, YouTube) or Ctrl/Cmd+/ (Google Docs, Slack). `?` can't work while a text field has focus, because it types a "?". Ctrl/Cmd+/ works everywhere.
2. **Where it opens from in the app.** For example a "Keyboard shortcuts" item in the settings or the app menu. Show it only where a keyboard is likely (desktop and web), or everywhere?
3. **Its shape.** A dialog on wide screens and a bottom sheet on phones, or the same at every width.

## Done when

- [ ] The key opens the sheet from anywhere in the app, and Esc closes it.
- [ ] The app menu or settings opens it too.
- [ ] Every entry in `defaultBindings()` has a row, in English and Sinhala.
