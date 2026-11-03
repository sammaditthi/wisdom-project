#!/usr/bin/env python3
"""Build assets/data/sc-to-bjt.json: SuttaCentral uid → BJT tree node.

Each book's suttas are paired in order. A pair needs the BJT page number SuttaCentral
records for that text (`bj<volume>.<page>`) to match the BJT node's page; titles only
break ties. Anything left unpaired goes to unmatched.txt with a reason.
How and why: docs/todo/search/sutta-references-plan.md, Part B.

Run:  python3 tools/suttacentral_map/build_map.py
"""

import difflib
import json
import re
import sys
import unicodedata
from collections import defaultdict

import sc_source as sc

ROOT = sc.HERE.parent.parent
TREE = ROOT / 'assets/data/tree.json'
TEXT = ROOT / 'assets/text'
OUT = ROOT / 'assets/data/sc-to-bjt.json'
UNMATCHED = sc.HERE / 'unmatched.txt'
REVIEW = sc.HERE / 'review.txt'

# SuttaCentral book → (its pitaka folder, the BJT subtrees that hold it, in order).
# Milindapañha (mil) is not in BJT.
BOOKS = [
    ('dn', 'sutta', ['dn']),
    ('mn', 'sutta', ['mn']),
    ('sn', 'sutta', ['sn']),
    ('an', 'sutta', ['an']),
    ('kp', 'sutta', ['kn-khp']),
    ('dhp', 'sutta', ['kn-dhp']),
    ('ud', 'sutta', ['kn-ud']),
    ('iti', 'sutta', ['kn-iti']),
    ('snp', 'sutta', ['kn-snp']),
    ('vv', 'sutta', ['kn-vv']),
    ('pv', 'sutta', ['kn-pv']),
    ('thag', 'sutta', ['kn-thag']),
    ('thig', 'sutta', ['kn-thig']),
    ('tha-ap', 'sutta', ['kn-ap-1']),
    ('thi-ap', 'sutta', ['kn-ap-2']),
    ('bv', 'sutta', ['kn-bv']),
    ('cp', 'sutta', ['kn-cp']),
    ('ja', 'sutta', ['kn-jat']),
    ('mnd', 'sutta', ['kn-mn']),
    ('cnd', 'sutta', ['kn-nc']),
    ('ps', 'sutta', ['kn-ps']),
    ('ne', 'sutta', ['kn-nett']),
    ('pe', 'sutta', ['kn-petk']),
    ('pli-tv-bu-vb', 'vinaya', ['vp-prj', 'vp-pct-1']),
    ('pli-tv-bi-vb', 'vinaya', ['vp-pct-2']),
    ('pli-tv-kd', 'vinaya', ['vp-mv', 'vp-cv']),
    ('pli-tv-pvr', 'vinaya', ['vp-pv']),
    ('ds', 'abhidhamma', ['ap-dhs']),
    ('vb', 'abhidhamma', ['ap-vbh']),
    ('dt', 'abhidhamma', ['ap-dhk']),
    ('pp', 'abhidhamma', ['ap-pug']),
    ('kv', 'abhidhamma', ['ap-kvu']),
    ('ya', 'abhidhamma', ['ap-yam']),
    ('patthana', 'abhidhamma', ['ap-pat']),
]

# The research store's translators, and the order the reader prefers them in.
TRANSLATORS = ['bodhi', 'sujato', 'brahmali']

TITLE_SAME = 0.85
TITLE_CLOSE = 0.6
# Slots per range when aligning; a longer range's extra BJT nodes join it by count.
MAX_MEMBERS = 30


# ── Titles: BJT's Pali is in Sinhala script, SuttaCentral's in Roman ─────────

_CONSONANTS = dict(zip(
    'කඛගඝඞචඡජඣඤටඨඩඪණතථදධනපඵබභමයරලළවසහශෂෆඬඳඹඟ',
    ['k', 'kh', 'g', 'gh', 'ṅ', 'c', 'ch', 'j', 'jh', 'ñ', 'ṭ', 'ṭh', 'ḍ', 'ḍh', 'ṇ',
     't', 'th', 'd', 'dh', 'n', 'p', 'ph', 'b', 'bh', 'm', 'y', 'r', 'l', 'ḷ', 'v',
     's', 'h', 'ś', 'ṣ', 'f', 'ṇḍ', 'nd', 'mb', 'ṅg']))
