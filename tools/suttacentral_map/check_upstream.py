#!/usr/bin/env python3
"""Has SuttaCentral moved anything sc-to-bjt.json links to?

Reads SuttaCentral's file lists as they are today (no texts) and fails when an ID
the map names, or a translation the reader opens, is gone. The research store is
pinned, so its citations keep working either way; what breaks is the reader's
"Open on SuttaCentral" link. Run weekly by .github/workflows/suttacentral-check.yml.

Run:  python3 tools/suttacentral_map/check_upstream.py
"""

import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

import sc_source as sc
from build_map import BOOKS, OUT


def clone_head(url, branch, into, sparse=()):
    subprocess.run(['git', 'clone', '-q', '--depth', '1', '--filter=blob:none', '--no-checkout',
                    '--branch', branch, url, str(into)], check=True)
    if sparse:
        sc.git(into, 'sparse-checkout', 'set', '--cone', *sparse)
        sc.git(into, 'checkout', '-q')
    return sc.git(into, 'rev-parse', '--short', 'HEAD').strip()


def report(lines, failed):
    print('\n'.join(lines))
    summary = os.environ.get('GITHUB_STEP_SUMMARY')
    if summary:
        with open(summary, 'a', encoding='utf-8') as out:
            out.write('\n'.join(['## SuttaCentral check', ''] + [f'    {l}' for l in lines]) + '\n')
    return 1 if failed else 0


def main():
    asset = json.loads(OUT.read_text())
    linked = set(asset['map'])
    english = asset['english']

    with tempfile.TemporaryDirectory() as tmp:
        bilara, scdata = Path(tmp) / 'bilara-data', Path(tmp) / 'sc-data'
        bilara_head = clone_head(sc.BILARA_URL, 'published', bilara)
        scdata_head = clone_head(sc.SCDATA_URL, 'main', scdata, sparse=sc.SCDATA_DIRS)
        # The pinned snapshot's file list too, to tell what SuttaCentral added since.
        sc.git(bilara, 'fetch', '-q', '--depth', '1', '--filter=blob:none', 'origin', sc.BILARA_SHA)

        texts = sc.list_uids(bilara, 'HEAD', 'root/pli/ms', '_root-pli-ms.json')
        now, pinned = {}, {}
        for t, folder in sc.SEGMENTED.items():
            now[t] = sc.list_uids(bilara, 'HEAD', folder, f'_translation-en-{t}.json')
            pinned[t] = sc.list_uids(bilara, sc.BILARA_SHA, folder, f'_translation-en-{t}.json')
        now['bodhi'] = sc.load_bodhi(scdata)
        divisions = set()
        for book, pitaka, _ in BOOKS:
            divisions.update(sc.load_tree(scdata, pitaka, book)[2])

    gone = sorted(u for u in linked if u not in texts and u not in divisions)
    lost = sorted(f'{u} ({t})' for t, uids in english.items() for u in uids if u not in now[t])
    added = sorted(u for t in sc.SEGMENTED for u in now[t] - pinned[t])

    lines = [
        f'map built from  bilara-data {asset["source"]["bilara-data"]}, '
        f'sc-data {asset["source"]["sc-data"]}',
        f'checked against bilara-data published@{bilara_head}, sc-data main@{scdata_head}',
        f'IDs gone from SuttaCentral           {len(gone)}',
        f'translations the reader opens, gone  {len(lost)}',
        f'new IDs in the ingested folders      {len(added)} (not an error)',
    ]
    for label, uids in (('gone', gone), ('translation gone', lost), ('new', added)):
        lines += [f'  {label}: {u}' for u in uids[:50]]
        if len(uids) > 50:
            lines.append(f'  {label}: … and {len(uids) - 50} more')
    if gone or lost:
        lines += ['', 'The reader links above now open a missing page on SuttaCentral. Research '
                  'citations still work (the store is pinned). To fix: see '
                  'docs/todo/search/sutta-references-plan.md, "Keeping it right".']
        for u in gone + lost:
            print(f'::error title=SuttaCentral moved a linked page::{u}')
    return report(lines, gone or lost)


if __name__ == '__main__':
    sys.exit(main())
