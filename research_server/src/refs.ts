// Canonical-reference helpers: uid → display ref ("sn15.3" → "SN 15.3") and
// back, plus the prose-ref matcher the linkifier uses.

interface Book {
  name: string;
  prefix: string;
  aliases?: string[];
}

// Hand copy of canonBooks (packages/wisdom_shared/lib/src/refs/canon_books.dart): change both.
const BOOKS: readonly Book[] = [
  // Sutta
  { name: 'DN', prefix: 'dn' },
  { name: 'MN', prefix: 'mn' },
  { name: 'SN', prefix: 'sn' },
  { name: 'AN', prefix: 'an' },
  { name: 'Kp', prefix: 'kp', aliases: ['Khp'] },
  { name: 'Dhp', prefix: 'dhp' },
  { name: 'Ud', prefix: 'ud' },
  { name: 'Iti', prefix: 'iti', aliases: ['It'] },
  { name: 'Snp', prefix: 'snp' },
  { name: 'Vv', prefix: 'vv' },
  { name: 'Pv', prefix: 'pv' },
  { name: 'Thag', prefix: 'thag' },
  { name: 'Thig', prefix: 'thig' },
  { name: 'Tha Ap', prefix: 'tha-ap' },
  { name: 'Thi Ap', prefix: 'thi-ap' },
  { name: 'Bv', prefix: 'bv' },
  { name: 'Cp', prefix: 'cp' },
  { name: 'Ja', prefix: 'ja' },
  { name: 'Mnd', prefix: 'mnd', aliases: ['Nm'] },
  { name: 'Cnd', prefix: 'cnd', aliases: ['Nc'] },
  { name: 'Ps', prefix: 'ps' },
  { name: 'Ne', prefix: 'ne' },
  { name: 'Pe', prefix: 'pe' },

  // Abhidhamma
  { name: 'Ds', prefix: 'ds' },
  { name: 'Vb', prefix: 'vb' },
  { name: 'Dt', prefix: 'dt' },
  { name: 'Pp', prefix: 'pp' },
  { name: 'Kv', prefix: 'kv' },
  { name: 'Ya', prefix: 'ya' },
  { name: 'Patthana', prefix: 'patthana' },

  // Vinaya: the monks' (Bu) and the nuns' (Bi) rule books.
  { name: 'Kd', prefix: 'pli-tv-kd' },
  { name: 'Pvr', prefix: 'pli-tv-pvr' },
  { name: 'Bu Pj', prefix: 'pli-tv-bu-vb-pj' },
  { name: 'Bu Ss', prefix: 'pli-tv-bu-vb-ss' },
  { name: 'Bu Ay', prefix: 'pli-tv-bu-vb-ay' },
  { name: 'Bu Np', prefix: 'pli-tv-bu-vb-np' },
  { name: 'Bu Pc', prefix: 'pli-tv-bu-vb-pc' },
  { name: 'Bu Pd', prefix: 'pli-tv-bu-vb-pd' },
  { name: 'Bu Sk', prefix: 'pli-tv-bu-vb-sk' },
  { name: 'Bu As', prefix: 'pli-tv-bu-vb-as' },
  { name: 'Bi Pj', prefix: 'pli-tv-bi-vb-pj' },
  { name: 'Bi Ss', prefix: 'pli-tv-bi-vb-ss' },
  { name: 'Bi Np', prefix: 'pli-tv-bi-vb-np' },
  { name: 'Bi Pc', prefix: 'pli-tv-bi-vb-pc' },
  { name: 'Bi Pd', prefix: 'pli-tv-bi-vb-pd' },
  { name: 'Bi Sk', prefix: 'pli-tv-bi-vb-sk' },
  { name: 'Bi As', prefix: 'pli-tv-bi-vb-as' },
];

// Every name of a book, lowercased → its uid prefix.
const PREFIX_BY_NAME = new Map(
  BOOKS.flatMap((b) => [b.name, ...(b.aliases ?? [])].map((n) => [n.toLowerCase(), b.prefix])),
);

// Numbers joined by '.' or ':', maybe ending in a range ("Dhp 1-20").
const NUMBER = String.raw`\d+(?:[.:]\d+)*(?:-\d+)?`;

// Names as the table writes them, case kept: in English prose "an 8" or
// "it 5" is a word, not a book.
const NAMES = BOOKS.flatMap((b) => [b.name, ...(b.aliases ?? [])]).join('|');

// No capture groups: pipeline.ts builds bigger regexes around this one.
export const REF_IN_PROSE = new RegExp(`\\b(?:${NAMES})\\s?${NUMBER}\\b`, 'g');

const REF = new RegExp(`^([A-Za-z]+(?:\\s+[A-Za-z]+)?)\\s*(${NUMBER})$`);

// `kp1` → "Kp 1", `pli-tv-bu-vb-pj1` → "Bu Pj 1"; no book → the uid unchanged.
export function refFromUid(uid: string): string {
  for (const b of BOOKS) {
    const num = uid.slice(b.prefix.length);
    // A digit must follow: `snp1.8` is not `sn` + "p1.8".
    if (uid.startsWith(b.prefix) && /^\d/.test(num)) return `${b.name} ${num}`;
  }
  return uid;
}

// "SN 15:3" → `sn15.3`, "Bu Pj 1" → `pli-tv-bu-vb-pj1`; not a book → null.
export function uidFromRef(ref: string): string | null {
  const m = REF.exec(ref.trim());
  if (!m) return null;
  const prefix = PREFIX_BY_NAME.get(m[1]!.toLowerCase().replace(/\s+/g, ' '));
  return prefix ? prefix + m[2]!.replace(/:/g, '.') : null;
}

// The uid in `cited` that holds `uid`: itself, else a range of its stem holding
// its last number (`an1.1` → `an1.1-10`); null when none does.
// Hand copy of resolve (packages/wisdom_shared/lib/src/refs/suttacentral_ref_resolver.dart): change both.
export function citedHolding(uid: string, cited: ReadonlySet<string>): string | null {
  if (cited.has(uid)) return uid;
  const last = /^(.*\D)(\d+)$/.exec(uid);
  if (!last) return null;
  const stem = last[1]!;
  const number = Number(last[2]);
  for (const c of cited) {
    if (!c.startsWith(stem)) continue;
    // A numeric N-M only, so a chapter uid like `sn1-nalavagga` never counts.
    const range = /^(\d+)-(\d+)$/.exec(c.slice(stem.length));
    if (range && Number(range[1]) <= number && number <= Number(range[2])) return c;
  }
  return null;
}
