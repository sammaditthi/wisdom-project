#!/bin/bash
# Prove every target still deploys, without releasing anything: each target's
# deploy.sh once, `--dev --dry-run`, then one summary. A target that lives in
# prod only (its header says dev=placeholder prod=live) gets `--prod --dry-run`
# instead, so it is still built; its dry run must stay offline and need no
# credentials, as research_server's does.
#
# Usage:
#   ./scripts/release_all_dryrun.sh            # the dry-run sweep
#   ./scripts/release_all_dryrun.sh --list     # every target, live or placeholder
#   -h, --help
#
# Never a release: it always passes --dry-run and takes no target, so it cannot
# upload. To release, run that target's own deploy.sh, e.g.
# ./scripts/static_site/deploy.sh --prod.
#
# Keeps going after a failure and prints PASS, FAIL or NOT SET UP (a
# placeholder's exit 3) for each target; exits 1 only on a FAIL. An exit that
# disagrees with the header for the side it ran is a FAIL.
#
# Never run it while a static-site deploy is uploading: it rebuilds
# static_site_generator/build/ under that upload.
#
# It also reports whether the vendored canon is behind upstream, because a
# release is the moment to know. Reporting only: taking the corrections is
# sync-regen.sh's job, and a human reviews the tree.json diff there.
#
# --list reads the `# Status: dev=… prod=…` line in each deploy.sh header,
# because running a live deploy.sh to ask would start its tests.
# END-USAGE

. "$(dirname "$0")/lib/common.sh"

# Every target with a deploy.sh, named by its folder under scripts/, in sweep
# order. A new target is added here.
TARGETS=(static_site research_server app/web app/android app/ios app/macos)

deploy_script() {
  printf '%s' "$WISDOM_ROOT/scripts/$1/deploy.sh"
}

# `status_of TARGET dev|prod` — live or placeholder, from the header line.
status_of() {
  local value
  value=$(sed -n "s/^# Status:.*$2=\([a-z]*\).*/\1/p" "$(deploy_script "$1")")
  printf '%s' "${value:-unknown}"
}

list_targets() {
  local t
  printf '%-18s %-12s %s\n' "target" "dev" "prod"
  for t in "${TARGETS[@]}"; do
    printf '%-18s %-12s %s\n' "$t" "$(status_of "$t" dev)" "$(status_of "$t" prod)"
  done
}

# `sweep_step NAME SIDE COMMAND...` — run_step with a third state: exit 3 is
# NOT SET UP, neither a pass nor a failure. The exit must also match the
# header's SIDE=: 0 needs live and 3 needs placeholder, or it is a FAIL, so
# --list never goes stale. Kept out of run_step so no test.sh can ever read a 3
# as a pass.
_LINES=()
_FAILED=0
sweep_step() {
  local name="$1" side="$2" start status word colour header
  shift 2
  echo ""
  echo "${BOLD}── $name ($side)${NC}"
  start=$SECONDS
  "$@"
  status=$?
  header=$(status_of "$name" "$side")
  case "$status:$header" in
    0:live)        word="PASS";       colour="$GREEN" ;;
    3:placeholder) word="NOT SET UP"; colour="" ;;
    0:*|3:*)
      word="FAIL"; colour="$RED"; _FAILED=1
      echo "error: $name exited $status but its header says $side=$header." >&2
      ;;
    *)             word="FAIL";       colour="$RED"; _FAILED=1 ;;
  esac
  # Padded before the colour codes go on, so the time column lines up.
  _LINES+=("$(printf '%-28s %s%-10s%s  %4ss' "$name ($side)" "$colour" "$word" "$NC" $((SECONDS - start)))")
}

# The canon's staleness, printed beside the verdict. Never a failure and never
# a fix: upstream text corrections can move tree.json nodeKeys, which breaks
# deep links, so they are taken by hand through sync-regen.sh. A missing
# receipt, no jq or no network says nothing rather than crying wolf.
canon_heartbeat() {
  local receipt="$WISDOM_ROOT/scripts/bjt-sync-regen/bjt-provenance.json"
  local ours source branch upstream
  command -v jq >/dev/null 2>&1 || return 0
  [ -f "$receipt" ] || return 0
  ours=$(jq -r '.upstream_sha // empty' "$receipt" 2>/dev/null)
  source=$(jq -r '.source // empty' "$receipt" 2>/dev/null)
  branch=$(jq -r '.branch // empty' "$receipt" 2>/dev/null)
  [ -n "$ours" ] && [ -n "$source" ] && [ -n "$branch" ] || return 0
  # GIT_TERMINAL_PROMPT=0: a remote that asks for credentials must fail, not
  # sit waiting for someone to type them.
  upstream=$(GIT_TERMINAL_PROMPT=0 git ls-remote "$source" "refs/heads/$branch" \
    2>/dev/null | awk '{print $1}')
  if [ -z "$upstream" ]; then
    echo "canon: upstream unreachable, staleness unknown."
  elif [ "$upstream" = "$ours" ]; then
    echo "canon: up to date with upstream ${ours:0:8}."
  else
    echo "${BOLD}canon: upstream is at ${upstream:0:8}, we vendored ${ours:0:8}.${NC}"
    echo "       ./scripts/bjt-sync-regen/sync-regen.sh --dry-run   # review, then sync"
  fi
}

sweep() {
  local t side line
  for t in "${TARGETS[@]}"; do
    side=dev
    if [ "$(status_of "$t" dev)" = placeholder ] && [ "$(status_of "$t" prod)" = live ]; then
      side=prod
    fi
    # Both flags said out loud, so a deploy.sh whose default ever changed
    # still gets the side asked for.
    sweep_step "$t" "$side" "$(deploy_script "$t")" "--$side" --dry-run
  done
  echo ""
  echo "${BOLD}── release_all_dryrun${NC}"
  for line in "${_LINES[@]}"; do
    echo "$line"
  done
  echo ""
  canon_heartbeat
  echo ""
  if [ $_FAILED -eq 0 ]; then
    echo "${GREEN}${BOLD}release_all_dryrun: no dry run failed.${NC}"
  else
    echo "${RED}${BOLD}release_all_dryrun: a dry run FAILED (table above).${NC}"
  fi
  exit $_FAILED
}

case "$#:${1-}" in
  0:)               sweep ;;
  1:--list)         list_targets ;;
  1:-h|1:--help)    usage ;;
  *)
    echo "error: release_all_dryrun.sh takes no target and no flags but --list." >&2
    echo "       To release, run the target's own deploy.sh, e.g." >&2
    echo "       ./scripts/static_site/deploy.sh --prod" >&2
    exit 1
    ;;
esac