_VOWELS = dict(zip('අආඇඈඉඊඋඌඑඒඔඕ',
                   ['a', 'ā', 'æ', 'ǣ', 'i', 'ī', 'u', 'ū', 'e', 'ē', 'o', 'ō']))
_SIGNS = dict(zip('ාැෑිීුූෙේොෝ',
                  ['ā', 'æ', 'ǣ', 'i', 'ī', 'u', 'ū', 'e', 'ē', 'o', 'ō']))
_VIRAMA, _NIGGAHITA = '්', 'ං'


def roman(sinhala):
    out = []
    chars = sinhala.replace('\u200d', '')
    for i, ch in enumerate(chars):
        nxt = chars[i + 1] if i + 1 < len(chars) else ''
        if ch in _CONSONANTS:
            out.append(_CONSONANTS[ch])
            if nxt != _VIRAMA and nxt not in _SIGNS:
                out.append('a')
        elif ch in _SIGNS:
            out.append(_SIGNS[ch])
        elif ch in _VOWELS:
            out.append(_VOWELS[ch])
        elif ch == _NIGGAHITA:
            out.append('ṁ')
        elif ch != _VIRAMA:
            out.append(ch)
    return ''.join(out)


_ENDINGS = re.compile(r'(suttam|suttani|suttantam|sutta|suttanta|vaggo|vagga|vaggam|kandam|kando|kanda'
                      r'|samyuttam|samyutta|nipato|nipata|pali|jatakam|jataka|apadanam|apadana)$')


def norm(title):
    t = unicodedata.normalize('NFD', roman(title).lower())
    t = re.sub(r'[^a-z]', '', ''.join(c for c in t if not unicodedata.combining(c)))
    while True:
        stripped = _ENDINGS.sub('', t)
        if stripped == t or not stripped:
            break
        t = stripped
    return re.sub(r'[mo]$', 'a', t)


def similarity(a, b):
    a, b = norm(a), norm(b)
    return difflib.SequenceMatcher(None, a, b).ratio() if a and b else 0.0


# ── BJT ──────────────────────────────────────────────────────────────────────

def natural(key):
    return [int(p) if p.isdigit() else p for p in re.split(r'(\d+)', key)]


class Bjt:
    def __init__(self):
        self.tree = json.loads(TREE.read_text())
        self.children = defaultdict(list)
        for key, node in self.tree.items():
            if not key.startswith('atta'):
                self.children[node[4]].append(key)
        for kids in self.children.values():
            kids.sort(key=natural)
        self._files = {}

    def units(self, key):
        """Nodes that carry text, in reading order: every leaf, and a parent whose own
        text runs onto a later page than its first child's heading (a Vinaya rule
        before its case stories)."""
        kids = self.children.get(key)
        if not kids:
            return [key]
        own = [key] if self.tree[kids[0]][3][0] > self.tree[key][3][0] else []
        return own + [u for kid in kids for u in self.units(kid)]

    def descendants(self, key):
        out = []
        for kid in self.children.get(key, []):
            out.append(kid)
            out.extend(self.descendants(kid))
        return out

    def page(self, key):
        node = self.tree[key]
        file_id = node[5]
        if file_id not in self._files:
            self._files[file_id] = json.loads((TEXT / f'{file_id}.json').read_text())
        return self._files[file_id]['pages'][node[3][0]]['pageNum']

    def title(self, key):
        # A few tree.json titles hold a line break or a double space.
        return ' '.join(re.sub(r'^[\d.\s]+', '', self.tree[key][0]).split())


# ── Pairing one book ─────────────────────────────────────────────────────────

def start_pages(leaves, refs):
    """Candidate first BJT pages for each text, best first: its own marker if its first
    numbered segment has one, else the page the text before it ended on. A text whose
    first marker opens another volume may also start on the page before that marker.
    Also returns the last page each text reaches."""
    pages, ends, current = {}, {}, None
    for uid in leaves:
        segments = [s for s in refs.get(uid, []) if s is not None]
        marks = [m for s in segments for m in s]
        candidates = []
        if segments and segments[0]:
            candidates = [segments[0][0][1]]
        else:
            if current is not None:
                candidates.append(current[1])
            if marks and current is None:
                candidates.append(marks[0][1])
            elif marks and marks[0][0] != current[0]:
                candidates.append(max(marks[0][1] - 2, 1))
        if candidates:
            pages[uid] = candidates
            ends[uid] = marks[-1][1] if marks else candidates[0]
        if marks:
            current = marks[-1]
    return pages, ends


