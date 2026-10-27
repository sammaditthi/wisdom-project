# Warm dark theme (V4)

This is the dark theme for the app: a warm near-black page, off-white text, one sand-gold accent, and highlights you can find at a glance. A second, cooler dark theme (**Graphite**) may come later on the same role map.

Code to paste is in [`warm-dark-code.md`](warm-dark-code.md). The visual reference is the "V4" row of the *Wisdom dark theme* design canvas. No colour here has been applied in `lib/` yet.

Status: palette, highlights and picker are settled, and none of it has run on a device. The one piece of layout built ahead of the theme is the search box (see [Surfaces](#surfaces)).

## Decisions

| Question | Decision |
|---|---|
| Overall look | **Modern warm.** Fills stay neutral and colour goes only into small marks: links, active icons, the tab indicator, the focus ring, highlights. The earlier versions filled selections with brown, olive and sienna, which read as dated in dark. |
| Ground | A warm near-black: page `#201F1D`, chrome `#1A1918`. Its colour cast is about as faint as Claude desktop's. |
| Accent | **Sand-gold `#D8B37A`.** Its lightness matches muted sand, with a little more colour so links stand out from body text. It leans gold, not orange. Think of an aged palm-leaf manuscript, not robe cloth. |
| Reds | Only as small marks: the Sutta icon in terracotta `#D49A88`. Its source is the lacquered cover boards of palm-leaf books. |
| Highlights | Like light, they must be found at a glance. The tapped word and current match are a bright mint fill with dark text. Search matches are violet. Selection is gold. Each keeps the same hue it has in light (see [Highlights](#highlights)). |
| Theme picker | Two buttons, **Light \| Dark**. No dark-style switch for now. |
| Light theme | Unchanged. Optional suggestions are at the end. |

## Principles

1. **No pure black, no pure white.** Body text sits at 13:1 contrast on the page. Pure white on black glares and blurs at the edges over long reading.
2. **Higher means lighter.** The chrome (app bar, tabs, navigator) is darkest. The reading page is one step up, and panels, menus and dialogs rise from there. This follows M3's surface-container ladder and Apple's base and elevated backgrounds.
3. **Colour only in marks.** Selected rows and pills are a lighter neutral grey. Colour goes into the icon, the underline or the ring. Dark coloured fills turn brown, and brown reads as old.
4. **One accent.** On dark, thin marks need a light tone to be seen, so the same sand-gold serves links and marks. A second, deeper accent would make 2px marks harder to see.
5. **Highlights pop and stay readable.** Bright fills get dark text; text never sits light-on-bright. Find-type highlights should stand out from the page; read-through highlights stay visible but calmer.
6. **Every role is a solid colour,** except the two outline roles, which are translucent white hairlines, and `surfaceTint`, which is transparent to switch the tint off. This fixes the dimming bug at its root (see [Known issues](#known-issues--resolutions)).
7. **Contrast:** at least 4.5:1 for all text; 7:1 or better for reading text (Apple's target for custom colours); at least 3:1 for marks that aren't text.

## Palette

### Surfaces

| Role | Light | Warm dark | Used for |
|---|---|---|---|
| `surfaceContainerLowest` | `#FDF8F3` | `#1A1918` | Chrome: tab strip, resizable divider well |
| `background` (scaffold) | `#FAF9F5` | `#201F1D` | Reader page |
| `surfaceDim` | `#DED8CE` | `#201F1D` | = page |
| `surfaceContainerLow` | `#F5EEE5` | `#242321` | App bar at rest, grouped result tile, Singlish preview |
| `surface` | `#FFFFFF` | `#292826` | Panels, sheets, menus, in-page search bar |
| `surfaceContainer` | `#EDE6DD` | `#2E2D2A` | Cards, app bar scrolled, **selected tree row** |
| `surfaceContainerHigh` | `#E8DFD0` | `#33322F` | Gatha block, search field, dialogs (Flutter's M3 default) |
| `surfaceContainerHighest` | `#E0D7C8` | `#3D3B38` | Active tab, filter row |
| `surfaceBright` | `#FAF9F5` | `#45433F` | Raised chips (after code §7) |

Every neutral has a colour strength (LCh chroma) under 3: warm, but not brown.

The search box is already built this way (2026-10-27): `surfaceContainerHigh`
at rest, `surfaceContainer` when the reader is scrolled so it merges with the
app bar, an `outline` hairline, and a `primary` ring when focused. Its fill
never moves on focus — M3 has no focus container for a text field, only an
indicator — so a raised pill is settled, not open. The gold ring reads 6.5:1
on that fill here.

### Text

| Role | Light | Warm dark | Notes |
|---|---|---|---|
| `onSurface` | `#422701` | `#E8E6E1` | Body text. A clean off-white, not cream. |
| `heading` (custom) | `#2A2318` | `#F5F4F0` | One step brighter than body, same hue, as in light. |
| `onSurfaceVariant` | `#705E46` | `#B4B1A9` | Muted text. Solid, no alpha. |

### Accent and selection

| Role | Light | Warm dark | Notes |
|---|---|---|---|
| `primary` | `#5A3A18` | `#D8B37A` | Sand-gold: links, active icons, focus, slider, switch, tab indicator |
| `onPrimary` | `#FFFFFF` | `#1F1E1C` | Text on gold fills (filled button, send) |
| `primaryContainer` | `#BAC095` | `#2E2D2A` | **Neutral.** Toggle on, Refine with filters, update banner, research chips |
| `onPrimaryContainer` | `#2A2318` | `#F5F4F0` | Selected tree label, badge label, FTS snippet text |
| `secondary` | `#705E46` | `#E8E6E1` | Selected filter chip fill (near-white) |
| `onSecondary` | `#FFFFFF` | `#1F1E1C` | Selected chip label |
| `secondaryContainer` | `#D0CABE` | `#3D3B38` | Selected pill, selected menu row, segmented button |
| `onSecondaryContainer` | `#2A2318` | `#F5F4F0` | |
| `surfaceTint` | `#5A3A18` | transparent | Avoids a gold cast on elevated surfaces |

In light, selection fills carry colour (olive, greige). In dark they're neutral greys: pastel fills read as airy in light, but dark coloured fills read as wood or leather.

### Highlights

| Role | Light | Warm dark | Notes |
|---|---|---|---|
| `tertiary` | `#ADEBB3` mint | **`#9BE3AE` mint** | Fill for the tapped word and the current in-page match |
| `onTertiary` | `#2A2318` | **`#10261A`** | Text on that fill. **Needs a small code change** (see code §6). |
| `tertiaryContainer` | `#D3D3FF` lavender | **`#47468A` violet** | Fill for search matches, in the reader and in result snippets |
| `onTertiaryContainer` | `#26282F` | `#C9C9F0` | Commentary icon |
| `highlight` (selection, custom) | `#FFE680` yellow | **`#5E5236` gold** | Text selection; body text stays light on it |

### Error, outline, inverse

| Role | Light | Warm dark | Notes |
|---|---|---|---|
| `error` | `#B3261E` | `#F2B8B5` | |
| `onError` | `#FFFFFF` | `#601410` | |
| `errorContainer` | `#FFDAD0` | `#3E2420` | |
| `onErrorContainer` | `#410001` | `#D49A88` | Also the **Sutta icon**: terracotta |
| `outline` | `#D6C9B8` | white 14% (`0x24FFFFFF`) | Field and chip borders, menu edge |
| `outlineVariant` | `#E0D7C8` | white 8% (`0x14FFFFFF`) | Dividers (`dividerColor` in dark) |
| `inverseSurface` | `#362F25` | `#E8E6E1` | Snackbar, tooltip |
| `onInverseSurface` | `#F5EEE5` | `#1F1E1C` | |
| `inversePrimary` | `#FFB77C` | `#8A5A1E` | Snackbar action |
| `shadow` / `scrim` | `#2A2318` / `#000000` | `#000000` / `#000000` | |

The two outlines are translucent so a hairline looks the same on every surface. Nothing in `lib/` calls `outline.withValues(…)` today, so there's no alpha-replacement risk. Keep it that way.

## Contrast: light vs warm dark

Calculated with the WCAG 2 formula.

| Pair | Roles | Light | Warm dark |
|---|---|---|---|
| Body text on page | `onSurface` on bg | 13.1 | 13.2 |
| Reader heading on page | `heading` on bg | 14.7 | 15.0 |
| Gatha text on gatha block | `onSurface` on `surfaceContainerHigh` | 10.4 | 10.3 |
| Muted text on page | `onSurfaceVariant` on bg | 5.9 | 7.7 |
| Muted text on panel | `onSurfaceVariant` on `surface` | 6.2 | 6.9 |
| Muted text on dialog / search field | `onSurfaceVariant` on `surfaceContainerHigh` | 4.7 | 6.0 |
| Chip label, today | `onSurfaceVariant` on `surfaceContainerLow` | 5.4 | 7.3 |
| Chip label on raised chip (after code §7) | `onSurfaceVariant` on `surfaceBright` | 5.9 | **4.6** |
| Link / icon on page | `primary` on bg | 9.7 | 8.4 |
| Link / icon on panel | `primary` on `surface` | 10.2 | 7.5 |
| Text on primary fill | `onPrimary` on `primary` | 10.2 | 8.4 |
| Selected tree label | `onPrimaryContainer` on `surfaceContainer` | 12.5 | 12.5 |
| Selected chip label | `onSecondary` on `secondary` | 6.2 | 13.4 |
| Text on selected pill | `onSecondaryContainer` on `secondaryContainer` | 9.5 | 10.1 |
| Tapped word / current match | `onTertiary` on `tertiary` | 11.3 | 10.6 |
| Body text on search match | `onSurface` on `tertiaryContainer` | 9.5 | 6.7 |
| FTS snippet text | `onPrimaryContainer` on `tertiaryContainer` | 10.7 | 7.6 |
| Body text on selection | `onSurface` on highlight | 11.1 | 6.2 |
| Commentary icon on page | `onTertiaryContainer` on bg | 14.0 | 10.3 |
| Sutta icon on page | `onErrorContainer` on bg | 16.3 | 6.9 |
| Text on error container | `onErrorContainer` on `errorContainer` | 13.2 | 5.9 |
| Error text on page | `error` on bg | 6.2 | 9.6 |
| Snackbar text | `onInverseSurface` on `inverseSurface` | 11.5 | 13.4 |
| Snackbar action | `inversePrimary` on `inverseSurface` | 7.7 | 4.7 |

Findability, measured as the highlight's lightness against the page:
- **Tapped word / current match:** 11:1 in dark. In light it stands out by colour rather than lightness, at 1.3:1.
- **Search matches:** 2:1 in dark. Visible, but calmer than the current match.

## Highlights

Readers use highlights for two different jobs, and good apps treat them differently:

- **Find highlights** are transient and must be spotted instantly: the tapped word and the current in-page match. Browsers keep these bright (yellow or orange) even in dark mode, and switch the text on them to dark. Firefox users complain when the current match blends into the page.
- **Read-through highlights** can be many per page, and you read through them: search matches. Editors keep these calmer. VS Code requires its "other matches" colour to be translucent and saves a strong fill for the current match. Readwise Reader uses muted highlighter tones that work on light and dark.
- **The trap is a bright fill with light text.** Scrivener's bright yellow find highlight in dark mode was unreadable, and its makers moved to a darker yellow.

Applied here:

- **`tertiary` mint `#9BE3AE` with dark text `#10261A`.** Bright as a highlighter, not neon. Fully saturated green behind Sinhala serif glares and makes the strokes shimmer at night. It's the same hue as light's mint, so "the word I tapped / where I am" is green in both themes.
- **`tertiaryContainer` violet `#47468A`, body text stays light.** Clearly violet, about twice the colour strength of the first V4 draft, which looked like grey boxes. It's the same family as light's lavender.
- **Selection: gold `#5E5236`.** It matches light's yellow and echoes the accent, the way macOS tints selection with the accent colour.
- **One mechanism.** Flutter's `RenderParagraph` paints the selection *behind* the text (`paintSelection` runs before `_textPainter.paint`), so solid selection colours are safe. That's why light's solid yellow already works.
- **The only code change** is setting the text colour where `tertiary` is used as a background (code §6). Light barely changes: the text on mint goes from body brown `#422701` to the darker heading brown `#2A2318`.

`tertiary` is now used the way M3 intends in dark: a light tone with dark text on it. The earlier worry about the role being used off-spec goes away. A separate `ReaderHighlightColors` extension is no longer needed for this theme.

## Dictionary badges

The badge draws its colour as **text** on a 15% tint of itself. With the shared Material-500 palette, PTS, DPDC and ND drop to about 2:1 on a dark panel. Dark themes get a second palette with the same hue per dictionary, lighter and softer:

| Dict | Standard (light) | Dark | Dark label on panel |
|---|---|---|---|
| DPD | `#2196F3` | `#7FB8EE` | 5.2 |
| PTS | `#9C27B0` | `#C99AD6` | 4.8 |
| BUS/BUE | `#4CAF50` | `#8FC293` | 5.4 |
| MS | `#009688` | `#6FBFB3` | 5.2 |
| VRI | `#FF9800` | `#F0B46A` | 5.8 |
| CR | `#F44336` | `#EE9590` | 5.0 |
| DPDC | `#3F51B5` | `#9AA5DB` | 4.7 |
| ND | `#795548` | `#C2A89B` | 5.0 |
| PN | `#FFC107` | `#E8C766` | 6.4 |

This changes the "one shared palette" decision in `docs/done/dictionary/dictionary-badges-shared-palette.md` to "one palette per brightness".

The edition badge in search results uses `tertiary` at 30% over the panel. In dark that comes out as a soft mint `#4B604F`, with its label (`onPrimaryContainer`) at 6.2:1. That works as is.

## Content-type icons

| Type | Role | Light | Warm dark |
|---|---|---|---|
| Sutta | `onErrorContainer` | maroon `#410001` | terracotta `#D49A88` |
| Commentary | `onTertiaryContainer` | charcoal `#26282F` | lavender `#C9C9F0` |
| Treatise | `secondary` | taupe `#705E46` | **near-white `#E8E6E1`** ⚑ |

⚑ In dark, `secondary` is the near-white fill of the selected chip, so the Treatise icon becomes the brightest icon in the tree. Code §7 points Treatise at `onSurfaceVariant` instead. In light that's the same colour (`#705E46`), so nothing changes there; in dark it becomes a quiet grey `#B4B1A9`.

The navigator draws unselected icons at 80% alpha and selected icons in `onSurface`. Both are fine with these values.

## Known issues → resolutions

These are from `dark-theme.md`, plus the ones marked new, found while designing or in later review.

| Issue | Resolution | Code change? |
|---|---|---|
| **Dimmed text doesn't dim** (`onSurfaceVariant` had alpha 0.7, and `withValues(alpha:)` replaces alpha rather than multiplying) | `onSurfaceVariant` is now solid `#B4B1A9`, so `withValues(alpha: x)` dims as it does in light. | Theme only. |
| **Chips look sunken** (chip on `…Low`, row on `…Highest`; in M3 dark, Low is darker) | Chip fill (and Refine at rest) → `surfaceBright`, which is lighter than Highest in both themes. | `pill_chip.dart`, two role swaps, and the refine dialog's language segment (code §7). |
| **Selected chips are loud** (orange `secondary`) | `secondary` is now a near-white fill with dark text: clearly selected, no colour noise. | Theme only. |
| **White ring on Refine with filters** | Border = sand-gold `primary`, fill = neutral `primaryContainer`. | Theme only. |
| **Selected row in the match menu barely shows** | Fill → `secondaryContainer` (light greige, dark `#3D3B38`). | `match_options_menu.dart` (code §7). |
| **Menus merge into panels in dark** (new). The match menu is `surface` on a `surface` panel, and shadows barely show on dark. | Already handled: the menu's shape draws a 1px `outline` border. The translucent `outline` keeps that edge visible in dark. | None. |
| **Recent-searches card has no edge in dark** (new; 2026-10-27). It is a hand-rolled `Material(elevation: 8)` on `surface` with no border, so the row above does not cover it — that one is about `MenuAnchor`, which gets its edge from `AppMenuTheme`. On the reader page it comes out at 1.12:1, carried by a shadow that barely shows in dark. Light is 1.05:1 but white on cream with a real shadow reads fine. | Undecided, and a border was declined for light. Either give it an `outline` border in dark only, or raise the card: `surfaceContainerHighest` 1.48:1, `surfaceBright` 1.67:1. | `recent_search_overlay.dart`, one line. |
| **Highlights too dim to find** (new; V4 draft) | Bright mint with dark text, a stronger violet, and gold selection. See [Highlights](#highlights). | `text_entry_widget.dart` (code §6). |
| **Treatise icon too bright** (new) | Use `onSurfaceVariant`. | `content_icons.dart`, one line (code §7). |

## Theme picker

**Light | Dark**, two buttons in the existing Theme segment of the settings menu.

- `AppThemeMode` becomes `{light, dark}`. `dark` builds `AppTheme.warmDark()`. The old `AppThemeMode.warm`, `AppTheme.dark()`, `AppTheme.warm()`, `DarkThemeColors` and `WarmThemeColors` are removed.
- No migration for a stored `warm` value: the app is unreleased, and the existing `orElse` falls back to Light.
- New ARB key `themeDark`: EN "Dark", SI "කාළ", paired with "ශ්වේත". It is spelled with ළ: `කාළ` means black (Pāli *kāḷa*), while `කාල` means time (Pāli *kāla*).
- **Optional:** on first launch, with no saved choice, start in the device's appearance. Still two buttons, but people who use dark mode at night land in dark. Apple's HIG advises respecting the system setting, and this does it without a third button. Code §5 has it, behind a comment.
- **Platform note:** on macOS the window title bar follows the *system* appearance, so a dark app on a light Mac shows a light title bar. The optional first-launch default reduces how often this happens.

## Graphite (later)

Same role map; only the neutrals change: a cool graphite at about 220° hue, 3–5% saturation, with the same lightness steps as Warm. Highlights, accent rules and contrast targets carry over. When it lands, the picker may grow a dark-style choice.

## Optional layout polish (from the V4 canvas)

These aren't needed for the theme. The canvas shows them, and each is a small widget change:

- **Active tab:** a 2px `primary` underline instead of a `…Highest` fill.
- **App bar and tab strip** on `surfaceContainerLowest`, so the chrome is one dark frame and the reading page is the lit panel inside it.
- **Search pane:** drop the filled band behind the filters; rest chips outlined and transparent.
- **Current in-page match:** add a 1.5px `primary` ring on top of the mint fill.

## Optional light-theme notes

These aren't applied, and each is independent.

1. **Badge labels in light are low contrast.** On their own 15% tint over white: VRI 1.9, PN 1.5, BUS 2.4, DPD 2.7, CR 3.0, MS 3.1. Deeper tones of the same hues pass AA: for example VRI `#9A4F00` 4.8, PN `#765A00` 5.2, BUS `#276B2B` 5.2.
2. **`outline` is very soft** at 1.5:1. That's fine for dividers, but low for either search field's border: the in-page one, and the main box since it took an `outline` hairline (1.23:1 in light, 1.57:1 in warm dark — the softer of the two is light). Fix a field locally if it feels lost.
3. **`shadow`:** `docs/done/theme/light_theme_m3_alignment_plan.md` says `#3A2510`, but the code has `#2A2318`. Align one with the other.

## Rollout

1. **Theme:** code §1–§5. This is enough to switch to Dark and read.
2. **Highlights:** code §6. Do this together with step 1, or the mint fill shows light text.
3. **Widget fixes:** code §7, covering chips, the match menu and the Treatise icon.
4. **Optional:** the layout polish above.
5. **Later:** Graphite.

### Check by hand (both themes, phone and desktop)

- **Reader:**
  - Pāli and Sinhala body text, all heading levels, gatha block, footnotes.
  - A long sutta at 1.5× font scale.
  - A 20-minute night read on the phone.
- **Highlights:**
  - Tap a word, open a sutta from FTS, run find-in-page with a current match, select text.
  - All four should be distinct. Mint text must be dark.
- **Navigator:** Sutta, Commentary and Treatise icons; selected node; hover.
- **Search pane:**
  - Filter chips at rest and selected; Refine with filters on.
  - The match menu, including its edge and selected row.
  - All nine dictionary badges; the edition badge; grouped results.
- **Tabs:** active vs inactive; resizable divider while dragging.
- **Sheets and dialogs:** dictionary sheet, settings, snackbar, tooltip, update banner.
- **Research:** dimmed model label, citation chips, send button.
- **System settings:**
  - iOS: Increase Contrast.
  - macOS: Increase contrast and Reduce transparency.
  - Android: High contrast text.

## To revisit

Found in review (2026-10-11); not decided.

1. **"Chrome is darkest" (Principle 2) isn't true yet.** The app bar at rest is `surfaceContainerLow` (`#242321`), one step *lighter* than the page. Only the optional polish (app bar on `…Lowest`) makes the principle hold. Adopt that polish with the theme, or reword the principle.
2. **The chip fix costs label contrast in dark.** Chip labels drop from 7.3 (on `…Low`) to 4.6 (on `surfaceBright`), just over AA. And `surfaceBright` on the `…Highest` row is only a hair lighter (about 1.1:1), so "raised" is subtle. Compare with the "no filter band, outlined transparent chips" polish before choosing.
3. **Toggle "on" barely shows in dark.** `CircularToggleButton` (dictionary sheet) fills with neutral `primaryContainer` `#2E2D2A` on a `#292826` sheet: 1.07:1. Only the icon brightening shows the state. Principle 3 says colour goes in the icon: consider a `primary` icon when on.
4. **Reference result row loses its tint.** The "SN 15.3" row in search results (`search_results_panel.dart`, `_ReferenceResultTile`) is `primaryContainer` at 22%. In dark the neutral container makes that `#2A2927` on `#292826`, so the row looks plain. Decide whether it needs its own fill.
5. **Design canvas link.** The "V4 row of the *Wisdom dark theme* design canvas" has no link or path. Add where it lives.

## References

- **Apple HIG:**
  - *Dark Mode:* base vs elevated backgrounds; minimum contrast 4.5:1, 7:1 for custom small text; respect the system setting.
  - *Accessibility:* 4.5:1 up to 17 pt; 3:1 at 18 pt or bold.
  - *Color:* "in dark environments, colors appear bright and saturated."
- **Material 3 color roles,** dark baseline tones (material-components-android `docs/theming/Color.md`): primary and tertiary at tone 80 with their on-colours at 20; surface 6; containers 4, 10, 12, 17, 22; surfaceBright 24.
- **Highlights:**
  - Scrivener forum, "In Dark Mode the Find highlight color is yellow": a bright fill with light text is unreadable.
  - Mozilla Connect, current find-match visibility.
  - VS Code theme colour reference: `findMatchHighlightBackground` must be translucent.
  - Readwise Reader design notes: muted highlighter tones on both themes.
- **Flutter `RenderParagraph.paint`:** selection is painted before the text, so solid selection colours are safe.
- **Daily Planner** `[data-theme="dark"]`: the source of the ground tones.
