#!/bin/bash
# The Today card's moon photos, moon/00.webp to 29.webp: 00 the new moon, 15
# the full moon. Kept here and not in moon/, because pubspec.yaml lists that
# whole folder and would ship this file with it.
#
# Source: NASA's Scientific Visualization Studio, "Moon Phase and Libration,
# 2026" (svs.gsfc.nasa.gov/5587), the 730px frames, one an hour from
# 1 Jan 2026 00:00 UT.
# Requires: curl, cwebp (brew install webp), Pillow (pip install Pillow).
#
# Run by hand and commit the output, like icons/make_icons.sh. To compare
# before replacing, pass another folder: ./make_moon.sh /tmp/moon
# NASA's server is slow, so each frame is fetched once and kept under
# $TMPDIR/moon-frames, in a folder named after the NASA set.

set -euo pipefail
out="${1:-$(dirname "$0")/moon}"

python3 - "$out" "${TMPDIR:-/tmp}/moon-frames" <<'PY'
import os
import shutil
import subprocess
import sys

from PIL import Image, ImageDraw

BASE = ("https://svs.gsfc.nasa.gov/vis/a000000/a005500/a005587/frames/"
        "730x730_1x1_30p")
out = sys.argv[1]
# Named after BASE, so another set or size never cuts from these frames.
frames = os.path.join(sys.argv[2], BASE.split("/vis/")[1].replace("/", "_"))
os.makedirs(out, exist_ok=True)
os.makedirs(frames, exist_ok=True)

# One cycle of the moon, as frame numbers.
NEW, FULL, NEXT_NEW = 429, 767, 1141
SIZE = 384


def frame_of(photo):
    """Fifteen even steps on each side, so photo 15 is the full moon itself."""
    if photo <= 15:
        return round(NEW + photo * (FULL - NEW) / 15)
    return round(FULL + (photo - 15) * (NEXT_NEW - FULL) / 15)


def fetch(number):
    name = f"moon.{number:04d}.jpg"
    path = os.path.join(frames, name)
    if not os.path.exists(path):
        # To a .part file first, so a cut download is never taken for a frame.
        # All errors: the server often cuts a transfer short.
        subprocess.run(["curl", "-fsS", "--retry", "3", "--retry-all-errors",
                        "-o", path + ".part", f"{BASE}/{name}"], check=True)
        os.replace(path + ".part", path)
    return Image.open(path).convert("RGB")


# A circle drawn 4x and scaled down, for a smooth edge. One source pixel in
# from the edge, so no black sky fringes the lit limb.
inset = 4 * SIZE / 650
mask = Image.new("L", (SIZE * 4, SIZE * 4), 0)
ImageDraw.Draw(mask).ellipse(
    [inset, inset, SIZE * 4 - 1 - inset, SIZE * 4 - 1 - inset], fill=255)
mask = mask.resize((SIZE, SIZE), Image.LANCZOS)

# Every frame before any photo is cut, so a dropped download leaves the old
# photos whole and not half replaced.
fetched = [fetch(frame_of(photo)) for photo in range(30)]

for photo, frame in enumerate(fetched):
    # The whole disc: the dark side is faintly lit, the sky is pure black. Its
    # size in the frame changes with the moon's distance, so each is measured.
    box = frame.convert("L").point(lambda v: 255 if v > 5 else 0).getbbox()
    width, height = box[2] - box[0], box[3] - box[1]
    side = max(width, height)
    cx, cy = (box[0] + box[2]) / 2, (box[1] + box[3]) / 2
    # A dark limb as black as the sky leaves the box short on that side (photo
    # 16), and its centre off. The moon sits within 3px of the frame's centre,
    # so a short axis takes that instead.
    if side - width > 3:
        cx = frame.width / 2
    if side - height > 3:
        cy = frame.height / 2
    if side - min(width, height) > 3:
        # Said, because with another year's frames it may be a wrong cut.
        print(f"{photo:02d}.webp: box {width}x{height}, centred on the frame")
    # One rounding per axis, so the cut is square.
    left, top = round(cx - side / 2), round(cy - side / 2)
    disc = frame.crop((left, top, left + side, top + side))
    disc = disc.resize((SIZE, SIZE), Image.LANCZOS).convert("RGBA")
    disc.putalpha(mask)
    # Made beside the frames and moved in whole: pubspec.yaml ships the output
    # folder, and a failed run must leave no PNG or half-written photo in it.
    png = os.path.join(frames, f"{photo:02d}.png")
    webp = os.path.join(frames, f"{photo:02d}.webp")
    disc.save(png)
    subprocess.run(["cwebp", "-quiet", "-q", "82", "-alpha_q", "100", "-m", "6",
                    png, "-o", webp], check=True)
    os.remove(png)
    shutil.move(webp, os.path.join(out, f"{photo:02d}.webp"))
PY

echo "Wrote 00.webp to 29.webp into $out"
