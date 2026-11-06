import 'canon_books.dart';

/// Resolves a canonical SuttaCentral reference to our BJT tree node key, and a
/// BJT node back to its SuttaCentral page.
///
/// Pure and I/O-free: the concordance (`assets/data/sc-to-bjt.json`, built by
/// `tools/suttacentral_map/`) is injected, so this stays plain Dart.
///   1. [parseRef]        — "SN 15.3" / "sn15.3"  ->  canonical uid "sn15.3"
///   2. [resolve]         — "sn15.3" / "dhp5"     ->  "sn-2-3-1-3" / "kn-dhp-1"
///   3. [suttaCentralUrl] — BJT node              ->  its page on SuttaCentral
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

  /// A typed copy, so a malformed asset fails here, at load.
  static Map<String, String> _strings(Object? value) =>
      Map<String, String>.from((value as Map<String, dynamic>?) ?? const {});

  /// Every name of a book, lowercased -> its uid prefix.
  static final Map<String, String> _prefixByName = {
    for (final book in canonBooks)
      for (final name in [book.name, ...book.aliases])
        name.toLowerCase(): book.uidPrefix,
  };

  /// A book name (one space allowed: "Bu Pj"), then numbers joined by `.` or
  /// `:`, maybe ending in a range as SuttaCentral writes it ("Dhp 1-20").
  /// Anchored, so it never fires on a sentence that merely holds one.
  static final RegExp _refPattern = RegExp(
    r'^([A-Za-z]+(?:\s+[A-Za-z]+)?)\s*([0-9]+(?:[.:][0-9]+)*(?:-[0-9]+)?)$',
  );

  /// The uid prefix for a typed book name, or `null` when the table has none.
  static String? _prefixOf(String book) =>
      _prefixByName[book.trim().toLowerCase().replaceAll(_spaces, ' ')];

  static final RegExp _spaces = RegExp(r'\s+');

  /// A typed reference as a SuttaCentral uid, or `null` if it isn't one:
  /// "SN 15:3" -> `sn15.3`, "Bu Pj 1" -> `pli-tv-bu-vb-pj1`.
  static String? parseRef(String input) {
    final match = _refPattern.firstMatch(input.trim());
    if (match == null) return null;
    final prefix = _prefixOf(match.group(1)!);
    if (prefix == null) return null;
    return '$prefix${match.group(2)!.replaceAll(':', '.')}';
  }

  /// Whether [input] is just the name of a book in [canonBooks]: "SN", "dhp",
  /// "Tha Ap". Not "KN" or "Mil".
  static bool isBookName(String input) => _prefixOf(input) != null;

  /// A uid as people cite it: `kp1` -> "Kp 1", `pli-tv-bu-vb-pj1` -> "Bu Pj 1".
  /// Returns [uid] unchanged when no book's prefix is followed by a number.
  static String displayRef(String uid) {
    final id = uid.trim();
    for (final book in canonBooks) {
      final prefix = book.uidPrefix;
      if (!id.startsWith(prefix)) continue;
      final number = id.substring(prefix.length);
      // A digit must follow: `snp1.8` is not `sn` + "p1.8".
      if (number.startsWith(_digit)) return '${book.name} $number';
    }
    return uid;
  }

  static final RegExp _digit = RegExp('[0-9]');

  /// Canonical uid (from [parseRef] or a research citation) -> BJT node key.
  /// `null` if not in the concordance. Exact only: see [resolve].
  String? nodeKeyForUid(String uid) => _scToNode[uid];

  /// What a reference opens: [uid] itself when mapped, else the map's range
  /// holding its last number (`dhp5` -> `dhp1-20`, `an1.1` -> `an1.1-10`).
  /// Search and research both open through this. `null` when neither is.
  /// The Worker's `citedHolding` (research_server/src/refs.ts) is a hand copy: change both.
  ({String uid, String nodeKey})? resolve(String uid) {
    final exact = nodeKeyForUid(uid);
    if (exact != null) return (uid: uid, nodeKey: exact);
    final match = _lastNumber.firstMatch(uid);
    if (match == null) return null;
    final stem = match.group(1)!; // `dhp`, `an1.`
    // tryParse: a typed number too long for an int opens nothing.
    final number = int.tryParse(match.group(2)!);
    if (number == null) return null;
    // Runs only on a miss. A range is the stem plus a numeric N-M, so a
    // chapter uid like `sn1-nalavagga` never counts.
    for (final entry in _scToNode.entries) {
      if (!entry.key.startsWith(stem)) continue;
      final range = _numericRange.firstMatch(entry.key.substring(stem.length));
      if (range != null &&
          int.parse(range.group(1)!) <= number &&
          number <= int.parse(range.group(2)!)) {
        return (uid: entry.key, nodeKey: entry.value);
      }
    }
    return null;
  }

  static final RegExp _lastNumber = RegExp(r'^(.*\D)(\d+)$');
  static final RegExp _numericRange = RegExp(r'^(\d+)-(\d+)$');

  /// The node's page on SuttaCentral: the preferred English translation when
  /// there is one, else SuttaCentral's own page for that text or division.
  /// `null` where the two editions don't line up (never the nearest one).
  Uri? suttaCentralUrl(String nodeKey) {
    final uid = _nodeToSc[nodeKey];
    if (uid == null) return null;
    final translator = _translators[uid];
    return Uri.https(
      'suttacentral.net',
      translator == null ? '/$uid' : '/$uid/en/$translator',
    );
  }
}
