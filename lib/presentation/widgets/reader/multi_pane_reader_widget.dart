import 'dart:async';

import 'package:flutter/gestures.dart' show computeHitSlop, kPrimaryButton;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/l10n/app_localizations.dart';
import '../../models/reader_layout.dart';
import '../../models/in_page_search_state.dart';
import '../../../domain/entities/navigation/tipitaka_tree_node.dart';
import '../../../domain/entities/reader/document_slice.dart';
import '../../../domain/entities/reader/reader_unit.dart';
import '../../providers/document_provider.dart';
import '../../providers/dictionary_provider.dart'
    show
        selectedDictionaryWordProvider,
        dictionaryHighlightProvider,
        hasActiveSelectionProvider;
import '../../providers/in_page_search_provider.dart';
import '../../providers/tab_provider.dart'
    show
        activeTabIndexProvider,
        activeTabProvider,
        tabsProvider,
        activeReaderLayoutProvider,
        activeNodeKeyProvider;
import '../../providers/navigate_to_sutta_provider.dart'
    show navigateToSuttaProvider;
import '../../providers/reader_unit_provider.dart'
    show ReaderStep, neighbourLeafProvider;
import '../../providers/fts_highlight_provider.dart';
import '../../providers/reader_scroll_provider.dart';
import 'entry_key_registry.dart';
import 'single_column_pane.dart';
import 'dual_column_pane.dart';
import 'stacked_pane.dart';
import 'reader_selection_handler.dart';
import 'in_page_search_bar.dart';
import 'reader_action_buttons.dart';
import 'reader_actions.dart' show ReaderStepTarget;
import '../dictionary/dictionary_bottom_sheet.dart';
import '../common/app_emblem.dart';
import '../common/status_message_view.dart';
import '../../../core/utils/responsive_utils.dart';

class MultiPaneReaderWidget extends ConsumerStatefulWidget {
  const MultiPaneReaderWidget({super.key});

  @override
  ConsumerState<MultiPaneReaderWidget> createState() =>
      _MultiPaneReaderWidgetState();
}

