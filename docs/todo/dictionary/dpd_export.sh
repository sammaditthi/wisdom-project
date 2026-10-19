#!/usr/bin/env bash
# Export the two DPD views from a release's dpd.db into the shape
# tools/dict-populate.js reads. Replaces the DB Browser export.
#
#   dpd_export.sh <dpd.db> <out-dir> [dpd_view.sql]
#
# Read-only on purpose: dpd.db is opened immutable, so the views are created
# TEMP and the 2 GB input is never written to. (A WAL database cannot even be
# opened -readonly without writing its -shm; DB Browser wrote the views into
# the file itself.)
#
# Temporary home beside dpd_view.sql; both move to scripts/dpd-sync-regen/
# when that script exists. See dpd-provenance-and-refresh.md.
set -euo pipefail

usage="usage: dpd_export.sh <dpd.db> <out-dir> [dpd_view.sql]"
db=${1:?$usage}
out=${2:?$usage}
view_sql=${3:-"$(dirname "$0")/dpd_view.sql"}

mkdir -p "$out"

# file: URI so immutable=1 can be passed; the path may contain spaces.
uri="file:$(python3 -c 'import sys,urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "$db")?immutable=1"

# Same SQL, created as TEMP views so an immutable database accepts it.
views=$(sed -e 's/^CREATE VIEW /CREATE TEMP VIEW /' \
            -e 's/^DROP VIEW IF EXISTS /DROP VIEW IF EXISTS temp./' "$view_sql")

export_view() { # <view> <output basename>
  echo "exporting $1 -> $out/$2.json"
  # json_group_array(json_array(...)) is the only form that emits the
  # array-of-arrays shape; .mode json writes array-of-objects, which breaks
  # dict-populate.js. ORDER BY lives here and not in the view, so the export
  # is byte-reproducible without churning the receipt's view_sql_sha256.
  printf '%s\n%s\n' "$views" \
    "SELECT json_group_array(json_array(aword, meaning))
     FROM (SELECT aword, meaning FROM $1 ORDER BY aword);" \
    | sqlite3 "$uri" \
    | python3 -c 'import json,sys
sys.stdout.write(json.dumps(json.load(sys.stdin), indent=4, ensure_ascii=False))' \
    > "$out/$2.json"
}

export_view view_dpd              en-dpd
export_view view_dpd_construction en-dpd-construction

echo "release: $(sqlite3 "$uri" "SELECT value FROM db_info WHERE key='dpd_release_version';")"
