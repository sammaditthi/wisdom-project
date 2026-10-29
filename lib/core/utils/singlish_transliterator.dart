/// Singlish (romanized Sinhala) to Sinhala Unicode transliterator.
///
/// Converts romanized Sinhala (Singlish) input to Sinhala Unicode.
/// Uses case-sensitive mappings for disambiguation:
/// - `th` → ත (dental)
/// - `Th` → ථ (dental aspirated)
/// - `t` → ට (retroflex)
/// - `T` → ඨ (retroflex aspirated)
///
/// The scheme is UCSC LTRL's SinGlish (2011,
/// https://www.ucsc.cmb.ac.lk/ltrl/services/feconverter/), ported from
/// https://github.com/Open-SL/sinhala-unicode-converter. The deliberate
/// divergences, listed here and nowhere else:
/// - `~` replaces their `\` escape, and `~N` carries the hal.
/// - `c` is added for romanized Pali.
/// - `nndh` comes before `nnd`; upstream gets a standalone `nndh` wrong.
/// - Their `a)` / `/a` forms are dropped (regex patterns upstream, which do
///   not survive a plain string replace), and so is `\y`, a duplicate of `Y`.
library;

/// Singlish transliterator for search functionality.
///
/// Converts romanized Sinhala (Singlish) to Sinhala Unicode string.
/// Case-sensitive: uppercase letters indicate aspirated/special consonants.
class SinglishTransliterator {
  // Singleton
  static final SinglishTransliterator instance = SinglishTransliterator._();
  SinglishTransliterator._();

  // ============== Mappings ==============
  // From sinhala-unicode-converter, reordered for correct matching.
  // Every ZWJ is written `\u200D`: a literal one is invisible in a diff.

  /// Vowels with modifiers: [singlish, independent vowel, vowel modifier (pili)]
  /// Order: longer patterns first
  static const List<List<String>> _vowels = [
    ['oo', 'ඌ', 'ූ'],
    ['aa', 'ආ', 'ා'],
    ['Aa', 'ඈ', 'ෑ'],
    ['ae', 'ඈ', 'ෑ'],
    ['ii', 'ඊ', 'ී'],
    ['ie', 'ඊ', 'ී'],
    ['ee', 'ඊ', 'ී'],
    ['ea', 'ඒ', 'ේ'],
    ['ei', 'ඒ', 'ේ'],
    ['uu', 'ඌ', 'ූ'],
    ['au', 'ඖ', 'ෞ'],
    ['oe', 'ඕ', 'ෝ'],
    ['a', 'අ', ''], // inherent vowel - empty modifier
    ['A', 'ඇ', 'ැ'],
    ['i', 'ඉ', 'ි'],
    ['e', 'එ', 'ෙ'],
    ['u', 'උ', 'ු'],
    ['o', 'ඔ', 'ො'],
    ['I', 'ඓ', 'ෛ'],
  ];

  /// Consonants: [singlish, sinhala unicode]
  /// Order: CRITICAL - longer patterns MUST come first (e.g., 'nndh' before 'nnd')
  static const List<List<String>> _consonants = [
    // 4+ character combinations
    ['nndh', 'ඳ'],
    // 3 character combinations
    ['nnd', 'ඬ'],
    ['nng', 'ඟ'],
    // 2 character combinations (case-sensitive)
    ['Th', 'ථ'], // dental aspirated
    ['Dh', 'ධ'], // dental aspirated
    ['gh', 'ඝ'],
    ['Ch', 'ඡ'],
    ['ph', 'ඵ'],
    ['bh', 'භ'],
    ['sh', 'ශ'],
    ['Sh', 'ෂ'],
    ['GN', 'ඥ'],
    ['KN', 'ඤ'],
    ['Lu', 'ළු'],
    ['dh', 'ද'], // dental
    ['ch', 'ච'],
    ['kh', 'ඛ'],
    ['th', 'ත'], // dental
    // Single character (case-sensitive)
    // Not in the UCSC scheme, which has only ch/Ch — but romanized Pali spells
    // ච as `c` (cakka, citta, pañca). Below `ch`, so `ch` still wins.
    ['c', 'ච'],
    ['t', 'ට'], // retroflex
    ['k', 'ක'],
    ['d', 'ඩ'], // retroflex
    ['n', 'න'],
    ['p', 'ප'],
    ['b', 'බ'],
    ['m', 'ම'],
    ['Y', '\u200Dය'], // yansaya
    ['y', 'ය'],
    ['j', 'ජ'],
    ['l', 'ල'],
    ['v', 'ව'],
    ['w', 'ව'],
    ['s', 'ස'],
    ['h', 'හ'],
    ['N', 'ණ'],
    ['L', 'ළ'],
    ['K', 'ඛ'],
    ['G', 'ඝ'],
    ['T', 'ඨ'], // retroflex aspirated
    ['D', 'ඪ'],
    ['P', 'ඵ'],
    ['B', 'ඹ'],
    ['f', 'ෆ'],
    ['q', 'ඣ'],
    ['g', 'ග'],
    ['r', 'ර'],
  ];

