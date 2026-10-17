#!/bin/bash
# Small derivatives of app_logo.png, the 1024px master. The master stays in the
# repo but is never shipped: pubspec.yaml lists emblem.webp, not this folder.
# Requires: Pillow, with WebP (pip install Pillow).
#
# Emits:
#   emblem.webp  the app's emblem (AppEmblem), shown at 96pt: the loading
#                screens and the reader hint. Lossless, 96px, with 192, 288 and
#                384px copies in 2.0x/, 3.0x/ and 4.0x/ for sharper screens.
#   favicon.png  32px, the centre disc only (the outer ring is noise at tab
#                size), into web/. The static site reads that same file.
#   emblem.png   the static site's toolbar mark, drawn at 36px, into
#                static_site_generator/assets/, with emblem@2x.png and
#                emblem@3x.png beside it for srcset. PNG, which every browser
#                reads.
#   og-card.png  the static site's 1200x630 link-preview card, beside the
#                emblem copies.
#
# Run by hand and commit the output, like ../fonts/subset_fonts.sh.

set -euo pipefail
cd "$(dirname "$0")"

python3 - <<'PY'
import json
import os
from PIL import Image, ImageDraw

logo = Image.open("app_logo.png").convert("RGBA")

# One copy per screen density, which Flutter's AssetImage and #boot in
# web/index.html pick from, so it is drawn 1:1. Shrinking one large copy at
# draw time leaves jagged edges.
# Pillow resizes RGBA with premultiplied alpha, so the edge gets no dark fringe.
for scale in (1, 2, 3, 4):
    folder = "" if scale == 1 else f"{scale}.0x/"
    if folder:
        os.makedirs(folder, exist_ok=True)
    logo.resize((96 * scale, 96 * scale), Image.LANCZOS).save(
        folder + "emblem.webp", lossless=True, quality=100, method=6)

# The dark disc the lotus sits on, centred in the 1024px master.
disc = logo.crop((200, 200, 824, 824))
size = disc.size[0]
# A circle drawn 4x and scaled down, for a smooth edge.
mask = Image.new("L", (size * 4, size * 4), 0)
ImageDraw.Draw(mask).ellipse((0, 0, size * 4 - 1, size * 4 - 1), fill=255)
mask = mask.resize((size, size), Image.LANCZOS)
disc.putalpha(Image.composite(disc.getchannel("A"), Image.new("L", (size, size), 0), mask))
disc.resize((32, 32), Image.LANCZOS).save("../../web/favicon.png")

# The site's toolbar mark, drawn 1:1 on 1x-3x screens like AppEmblem's copies.
# 36 is emblemSize in static_site_generator/lib/render/site_assets.dart.
for scale in (1, 2, 3):
    suffix = "" if scale == 1 else f"@{scale}x"
    logo.resize((36 * scale, 36 * scale), Image.LANCZOS).save(
        f"../../static_site_generator/assets/emblem{suffix}.png", optimize=True)

# The link-preview card. 1200x630 is the size every scraper documents and the
# one ratio (1.91:1) Facebook, WhatsApp and X crop to without cutting the mark.
# The logo at 440px, centred on the site's page background, so a shared link
# previews in the paper colour of the page it opens. Read from the tokens, so
# a theme change reaches the card on the next run.
# PNG, not JPEG, though JPEG is under a third the size: only scrapers fetch it,
# never a reader, and JPEG rings the line art.
tokens = json.load(open("../../static_site_generator/assets/theme_tokens.json"))
card = Image.new("RGBA", (1200, 630), tokens["colors"]["light"]["background"])
card.alpha_composite(logo.resize((440, 440), Image.LANCZOS), (380, 95))
card.convert("RGB").save("../../static_site_generator/assets/og-card.png", optimize=True)
PY

echo "Wrote emblem.webp, its 2.0x/ 3.0x/ 4.0x/ copies, web/favicon.png and"
echo "the site's emblem.png, emblem@2x.png, emblem@3x.png and og-card.png"
