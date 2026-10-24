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
| General | **Appearance:** Theme (two icons, Dark disabled — see Decisions 3). **Language:** App language (English \| සිංහල) and Content language (Pāli \| සිංහල), each with a one-line hint. **Pali letters:** the three switches, under a sample line that follows them. **About:** the version. |
| Anumodanā (Sinhala: පුණ්‍යානුමෝදනා) | Text sources, Dictionaries, Thanks, Licences. One placeholder section — see *Anumodanā*. |

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
3. **Theme shows Light and Dark as icons; Dark is disabled** (2026-10-23),
   labelled as coming soon. The names are tooltips, which is also what a
   screen reader announces for a segment. `AppThemeMode.dark` today is the
   old near-black `AppTheme.dark`, not the warm dark in
   `docs/todo/theme/warm-dark-theme.md`, which is the next
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
9. **First review round** (2026-10-24). Theme is icons with tooltips; Sinhala
   Dark is කාළ. Every `SegmentedButton` is a soft rectangle, from
   `AppSegmentedButtonTheme` in all three themes — except the search Refine
   dialog's language toggle, which keeps the pill it shares with the filter
   chips beside it. Content language reads `Pāli | සිංහල`, self-labelled like
   App language, from the two ARB keys the Refine dialog shares. The
   Anumodanā tab icon is `Symbols.folded_hands`. Dictionaries are
   alphabetical, and the hint says so. Open-source licences is demoted from a
   row to a plain link rather than dropped: the MIT/BSD packages and the
   bundled Noto faces (OFL) need their text readable somewhere in the app.

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
  are removed. The version now lives on General, under *About*.
- Icon `Icons.tune`; tooltip from a new `readerSettings` key.
- Renamed `ReaderSettingsMenuButton`, moved to
  `widgets/reader/reader_settings_menu_button.dart`. One call site
  (`reader_screen.dart`).

### Rail

The gear goes in `AppShell`'s `NavigationRail.trailing` with
`trailingAtBottom: true` (this SDK has it). Tooltip: the existing `settings`
key.

### Pali letters sample

`තත්රාභිරතිමිච්ඡෙය්ය හිත්වා කාමෙ අකිඤ්චනො` — Dhammapada 88 (`kn-dhp.json`
p44), rendered through `beautifyPaliText` and `paliLetterOptionsProvider` — the
same pair the reader uses. A `const` in the page, not an ARB key: Pali is Pali
in both locales, so a key would put the identical string in both files.
Defaults unchanged.

No "Sample" label above it, and no italics. The tinted rounded card already
reads as a preview, and the reader never slants Pali — the bundled Noto Serif
Sinhala has no italic face, so Flutter would synthesise a skew and the line
would stop matching the text it is previewing.

Chosen over the old `ධර්ම බුද්ධ ධම්ම චන්ද` because that line left two of
Switch 3's three rules unpreviewed and led with `ධර්ම`, which is Sinhala, not
Pali. A corpus scan settled the rest: the sample needs one cluster from each of
five classes — yansaya `්ය`, rakaransaya `්ර`, a common pair, an *active*
special pair (`ඤ්ච ට්ඨ ද්ධ ද්ව` only), and anything else for touching. Three
things can never be previewed and no sample should chase them: repaya does not
occur in Pali, Switch 1's long→short vowel step has no triggers because the
edition already uses short vowels, and `ක්ෂ` never appears. Keep `ඤ්ජ`, `ඤ්ඡ`
and `ණ්ඩ` out — they are disabled for want of a font glyph, so they would make
Switch 2 look broken.

### Anumodanā

Four sections. Proper names, licence names and dictionary names are never
translated. A fifth, භාණක පරම්පරාව — the reciters' lineage that carried the
canon — is written and commented out in `anumodana_page.dart`, waiting on its
wording; its two ARB keys stay. It returns as the first section, and Text
sources gives `isFirst` back.

