# Warm dark theme (V4): code to paste

This goes with [`warm-dark-theme.md`](warm-dark-theme.md). The code is in Markdown, not `.dart` files, because a `.dart` file under `docs/` would be picked up by `flutter analyze` and fail on its imports.

| § | What | File |
|---|---|---|
| 1 | `WarmDarkThemeColors`; delete `DarkThemeColors` and `WarmThemeColors` | `lib/core/theme/app_colors.dart` |
| 2 | `AppTheme.warmDark()`; delete `dark()` and `warm()` | `lib/core/theme/app_theme.dart` |
| 3 | `DictionaryBadgeColors.dark()` | `lib/core/theme/dictionary_badge_theme.dart` |
| 4 | Light \| Dark segments + ARB key | `settings_menu_button.dart`, `app_en.arb`, `app_si.arb` |
| 5 | `AppThemeMode {light, dark}`, legacy mapping, optional system default | `lib/core/theme/theme_notifier.dart` |
| 6 | Dark text on mint highlights | `lib/presentation/widgets/reader/text_entry_widget.dart` |
| 7 | Widget fixes: chips, match menu row, Treatise icon | `pill_chip.dart`, `refine_search_dialog.dart`, `match_options_menu.dart`, `content_icons.dart` |

Line numbers are as of 2026-10-11. This code has not been compiled, so expect small fix-ups.

---

## 1. `app_colors.dart`

Delete `DarkThemeColors` and `WarmThemeColors`. They are only referenced from `app_theme.dart`, which §2 rewrites. Add:

```dart
/// Warm dark palette (V4): warm near-black ground, off-white text, sand-gold
/// accent. Neutral fills for selection; colour only in marks and highlights.
/// Design and contrast table: docs/todo/theme/warm-dark-theme.md
class WarmDarkThemeColors {
  // ============================================
  // Background & Surface (higher = lighter)
  // ============================================
  static const background = Color(0xFF201F1D); // Reader page (scaffoldBg)
  static const surface = Color(0xFF292826); // Panels, sheets, menus
  static const onSurface = Color(0xFFE8E6E1); // Body text
  static const onSurfaceVariant = Color(0xFFB4B1A9); // Muted text (opaque)
  static const surfaceContainerLowest = Color(0xFF1A1918); // Chrome: tab strip
  static const surfaceContainerLow = Color(0xFF242321); // App bar at rest
  static const surfaceContainer = Color(0xFF2E2D2A); // Cards, selected tree row
  static const surfaceContainerHigh = Color(0xFF33322F); // Gatha, search field, dialogs
  static const surfaceContainerHighest = Color(0xFF3D3B38); // Active tab, filter row
  static const surfaceDim = Color(0xFF201F1D); // = bg
  static const surfaceBright = Color(0xFF45433F); // Raised chips
  static const surfaceTint = Color(0x00000000); // No tint on elevated surfaces

  // ============================================
  // Primary group (sand-gold accent; neutral container)
  // ============================================
  static const primary = Color(0xFFD8B37A);
  static const onPrimary = Color(0xFF1F1E1C);
  static const primaryContainer = Color(0xFF2E2D2A);
  static const onPrimaryContainer = Color(0xFFF5F4F0);

  // ============================================
  // Secondary group (selected chip / pill)
  // ============================================
  static const secondary = Color(0xFFE8E6E1); // Selected filter chip fill
  static const onSecondary = Color(0xFF1F1E1C);
  static const secondaryContainer = Color(0xFF3D3B38); // Selected pill, menu row
  static const onSecondaryContainer = Color(0xFFF5F4F0);

  // ============================================
  // Tertiary group (reader highlights; same hues as light)
  // ============================================
  static const tertiary = Color(0xFF9BE3AE); // Mint: tapped word, current match
  static const onTertiary = Color(0xFF10261A); // Text on mint
  static const tertiaryContainer = Color(0xFF47468A); // Violet: search matches
  static const onTertiaryContainer = Color(0xFFC9C9F0); // Also Commentary icon

  // ============================================
  // Error group
  // ============================================
  static const error = Color(0xFFF2B8B5);
  static const onError = Color(0xFF601410);
  static const errorContainer = Color(0xFF3E2420);
  static const onErrorContainer = Color(0xFFD49A88); // Also Sutta icon (terracotta)

  // ============================================
  // Outline & Dividers (translucent hairlines)
  // ============================================
  static const outline = Color(0x24FFFFFF); // White 14%
  static const outlineVariant = Color(0x14FFFFFF); // White 8%

  // ============================================
  // Inverse group (snackbars, tooltips)
  // ============================================
  static const inverseSurface = Color(0xFFE8E6E1);
  static const inverseOnSurface = Color(0xFF1F1E1C);
  static const inversePrimary = Color(0xFF8A5A1E);

  // ============================================
  // Utility
  // ============================================
  static const scrim = Color(0xFF000000);
  static const shadow = Color(0xFF000000);

  // ============================================
  // Custom (not M3 roles)
  // ============================================
  static const heading = Color(0xFFF5F4F0); // Reader headings
  static const highlight = Color(0xFF5E5236); // Text selection (gold)
}
```

