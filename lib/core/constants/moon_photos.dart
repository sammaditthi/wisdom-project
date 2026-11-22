/// The Today card's moon photos, one for each day of the moon's cycle: 00 the
/// new moon, 15 the full moon. Made by `assets/make_moon.sh`.
const int moonPhotoCount = 30;

/// The asset path of photo [index], 0 to 29.
String moonPhotoAsset(int index) =>
    'assets/moon/${index.toString().padLeft(2, '0')}.webp';
