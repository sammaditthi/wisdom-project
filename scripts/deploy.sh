#!/bin/bash
# Release every product to production: test, ask, tag, push, deploy.
#
# Usage:
#   ./scripts/deploy.sh --prod           # the release
#   ./scripts/deploy.sh --prod --yes     # the same with no question (CI)
#   -h, --help
#
# Run ./scripts/release.sh <part> first; it raises the version and commits.
# This then:
#   1. refuses in seconds: not main, a dirty tree, behind GitHub, a drifted
#      version file, no CHANGELOG entry for this version, or this version's
#      tag already on another commit
#   2. runs every product's tests (scripts/test_all.sh)
#   3. asks once
#   4. tags v<version> and pushes main with it, both or neither
#   5. runs each product's deploy.sh --prod --yes --skip-tests, stopping at the
#      first failure: the tag just made proves the tests passed
#
# The tag comes after the tests, so a red test costs no version: fix, commit,
# run this again, and the fixed commit gets the tag. Once the tag is on HEAD,
# as on a re-run after a failed push or upload, the tests are not run again.
#
# Prod only. A dev deploy is the product's own deploy.sh, and a product's own
# deploy.sh --prod re-deploys a released commit by itself.
# END-USAGE

. "$(dirname "$0")/lib/common.sh"

# In deploy order: the app calls the Worker and the site links into the app,
# so each goes live after what it depends on.
PRODUCTS=(research_server app/web static_site)

PROD=false
ASSUME_YES=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --prod)    PROD=true; shift ;;
    --yes|-y)  ASSUME_YES=true; shift ;;
    -h|--help) usage ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Run with -h for help." >&2
      exit 1
      ;;
  esac
done

if [ "$PROD" = false ]; then
  echo "error: deploy.sh releases to production, so --prod is said out loud." >&2
  echo "       A dev deploy is the product's own, e.g. ./scripts/app/web/deploy.sh --dev" >&2
  exit 1
fi
# The question comes after the tests, so a missing terminal is refused before them.
if [ "$ASSUME_YES" = false ] && [ ! -t 0 ]; then
  echo "error: a release needs a terminal to confirm. Pass --yes in automation." >&2
  exit 1
fi

cd "$WISDOM_ROOT"

# --- Refusals that take seconds ----------------------------------------------
# One tag for every product, so they must release from one branch: otherwise
# the tag is pushed and then a product's own guard refuses it.
BRANCH=$(target APP_WEB_PROD_BRANCH) || exit 1
for key in STATIC_SITE_PROD_BRANCH RESEARCH_PROD_BRANCH; do
  if [ "$(target "$key")" != "$BRANCH" ]; then
    echo "error: $key differs from APP_WEB_PROD_BRANCH ('$BRANCH') in" >&2
    echo "       scripts/config/targets.env. One tag needs one branch." >&2
    exit 1
  fi
done

require_release_tree "$BRANCH" || exit 1

# Behind GitHub, the push after the tag would be rejected.
echo "Checking $BRANCH is not behind GitHub..."
if ! git fetch --quiet origin "$BRANCH"; then
  echo "error: could not fetch origin/$BRANCH (network?). Nothing tagged." >&2
  exit 1
fi
if [ -n "$(git rev-list "HEAD..origin/$BRANCH")" ]; then
  echo "error: $BRANCH is behind origin/$BRANCH. Pull first: git pull --rebase" >&2
  exit 1
fi

TAGGED=false
if release_tag_at_head; then
  TAGGED=true
elif git rev-parse --verify --quiet "refs/tags/$RELEASE_TAG" >/dev/null; then
  AT=$(git rev-parse --short "$RELEASE_TAG^{commit}")
  # A failed push leaves the tag here only, and the pull after it moves HEAD on.
  # ls-remote exits 2 for "no such ref"; any other failure is the network, and
  # must not read as "drop the tag".
  git ls-remote --exit-code --tags origin "refs/tags/$RELEASE_TAG" >/dev/null
  case $? in
    0) ;;
    2)
      echo "error: $RELEASE_TAG is on $AT, not HEAD, and never reached GitHub." >&2
      echo "       Drop it, then run this again: git tag -d $RELEASE_TAG" >&2
      exit 1
      ;;
    *)
      echo "error: could not ask GitHub whether $RELEASE_TAG is there (network?)." >&2
      exit 1
      ;;
  esac
  echo "error: $RELEASE_TAG is already released, at $AT." >&2
  echo "       A new release needs a new version: ./scripts/release.sh patch" >&2
  exit 1
fi

# --- Tests -------------------------------------------------------------------
# Without the deploy tokens: no test needs them.
if [ "$TAGGED" = true ]; then
  echo "$RELEASE_TAG is already on HEAD; its tests passed when it was made."
else
  if ! env -u CLOUDFLARE_API_TOKEN -u CLOUDFLARE_ACCOUNT_ID ./scripts/test_all.sh; then
    echo "" >&2
    echo "error: a test failed (summary above). Nothing tagged, nothing deployed." >&2
    echo "       Fix, commit, run this again: the fixed commit gets $RELEASE_TAG." >&2
    exit 1
  fi
  # A test that rewrote a file would leave the tag on a tree nobody built.
  require_release_tree "$BRANCH" || { echo "       The tests left it so. Nothing tagged." >&2; exit 1; }
fi

# --- The question, then the tag ----------------------------------------------
echo ""
if [ "$ASSUME_YES" = false ]; then
  confirm_release "Release $RELEASE_TAG to PRODUCTION: ${PRODUCTS[*]}?"
fi

if [ "$TAGGED" = false ]; then
  git tag -a "$RELEASE_TAG" -m "Release $RELEASE_TAG" || exit 1
  echo "tag        $RELEASE_TAG"
fi
# Both or neither, and on every run, so a re-run sends whatever is missing.
if ! git push --atomic origin "$BRANCH" "$RELEASE_TAG"; then
  echo "error: the push failed. Nothing deployed. Run this again: $RELEASE_TAG" >&2
  echo "       is on HEAD, so it goes straight to the question. If GitHub moved" >&2
  echo "       on instead, git tag -d $RELEASE_TAG, then pull first." >&2
  exit 1
fi
echo "pushed     $BRANCH, $RELEASE_TAG"

# --- Deploy ------------------------------------------------------------------
SHIPPED=()
for product in "${PRODUCTS[@]}"; do
  echo ""
  echo "${BOLD}── $product${NC}"
  if ! "./scripts/$product/deploy.sh" --prod --yes --skip-tests; then
    echo "" >&2
    echo "error: $product failed. Shipped before it: ${SHIPPED[*]:-nothing}." >&2
    echo "       Run this again: $RELEASE_TAG is on HEAD, so it skips the tests," >&2
    echo "       and what already shipped re-deploys unchanged." >&2
    exit 1
  fi
  SHIPPED+=("$product")
done

echo ""
echo "${GREEN}${BOLD}deploy: $RELEASE_TAG is live — ${SHIPPED[*]}.${NC}"