---

## 2. `app_theme.dart`

Delete `dark()` and `warm()`. Leave `light()` untouched. Add:

```dart
  /// Warm dark theme (V4): near-black ground, off-white text, sand-gold accent.
  static ThemeData warmDark({double fontScale = 1.0}) {
    const colorScheme = ColorScheme.dark(
      primary: WarmDarkThemeColors.primary,
      onPrimary: WarmDarkThemeColors.onPrimary,
      primaryContainer: WarmDarkThemeColors.primaryContainer,
      onPrimaryContainer: WarmDarkThemeColors.onPrimaryContainer,
      secondary: WarmDarkThemeColors.secondary,
      onSecondary: WarmDarkThemeColors.onSecondary,
      secondaryContainer: WarmDarkThemeColors.secondaryContainer,
      onSecondaryContainer: WarmDarkThemeColors.onSecondaryContainer,
      tertiary: WarmDarkThemeColors.tertiary,
      onTertiary: WarmDarkThemeColors.onTertiary,
      tertiaryContainer: WarmDarkThemeColors.tertiaryContainer,
      onTertiaryContainer: WarmDarkThemeColors.onTertiaryContainer,
      surface: WarmDarkThemeColors.surface,
      onSurface: WarmDarkThemeColors.onSurface,
      onSurfaceVariant: WarmDarkThemeColors.onSurfaceVariant,
      surfaceContainerLowest: WarmDarkThemeColors.surfaceContainerLowest,
      surfaceContainerLow: WarmDarkThemeColors.surfaceContainerLow,
      surfaceContainer: WarmDarkThemeColors.surfaceContainer,
      surfaceContainerHigh: WarmDarkThemeColors.surfaceContainerHigh,
      surfaceContainerHighest: WarmDarkThemeColors.surfaceContainerHighest,
      surfaceDim: WarmDarkThemeColors.surfaceDim,
      surfaceBright: WarmDarkThemeColors.surfaceBright,
      surfaceTint: WarmDarkThemeColors.surfaceTint,
      error: WarmDarkThemeColors.error,
      onError: WarmDarkThemeColors.onError,
      errorContainer: WarmDarkThemeColors.errorContainer,
      onErrorContainer: WarmDarkThemeColors.onErrorContainer,
      outline: WarmDarkThemeColors.outline,
      outlineVariant: WarmDarkThemeColors.outlineVariant,
      inverseSurface: WarmDarkThemeColors.inverseSurface,
      onInverseSurface: WarmDarkThemeColors.inverseOnSurface,
      inversePrimary: WarmDarkThemeColors.inversePrimary,
      scrim: WarmDarkThemeColors.scrim,
      shadow: WarmDarkThemeColors.shadow,
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: AppFonts.ui,
      fontFamilyFallback: AppFonts.uiFallback,
      scaffoldBackgroundColor: WarmDarkThemeColors.background,
      cardColor: WarmDarkThemeColors.surfaceContainer,
      // Hairline dividers; light uses `outline` because its outline is already soft.
      dividerColor: WarmDarkThemeColors.outlineVariant,
      colorScheme: colorScheme,
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: WarmDarkThemeColors.highlight,
        selectionHandleColor: WarmDarkThemeColors.primary,
      ),
      extensions: [
        TextEntryTheme.standard(
          headingColor: WarmDarkThemeColors.heading,
          bodyColor: WarmDarkThemeColors.onSurface,
          fontScale: fontScale,
        ),
        AppTypography.fromColorScheme(colorScheme, fontScale: fontScale),
        DictionaryBadgeColors.dark(),
      ],
    );
  }
```

`light()` and `warmDark()` now differ only in their inputs. If Graphite arrives, extract a private `_build(scheme, background, heading, selection, badges, dividerColor, fontScale)` so a third copy isn't needed. Light's output through it would be identical.