class _MultiPaneReaderWidgetState extends ConsumerState<MultiPaneReaderWidget>
    with ReaderSelectionHandler<MultiPaneReaderWidget> {
  // Single scroll controller for all modes. Each new scroll view (a tab
  // switch, a layout switch, a unit that just loaded) starts at the active
  // tab's saved offset, so its first frame is already where that tab was left.
  late final ScrollController _scrollController = _TabScrollController(
    () => ref.read(activeTabProvider)?.scrollOffset ?? 0,
  );

  // Registry for entry-level GlobalKeys used to sync scroll position
  // across layout switches AND to drive in-page-search scroll-to-match.
  // Shared with all pane widgets.
  final EntryKeyRegistry _entryKeyRegistry = EntryKeyRegistry();

  // Tracks whether the user has scrolled away from the top.
  // Updated in _onScroll; only calls setState when the value actually changes.
  bool _isScrolledDown = false;

  // When true, the layout change listener is suppressed. Set during tab
  // switches to prevent the layout listener from firing when the "change"
  // is just a side-effect of switching to a tab with a different layout.
  bool _suppressLayoutListener = false;

  // Debounces scroll-position writes into the active tab so a fast scroll
  // doesn't push hundreds of state mutations through Riverpod / disk.
  Timer? _scrollSaveDebounce;
  static const _scrollSaveDelay = Duration(milliseconds: 400);

  // When true, _onScroll skips the debounced auto-save. Toggled around
  // programmatic jumpTo() calls during scroll restoration so a jump clamped
  // to a still-estimated extent can't overwrite the genuinely saved offset.
  bool _suppressScrollSave = false;

  // Bound on *stalled* restoration retries — see [_restoreScrollWithRetry].
  // Frames that grow the scroll extent are progress and cost nothing; this
  // only limits how long we keep re-jumping at an offset nothing is moving
  // toward (content shrunk, etc.).
  static const _restoreMaxRetries = 30;

  // True while [_anchorAt] jumps: that jump measures the old content, so
  // [_onScroll] leaves the scroll state to the sync after the new layout.
  bool _anchoring = false;

  // The pointer and position of a primary press on the page, while it may
  // still be a tap — see [_clearOnTap].
  int? _tapPointer;
  Offset? _tapDownPosition;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  /// Scroll listener for scroll-position tracking.
  void _onScroll() {
    if (_scrollController.hasClients) {
      if (!_anchoring) _syncScrollState();

      // Debounced persist of scroll position into the active tab. Without
      // this, a reload while parked in a tab (no tab switch) would lose
      // the position. TabsNotifier itself coalesces writes again before
      // hitting disk.
      //
      // Skip while a programmatic restore is in flight — otherwise the
      // jumpTo we just performed (possibly clamped to a small maxExtent
      // because pages haven't laid out yet) would clobber the real saved
      // offset on disk.
      if (!_suppressScrollSave) {
        _scrollSaveDebounce?.cancel();
        _scrollSaveDebounce = Timer(_scrollSaveDelay, _saveScrollPosition);
      }
    }
  }

  /// Syncs the two things that follow how much of the unit is above the
  /// viewport: Mode 1/Mode 2 of the action buttons, and the app bar's
  /// "scrolled under" tint ([readerScrolledUnderProvider]).
  ///
  /// Both read `extentBefore`, never `pixels`: offset 0 is the anchor row,
  /// which can sit pages into the unit. The tint uses `extentBefore > 0`, the
  /// threshold Material 3's own detection uses. Called from [_onScroll], and
  /// explicitly after anything that changes the content but not the offset
  /// (a restore, a new anchor), which notifies no scroll listener.
  void _syncScrollState() {
    if (!mounted || !_scrollController.hasClients) return;
    final extentBefore = _scrollController.position.extentBefore;

    // A small fixed threshold (not a full viewport) so Mode 2 kicks in
    // promptly once the user starts scrolling, while still ignoring
    // overscroll/bounce jitter near the top.
    const scrollAwayFromTopThreshold = 60.0;
    final scrolledDown = extentBefore > scrollAwayFromTopThreshold;
    if (scrolledDown != _isScrolledDown) {
      setState(() => _isScrolledDown = scrolledDown);
    }

    final scrolledUnder = extentBefore > 0;
    final notifier = ref.read(readerScrolledUnderProvider.notifier);
    if (notifier.state != scrolledUnder) {
      notifier.state = scrolledUnder;
    }
  }

  @override
  void dispose() {
    _scrollSaveDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _entryKeyRegistry.clear();
    super.dispose();
  }

  /// Persists the current scroll offset into the active tab's
  /// [ReaderTab.scrollOffset]. TabsNotifier debounces the disk write, so
  /// calling this often is cheap.
  void _saveScrollPosition([int? index]) {
    final int activeTabIndex = index ?? ref.read(activeTabIndexProvider);
    if (activeTabIndex >= 0 && _scrollController.hasClients) {
      ref
          .read(tabsProvider.notifier)
          .updateTabScrollOffset(activeTabIndex, _scrollController.offset);
    }
  }

  /// Scrolls to the beginning of the current unit by dropping the anchor.
  ///
  /// Not a scroll: above the anchor `minScrollExtent` is only an estimate
  /// until those pages are built, so a jump to it stops short of the top.
  void _scrollToBeginning() {
    // Reset scroll-tracking state so the button transitions correctly
    // (from scroll-to-top to skip-previous once we're at the beginning).
    setState(() => _isScrolledDown = false);
    _anchorAt(null);
  }

  /// Anchors the active tab at [anchor] (null: the unit's top), with the
  /// viewport on it.
  ///
  /// Jumps to 0 here, before the rebuild, so the frame that lays out the new
  /// anchor already sits at it: nothing between the old position and the new
  /// one is ever laid out.
  void _anchorAt((int, int)? anchor) {
    ref
        .read(tabsProvider.notifier)
        .setTabAnchor(ref.read(activeTabIndexProvider), anchor);
    if (_scrollController.hasClients) {
      _anchoring = true;
      _scrollController.jumpTo(0);
      _anchoring = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncScrollState());
  }

  /// Navigates to a neighbouring sutta.
  /// Delegates business logic to [navigateToSuttaProvider] and
  /// handles the widget-specific concern (scroll position).
  void _navigateToSutta(TipitakaTreeNode target) {
    // The new sutta has no anchor and offset 0.
    ref.read(navigateToSuttaProvider)(target);
    // When its text is already loaded the scroll view stays, and nothing else
    // moves it or re-reads Mode 1/2 after the new layout. The jump must not
    // measure the old layout, whose offset 0 may have pages above it.
    _anchorAt(null);
  }

  /// One step action, or null when the corpus ends that way.
  ReaderStepTarget? _stepTarget(TipitakaTreeNode? leaf) => leaf == null
      ? null
      : (name: leaf.paliName, onTap: () => _navigateToSutta(leaf));

  /// Restores the active tab's saved offset, measured from its anchor row.
  /// Call from a post-frame callback, once the content has rebuilt.
  ///
  /// Both extents are estimates until the rows out to them are built — below
  /// the anchor and above it alike — so a saved offset past either is jumped
  /// to as far as the estimate allows and tried again next frame, by which
  /// point that jump has built more. [retriesLeft] is spent only on frames
  /// where neither extent grew, which bounds it when the offset can genuinely
  /// no longer be reached (the unit got shorter). Throughout,
  /// [_suppressScrollSave] keeps a clamped jump from overwriting the saved
  /// offset.
  void _restoreScrollWithRetry({
    int retriesLeft = _restoreMaxRetries,
    double? lastMinExtent,
    double? lastMaxExtent,
  }) {
    if (!mounted) return;
    final activeTabIndex = ref.read(activeTabIndexProvider);
    final tabs = ref.read(tabsProvider);
    if (activeTabIndex < 0 ||
        activeTabIndex >= tabs.length ||
        !_scrollController.hasClients) {
      return;
    }
    final saved = tabs[activeTabIndex].scrollOffset;
    final position = _scrollController.position;
    final minExtent = position.minScrollExtent;
    final maxExtent = position.maxScrollExtent;

    _suppressScrollSave = true;
    _scrollController.jumpTo(saved.clamp(minExtent, maxExtent));
    // A jump to where the view already is fires no notification, so
    // _onScroll won't run — sync explicitly here.
    _syncScrollState();
    // The clamped jumpTo notifies _onScroll synchronously above; clear
    // the flag on the next frame so genuine user scrolls aren't missed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _suppressScrollSave = false;
      _syncScrollState();
    });

    if ((saved > maxExtent || saved < minExtent) && retriesLeft > 0) {
      final progressed = lastMaxExtent == null ||
          maxExtent > lastMaxExtent ||
          minExtent < lastMinExtent!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreScrollWithRetry(
          retriesLeft: progressed ? retriesLeft : retriesLeft - 1,
          lastMinExtent: minExtent,
          lastMaxExtent: maxExtent,
        );
      });
    }
  }

  /// Scrolls to the current in-page search match.
  void _scrollToCurrentMatch(InPageSearchState searchState) {
    final currentMatch = searchState.currentMatch;
    if (currentMatch == null) return;
    _revealEntry(currentMatch.pageIndex, currentMatch.entryIndex);
  }

  /// Brings the row at `(pageIndex, entryIndex)` to [alignment] of the
  /// viewport.
  ///
  /// A built row is scrolled to. One that isn't is anchored at instead: a
  /// lazy list can't know where an unbuilt row starts without laying out
  /// every row before it, and the anchor needs none of them.
  void _revealEntry(int pageIndex, int entryIndex, {double alignment = 0.3}) {
    if (!mounted) return;
    final key = _entryKeyRegistry.keyFor(pageIndex, entryIndex);
    if (key.currentContext?.findRenderObject()?.attached ?? false) {
      Scrollable.ensureVisible(
        key.currentContext!,
        alignment: alignment,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    final slice = ref.read(activeDocumentSliceProvider);
    if (slice == null) return;
    final local = pageIndex - slice.absolutePageStart;
    if (local < 0 || local >= slice.pages.length) return;
    _anchorAt((pageIndex, entryIndex));
    // The anchor puts the row at the top; settle it at [alignment] once the
    // rows above it are there to scroll into.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = key.currentContext;
      if (!mounted || context == null) return;
      Scrollable.ensureVisible(context, alignment: alignment);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to active tab changes
    ref.listen<int>(activeTabIndexProvider, (previous, next) {
      if (previous != null && previous != next) {
        // Suppress the layout listener during tab switches. When tabs have
        // different layout settings, activeReaderLayoutProvider changes as a
        // side-effect. Without this guard, the layout listener would override
        // the scroll position restoration below.
        _suppressLayoutListener = true;

        // Save the previous tab's offset, by its index. Closing the active
        // tab passes through -1, so a closed tab is never saved. Closing a
        // tab before the active one moves the index before removing the tab
        // (closeTabProvider), so `previous` still names the active tab here.
        if (previous >= 0 && next >= 0) {
          _saveScrollPosition(previous);
        }

        // A debounced save still pending from the old tab would otherwise
        // land on the new one.
        _scrollSaveDebounce?.cancel();

        // Clear entry key registry — old tab's keys are stale
        _entryKeyRegistry.clear();

        // Layout is now per-tab and derived from activeReaderLayoutProvider
        // No need to override or reset - each tab remembers its own column mode

        // The pane is keyed by the tab's index, so a switch gets a fresh
        // scroll view that starts at the new tab's saved offset. The restore
        // after it renders finishes the job when that offset was past what the
        // first layout built. It also corrects the one case the key misses:
        // closing the active first tab leaves the index at 0, so the next tab
        // draws one frame at the closed tab's offset.
        if (next >= 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _suppressLayoutListener = false;
            _restoreScrollWithRetry();
          });
        } else {
          _suppressLayoutListener = false;
          // No active tab (all tabs closed) — the reader shows the empty
          // state, so the app bar must not stay tinted.
          ref.read(readerScrolledUnderProvider.notifier).state = false;
        }
      }
    });

    // Restore scroll position once the unit's pages are actually on screen.
    // Watches the slice rather than the document, because the document can
    // arrive before the page plan does and there is nothing to scroll within
    // until both are in.
    ref.listen<DocumentSlice?>(activeDocumentSliceProvider, (previous, next) {
      if (next != null && previous == null) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _restoreScrollWithRetry());
      }
    });

    // Listen to layout changes — sync reading position by logical entry, not
    // pixels. Pixel offsets are meaningless across layouts (stacked is ~2x
    // taller than side-by-side per entry). The entry at the viewport top
    // becomes the anchor, so the new layout opens on it and builds nothing
    // above it.
    ref.listen<ReaderLayout>(activeReaderLayoutProvider, (previous, next) {
      if (previous != null && previous != next && !_suppressLayoutListener) {
        // Capture top-visible entry from the OLD layout (still mounted)
        final topEntry =
            _entryKeyRegistry.findTopVisibleEntry(_scrollController);
        // Clear stale keys from old layout before rebuild
        _entryKeyRegistry.clear();

        // Match set is layout-scoped — refresh against the new layout.
        // Also covered by the suppression guard above: tab switches skip
        // this because each tab's matches already align with its own layout.
        ref
            .read(inPageSearchStatesProvider.notifier)
            .recomputeActiveTabMatches();

        _anchorAt(topEntry);
      }
    });

    // Listen to in-page search state changes to trigger scroll-to-match
    ref.listen<InPageSearchState>(activeInPageSearchStateProvider,
        (previous, next) {
      if (next.currentMatchIndex >= 0 &&
          next.currentMatchIndex != (previous?.currentMatchIndex ?? -1)) {
        _scrollToCurrentMatch(next);
      }
    });

    // The unit resolves before its text does, so both are watched: the unit
    // says which file and which rows, the document supplies them.
    final unitAsync = ref.watch(activeReaderUnitProvider);
    final contentAsync = ref.watch(currentBJTDocumentProvider);
    final slice = ref.watch(activeDocumentSliceProvider);
    final anchor = ref.watch(activeAnchorProvider);
    // Watch per-tab reader layout (each tab remembers its own setting)
    final readerLayout = ref.watch(activeReaderLayoutProvider);
    // Watch selected word to conditionally mount the dictionary sheet
    final selectedWord = ref.watch(selectedDictionaryWordProvider);

    // Watch in-page search state for the active tab
    final searchState = ref.watch(activeInPageSearchStateProvider);

    // Watch the sutta on either side of this unit, for step navigation.
    // Each is null at the corpus edge, and the matching button is then absent.
    final nodeKey = ref.watch(activeNodeKeyProvider);
    final previousNode = nodeKey == null
        ? null
        : ref.watch(neighbourLeafProvider((nodeKey, ReaderStep.previous)));
    final nextNode = nodeKey == null
        ? null
        : ref.watch(neighbourLeafProvider((nodeKey, ReaderStep.next)));

    // Visibility flags for the two action button modes.
    // Computed once here so IgnorePointer, AnimatedOpacity, and AnimatedSlide
    // all reference the same boolean — avoids duplication and drift.
    // "Scrolled down" counts everything above the viewport, anchor or not.
    final hasContent = slice != null && !slice.isEmpty;
    final showMode1 = hasContent && !searchState.isVisible && !_isScrolledDown;
    final showMode2 = hasContent && !searchState.isVisible && _isScrolledDown;

    return Stack(
      children: [
        // Main content area
        Column(
          children: [
            Expanded(
              child: _buildBody(
                context,
                unitAsync: unitAsync,
                contentAsync: contentAsync,
                slice: slice,
                anchor: anchor,
                readerLayout: readerLayout,
                searchState: searchState,
              ),
            ),
          ],
        ),
        // In-page search bar (floating at top).
        // Mobile: full-width edge-to-edge. Tablet/desktop: right-anchored with
        // a capped width (Chrome/Safari/VS Code pattern — close button lands
        // where the eye expects it). Breakpoint comes from ResponsiveUtils so
        // it stays in sync with the rest of the app's layout decisions.
        // The inner ValueKey on InPageSearchBar (below) gives a fresh widget
        // instance per tab so the controller text resets; the outer key on the
        // Positioned is a separate concern — see its note.
        if (searchState.isVisible)
          Positioned(
            // Stable key so the Stack matches this child by identity. Without
            // it, inserting this child shifts the keyless Positioned wrappers
            // below by one slot, and the FAB's (opacity-1) AnimatedOpacity
            // element gets reused to render the Mode 1 toolbar for a frame —
            // making the top toolbar flash in on every open.
            key: const ValueKey('in-page-search-bar'),
            top: 8,
            right: 16,
            left: ResponsiveUtils.isMobile(context) ? 16 : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: InPageSearchBar.maxWidthOnLargeScreens,
              ),
              child: InPageSearchBar(
                key: ValueKey(
                  'search-bar-${ref.watch(activeTabIndexProvider)}',
                ),
              ),
            ),
          ),
        // Mode 1: the action toolbar at top-right when at the unit's beginning.
        // IgnorePointer disables taps on the invisible widget.
        if (hasContent)
          Positioned(
            // Keyed so reconciliation pins this to the Mode 1 element no matter
            // what conditional siblings appear/disappear above it (see the
            // search-bar key note above).
            key: const ValueKey('reader-actions-top'),
            top: 12,
            // Bounded on both sides so the toolbar gets the width it may use.
            left: 16,
            right: 16,
            child: IgnorePointer(
              ignoring: !showMode1,
              child: AnimatedOpacity(
                opacity: showMode1 ? 1.0 : 0.0,
                // Matches Mode 2's 200ms so the two modes cross-fade
                // symmetrically with no brief "neither visible" gap.
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: Align(
                  alignment: Alignment.topRight,
                  child: ReaderActionToolbar(
                    visible: showMode1,
                    onSearchTap: () => ref
                        .read(inPageSearchStatesProvider.notifier)
                        .openSearch(),
                    previous: _stepTarget(previousNode),
                    next: _stepTarget(nextNode),
                  ),
                ),
              ),
            ),
          ),
        // Mode 2: FAB at bottom-right (scrolled down), opening the actions
        // menu.
        if (hasContent)
          Positioned(
            // Keyed so reconciliation pins this to the Mode 2 (FAB) element —
            // see the search-bar key note above.
            key: const ValueKey('reader-actions-fab'),
            bottom: 24,
            right: 16,
            child: IgnorePointer(
              ignoring: !showMode2,
              child: AnimatedOpacity(
                opacity: showMode2 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: AnimatedSlide(
                  offset: showMode2 ? Offset.zero : const Offset(0, 0.3),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: ReaderActionMenuFab(
                    visible: showMode2,
                    onSearchTap: () => ref
                        .read(inPageSearchStatesProvider.notifier)
                        .openSearch(),
                    onScrollTap: _scrollToBeginning,
                    previous: _stepTarget(previousNode),
                    next: _stepTarget(nextNode),
                  ),
                ),
              ),
            ),
          ),
        // Non-modal dictionary bottom sheet overlay
        // Only mounted when a word is selected (conditional mounting for performance)
        if (selectedWord != null)
          const DictionaryBottomSheet(key: ValueKey('dictionary-sheet')),
      ],
    );
  }

  /// The reader's content area, across the states its two inputs can be in.
  ///
  /// Errors are reported from whichever half failed, and loading covers both:
  /// a unit with no text yet looks the same to a reader as text with no unit.
  Widget _buildBody(
    BuildContext context, {
    required AsyncValue<ReaderUnit?> unitAsync,
    required AsyncValue<Object?> contentAsync,
    required DocumentSlice? slice,
    required (int, int)? anchor,
    required ReaderLayout readerLayout,
    required InPageSearchState searchState,
  }) {
    final failure = unitAsync.error ?? contentAsync.error;
    if (failure != null) {
      // No Retry / no widget-level logging:
      //   - BJTDataSource logs the raw error + stack trace at the catch site,
      //     so DevTools shows the real cause.
      //   - The text comes from this device's own copy of `bjt.db`, so a
      //     retry cannot fix what went wrong reading it.
      final variant = statusVariantForError(failure);
      final l10n = AppLocalizations.of(context);
      return StatusMessageView(
        variant: variant,
        title: variant == StatusVariant.offline
            ? l10n.statusOfflineTitle
            : l10n.errorLoadingContent,
        description: variant == StatusVariant.offline
            ? l10n.statusOfflineDescription
            : l10n.statusErrorDescription,
      );
    }

    // No tab, or a tab with no unit — the first-run hint.
    if (unitAsync.hasValue && unitAsync.value == null) {
      return StatusMessageView(
        variant: StatusVariant.info,
        leading: const AppEmblem(),
        title: AppLocalizations.of(context).statusSelectSuttaToRead,
      );
    }

    if (slice == null) {
      return const StatusMessageView(variant: StatusVariant.loading);
    }

    if (slice.isEmpty) {
      return StatusMessageView(
        variant: StatusVariant.empty,
        // The user didn't search — search_off is wrong here.
        // menu_book_outlined matches the reader's vocabulary
        // (also used for the "select a sutta" info hint).
        iconOverride: Icons.menu_book_outlined,
        title: AppLocalizations.of(context).statusNoContentToDisplay,
      );
    }

    return _clearOnTap(
      _buildContentLayout(context, slice, anchor, readerLayout, searchState),
    );
  }

  /// Calls [_clearAllHighlights] on any tap on the page, as a browser clears
  /// a link-to-text highlight.
  ///
  /// A raw [Listener] joins no gesture arena, so the selection and a word
  /// still get the click. On pointer-up, not down: on a word tap the clear
  /// and the new word land in the same frame, so the dictionary sheet swaps
  /// its word instead of closing and reopening.
  Widget _clearOnTap(Widget child) {
    return Listener(
      onPointerDown: (event) {
        if (event.buttons & kPrimaryButton == 0) return;
        _tapPointer = event.pointer;
        _tapDownPosition = event.position;
      },
      onPointerUp: (event) {
        final down = _tapDownPosition;
        if (event.pointer != _tapPointer || down == null) return;
        _tapPointer = null;
        _tapDownPosition = null;
        final slop = computeHitSlop(
            event.kind, MediaQuery.maybeGestureSettingsOf(context));
        if ((event.position - down).distance <= slop) _clearAllHighlights();
      },
      onPointerCancel: (event) {
        if (event.pointer == _tapPointer) _tapDownPosition = null;
      },
      child: child,
    );
  }

  /// Clears the dictionary and search highlights and closes the dictionary
  /// sheet. A text selection clears itself: it gets the same click.
  void _clearAllHighlights() {
    // Clear dictionary and FTS highlights (per-tab for FTS)
    ref.read(dictionaryHighlightProvider.notifier).state = null;
    ref.read(selectedDictionaryWordProvider.notifier).state = null;
    ref.read(ftsHighlightProvider.notifier).clearForActiveTab();
  }

  /// Handles word tap for dictionary lookup.
  /// If there's an active text selection, clears it instead of opening dictionary.
  void _handleWordTap(String word) {
    // If there's an active text selection, clear it and don't open dictionary
    if (ref.read(hasActiveSelectionProvider)) {
      FocusManager.instance.primaryFocus?.unfocus();
      // Clear the highlight that was set by TextEntryWidget before this callback
      ref.read(dictionaryHighlightProvider.notifier).state = null;
      return;
    }
    // Open dictionary lookup — pass word with conjuncts intact so the
    // dictionary bottom sheet displays proper bound letters in the text field.
    // The lookup itself strips ZWJ via computeEffectiveQuery/normalizeText.
    ref.read(selectedDictionaryWordProvider.notifier).state = word;
  }

  /// Delegates to the appropriate pane widget based on reader layout.
  ///
  /// Keyed by the tab's index, so a tab switch starts a fresh scroll view at
  /// that tab's saved offset rather than keeping the last tab's.
  Widget _buildContentLayout(
    BuildContext context,
    DocumentSlice slice,
    (int, int)? anchor,
    ReaderLayout readerLayout,
    InPageSearchState searchState,
  ) {
    return KeyedSubtree(
      key: ValueKey(ref.watch(activeTabIndexProvider)),
      child: _buildPane(slice, anchor, readerLayout, searchState),
    );
  }

  Widget _buildPane(
    DocumentSlice slice,
    (int, int)? anchor,
    ReaderLayout readerLayout,
    InPageSearchState searchState,
  ) {
    switch (readerLayout) {
      case ReaderLayout.paliOnly:
        return SingleColumnPane(
          scrollController: _scrollController,
          slice: slice,
          anchor: anchor,
          searchState: searchState,
          languageCode: 'pi',
          enableDictionaryLookup: true,
          entryKeyRegistry: _entryKeyRegistry,
          onWordTap: _handleWordTap,
          onSelectionChanged: onSelectionChanged,
          contextMenuBuilder: buildSelectionContextMenu,
        );
      case ReaderLayout.sinhalaOnly:
        return SingleColumnPane(
          scrollController: _scrollController,
          slice: slice,
          anchor: anchor,
          searchState: searchState,
          languageCode: 'si',
          enableDictionaryLookup: false,
          entryKeyRegistry: _entryKeyRegistry,
          onWordTap: _handleWordTap,
          onSelectionChanged: onSelectionChanged,
          contextMenuBuilder: buildSelectionContextMenu,
        );
      case ReaderLayout.sideBySide:
        return DualColumnPane(
          scrollController: _scrollController,
          slice: slice,
          anchor: anchor,
          searchState: searchState,
          entryKeyRegistry: _entryKeyRegistry,
          onWordTap: _handleWordTap,
          onSelectionChanged: onSelectionChanged,
          contextMenuBuilder: buildSelectionContextMenu,
        );
      case ReaderLayout.stacked:
        return StackedPane(
          scrollController: _scrollController,
          slice: slice,
          anchor: anchor,
          searchState: searchState,
          entryKeyRegistry: _entryKeyRegistry,
          onWordTap: _handleWordTap,
          onSelectionChanged: onSelectionChanged,
          contextMenuBuilder: buildSelectionContextMenu,
        );
    }
  }
}

/// A [ScrollController] whose new scroll positions start at [_initialOffset]
/// rather than at a fixed offset.
class _TabScrollController extends ScrollController {
  _TabScrollController(this._initialOffset);

  final double Function() _initialOffset;

  @override
  double get initialScrollOffset => _initialOffset();
}
