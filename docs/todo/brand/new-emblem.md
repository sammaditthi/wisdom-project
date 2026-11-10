# New emblem

Retire the painted lotus (`assets/icons/app_logo.png`) everywhere. Feedback
(2026-11-09): too vague at phone and tab size, too much detail. At 36px the
brush ring turns into two grey rings and the lotus into a smudge; at 16px it is
a grey dot.

The new mark: a white lotus (sammā-diṭṭhi) on near-black (the mud of saṃsāra),
inside a saffron ring (the Sāsana, still alive). Flat, three colours. The
designer prompt is at the end.

## 1. Artwork

- [ ] Run the designer prompt; get a few variations.
- [ ] Compare them at real sizes, light and dark: 16 and 32 (tab), 18–36
      (toolbar), 60 (phone), 96 (loading screen).
- [ ] Commit the chosen master: SVG if we have one, else a 2048px PNG (1024
      at least). A PNG-only master gets traced to SVG (`potrace`, not
      installed yet).
- [ ] Record the three hex colours.

## 2. One script makes every copy

`assets/icons/make_icons.sh` makes the app emblem, favicon and OG card
today. The web install icons were made by hand; the native ones are
still the Flutter logo.

- [ ] Point `make_icons.sh` at the new master.
- [ ] Favicon: the whole mark (the ring is its edge on a dark tab bar), not
      the cropped disc. Consider an SVG favicon beside the PNG.
- [ ] Web install icons: `web/icons/Icon-192/512`, `Icon-maskable-192/512`.
      `apple-touch-icon` uses `Icon-maskable-192` today; Apple wants an
      opaque 180px.
- [ ] Native icons. Decide: extend `make_icons.sh`, or use
      `flutter_launcher_icons`.
  - iOS `AppIcon.appiconset`: opaque, no transparency.
  - macOS `AppIcon.appiconset`: macOS does not crop, so the shape is drawn in.
  - Android: adaptive icon (foreground + background layers) and a
    one-colour layer for themed icons. Today only `mipmap-*/ic_launcher.png`.
  - Windows `app_icon.ico`.
- [ ] OG card: new mark. Decide its background (the cream page colour today).

## 3. App

- [ ] `AppEmblem` (install screen, reader hint, web `#boot`) gets the new
      `emblem.webp` copies. Check it on light and dark.
- [ ] `web/manifest.json` `theme_color` (brown) and `background_color`: keep,
      or follow the new mark? Decide.

## 4. Static site

- [x] Breadcrumb home: drop the emblem image for the library `SiteIcon`
      below, in `site_icons.dart` with the site's other icons.
- [x] Remove the emblem PNG path: `emblemFileNames` and `SiteAssets.emblems`,
      the copy in `sitegen.dart`, the emblem check in
      `scripts/static_site/deploy.sh`, the srcset handling in
      `tool/check_links.dart`, the site emblems in `make_icons.sh`, and
      `static_site_generator/assets/emblem*.png`.
- [x] Re-derive the phone breakpoints in `stylesheet.dart`. The icon is 8px
      narrower than the emblem, so the trail steps stay 60/46/31rem and the
      fold 39rem; only the app pill moved, 69 → 68rem (2026-11-10).

## 5. Retire and tidy

- [ ] Delete `assets/icons/app_logo.png` once nothing reads it.
- [ ] Delete `assets/icons/urna_hair_relic.png` (unused); fix the stale
      comment in `test/presentation/widgets/multi_pane_reader_widget_test.dart`.
- [ ] Point the "App icons" item in
      `docs/todo/mobile-release/first-ios-release.md` §1 here.
- [x] Tests that name the site's emblem files (site asset and wiring
      tests), plus a test for the home link's name (2026-11-10).
- [ ] `CHANGELOG.md` note under `## Unreleased`.

## Breadcrumb home icon (decided 2026-11-09)

Books on a shelf, drawn by us like the site's other icons. A puskola was
tried in several forms; at 24px its long thin shape read as ☰, a plug or a
paperclip.

28px, in the leaf's colour (`--c-on-surface`), not the dimmed links': at
24px and muted it was too faint on the toolbar (2026-11-10). The link is
padded to 36px tall, as tall as the up button; its width stays 28px so the
breakpoints hold. Drawn on its own 28 grid, not a 24 drawing scaled up, which
would move every line off the pixel grid.

A 1.5 line, not the shared 1.6: every straight line sits on a .25/.75
position, so it fills whole pixels on 2x screens. Keep those positions if it
is ever redrawn. On a 1x screen each line is one solid pixel plus a grey one
and the short book looks soft; a 2px line (sharp on 1x, 2x and 3x) was tried
and turned down as too heavy (2026-11-10).

The drawing is `homeIcon` in `static_site_generator/lib/render/site_icons.dart`.

## Open decisions

- OG card background.
- Manifest colours.
- Native icons: own script or `flutter_launcher_icons`.

## Designer prompt

```
Design a minimal emblem and app icon for "Sammaditthi", a Theravāda Buddhist app for reading the Pali Canon.

MEANING
- Centre: one white sacred lotus (Nelumbo nucifera, the white "puṇḍarīka") in bloom. It stands for sammā-diṭṭhi, right view: born in the mud, rising above the water, unstained by it.
- Background: near-black, standing for the mud of saṃsāra.
- Around the lotus: a saffron-orange ring, the colour of the monks' robes. It stands for the Sāsana and the Saṅgha: complete, unbroken, still alive.

COMPOSITION
- Square canvas, 1:1, everything centred.
- The ring is one solid, unbroken circle. Its outer edge spans about 88% of the canvas width. Its thickness is about 6% of the canvas width.
- The lotus sits inside the ring and spans about 55% of the canvas width, with clear dark space between the lotus and the ring.
- Front view of a half-open bloom: one tall centre petal, two petals on each side of it, and a low outer pair. About 7 petals in all, no more.
- No stem, no leaves, no water, no text, no other objects.

STYLE
- Flat vector art in exactly three solid colours. No gradients, textures, grain, shadows, glow, highlights or 3D.
- The lotus should look natural and hand-drawn, not geometric: gently curved petals, slightly different in width and length, softly pointed tips, a little asymmetry. Not a mandala, not drawn with a compass, not perfectly mirrored.
- Petals are separated by gaps where the black background shows through. No outlines or thin lines. Each gap is at least 1.5% of the canvas width.
- Bold enough to read at tiny sizes: shrunk to a 32×32 pixel browser-tab icon, it must still clearly be a white lotus in an orange ring.

COLOURS
- Background: warm near-black, e.g. #141210
- Lotus: warm white, e.g. #F7F4EC
- Ring: saffron orange like a monk's robe, e.g. #E07B1F. Not neon, not red, not yellow.

OUTPUT
- One square image, 2048×2048 if possible (at least 1024×1024). The background fills the whole square: no rounded corners, no border, no transparency.
- If you can make vector files, also give an SVG.
- List the three colours used as hex codes.

AVOID
Buddha figures, Dharma wheels, stupas, letters or words, sparkles, light rays, glow or halo effects, water or reflections, leaves, a stem, brush strokes, watercolour, ink texture, gold, gradients, thin line art, very detailed petals.
```