def heaviest_chain(pairs, width):
    """The highest-weight list of pairs increasing in both i and j."""
    pairs.sort(key=lambda p: (p[0], -p[1]))
    tree = [(0, -1)] * (width + 1)
    best, back = [], []
    for n, (i, j, w) in enumerate(pairs):
        q, k = (0, -1), j
        while k > 0:
            q = max(q, tree[k])
            k -= k & -k
        best.append(q[0] + w)
        back.append(q[1])
        k = j + 1
        while k <= width:
            tree[k] = max(tree[k], (best[n], n))
            k += k & -k
    if not pairs:
        return []
    n = max(range(len(pairs)), key=lambda x: (best[x], -x))
    chain = []
    while n != -1:
        chain.append(pairs[n][:2])
        n = back[n]
    return chain[::-1]


def pair_book(sc_leaves, bjt, roots, refs, names):
    """Returns (forward, reverse, unmatched, review) for one book."""
    leaves = [u for r in roots for u in bjt.units(r)]
    starts, ends = start_pages(sc_leaves, refs)
    b_pages = [bjt.page(k) for k in leaves]
    by_page = defaultdict(list)
    for j, p in enumerate(b_pages):
        by_page[p].append(j)

    def title_sim(i, j):
        return similarity(names.get(sc_leaves[i], ''), bjt.title(leaves[j]))

    def page_gap(i, j):
        return min((abs(p - b_pages[j]) for p in starts.get(sc_leaves[i], [])), default=10**6)

    def within(i, j):
        first = min(starts.get(sc_leaves[i], [10**6]))
        return first - 2 <= b_pages[j] <= ends.get(sc_leaves[i], -10**6)

    # One slot per sutta a range covers, so `sn33.16-20` has to line up with five BJT
    # nodes where BJT spells them out.
    members = [(i, k) for i, uid in enumerate(sc_leaves)
               for k in range(min(range_size(uid), MAX_MEMBERS))]
    pairs = []
    for e, (i, k) in enumerate(members):
        uid, near = sc_leaves[i], {}
        if k == 0:
            for n, page in enumerate(starts.get(uid, [])):
                for p, score in ((page, 3), (page - 2, 2), (page + 2, 2), (page - 1, 2), (page + 1, 2)):
                    near[p] = max(near.get(p, 0), score - n)
        elif uid in starts:
            near = {p: 2 for p in range(min(starts[uid]), ends[uid] + 3)}
        for p, page_score in near.items():
            for j in by_page.get(p, []):
                bonus = 0
                if k == 0:
                    t = title_sim(i, j)
                    bonus = 2 if t >= TITLE_SAME else 1 if t >= TITLE_CLOSE else 0
                pairs.append((e, j, page_score + bonus))
    chain = heaviest_chain(pairs, len(leaves))

    spans = defaultdict(list)  # SuttaCentral text → the BJT nodes that hold it
    for e, j in chain:
        spans[members[e][0]].append(j)
    bundled, left_sc, left_bjt = {}, [], []
    anchors = [(-1, -1)] + chain + [(len(members), len(leaves))]
    for (e1, j1), (e2, j2) in zip(anchors, anchors[1:]):
        texts = sorted({members[e][0] for e in range(e1 + 1, e2)} - set(spans))
        bjt_gap = list(range(j1 + 1, j2))
        if e1 >= 0:
            # A text runs on over the BJT nodes after it, as far as its pages go, or as
            # many as its range counts: `sn24.20-35` abbreviates what BJT spells out.
            i1 = members[e1][0]
            while bjt_gap and (within(i1, bjt_gap[0]) or len(spans[i1]) < range_size(sc_leaves[i1])):
                spans[i1].append(bjt_gap.pop(0))
            if texts and not bjt_gap:
                # BJT holds these texts inside the node before them, if their pages agree.
                holder = spans[i1][-1]
                # The next anchor may open a new volume, where pages start again.
                top = b_pages[j2] + 2 if j2 < len(leaves) and b_pages[j2] >= b_pages[holder] else 10**6
                for i in texts:
                    if any(b_pages[holder] - 2 <= p <= top for p in starts.get(sc_leaves[i], [])):
                        bundled[i] = holder
                    else:
                        left_sc.append(i)
                continue
        left_sc += texts
        left_bjt += bjt_gap

    # The editions order a few texts differently (Jātaka 542, 543). Pair leftovers on
    # the same page when the title agrees, or when nothing else is on that page.
    for i in list(left_sc):
        same_page = [j for j in left_bjt if page_gap(i, j) == 0]
        rivals = [k for k in left_sc if same_page and page_gap(k, same_page[0]) == 0]
        titled = [j for j in left_bjt if page_gap(i, j) <= 2
                  and _title_any(bjt, names, sc_leaves[i], leaves[j]) >= TITLE_SAME]
        j = titled[0] if titled else same_page[0] if len(same_page) == 1 and rivals == [i] else None
        if j is None:
            continue
        left_sc.remove(i)
        left_bjt.remove(j)
        spans[i] = [j]
        while j + 1 in left_bjt and within(i, j + 1):
            j += 1
            spans[i].append(j)
            left_bjt.remove(j)

    forward, reverse, review = {}, {}, []
    for i in sorted(set(spans) | set(bundled)):
        uid = sc_leaves[i]
        if i not in spans:
            forward[uid] = leaves[bundled[i]]
            continue
        span = [leaves[j] for j in sorted(spans[i])]
        forward[uid] = (_holder(bjt, span) if len(span) > 1 else None) or span[0]
        for key in span:
            if key != forward[uid]:
                reverse[key] = uid
        if _title_any(bjt, names, uid, span[0]) < TITLE_CLOSE:
            review.append(f'{uid}\t{span[0]}\t{names.get(uid, "")}\t{bjt.title(span[0])}')

    unmatched = []
    for i in left_sc:
        page = '/'.join(map(str, starts.get(sc_leaves[i], []))) or 'no page'
        unmatched.append(f'{sc_leaves[i]}\tno BJT node on its page ({page})')
    for j in left_bjt:
        unmatched.append(f'{leaves[j]}\tBJT only: no SuttaCentral text on its page ({b_pages[j]})')
    return forward, reverse, unmatched, review