  /// Special characters: [singlish, sinhala unicode]
  /// Used for anusvara, visarga, repaya, etc.
  /// Mostly `~`-prefixed, replacing the `\` escape of the scheme this came
  /// from. Replaced before any other pass, so a `~` form always wins over the
  /// bare letter below it.
  static const List<List<String>> _specialChars = [
    ['~n', 'ං'], // Anusvara - used in: sanghang, dhammang
    ['~h', 'ඃ'], // Visarga - used in: duhkha
    ['~N', 'ඞ්'], // Velar nasal (ṅ) – always conjunct in Pali Sinhala
    ['~R', 'ඍ'], // Vocalic R (Pali/Sanskrit)
    // Repaya: ර් drawn as a hook over the next consonant. Typed before that
    // consonant — `vaRgaya` → වර්\u200Dගය. Must stay below `~R`, which would
    // otherwise lose its R here.
    ['R', 'ර්\u200D'],
  ];

  /// Special modifiers for ru/ruu sounds
  static const List<List<String>> _specialModifiers = [
    ['ruu', 'ෲ'],
    ['ru', 'ෘ'],
  ];

  // ============== Public API ==============

  /// Converts Singlish text to Sinhala Unicode.
  ///
  /// Returns a single deterministic result based on case-sensitive mappings.
  /// If input contains no ASCII letters, returns as-is.
  ///
  /// Example:
  /// ```dart
  /// convert('sathi')  // → 'සති'
  /// convert('saThi')  // → 'සථි' (different - capital T = ථ)
  /// convert('dharma') // → 'දර්ම'
  /// ```
  String convert(String input) {
    if (input.isEmpty) return '';
    if (!isSinglishQuery(input)) return input;

    var text = input;

    // Step 0: Replace special characters (anusvara, visarga, repaya, etc.)
    for (final special in _specialChars) {
      text = text.replaceAll(special[0], special[1]);
    }

    // Step 1: Replace consonant + special modifiers (ruu, ru)
    for (final cons in _consonants) {
      for (final mod in _specialModifiers) {
        text = text.replaceAll('${cons[0]}${mod[0]}', '${cons[1]}${mod[1]}');
      }
    }

    // Step 2: Replace consonant + rakaransha + vowel (e.g., "kra" → "ක්\u200Dර")
    for (final cons in _consonants) {
      for (final vowel in _vowels) {
        text = text.replaceAll(
          '${cons[0]}r${vowel[0]}',
          '${cons[1]}්\u200Dර${vowel[2]}',
        );
      }
      // Consonant + rakaransha without trailing vowel
      text = text.replaceAll('${cons[0]}r', '${cons[1]}්\u200Dර');
    }

    // Step 3: Replace consonant + vowel (CRITICAL: uses simple string replace)
    for (final cons in _consonants) {
      for (final vowel in _vowels) {
        text =
            text.replaceAll('${cons[0]}${vowel[0]}', '${cons[1]}${vowel[2]}');
      }
    }

    // Step 4: Replace standalone consonants (add hal ්)
    for (final cons in _consonants) {
      text = text.replaceAll(cons[0], '${cons[1]}්');
    }

    // Step 5: Replace standalone vowels
    for (final vowel in _vowels) {
      text = text.replaceAll(vowel[0], vowel[1]);
    }

    return text;
  }

  static final _latinLetterPattern = RegExp(r'[A-Za-z]');

  /// Checks if the query contains ASCII letters (needs transliteration).
  bool isSinglishQuery(String query) {
    return _latinLetterPattern.hasMatch(query);
  }
}