---

## 3. `dictionary_badge_theme.dart`

Next to the existing constants:

```dart
// Dark-theme variants: same hue per dictionary, lighter and softer, so the
// label (text on a 15% tint of itself) stays ≥ 4.5:1 on dark panels.
const _dictDpdDark = Color(0xFF7FB8EE);
const _dictPtsDark = Color(0xFFC99AD6);
const _dictBuddhadattaDark = Color(0xFF8FC293);
const _dictSumangalaDark = Color(0xFF6FBFB3);
const _dictVriDark = Color(0xFFF0B46A);
const _dictCriticalDark = Color(0xFFEE9590);
const _dictDpdcDark = Color(0xFF9AA5DB);
const _dictNyanatilokaDark = Color(0xFFC2A89B);
const _dictProperNamesDark = Color(0xFFE8C766);
```

Below `standard()`:

```dart
  /// Badge palette for dark themes.
  factory DictionaryBadgeColors.dark() => const DictionaryBadgeColors(
        dpd: _dictDpdDark,
        pts: _dictPtsDark,
        buddhadatta: _dictBuddhadattaDark,
        sumangala: _dictSumangalaDark,
        vri: _dictVriDark,
        critical: _dictCriticalDark,
        dpdc: _dictDpdcDark,
        nyanatiloka: _dictNyanatilokaDark,
        properNames: _dictProperNamesDark,
      );
```

Update the class doc: change "single shared palette … registered identically in light/dark/warm" to "one palette per brightness: `standard()` for light, `dark()` for dark". The same claim is in the comment block at the top of the file ("theme-independent", "single shared palette across all themes") and in `light()`'s extensions list in `app_theme.dart` ("one shared palette across all themes"); update both.

---

## 4. Picker: Light | Dark

### `settings_menu_button.dart` (about lines 145–160)

Replace the commented-out dark and warm segments with one dark segment:

```dart
      segments: [
        ButtonSegment(
          value: AppThemeMode.light,
          label: Text(l10n.themeLight),
          icon: const Icon(Icons.light_mode, size: 16),
        ),
        ButtonSegment(
          value: AppThemeMode.dark,
          label: Text(l10n.themeDark),
          icon: const Icon(Icons.dark_mode, size: 16),
        ),
      ],
```

### ARB

`app_en.arb`, next to `themeLight`:

```json
  "themeDark": "Dark",
  "@themeDark": {
    "description": "Label for the dark theme option in the theme selector"
  },
```

`app_si.arb`, next to `themeLight` (`"ශ්වේත"`). Spell it with **ළ**: `කාළ` means black (Pāli *kāḷa*), while `කාල` means time (Pāli *kāla*).

```json
  "themeDark": "කාළ",
```

Then regenerate localizations.

---

## 5. `theme_notifier.dart`

### Enum

```dart
/// Available theme modes
enum AppThemeMode {
  light, // Warm cream - daytime reading
  dark, // Warm near-black - night reading
}
```

### `loadSavedTheme()`

Unchanged except for the optional first-launch default. No mapping for a stored `warm`: the app is unreleased, and `orElse` falls back to Light.

```dart
      final saved = prefs.getString(_storageKey);

      if (saved != null) {
        final mode = AppThemeMode.values.firstWhere(
          (e) => e.name == saved,
          orElse: () => AppThemeMode.light,
        );
        state = mode;
      }
      // Optional: on first launch, start in the device's appearance.
      // else {
      //   final b = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      //   state = b == Brightness.dark ? AppThemeMode.dark : AppThemeMode.light;
      // }
```

### `currentThemeDataProvider`

```dart
  final theme = switch (mode) {
    AppThemeMode.light => AppTheme.light(fontScale: fontScale),
    AppThemeMode.dark => AppTheme.warmDark(fontScale: fontScale),
  };
```

Besides this switch, only the commented-out segment in the settings menu (§4) references `AppThemeMode.warm`. No tests do.

---

## 6. `text_entry_widget.dart`: dark text on mint

Mint is a bright fill, so the text drawn on it must switch to `onTertiary`. This applies to the dictionary-tapped word and the current in-page match. Search matches (`tertiaryContainer`) keep the body colour. In light, `onTertiary` is the heading brown `#2A2318`, a shade darker than body text, so light barely changes.

**a. In `_buildTextSpan`, next to the other colours (about line 349):**