def range_size(uid):
    """How many suttas an ID covers: `sn24.20-35` is 16."""
    m = re.search(r'(\d+)-(\d+)$', uid)
    return int(m.group(2)) - int(m.group(1)) + 1 if m else 1


def _title_any(bjt, names, uid, key):
    """Title agreement with the BJT node, or with a parent whose heading opens it."""
    best, node = 0.0, key
    while node in bjt.tree and bjt.page(node) == bjt.page(key):
        best = max(best, similarity(names.get(uid, ''), bjt.title(node)))
        node = bjt.tree[node][4]
    return best


def _holder(bjt, span):
    """The BJT node whose text is exactly [span], if there is one."""
    node = span[0]
    while node in bjt.tree:
        units = bjt.units(node)
        if units == span:
            return node
        if set(span) <= set(units):
            return None
        node = bjt.tree[node][4]
    return None


# ── Divisions: a SuttaCentral vagga ↔ a BJT node holding exactly its texts ───

def pair_divisions(bjt, roots, sc_leaves, parent, order, forward, reverse):
    under = defaultdict(set)
    for leaf in sc_leaves:
        up = parent[leaf]
        while up is not None:
            under[up].add(leaf)
            up = parent[up]
    signature = {frozenset(v): k for k, v in under.items()}
    owner = defaultdict(set)  # BJT node → SuttaCentral texts in it
    for uid, key in forward.items():
        owner[key].add(uid)
    for key, uid in reverse.items():
        owner[key].add(uid)

    # Every BJT node holding exactly one division's texts links to it. A BJT-only text
    # inside (one SuttaCentral doesn't number) doesn't stop it.
    divisions, extra = {}, {}
    for root in roots:
        for node in [root] + bjt.descendants(root):
            if not bjt.children.get(node):
                continue
            texts = set()
            for key in [node] + bjt.descendants(node):
                texts |= owner.get(key, set())
            uid = signature.get(frozenset(texts)) if texts else None
            if uid and uid not in divisions:
                divisions[uid] = node  # the shallowest: nodes come top-down
            elif uid:
                extra[node] = uid
    return {uid: divisions[uid] for uid in order if uid in divisions}, extra


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    bilara, scdata = sc.fetch()
    names = sc.load_names(bilara)
    refs = sc.load_references(bilara)
    has_text = sc.list_uids(bilara, sc.BILARA_SHA, 'root/pli/ms', '_root-pli-ms.json')
    english = {t: sc.list_uids(bilara, sc.BILARA_SHA, d, f'_translation-en-{t}.json')
               for t, d in sc.SEGMENTED.items()}
    english['bodhi'] = sc.load_bodhi(scdata)
    research = english['sujato'] | english['brahmali']
    bjt = Bjt()

    mapping, reverse, unmatched, review = {}, {}, [], []
    for book, pitaka, roots in BOOKS:
        leaves, parent, order = sc.load_tree(scdata, pitaka, book)
        leaves = [u for u in leaves if u in has_text]
        fwd, rev, miss, rv = pair_book(leaves, bjt, roots, refs, names)
        divisions, extra = pair_divisions(bjt, roots, leaves, parent, order, fwd, rev)
        for uid in order:
            if uid in fwd:
                mapping[uid] = fwd[uid]
            elif uid in divisions:
                mapping[uid] = divisions[uid]
        reverse.update(rev)
        for key, uid in extra.items():
            reverse.setdefault(key, uid)
        unmatched += [f'{book}\t{line}' for line in miss]
        review += [f'{book}\t{line}' for line in rv]

    # The app inverts "map" keeping the first uid per node, which for a node a division
    # shares with its one text is the division. The reader should open the text.
    texts = {u for u in mapping if u in has_text}
    first = {}
    for uid, key in mapping.items():
        first.setdefault(key, uid)
    preferred = dict(first)
    for uid, key in mapping.items():
        if uid in texts and preferred[key] not in texts:
            preferred[key] = uid
    reverse = {key: uid for key, uid in reverse.items() if key not in first}
    reverse.update({key: uid for key, uid in preferred.items() if first[key] != uid})
    reverse = dict(sorted(reverse.items(), key=lambda kv: natural(kv[0])))

    chosen, taken = {}, set()
    for t in TRANSLATORS:
        chosen[t] = [u for u in mapping if u in texts and u in english[t] and u not in taken]
        taken.update(chosen[t])

    OUT.write_text(json.dumps({
        'description': 'SuttaCentral uid → BJT tree node key, built by tools/suttacentral_map/'
                       'build_map.py. "reverse": BJT nodes the map does not name, to the '
                       'SuttaCentral text they belong to. "english": which translation the '
                       'reader opens on SuttaCentral; texts in none of the lists open '
                       'SuttaCentral\'s own page for them.',
        'source': {
            'bilara-data': f'published@{sc.BILARA_SHA[:7]} ({sc.BILARA_DATE})',
            'sc-data': f'main@{sc.SCDATA_SHA[:7]} ({sc.SCDATA_DATE})',
        },
        'map': mapping,
        'reverse': reverse,
        'english': chosen,
    }, ensure_ascii=False, indent=0) + '\n')

    uncovered = sorted((u for u in research if u not in mapping), key=natural)
    UNMATCHED.write_text(
        '# Not in sc-to-bjt.json, with the reason. Written by build_map.py.\n'
        '# Texts the research store can cite (Sujato, Brahmali):\n'
        + ''.join(f'research\t{u}\n' for u in uncovered)
        + '# By book:\n' + ''.join(line + '\n' for line in unmatched))
    REVIEW.write_text(
        '# Paired by page and order, but the titles differ. Written by build_map.py.\n'
        + ''.join(line + '\n' for line in review))

    leaves = sum(1 for u in mapping if u in texts)
    print(f'texts {leaves}, divisions {len(mapping) - leaves}, reverse {len(reverse)}, '
          f'unmatched {len(unmatched)}, review {len(review)}')
    print(f'research uids {len(research)}, not covered {len(uncovered)}')
    print('english', {t: len(v) for t, v in chosen.items()})
    return 0


if __name__ == '__main__':
    sys.exit(main())
