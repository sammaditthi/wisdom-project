#!/bin/bash
# The research server's release gate: a TypeScript typecheck + build, then the
# unit tests. `wrangler deploy` strips types without checking them, so without
# this a type error ships.
#
# Usage:
#   ./scripts/research_server/test.sh            # everything
#   ./scripts/research_server/test.sh --quick    # the same: nothing here needs
#                                                # more than a checkout
#   -h, --help
#
# Runs every step even after one fails, then prints a summary and exits 0 or 1.
# Called first by ./scripts/research_server/deploy.sh.
# END-USAGE

. "$(dirname "$0")/../lib/common.sh"

QUICK=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --quick)   QUICK=true; shift ;;
    -h|--help) usage ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Run with -h for help." >&2
      exit 1
      ;;
  esac
done

cd "$WISDOM_ROOT/research_server" || exit 1

require_node22

# tsc typechecks and writes dist/ (even on a type error); the tests run from it.
# It never deletes there, so start clean, or a renamed test's old copy still runs.
typecheck_build() {
  rm -rf dist && npm run build
}

unit_tests() {
  node --test "dist/test/**/*.test.js"
}

run_step "dependencies" research_deps
run_step "typecheck + build" typecheck_build
run_step "unit tests" unit_tests

if [ "$QUICK" = true ]; then
  step_summary "research_server (--quick)"
else
  step_summary "research_server"
fi
