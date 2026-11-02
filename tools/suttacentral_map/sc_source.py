"""SuttaCentral's side of the map, read from pinned clones of its two data repos.

bilara-data is pinned to the snapshot the research store was ingested from, so the
map and the store agree on every sutta ID (docs/done/canon-sources/sc-sync-ingest.md).
"""

import json
import re
import subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
CACHE = HERE / '.cache'

BILARA_URL = 'https://github.com/suttacentral/bilara-data.git'
BILARA_SHA = 'ce5b98f032ec20132a5678bddf15a76c94263913'
BILARA_DATE = '2026-09-28'
SCDATA_URL = 'https://github.com/suttacentral/sc-data.git'
SCDATA_SHA = 'd85451882dd1c73edb2cd9ac34a168587e14baf7'
SCDATA_DATE = '2026-11-02'

BILARA_DIRS = [
    'reference/pli/ms',
    'root/misc/site/name/sutta',
    'root/misc/site/name/vinaya',
    'root/misc/site/name/abhidhamma',
]
SCDATA_DIRS = ['structure/tree', 'html_text/en/pli/sutta']

# Translations the reader can open, in bilara-data. Bodhi's are legacy HTML in sc-data.
SEGMENTED = {
    'sujato': 'translation/en/sujato/sutta',
    'brahmali': 'translation/en/brahmali/vinaya',
}

# `bj14.276` is volume 14, page 276; a split volume reads `bj17.1.2`.
_BJ = re.compile(r'\bbj(\d+(?:\.\d+)?)\.(\d+)(?![.\d])')


def git(repo, *args):
    return subprocess.run(['git', '-C', str(repo), *args], check=True,
                          capture_output=True, text=True).stdout


def ensure_clone(name, url, sha, dirs):
    """A shallow, blobless, sparse clone of [url] checked out at [sha]."""
    path = CACHE / name
    if (path / '.git').exists() and git(path, 'rev-parse', 'HEAD').strip() == sha:
        return path
    CACHE.mkdir(exist_ok=True)
    if not (path / '.git').exists():
        subprocess.run(['git', 'clone', '-q', '--depth', '1', '--filter=blob:none',
                        '--no-checkout', url, str(path)], check=True)
    git(path, 'sparse-checkout', 'set', '--cone', *dirs)
    git(path, 'fetch', '-q', '--depth', '1', '--filter=blob:none', 'origin', sha)
    git(path, '-c', 'advice.detachedHead=false', 'checkout', '-q', '--detach', sha)
    return path


def list_uids(repo, sha, folder, suffix):
    """IDs from file names under [folder], read from git's tree: no file contents."""
    names = git(repo, 'ls-tree', '-r', '--name-only', sha, '--', folder).split()
    return {Path(n).name[:-len(suffix)] for n in names if n.endswith(suffix)}


def load_tree(scdata, pitaka, book):
    """SuttaCentral's navigation for one book: ordered leaves, and each division's parent."""
    root = json.loads((scdata / 'structure/tree' / pitaka / f'{book}-tree.json').read_text())
    leaves, parent, order = [], {}, []

    def walk(node, up):
        if isinstance(node, str):
            leaves.append(node)
            parent[node] = up
            order.append(node)
            return
        for uid, children in node.items():
            parent[uid] = up
            order.append(uid)
            for child in children:
                walk(child, uid)

    walk(root, None)
    return leaves, parent, order


def load_names(bilara):
    """uid → Pali title, divisions included."""
    names = {}
    for path in sorted((bilara / 'root/misc/site/name').rglob('*.json')):
        for key, title in json.loads(path.read_text()).items():
            names[key.split(':', 1)[1].split('.', 1)[1]] = title
    return names


def load_references(bilara):
    """uid → that text's segments in order, each a list of (volume, page) BJT markers,
    or None for a segment with no references at all."""
    refs = {}
    for path in (bilara / 'reference/pli/ms').rglob('*_reference.json'):
        segments = json.loads(path.read_text())
        refs[path.name[:-len('_reference.json')]] = [
            [(v, int(p)) for v, p in _BJ.findall(r)] if r else None
            for r in segments.values()
        ]
    return refs


def load_bodhi(scdata):
    """IDs with a Bhikkhu Bodhi translation among SuttaCentral's legacy texts."""
    uids = set()
    for path in (scdata / 'html_text/en/pli/sutta').rglob('*.html'):
        head = path.read_text(encoding='utf-8')[:2000]
        if "<meta name='author' content='Bhikkhu Bodhi'>" in head:
            uids.add(path.stem)
    return uids


def fetch():
    bilara = ensure_clone('bilara-data', BILARA_URL, BILARA_SHA, BILARA_DIRS)
    scdata = ensure_clone('sc-data', SCDATA_URL, SCDATA_SHA, SCDATA_DIRS)
    return bilara, scdata
