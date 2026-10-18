import 'dart:convert';

import 'package:crypto/crypto.dart';

/// The first 16 hex characters of the SHA-256 of [content]'s UTF-8 bytes.
///
/// **Change detection, not cryptography.** The only question asked of it is
/// "did these bytes change since the last build?" — by `.manifest.json` of the
/// corpus files, and by `SiteAssets` of everything the pages link — and 64 bits
/// answers that while keeping every `?v=` short. One file's digest can be
/// checked from a shell: `shasum -a 256 <file> | cut -c1-16`.
///
/// Lives in `domain/` rather than beside its consumer in `manifest/` because
/// `data/` needs it too, and `data/ -> manifest/` would have the layers
/// pointing the wrong way. It is a pure string transform with no I/O, so
/// `domain/` costs it nothing.
String contentHash(String content) => contentHashOfBytes(utf8.encode(content));

/// The same digest over bytes that are not text.
///
/// The emblem and the WOFF2 subsets are versioned by content like everything
/// else the site links (`SiteAssets`), and decoding a PNG as UTF-8 to reach
/// [contentHash] would throw on the first invalid sequence.
String contentHashOfBytes(List<int> bytes) =>
    sha256.convert(bytes).toString().substring(0, 16);
