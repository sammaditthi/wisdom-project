import 'package:flutter/widgets.dart';

import '../models/reader_layout.dart';
import '../providers/reader_unit_provider.dart' show ReaderStep;
import '../widgets/settings/settings_tab.dart';

/// App-wide keyboard intents.
///
/// An [Intent] in Flutter is just a data class that names "what the user wants
/// to happen". It carries no behaviour — the behaviour lives in the matching
/// [Action] (see `shortcut_actions.dart`). Keys are mapped to intents in
/// `keyboard_bindings.dart`.
///
/// Keeping intents as pure data classes is what lets us swap the keybindings
/// (defaults vs user overrides) without touching any other file.

/// Dismiss the most-recently-opened overlay (LIFO).
///
/// Wired to ESC. Pops the top entry of `overlayStackProvider` so the user's
/// "undo the last thing I opened" mental model holds, regardless of which
/// overlay (FTS panel / in-page search / dictionary sheet) it is.
class DismissTopOverlayIntent extends Intent {
  const DismissTopOverlayIntent();
}

/// Open the reader's in-page search bar for the active tab.
///
/// Wired to Ctrl/Cmd+F. Suppressed when the main FTS search bar already has
/// focus, so the user can keep typing into it.
class OpenInPageSearchIntent extends Intent {
  const OpenInPageSearchIntent();
}

/// Move keyboard focus into the main FTS search bar in the app bar.
///
/// Wired to Ctrl/Cmd+Shift+F. Always fires, even from inside another text
/// field — that's the standard "jump to global search" behaviour.
class OpenMainSearchIntent extends Intent {
  const OpenMainSearchIntent();
}

/// Close the currently active reader tab.
///
/// Wired to Ctrl/Cmd+Alt/Option+W. Mirrors the X button on each tab —
/// the focus moves to the previous tab automatically (handled by
/// [closeTabProvider]). No-op when there are no tabs open.
///
/// We can't use plain Cmd/Ctrl+W because browsers reserve that combo at
/// the OS layer (close-tab) and don't dispatch a keydown event to the
/// page — so neither Flutter nor any JS can override it. Adding Alt/Option
/// produces a combo that genuinely reaches the page on every platform.
class CloseActiveTabIntent extends Intent {
  const CloseActiveTabIntent();
}

/// Copy the current selection to the clipboard.
///
/// Wired to Ctrl/Cmd+C. The corresponding action first tries the focused
/// widget's native copy handler (so TextField + SelectableRegion keep their
/// default behaviour); if no native handler responds, it falls back to
/// copying the last text the user highlighted in any reader SelectionArea.
///
/// The fallback is the path that rescues Ctrl+C on web, where the focus tree
/// sometimes leaves the SelectableRegion unfocused even though the user has
/// a visible selection.
class SmartCopyIntent extends Intent {
  const SmartCopyIntent();
}

/// Move to the next (+1) or previous (-1) reader tab, wrapping at the ends.
class SwitchTabIntent extends Intent {
  const SwitchTabIntent(this.offset);

  final int offset;
}

/// Set the active tab's reading layout (⌥⌘1–4).
class SetLayoutIntent extends Intent {
  const SetLayoutIntent(this.layout);

  final ReaderLayout layout;
}

/// Where the search box's keys land in the results panel.
enum SearchPanelStop {
  /// ↓: the first result.
  firstResult,

  /// Tab: the first Tab stop — the panel's first control, or the first
  /// recent search — so Tab walks what shows in its own order.
  firstControl,
}

/// From the main search box into the results or recent searches (↓ or Tab).
class MoveIntoSearchResultsIntent extends Intent {
  const MoveIntoSearchResultsIntent(this.stop);

  final SearchPanelStop stop;
}

/// From the first Tab stop under the search box back to the box (Shift+Tab).
class BackToSearchBoxIntent extends Intent {
  const BackToSearchBoxIntent();
}

/// To the next search result (↓ in the results).
class NextSearchResultIntent extends Intent {
  const NextSearchResultIntent();
}

/// To the previous search result, or from the first back to the search box
/// (↑ in the results).
class PreviousSearchResultIntent extends Intent {
  const PreviousSearchResultIntent();
}

/// Go to the previous or next text (⌥⌘< >), as the toolbar's ⏮ ⏭ do.
class StepSuttaIntent extends Intent {
  const StepSuttaIntent(this.step);

  final ReaderStep step;
}

/// Scroll the reader a line (↑ ↓) or a page (PgUp PgDn).
class ScrollReaderIntent extends Intent {
  const ScrollReaderIntent(this.direction, this.type);

  final AxisDirection direction;
  final ScrollIncrementType type;
}

/// How a text-size key changes the reader text.
enum TextSizeChange { bigger, smaller, normal }

/// Make the text bigger, smaller or back to normal (⌘+ ⌘− ⌘0).
class TextSizeIntent extends Intent {
  const TextSizeIntent(this.change);

  final TextSizeChange change;
}

/// Show or hide the navigator (⌘B), as the app-bar button does.
class ToggleNavigatorIntent extends Intent {
  const ToggleNavigatorIntent();
}

/// Open the Settings dialog on [tab] (⌘, for General, ⌘/ for the shortcut
/// list).
class OpenSettingsIntent extends Intent {
  const OpenSettingsIntent(this.tab);

  final SettingsTab tab;
}
