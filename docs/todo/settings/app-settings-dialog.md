# App settings dialog — plan

Started 2026-10-22. Building 2026-10-23 on `feat/app-settings-dialog`.
Design: [App settings dialog canvas](https://claude.ai/artifact/Kd5nkzPuL2PdCmtyQLGjXn).

**Goal:** app-wide settings move out of the reader's gear menu into a Settings
dialog opened from the navigation rail. The reader menu keeps only what you
adjust while reading.

**UI and wiring only.** No new preferences: every control writes the provider it
writes today.

**This release:** General and Anumodanā. Web first. The canvas's two reference
tabs and its phone screens are in *Later*.

## What the user sees

### Settings dialog (tablet and desktop)

- A gear at the foot of the navigation rail opens it. It is not a rail
  destination.
- Sidebar on the left, page on the right, close button top right. 760 × 640;
  long pages scroll.
- Esc, the close button and a tap outside close it.

| Tab | Holds |
|---|---|
| General | **Appearance:** Theme (Light \| Dark, Dark disabled — see Decisions 3). **Language:** App language (English \| සිංහල) and Content language (Pali \| Sinhala), each with a one-line hint. **Pali letters:** the three switches, under a sample line that follows them. |
| Anumodanā (Sinhala: පුණ්‍යානුමෝදනා) | Bhāṇaka lineage, Text sources, Dictionaries, Thanks, Licences & version. Two placeholder sections — see *Anumodanā*. |

### Narrow windows

Below `ResponsiveUtils.mobileBreakpoint` the dialog becomes a full-screen
`Dialog.fullscreen` with a `TabBar` instead of the sidebar. Same two page
widgets, one code path.

This is not a phone entry point — there is none this release (Decisions 4). It
exists because the rail is still shown down to 768px and a desktop window can be
dragged below that with the dialog open; without it the 760-wide dialog is
clipped.

The canvas's phone drill-down (a list, each tab pushed with a back arrow) is
right for four tabs and wrong for two. Revisit when the reference tabs land.

### Reader menu

- Its icon changes from the gear to sliders (`Icons.tune`), tooltip
  "Reader settings".
- It keeps Font size and App layout (Hide navigation bar; tablet and desktop
  only). On a phone, Font size alone.

## Decisions

1. **The split.** Settings holds what you set once and that applies everywhere:
   Theme, App language, Content language, Pali letters. The reader menu holds
   what you change while reading: Font size, and Hide navigation bar, which must
   stay there as the way back when the rail is hidden.
2. **Two tabs this release** (2026-10-23). Keyboard shortcuts and
   Transliteration are in *Later*; `SettingsTab` takes them without rework.
3. **Theme shows Light and Dark; Dark is disabled** (2026-10-23), labelled as
   coming soon. `AppThemeMode.dark` today is the old near-black `AppTheme.dark`,
   not the warm dark in `docs/todo/theme/warm-dark-theme.md`, which is the next
   piece of work. Enabling it is deleting `enabled: false` and the hint.
4. **Phones cannot reach Settings this release** (2026-10-23). The way in is a
   Settings item in the bottom navigation bar, which is a separate change
   (`docs/todo/reader/phone-chrome-auto-hide.md`). Until it lands, a phone
   browser has no way to change Theme, App language, Content language or Pali
   letters — they are removed from the reader menu at every width, not kept
   behind a width check. Accepted knowingly: no temporary branch to unpick
   later.
5. **Anumodanā is names, uses and licences** (2026-10-23) — no prose intro. The
   user reviews and expands the copy before release.
6. **Anumodanā's row icons are generic.** Real logos only if supplied, with
   permission to use them.
7. **Sinhala wording** for the new strings is a placeholder until reviewed.
8. **Rail hidden on desktop.** Settings cannot be reached until the rail is
   shown again; the switch stays in the reader menu. Parked — a Ctrl/Cmd+,
   shortcut would cover it.

## How it is built

### New files

In `lib/presentation/widgets/settings/`:

- `settings_tab.dart`: the `SettingsTab` enum with its icon and localized label.
  One enum drives the sidebar, the tab bar and the page switch.
- `settings_dialog.dart`: `SettingsDialog.show(context, {SettingsTab initial})`,
  the sidebar, the narrow-window tab bar and the header.
- `settings_row.dart`: `SettingsSection` (header), `SettingsRow` (label,
  optional hint, leading tile, trailing control, divider), `SettingsTile` (the
  rounded square holding a row's icon or a dictionary's abbreviation) and
  `settingsGutter`, the one horizontal gutter every page and the dialog header
  share — the canvas's left edges disagree with each other.
- `general_settings_page.dart`, `anumodana_page.dart`.

### Reuse

- `_ThemeSelector`, `_AppLanguageSelector`, `_ContentLanguageSelector` and
  `_PaliLettersSection` **move** out of `settings_menu_button.dart` into
  `general_settings_page.dart` — not copied. They stay private: that page is
  their only caller, so nothing is gained by making them public.
- The Pali-letter switches render as `SettingsRow`s with a trailing `Switch`,
  not the menu's compact `_MenuSwitch`, which stays behind for App layout.
- Dictionaries: `DictionaryInfo.all`, grouped by `targetLanguage`.
- Version: `AppVersion.display`. Links: `UrlLauncherUtils.launchInAppBrowser`.
  Licences page: `showLicensePage`.
- Esc: register on `overlayStackProvider`, as `RefineSearchDialog.show` does.

### Reader menu (`settings_menu_button.dart`)

- Theme, App language, Content language, Pali letters and `_VersionFootnote`
  are removed. The version now lives on Anumodanā.
- Icon `Icons.tune`; tooltip from a new `readerSettings` key.
- Renamed `ReaderSettingsMenuButton`, moved to
  `widgets/reader/reader_settings_menu_button.dart`. One call site
  (`reader_screen.dart`).

### Rail

The gear goes in `AppShell`'s `NavigationRail.trailing` with
`trailingAtBottom: true` (this SDK has it). Tooltip: the existing `settings`
key.

### Pali letters sample

`ධර්ම බුද්ධ ධම්ම චන්ද`, from
`docs/done/language/pali-letter-settings-bandi-special-toggles.md`, rendered
through `beautifyPaliText` and `paliLetterOptionsProvider` — the same pair the
reader uses. A `const` in the page, not an ARB key: Pali is Pali in both
locales, so a key would put the identical string in both files. Defaults
unchanged.

### Anumodanā

Five sections. Proper names, licence names and dictionary names are never
translated.

| Section | Rows |
|---|---|
| භාණක පරම්පරාව | **Placeholder** — one line for the user to write. The reciters' lineage that carried the canon. |
| Text sources | Buddha Jayanti Tripiṭaka · tipitaka.lk · SuttaCentral |
| Dictionaries | A hint line, then the `DictionaryInfo.all` groups |
| Thanks | **Placeholder** — one general line for everyone who helped build the app. |
| Licences & version | Fonts · Open-source licences · Version |

Each source row says where it is used in the app and carries its licence.
Checked against the upstream licence pages 2026-10-23:

- **tipitaka.lk** — [CC BY-ND 4.0](https://github.com/pathnirvana/tipitaka.lk?tab=License-1-ov-file).
  Term 4 is *"Attribution should be given to tipitaka.lk"*, and term 1 scopes
  the licence to *"the Buddha Jayanthi Pali text"* — so the row names the Pali
  text, not the Sinhala translation or the aṭṭhakathā, whose terms are still
  unanswered (`docs/general/things-to-consider-before-going-live.md`, blocker 1).
- **SuttaCentral** — CC0 1.0. `bilara-data` requires every supported
  translation to be CC0. Used by Research, and by the `sc-to-bjt` concordance
  that makes `SN 15.3` resolve. **"File Search" is Gemini's name for the store
  we upload to — never user-facing copy.**
- **DPD** — CC BY-NC-SA 4.0, and
  [its citation form](https://digitalpalidictionary.github.io/how_to_cite/) is
  *Bodhirasa Bhikkhu. Digital Pāḷi Dictionary. Version <v>. https://www.dpdict.net/*.
  The shipped version is `v0.2.20250709` (`ver2.3`, per
  `docs/todo/dictionary/dpd-provenance-and-refresh.md`); nothing in the repo
  records it, so **re-check this string when the dictionary refreshes**.
- **Noto fonts** — SIL OFL 1.1.

### Licences

`assets/fonts/OFL.txt` (new) is registered with `LicenseRegistry.addLicense` in
`main.dart`, so the bundled Noto faces appear in Open-source licences.

### Colours

Theme roles only, no hex in widgets, so Light and Dark both work. Text styles
come from `AppTypography`, not inline `TextStyle`s.

| Where | Role |
|---|---|
| Dialog page | `surfaceContainerLowest` |
| Sidebar, Pali sample | `surfaceContainerLow` |
| Selected sidebar item and segment | `secondaryContainer` |
| Icon tiles | `surfaceContainer` |
| Segment borders | `outline` |
| Dividers | `outlineVariant` |
| Text | `onSurface` |
| Hints, section labels | `onSurfaceVariant` |
| Icons, links | `primary` |

### Strings

New keys in `app_en.arb` and `app_si.arb`. Existing keys are reused wherever one
exists (`settings`, `theme`, `themeLight`, `appLanguage`, `contentLanguage`,
`paliLetters`, the three switch labels, `close`).

- Tabs: `settingsGeneral`, `settingsAnumodana`.
- General: `settingsAppearance`, `settingsLanguage`, `themeDark`,
  `themeDarkComingSoon`, `appLanguageHint`, `contentLanguageHint`,
  `paliLettersHint`, `settingsSample`.
- Reader menu: `readerSettings`.
- Anumodanā: its five section names, the three source descriptions, the
  dictionary hint, the two group labels, the two placeholder lines,
  `openSourceLicences` and its hint, `versionLabel`, `openLinkTo`.

## Later, not in this scope

- **Align every dialog to this one.** Settings is the reference: the one
  `settingsGutter`, `SettingsSection`/`SettingsRow`/`SettingsTile`, theme roles
  and `AppTypography` only, a title row with the close button top right, and
  the same full-screen fallback below `mobileBreakpoint`. The refine search
  dialog, the refine dictionary dialog and the dictionary sheet were each
  styled on their own; one pass moves them onto those pieces, which graduate
  from `widgets/settings/` to `widgets/common/` once a second caller exists.
  After this lands.
- **Keyboard shortcuts tab.** Rows from `defaultBindings()`, device's
  activators only, chosen by `defaultTargetPlatform` (on the web, the browser's
  OS): `meta` on macOS and iOS, `control` elsewhere, Esc on both. No `kIsWeb`
  branch. See `docs/todo/reader/keyboard-shortcuts-sheet.md`.
- **Transliteration tab.** Needs its own letter→key list, in alphabet order,
  beside `SinglishTransliterator` in `lib/core/utils/`: the transliterator's
  tables are ordered for matching and some letters have two keys, so they
  cannot be shown directly. A unit test converts every key in the list and
  checks the letter. This is the bulk of the remaining work.
- **The phone entry point** — a Settings item in the bottom navigation bar
  (`docs/todo/reader/phone-chrome-auto-hide.md`), and whether the drill-down
  list replaces the tab bar once there are four tabs.
- **Warm dark**, which turns the Dark segment on
  (`docs/todo/theme/warm-dark-theme.md`).
- **One `show` helper.** `RefineSearchDialog.show`, `RefineDictionaryDialog.show`
  and now `SettingsDialog.show` repeat the same overlay-stack + `showDialog`
  block three times. One helper in `widgets/common/` replaces all three; folded
  into the dialog-alignment pass above.
- **Ctrl/Cmd+,** to open Settings when the rail is hidden (Decisions 8).

## Tests

Not written as part of this (project rule), but two existing files were
renamed to follow the widget and **four tests now fail** — they all tap
`Icons.settings`, which is now `Icons.tune`, and then assert on controls that
have moved:

`test/presentation/widgets/reader_settings_menu_button_test.dart` (was
`settings_menu_button_test.dart`), all four cases:

| Test | Why it fails now |
|---|---|
| renders complete settings menu structure | expects Theme, App language, Content language, Pali letters in the menu |
| updates providers when options selected | drives the moved selectors |
| content selector shows the effective (clamped) value | the content selector moved |
| closes with the running version, in each app language | the version footnote is gone |

`integration_test/search_mode_test.dart` only checks the button is absent in
search mode; the rename is all it needed.

The first three cases belong on `GeneralSettingsPage` now; the fourth belongs
on `AnumodanaPage`. What is left to cover in the reader menu is Font size and
Hide navigation bar.

Worth covering besides: the rail's gear opens the dialog and Esc closes it; the
Pali sample follows the switches (it is transformed, so the raw string is never
what is on screen); the Dark segment is disabled; Anumodanā lists every
`DictionaryInfo.all` entry; no overflow at 390 px.

## Verified while building

A throwaway harness (run, then deleted) confirmed: the dialog opens on General
and on a given initial tab; the sidebar switches pages; the sample renders
transformed; Anumodanā scrolls to Version and lists the dictionaries; at 390 px
it is full screen with a tab bar and nothing overflows; the close button pops
it. `flutter analyze` and `dart format --set-exit-if-changed` are both clean
over `lib`, `test` and `integration_test`.

One bug it caught and that is fixed: the sidebar was a coloured `Container`,
whose `ColoredBox` swallowed the `ListTile`'s selected fill and its ink. It is
a `Material` now.

**Not verified:** the gear inside a real `NavigationRail` (`AppShell` is too
heavy to pump), and Esc — the dismiss registration is copied verbatim from
`RefineSearchDialog.show`, but nothing exercised it.

## Related

- `docs/general/things-to-consider-before-going-live.md` — blocker 1 is the
  attribution surface this page is.
- `docs/todo/dictionary/dpd-provenance-and-refresh.md` — the DPD version string.
- `docs/decisions/reading-units-and-grouping.md`.

## Done when

- [x] The rail's gear opens Settings on General; the close button and a tap
      outside close it. Esc is wired the same way the refine dialogs are, but
      untested.
- [x] Two tabs, matching the canvas.
- [x] Below 768px the dialog is full screen with a tab bar.
- [x] The reader menu shows only Font size and App layout, under the sliders
      icon.
- [x] Every colour from theme roles; every string in both ARB files.
- [x] The fonts appear in Open-source licences.
- [ ] The Sinhala strings reviewed (Decisions 7).
- [ ] The Anumodanā copy reviewed, and the two placeholders written
      (Decisions 5).
- [ ] The four stale tests rehomed — see *Tests*.