```dart
    final dictHighlightColor = colorScheme.tertiary;
    final highlightTextColor = colorScheme.onTertiary; // text on the mint fill
    final searchHighlightColor = colorScheme.tertiaryContainer;
    final inPageMatchColor = colorScheme.tertiaryContainer;
    final inPageCurrentMatchColor = colorScheme.tertiary;
```

**b. Dictionary highlight span (about line 410):**

```dart
        spans.add(TextSpan(
          text: word,
          style: style?.copyWith(
                backgroundColor: dictHighlightColor,
                color: highlightTextColor,
              ) ??
              TextStyle(
                backgroundColor: dictHighlightColor,
                color: highlightTextColor,
              ),
          recognizer: recognizer,
        ));
```

**c. `_buildSpansWithSearchHighlight`: add a parameter and use it for the current match only (about lines 481 and 551–568):**

```dart
  List<InlineSpan> _buildSpansWithSearchHighlight({
    // …existing parameters
    Color? inPageCurrentMatchColor,
    Color? inPageCurrentMatchTextColor,
    // …
  }) {
    // …
      final highlightColor =
          isCurrentInPageMatch ? inPageCurrentMatchColor : searchHighlightColor;
      // null keeps the base colour (search matches stay body-coloured)
      final highlightTextColor =
          isCurrentInPageMatch ? inPageCurrentMatchTextColor : null;

      // …
      spans.add(TextSpan(
        text: text.substring(range.start, range.end),
        style: markedBase?.copyWith(
              backgroundColor: highlightColor,
              color: highlightTextColor,
            ) ??
            TextStyle(backgroundColor: highlightColor, color: highlightTextColor),
        recognizer: recognizer,
      ));
```

**d. Pass it at the three call sites (about lines 392, 426, 449), next to `inPageCurrentMatchColor`:**

```dart
          inPageCurrentMatchColor:
              inPageRanges.isNotEmpty ? inPageCurrentMatchColor : null,
          inPageCurrentMatchTextColor:
              inPageRanges.isNotEmpty ? highlightTextColor : null,
```

**e. Stale comments.** The doc comment at about lines 338–341 says the dictionary highlight uses `tertiaryContainer`, but the code uses `tertiary`, and calls the in-page colours "Sage Green" and "Golden Amber". The comment at about line 549 says "Golden Amber for current in-page match". Change both to name roles, not colours:
- `tertiary` (+ `onTertiary` text): tapped word, current in-page match
- `tertiaryContainer`: search matches

---

## 7. Widget fixes

### `pill_chip.dart` (about lines 40–55): raised chips in both themes

```dart
      (false, false) => (
          colors.surfaceBright, // was surfaceContainerLow
          colors.onSurfaceVariant,
          colors.outline,
        ),
      (false, true) => (colors.secondary, colors.onSecondary, colors.secondary),
      (true, false) => (
          colors.surfaceBright, // was surfaceContainerLowest
          colors.onSurfaceVariant,
          colors.outline,
        ),
```

Refine stays distinct through its tune icon; the match button ("Starts with ▾", same style) through its rounded-rectangle shape and ▾. In light, `surfaceBright` (`#FAF9F5`) is a hair lighter than the chip fill today (`#F5EEE5`) and about the same as Refine's (`#FDF8F3`).

### `refine_search_dialog.dart` (about line 239): keep the language segment matching the chips

Its comment says the unselected segment copies the `PillChip` look, so it moves with it:

```dart
              return isSelected ? cs.secondary : cs.surfaceBright; // was surfaceContainerLow
```

### `match_options_menu.dart` (about line 303): make the selected row visible

The menu needs no edge change: its shape already draws a 1px `outline` border.

```dart
          backgroundColor: selected ? colors.secondaryContainer : null,
```

The title stays `onSurface`: 8.5:1 in light and 9.0:1 in dark on that fill.

### `content_icons.dart`: Treatise icon

```dart
  } else if (isTreatise) {
    color = colorScheme.onSurfaceVariant; // was secondary
```

In light, `onSurfaceVariant` and `secondary` are both `#705E46`, so light doesn't change. In dark the icon becomes a quiet grey instead of the near-white chip fill. Update the doc comment ("Treatise (secondary warm taupe)") to match. Its "Commentary (onTertiaryContainer sage)" is stale too: that colour is charcoal in light and lavender in dark.

---

## Not in this change

- **The optional layout polish** in the spec: tab underline, chrome app bar, no filter band, inset search field, current-match ring.
- **Graphite.**
- **Light-theme notes**, such as deeper badge tones.
- **Tests.** None were written.
