# Search results: show more — plan

Started 2026-10-16, decided with the user the same day. Not started.

Needs steps 1–3 of `search-hits-by-sutta-and-in-page-search-plan.md`
first: suttas ranked by score, the whole ranked list in memory, counts in
suttas.

## Decided (2026-10-16)

- The Content tab opens with the top 50 suttas, ranked by score.
- A **Show more** button under the list adds the next 50, as long as there
  are more.
- The Top results page doesn't change: 3 suttas and "See all".
- A button, not infinite scroll and not numbered pages. Baymard's usability
  tests found a "load more" button with lazy loading the better of the three,
  and infinite scroll worst for search results, mobile above all
  ([Baymard](https://baymard.com/blog/external-load-more-vs-pagination-vs-infinite-scrolling),
  [Smashing Magazine](https://smashingmagazine.com/2016/03/pagination-infinite-scrolling-load-more-buttons)).

## How it works

- The button sits under the footer line, "Viewing 50 out of 2,912 suttas".
  The footer keeps its count up to date, and the button goes when everything
  is shown.
- Each tap takes the next 50 from the ranked list already in memory and loads
  their snippets in one batch. No new search query.
- New tiles appear below. The list keeps its scroll position and the button
  keeps focus. While the snippets load, the button shows a small spinner and
  can't be pressed again.
- A new query, or a changed filter or scope, goes back to 50.
- Groups the user expanded ("View N more") stay expanded.

## Decisions for the user

- **Titles and Definitions tabs.** They show the same footer. Recommended:
  the same button in all three tabs, from one shared footer widget, so it
  works the same everywhere. Titles search the tree in memory; Definitions
  already page with `offset`. Or Content only.
- **Label.** "Show more" or "Show 50 more". Take the Sinhala from tipitaka.lk
  as usual.

## Steps

1. Search state: how many suttas the Content tab shows, starting at 50 and
   reset by a new query, filter or scope.
2. The provider slices the ranked list to that number and loads snippets for
   the new tiles only.
3. A footer widget with the line and the button, used by
   `search_results_panel.dart`.
4. en/si strings.

## Tests

Written by the test-writer agent. They need: 50 at first; each tap adds 50;
the button goes at the end; a new query resets to 50; the scroll position is
kept.

## Handover

Not started.
