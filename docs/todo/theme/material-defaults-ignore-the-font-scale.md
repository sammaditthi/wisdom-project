# Material's own text styles ignore the font-size preference

Found 2026-10-24, auditing the Settings dialog's sizes. Not started.

Every text size in the app is built from `fontScale`: `AppTheme.light/dark/warm`
pass it to `AppTypography.fromColorScheme` and `TextEntryTheme.standard`, and
the reader's font-size slider (`fontScaleProvider`) moves it. `ThemeData`'s own
`textTheme` is **not** built from it — only `fontFamily` is set — so any widget
left on its Material default is frozen at the Material 3 size whatever the
slider says.

## What is frozen

Measured 2026-10-24, sizes at scale 1.0.

| Surface | Falls through to | Frozen at | Where |
|---|---|---|---|
| `SegmentedButton` segment labels | `textTheme.labelLarge` | 14 w500 | Settings > General (Theme, App language, Content language), search Refine dialog |
| `AppBar` titles | `textTheme.titleLarge` | 22 w400 | Settings' phone layout, reader screen, research screen |
| `TabBar` labels | `textTheme.titleSmall` | 14 w500 | Settings' phone layout |

Sharpest on the web, where the default scale is `AppFonts.webDefaultScale` and
Material's is not: a row label renders a step *below* the segmented button that
sits in the same row, so the control reads larger than the label naming it. On
native at 1.5× the opposite happens — every label and hint around a segmented
button grows and the segments stay put.

The `AppBar` case is also a plain inconsistency: Settings titles itself with
`dialogTitle` (base × 1.25, w600) on desktop and with Material's 22 w400 on a
phone — the same dialog, two titles.

## The pattern already exists

Two places do it right and are the model:

- The search panel's `TabBar` builds each `Tab` with
  `typography.tabLabelFor(...)` instead of `Tab(text:)`.
- Every sheet title — citation source, dictionary — uses `dialogTitle`.

## Fix

One place. All three theme factories already hold the `AppTypography` they just
built, so they can hand it to the component themes:

- `segmentedButtonTheme` — `AppSegmentedButtonTheme` becomes a factory like
  `AppMenuTheme.of(colorScheme)` and adds `textStyle`.
- `tabBarTheme` — `labelStyle` and `unselectedLabelStyle`.
- `appBarTheme` — `titleTextStyle`.

## Decide before starting

- **Which token for the segments.** `resultTitle` matches the row labels they
  sit beside; `treeNodeLabel` keeps them a step under. Same choice decides the
  tab labels.
- **The blast radius is every caller**, not just Settings: the Refine dialog's
  language toggle, the search panel's tabs, and the reader and research app
  bars all change size with it. A visual pass at 1.0, at the web default and at
  1.5×, since a wider segment label changes the control's own width and height.
