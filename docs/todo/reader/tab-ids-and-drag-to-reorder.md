# Stable tab ids, then drag to reorder tabs

Not started. Carried over 2026-11-25 from the Riverpod 3 upgrade ([`riverpod-3-upgrade.md`](../../done/upgrades/riverpod-3-upgrade.md), where it was step 2, with steps 3 and 5).

**Goal:** every tab gets an id that never changes. Then a reader can drag a tab to a new place, and it keeps its reading position, its find bar and its search highlights.

## Why ids come first

Per-tab state is stored by the tab's *position*, not by the tab:

| By position today | Where |
| --- | --- |
| Find bar state, and its debounce timers | `inPageSearchStatesProvider` (`Map<int, …>`) |
| Search highlights | `ftsHighlightProvider` (`Map<int, …>`) |
| Which tab is active, and the saved copy | `activeTabIndexProvider`, `activeTabIndexPersistenceProvider` |
| The reader's scroll view | `KeyedSubtree(key: ValueKey(activeTabIndex))` in `multi_pane_reader_widget.dart` |
| The tab strip's widgets | `_tabKeys` by index in `tab_bar_widget.dart` |

Closing a tab already has to shift all of this by hand (`closeTabProvider`, two `onTabClosed`s, the `-1` flip). It keeps breaking. The Riverpod 3 review found one more: closing the active tab shifted the search map before the active index moved, and the next tab jumped to its find match (`in_page_search_test` 6b).

A drag is worse than a close. Nothing is removed, but every tab between the old and new place changes position:

- Both maps and the timers need a third hand-written shuffle.
- The active index must follow the dragged tab. The reader saves the outgoing scroll offset *by index* on a switch, so if the list moves first, that offset lands on the wrong tab.
- The reader's layout listener treats "same length, new layout at the active index" as a layout switch. After a drag, that slot holds a different tab, so it would re-anchor a tab that never changed layout. The 6b guard (a length change counts as a switch) doesn't fire either, because a drag keeps the length.
- The reader's scroll view is keyed by index. Moving the active tab throws the view away and rebuilds it from the last saved offset. You see a jump, and you lose any scroll the save debounce hasn't written yet.
- Flutter's reorderable widgets (`ReorderableListView`, `ReorderableDragStartListener`) need a key per item that moves with it. An index key doesn't.

With ids, a drag is one list move. Nothing else is keyed by position, so nothing else changes. The reader's scroll view, keyed by tab id, isn't even rebuilt. **So ids are what make drag-to-reorder safe.** Without them, every bullet above has to be fixed by hand.

## Part 1 — tabs in one notifier, keyed by id (L)

- `ReaderTab` gets an `id`. It can live for one session only: give it out on load and on open, and never save it. The saved active tab stays an index into the saved list, read once at load. Any new `ReaderTab` field needs a `@Default` (see the warning on the class).
- One `Notifier` owns the tab list and the active tab id. `activeTabIndexProvider` becomes derived, or goes away.
- The find state, its timers and the highlights are keyed by tab id. `onTabClosed` just removes one key, and the `-1` flip goes.
- The reader keys its scroll view by tab id. Its layout listener compares tab ids instead of guessing from list length, and the 6b guard goes.
- Cost: tests name `activeTabIndexProvider` about 70 times, about 40 of them setting it. That churn is the main cost.

## Part 2 — settings save themselves (M, with part 1)

`navigatorVisibleProvider`, `navigationRailHiddenProvider` and `activeTabIndexProvider` each have a separate `Provider<void>` that saves changes, and `main.dart` must `read` all three at startup to keep them alive. A `Notifier` can save its own changes with `listenSelf` (a `StateProvider`'s `Ref` has no `listenSelf`). Part 1 moves the active tab's saving into the tab notifier. The other two become small `Notifier`s:

```dart
class NavigatorVisibleNotifier extends Notifier<bool> {
  @override
  bool build() {
    final store = ref.read(keyValueStoreProvider);
    // Save every change. No extra provider, nothing to start in main.dart.
    listenSelf((_, visible) =>
        store.setInt(StorageKeys.navigatorVisible, visible ? 1 : 0));
    // Nothing saved yet (first launch) means visible.
    return (store.getInt(StorageKeys.navigatorVisible) ?? 1) != 0;
  }

  void toggle() => state = !state;
}
```

While here: move the two generic setting notifiers (`BoolSettingNotifier` in `pali_letter_options_provider.dart`, `SavedChoiceNotifier<T extends Enum>` in `vinaya_times_provider.dart`) into one shared file as `Notifier`s. Then replace `ContentLanguageNotifier` and `AppLanguageNotifier`, which repeat `SavedChoiceNotifier` by hand (app language passes in its device-locale fallback). `LastReaderLayoutNotifier` stays: for it, "nothing saved" (`null`) is a real state.

## Part 3 — tab actions become notifier methods (M, with part 1)

`closeTabProvider`, `switchTabProvider`, `openTabFromNodeKeyProvider` and the other tab `Provider<… Function(…)>`s become methods on the tab notifier. The non-tab action providers stay as they are: each one captures its `Ref`, which is only a risk if its provider rebuilds, and none does today.

## Part 4 — drag to reorder (after parts 1–3)

- `moveTab(from, to)` on the tab notifier: one list move, active tab id unchanged.
- The tab strip becomes reorderable, keyed by tab id. Decide when this starts: mouse drag on desktop and web, long-press on touch, and how the strip's scrolling and close buttons behave mid-drag.
- Saved order: the tab list is already saved in order, so a moved tab comes back where it was put.

## Rules

- Its own PR, cut from `main` after the Riverpod 3 branch merges.
- It edits existing tests, so ask the user before starting. Write no new tests; a separate agent does that.
- The Riverpod rules in `CLAUDE.md` apply. New notifiers are `Notifier`, and new tests use `ProviderContainer.test()` / `tester.container()`.
