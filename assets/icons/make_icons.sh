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
#
# Run by hand and commit the output, like ../fonts/subset_fonts.sh.
# The site's emblem.png and og-card.png come from
# static_site_generator/assets/make_emblem.sh.

set -euo pipefail
cd "$(dirname "$0")"

python3 - <<'PY'
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
PY

echo "Wrote emblem.webp, its 2.0x/ 3.0x/ 4.0x/ copies and web/favicon.png"
