#!/bin/bash
# Get a release ready: raise the version, date the changelog notes, commit.
# Local only — no tag, no push. ./scripts/deploy.sh --prod does both once every
# test passes.
#
# Usage:
#   ./scripts/release.sh            # where things stand, and what's next
#   ./scripts/release.sh patch      # a fix                     1.1.0 → 1.1.1
#   ./scripts/release.sh minor      # something new             1.1.0 → 1.2.0
#   ./scripts/release.sh major      # breaks saved settings,    1.1.0 → 2.0.0
#                                   # bookmarks or deep links
#   -h, --help
#
# Write the notes under "## Unreleased" at the top of CHANGELOG.md first; this
# turns that heading into "## <version> - <today>". The rules for the notes are
# in docs/general/how-to-release.md. Only delegates: tools/release.dart does
# the work.
# END-USAGE

. "$(dirname "$0")/lib/common.sh"
cd "$WISDOM_ROOT"

case "$#:${1-}" in
  0:)                      exec dart run tools/release.dart status ;;
  1:-h|1:--help)           usage ;;
  1:patch|1:minor|1:major) exec dart run tools/release.dart cut "$1" ;;
  *)
    echo "error: release.sh takes patch, minor or major." >&2
    echo "Run with -h for help." >&2
    exit 1
    ;;
esac
