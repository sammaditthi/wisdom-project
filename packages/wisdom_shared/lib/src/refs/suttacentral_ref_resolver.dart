/// Resolves a canonical SuttaCentral reference to our BJT tree node key, and a
/// BJT node back to its SuttaCentral page.
///
/// Pure and I/O-free: the concordance (`assets/data/sc-to-bjt.json`, built by
/// `tools/suttacentral_map/`) is injected, so this stays plain Dart.
///   1. [parseRef]         — "SN 15.3" / "sn15.3"  ->  canonical uid "sn15.3"
///   2. [resolveToNodeKey] — "sn15.3"              ->  BJT node "sn-2-3-1-3"
///   3. [suttaCentralUrl]  — BJT node              ->  its page on SuttaCentral
///
/// Why a map and not a formula: `docs/todo/search/sutta-references-plan.md`.
class SuttaCentralRefResolver {
  /// SuttaCentral uid (e.g. `sn15.3`) -> BJT node key (e.g. `sn-2-3-1-3`).
  final Map<String, String> _scToNode;

  /// BJT node key -> the SuttaCentral uid its link opens.
  final Map<String, String> _nodeToSc;

  /// SuttaCentral uid -> the translator whose English the link opens.
  final Map<String, String> _translators;

  const SuttaCentralRefResolver(
    this._scToNode, {
    Map<String, String> nodeToSc = const {},
    Map<String, String> translators = const {},
  })  : _nodeToSc = nodeToSc,
        _translators = translators;

  /// Reads the asset's shape: `map` (uid -> node), `reverse` (node -> uid where
  /// the first uid naming a node isn't the one to open) and `english`
  /// (translator -> the uids opened in their translation).
  factory SuttaCentralRefResolver.fromJson(Map<String, dynamic> json) {
    final map = _strings(json['map']);
    final nodeToSc = <String, String>{};
    map.forEach((uid, node) => nodeToSc.putIfAbsent(node, () => uid));
    nodeToSc.addAll(_strings(json['reverse']));
    final english = (json['english'] as Map<String, dynamic>?) ?? const {};
    return SuttaCentralRefResolver(
      map,
      nodeToSc: nodeToSc,
      translators: {
        for (final entry in english.entries)
          for (final uid in (entry.value as List<dynamic>).cast<String>())
            uid: entry.key,
      },
    );
  }

  static Map<String, String> _strings(Object? value) =>
      ((value as Map<String, dynamic>?) ?? const {}).cast<String, String>();

  /// Book / nikāya abbreviations we accept as a *reference* (lowercased).
  ///
  /// This only gates what *looks* like a canonical reference so that ordinary
  /// search words ("metta123") don't parse as one; whether it actually resolves
  /// still depends on the concordance. Matches the linkifier's set in the RAG
  /// design doc.
  static const Set<String> knownBooks = {
    'sn', 'mn', 'dn', 'an', // four main nikāyas
    'dhp', 'ud', 'iti', 'snp', // Khuddaka — common verse/prose books
    'thag', 'thig', 'vv', 'pv', 'cp', 'bv', // Khuddaka — more verse books
  };

  /// `<letters><digits>(.<digits>)*` with an optional space after the letters:
  /// "SN 15.3", "sn15.3", "AN 3.65", "Dhp 1". Anchored — the whole string must
  /// be a reference, so it never fires on a sentence that merely contains one.
  static final RegExp _refPattern =
      RegExp(r'^([A-Za-z]+)\s*([0-9]+(?:\.[0-9]+)*)$');

  /// Step 1 — parse a human/uid string into a canonical SuttaCentral uid, or
  /// `null` if it isn't a canonical reference at all.
  ///
  /// "SN 15.3" | "sn 15.3" | "SN15.3" | "sn15.3"  ->  "sn15.3"
  static String? parseRef(String input) {
    final match = _refPattern.firstMatch(input.trim());
    if (match == null) return null;

    final book = match.group(1)!.toLowerCase();
    if (!knownBooks.contains(book)) return null;

    return '$book${match.group(2)!}'; // "sn" + "15.3" -> "sn15.3"
  }

  /// Canonical display abbreviations; anything else falls back to UPPERCASE.
  static const Map<String, String> _displayBook = {
    'sn': 'SN',
    'mn': 'MN',
    'dn': 'DN',
    'an': 'AN',
    'dhp': 'Dhp',
    'ud': 'Ud',
    'iti': 'Iti',
    'snp': 'Snp',
    'thag': 'Thag',
    'thig': 'Thig',
    'vv': 'Vv',
    'pv': 'Pv',
    'cp': 'Cp',
    'bv': 'Bv',
  };

  /// Format a canonical uid as a human display reference:
  /// "sn15.3" -> "SN 15.3", "dhp1" -> "Dhp 1". Returns [uid] unchanged if it
  /// doesn't split into letters + digits.
  static String displayRef(String uid) {
    final match = RegExp(r'^([A-Za-z]+)([0-9].*)$').firstMatch(uid.trim());
    if (match == null) return uid;
    final book = _displayBook[match.group(1)!.toLowerCase()] ??
        match.group(1)!.toUpperCase();
    return '$book ${match.group(2)!}';
  }

  /// Step 2 (combined) — resolve any reference string straight to a BJT node
  /// key, or `null` if it isn't a reference or the concordance doesn't cover it.
  String? resolveToNodeKey(String input) {
    final uid = parseRef(input);
    if (uid == null) return null;
    return _scToNode[uid];
  }

  /// Direct uid -> node key, for callers that already hold a canonical uid
  /// (e.g. RAG citations). `null` if not in the concordance.
  String? nodeKeyForUid(String uid) => _scToNode[uid];

  /// The SuttaCentral uid a BJT node links to, or `null` where the two
  /// editions don't line up (never the nearest one instead).
  String? uidForNodeKey(String nodeKey) => _nodeToSc[nodeKey];

  /// The node's page on SuttaCentral: the preferred English translation when
  /// there is one, else SuttaCentral's own page for that text or division.
  Uri? suttaCentralUrl(String nodeKey) {
    final uid = _nodeToSc[nodeKey];
    if (uid == null) return null;
    final translator = _translators[uid];
    return Uri.https(
      'suttacentral.net',
      translator == null ? '/$uid' : '/$uid/en/$translator',
    );
  }

  /// True once the concordance is non-empty. Lets a caller skip the reference
  /// check entirely before the asset has finished loading.
  bool get isReady => _scToNode.isNotEmpty;
}