| Section | Rows |
|---|---|
| Text sources | tipitaka.lk · SuttaCentral, each with its own logo |
| Dictionaries | A hint line, then the `DictionaryInfo.all` groups, alphabetical |
| Thanks | **Placeholder** — one general line for everyone who helped build the app. |
| Licences | Fonts, then Open-source licences as a plain link |

Each source row says where it is used in the app and carries its licence.
Checked against the upstream licence pages 2026-10-23:

- **tipitaka.lk** — [CC BY-ND 4.0](https://github.com/pathnirvana/tipitaka.lk?tab=License-1-ov-file).
  Term 4 is *"Attribution should be given to tipitaka.lk"*, and term 1 scopes
  the licence to *"the Buddha Jayanthi Pali text"* — so the row's licence
  sentence names the Pali text only, not the Sinhala translation or the
  aṭṭhakathā, whose terms are still unanswered
  (`docs/general/things-to-consider-before-going-live.md`, blocker 1).
  There is no separate Buddha Jayanti Tripiṭaka row: `sync-regen.sh` takes
  every byte of canon text from this one repo, the licence obliges us to the
  site rather than the edition, and a row with no link and no licence read as
  an empty one. The edition is credited in this row's own sentence instead,
  which is why it names the translation as well as the Pali.
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

#### The source logos

`assets/icons/sources/{tipitaka_lk,suttacentral}.webp`, with `2.0x/` and
`3.0x/` beside them: 36, 72 and 108px, 24 KB for all six. Both are each
project's own mark, used unmodified to credit them. Masters, if they ever need
regenerating:

| Row | Master |
|---|---|
| tipitaka.lk | `tipitaka.lk-readonly/web/public/static/images/tipitaka.lk-logo.png` |
| SuttaCentral | `suttacentral/suttacentral` → `client/img/apple-touch-icon.png` |

Two traps, both checked 2026-10-24. tipitaka.lk's `logo-500x500.png` is the
black Buddha Jayanti seal, not their mark — its ring of Sinhala text turns to
noise at tile size and the line art disappears on a dark surface; the gold
wheel above holds up on both. SuttaCentral's `android-chrome-512x512.png` has
an opaque blue background baked in, so only `apple-touch-icon.png` is
transparent. They also publish a real SVG (`client/img/sc-icon-home.js`,
`sc_logo`), unused: the app has no `flutter_svg` dependency and two icons do
not justify one.

A logo gets no tile at all: `SettingsTile`'s `imageAsset` skips the
`surfaceContainer` square and fills the whole 36px the other tiles occupy, so
rows still line up. Both marks read as round, so they sit together without one.

Three things the generation step has to do, each of which showed up as a soft
or mismatched logo on screen first:

- **Size the variants for 36px, not 24.** Flutter picks a variant by device
  pixel ratio and assumes the asset is drawn at its nominal size, so a 48px
  `2.0x` file drawn into 72 device px is upscaled and visibly soft. The
  variants must be 36 / 72 / 108.
- **Trim to the alpha bounding box first.** SuttaCentral's icon carries ~12%
  transparent padding and tipitaka.lk's none, so untrimmed they render
  noticeably different sizes in the same box.
- **Unsharp mask after the Lanczos downscale** (radius 0.6, 70%) — a 500px
  master losing 93% of its width goes soft without it.

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
  `paliLettersHint`.
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

Written 2026-10-24, after the build. The suite is 726 passing; it was 662
passing and 4 failing.

All four failures were in `settings_menu_button_test.dart`, and all four died
on the same first line — `tap(find.byIcon(Icons.settings))`, which is
`Icons.tune` now. Their deeper assertions never ran.

| File | Covers |
|---|---|
| `test/presentation/widgets/reader/reader_settings_menu_button_test.dart` | The reader menu, moved beside its widget and cut back to Font size and App layout. Every control that left is asserted ABSENT, so none can drift back beside its copy on General. The slider's 0.05 rounding, Reset appearing only off-default, the rail switch, and Font size alone on a phone. |
| `test/presentation/widgets/settings/general_settings_page_test.dart` | The three rehomed cases plus the page: the four sections, the theme segments (Dark disabled, names as tooltips, a tap on it cannot select), both language selectors, the clamped content value, the version in both app languages, and the Pali sample following each switch. |
| `test/presentation/widgets/settings/settings_dialog_test.dart` | Both shapes: sidebar above 768px with the width clamp, full screen with a tab bar below it. Opening on a given tab, switching pages, the close button, a tap outside, the shared gutter — and **Esc**, against `overlayStackProvider`. |
| `test/presentation/widgets/settings/anumodana_page_test.dart` | The attribution surface. The load-bearing case is that the two hardcoded groups account for all of `DictionaryInfo.all`: a third `targetLanguage` would be credited nowhere. Also alphabetical order on screen, DPD's mandated citation, the logos, and `showLicensePage`. |
| `test/presentation/widgets/settings/settings_row_test.dart` | `SettingsSection` / `SettingsRow` / `SettingsTile` on their own, since the dialog-alignment pass gives them more callers. Includes why `mergeSemantics` is off for a `SegmentedButton`. |
| `test/presentation/screens/app_shell_test.dart` | The rail's gear: at the foot, not a destination, opens over whichever section is showing. Pins the two accepted gaps (Decisions 4 and 8) so neither is forgotten — each flips when its follow-up lands. |
| `test/core/theme/app_segmented_button_theme_test.dart` | All three themes carry the shape, and a button's own shape still wins. |

Two existing files were edited: `refine_search_dialog_test.dart` now pumps the
real theme and asserts its toggle keeps its pill against the app-wide shape,
and `pump_app.dart` takes an optional `theme`. One helper is new,
`test/helpers/test_view.dart`, for the width-dependent layouts.

Prose on Anumodanā is asserted through `AppLocalizations`, not as literals —
the copy is still under review (Decisions 5 and 7), and what has to hold is
that the right key reaches the right row. The two exceptions are DPD's citation
form, which its licence mandates, and the Noto face names.

Integration: `search_mode_test.dart` and `search_language_toggle_test.dart`
both pass on macOS. Nothing else in `integration_test/` touches the shell, the
rail, the reader menu or the moved controls.

## Verified while building

A throwaway harness (run, then deleted) confirmed the dialog's shapes and
pages by eye; the tests above now hold all of it. `flutter analyze` and
`dart format --set-exit-if-changed` are clean over `lib`, `test` and
`integration_test`.

One bug the harness caught and that is fixed: the sidebar was a coloured
`Container`, whose `ColoredBox` swallowed the `ListTile`'s selected fill and
its ink. It is a `Material` now.

`AppShell` turned out to be pumpable after all — two overrides (the tree data
source and SharedPreferences) are the whole harness, so the gear is covered in
a widget test rather than left to the integration suite.

## Related

- `docs/general/things-to-consider-before-going-live.md` — blocker 1 is the
  attribution surface this page is.
- `docs/todo/dictionary/dpd-provenance-and-refresh.md` — the DPD version string.
- `docs/decisions/reading-units-and-grouping.md`.

## Done when

- [x] The rail's gear opens Settings on General; the close button, a tap
      outside and Esc all close it — all four covered by tests.
- [x] Two tabs, matching the canvas.
- [x] Below 768px the dialog is full screen with a tab bar.
- [x] The reader menu shows only Font size and App layout, under the sliders
      icon.
- [x] Every colour from theme roles; every string in both ARB files.
- [x] The fonts appear in Open-source licences.
- [ ] The Sinhala strings reviewed (Decisions 7).
- [ ] The Anumodanā copy reviewed, and the two placeholders written
      (Decisions 5).
- [x] The four stale tests rehomed — see *Tests*.
