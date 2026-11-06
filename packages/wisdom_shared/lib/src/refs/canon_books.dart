/// One book of the Pali canon as people cite it.
class CanonBook {
  const CanonBook(this.name, this.uidPrefix, {this.aliases = const []});

  /// As SuttaCentral writes it: "SN", "Dhp", "Bu Pj".
  final String name;

  /// What the book's SuttaCentral uids start with: `sn`, `pli-tv-bu-vb-pj`.
  final String uidPrefix;

  /// Other spellings of the same book: "Khp" for Kp.
  final List<String> aliases;
}

/// The one table of book names for the whole project
/// (`docs/todo/search/sutta-references-plan.md`, A1). Names are matched
/// ignoring case, so "Sn" is SN; the Sutta Nipāta is "Snp".
///
/// Never build a tree key from a name: in `tree.json`, `ap` is the Abhidhamma.
const List<CanonBook> canonBooks = [
  // Sutta
  CanonBook('DN', 'dn'),
  CanonBook('MN', 'mn'),
  CanonBook('SN', 'sn'),
  CanonBook('AN', 'an'),
  CanonBook('Kp', 'kp', aliases: ['Khp']),
  CanonBook('Dhp', 'dhp'),
  CanonBook('Ud', 'ud'),
  CanonBook('Iti', 'iti', aliases: ['It']),
  CanonBook('Snp', 'snp'),
  CanonBook('Vv', 'vv'),
  CanonBook('Pv', 'pv'),
  CanonBook('Thag', 'thag'),
  CanonBook('Thig', 'thig'),
  CanonBook('Tha Ap', 'tha-ap'),
  CanonBook('Thi Ap', 'thi-ap'),
  CanonBook('Bv', 'bv'),
  CanonBook('Cp', 'cp'),
  CanonBook('Ja', 'ja'),
  CanonBook('Mnd', 'mnd', aliases: ['Nm']),
  CanonBook('Cnd', 'cnd', aliases: ['Nc']),
  CanonBook('Ps', 'ps'),
  CanonBook('Ne', 'ne'),
  CanonBook('Pe', 'pe'),

  // Abhidhamma
  CanonBook('Ds', 'ds'),
  CanonBook('Vb', 'vb'),
  CanonBook('Dt', 'dt'),
  CanonBook('Pp', 'pp'),
  CanonBook('Kv', 'kv'),
  CanonBook('Ya', 'ya'),
  CanonBook('Patthana', 'patthana'),

  // Vinaya: the monks' (Bu) and the nuns' (Bi) rule books.
  CanonBook('Kd', 'pli-tv-kd'),
  CanonBook('Pvr', 'pli-tv-pvr'),
  CanonBook('Bu Pj', 'pli-tv-bu-vb-pj'),
  CanonBook('Bu Ss', 'pli-tv-bu-vb-ss'),
  CanonBook('Bu Ay', 'pli-tv-bu-vb-ay'),
  CanonBook('Bu Np', 'pli-tv-bu-vb-np'),
  CanonBook('Bu Pc', 'pli-tv-bu-vb-pc'),
  CanonBook('Bu Pd', 'pli-tv-bu-vb-pd'),
  CanonBook('Bu Sk', 'pli-tv-bu-vb-sk'),
  CanonBook('Bu As', 'pli-tv-bu-vb-as'),
  CanonBook('Bi Pj', 'pli-tv-bi-vb-pj'),
  CanonBook('Bi Ss', 'pli-tv-bi-vb-ss'),
  CanonBook('Bi Np', 'pli-tv-bi-vb-np'),
  CanonBook('Bi Pc', 'pli-tv-bi-vb-pc'),
  CanonBook('Bi Pd', 'pli-tv-bi-vb-pd'),
  CanonBook('Bi Sk', 'pli-tv-bi-vb-sk'),
  CanonBook('Bi As', 'pli-tv-bi-vb-as'),
];

// Left out on purpose: each would open nothing, so it stays a Singlish word.
//
// | Name                     | Book                  | Why not                     |
// | ------------------------ | --------------------- | --------------------------- |
// | Mil, Miln                | Milindapañha          | BJT has no Milindapañha     |
// | KN                       | Khuddaka Nikāya       | A nikāya, not one book      |
// | Nd                       | Niddesa               | Mnd or Cnd? Can't tell      |
// | Mv, Cv                   | Mahāvagga, Cullavagga | SuttaCentral numbers both   |
// |                          |                       | as Kd: Cv 1 is Kd 11        |
// | DhpA, KhpA, ThagA, ThigA | Commentaries          | SuttaCentral has none       |
// | A, D, M, S               | AN, DN, MN, SN        | Cited by PTS volume/page    |
// |                          |                       | ("S II 178"): not supported |
//
// To add a book:
// 1. Find its uid prefix: `suttacentral.net/api/suttaplex/<book>`.
// 2. Check `assets/data/sc-to-bjt.json` has uids with that prefix and a
//    number. None: it still opens nothing (the map is built by
//    `tools/suttacentral_map/`).
// 3. Add `CanonBook('<Name>', '<prefix>')`, other spellings as aliases. Case is
//    ignored, so no name may clash with another ("Sn" is SN).
// 4. Remove its row here, and update A1 in `sutta-references-plan.md`.
// 5. Add the same row to the hand copy in `research_server/src/refs.ts`.
