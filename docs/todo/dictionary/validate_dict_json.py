#!/usr/bin/env python3
"""Refuse a bad DPD export before it reaches assets/dictionary.

    validate_dict_json.py <candidate.json[.gz]> [--against <shipped.json[.gz]>]

Checks the shape dict-populate.js needs, the key set, the markup vocabulary,
and -- with --against -- the size band and the added/removed/changed counts.
Exit 1 on any failure.
"""
import gzip, json, re, sys, unicodedata
from collections import Counter

PALI = re.compile(r'^[a-zāīūṭḍṇṃñṅḷ ]+$')      # dpd_view.sql's GLOB allowlist
TAG = re.compile(r'</?([a-zA-Z][a-zA-Z0-9]*)')
ALLOWED_TAGS = {'b', 'i', 'br', 'a'}

def load(path):
    opener = gzip.open if path.endswith('.gz') else open
    with opener(path, 'rb') as fh:
        raw = fh.read()
    return raw, json.loads(raw.decode('utf-8'))

def check(path, prev_path=None):
    fails, notes = [], []
    raw, data = load(path)

    # --- shape: dict-populate.js destructures each element as [word, meaning]
    if not isinstance(data, list):
        fails.append('top level is not an array')
        return fails, notes
    bad_shape = [i for i, e in enumerate(data)
                 if not (isinstance(e, list) and len(e) == 2
                         and all(isinstance(x, str) for x in e))]
    if bad_shape:
        fails.append(f'{len(bad_shape)} entries are not [string, string] '
                     f'(first at index {bad_shape[0]}) -- '
                     'array-of-objects exports break the build')
        return fails, notes

    keys = [k for k, _ in data]
    notes.append(f'{len(data):,} entries, {len(raw):,} bytes')

    # --- keys
    dupes = [k for k, n in Counter(keys).items() if n > 1]
    if dupes:
        fails.append(f'{len(dupes)} duplicate keys, e.g. {dupes[:5]}')
    if '' in keys:
        fails.append('empty key present')
    non_nfc = [k for k in keys if unicodedata.normalize('NFC', k) != k]
    if non_nfc:
        fails.append(f'{len(non_nfc)} keys are not NFC, e.g. {non_nfc[:5]}')
    non_pali = [k for k in keys if k and not PALI.match(k)]
    if non_pali:
        fails.append(f'{len(non_pali)} keys outside the Pali letter set, '
                     f'e.g. {non_pali[:8]} -- upstream added a key class; '
                     'dict-populate.js would mangle these into Sinhala junk')

    # --- values
    empty = sum(1 for _, v in data if not v.strip())
    if empty:
        fails.append(f'{empty} empty meanings')
    tags = Counter(t.lower() for _, v in data for t in TAG.findall(v))
    notes.append('markup: ' + (', '.join(f'{t}={n:,}' for t, n in sorted(tags.items()))
                               or 'none'))
    unknown = set(tags) - ALLOWED_TAGS
    if unknown:
        fails.append(f'unexpected markup tags: {sorted(unknown)}')

    # --- the Read more link must point at its own key (en-dpd only)
    links = [(k, v) for k, v in data if 'dpdict.net' in v]
    if links:
        mismatched = [k for k, v in links
                      if f'<a href="https://www.dpdict.net/?q={k}">Read more</a>' not in v]
        if mismatched:
            fails.append(f'{len(mismatched)} Read-more links do not match their key, '
                         f'e.g. {mismatched[:5]}')
        if len(links) != len(data):
            fails.append(f'{len(data) - len(links)} entries have no Read-more link')

    # --- formatting: the committed files are indent=4, ensure_ascii=False, no final newline
    if raw != json.dumps(data, indent=4, ensure_ascii=False).encode('utf-8'):
        fails.append('formatting differs from 4-space, non-escaped-unicode, '
                     'no-trailing-newline JSON')

    # --- against the file it replaces
    if prev_path:
        _, prev = load(prev_path)
        pm, nm = dict((k, v) for k, v in prev), dict(data)
        added, removed = set(nm) - set(pm), set(pm) - set(nm)
        changed = sum(1 for k in set(nm) & set(pm) if nm[k] != pm[k])
        notes.append(f'vs {prev_path.split("/")[-1]}: {len(set(nm) & set(pm)):,} shared, '
                     f'+{len(added):,} added, -{len(removed):,} removed, '
                     f'{changed:,} meanings changed')
        if len(data) < 0.9 * len(prev):
            fails.append(f'key count collapsed: {len(data):,} vs {len(prev):,} '
                         '(>10% smaller)')
        if len(data) > 1.5 * len(prev):
            fails.append(f'key count ballooned: {len(data):,} vs {len(prev):,} '
                         '(>50% bigger)')
    return fails, notes

if __name__ == '__main__':
    args = sys.argv[1:]
    prev = args[args.index('--against') + 1] if '--against' in args else None
    cand = args[0]
    fails, notes = check(cand, prev)
    print(f'== {cand}')
    for n in notes:
        print(f'   {n}')
    for f in fails:
        print(f'   FAIL {f}')
    print('   OK' if not fails else f'   {len(fails)} failure(s)')
    sys.exit(1 if fails else 0)
