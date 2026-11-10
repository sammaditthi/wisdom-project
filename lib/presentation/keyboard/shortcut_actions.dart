import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_notifier.dart';
import '../providers/app_section_provider.dart';
import '../providers/in_page_search_focus_provider.dart';
import '../providers/in_page_search_provider.dart';
import '../providers/last_selected_text_provider.dart';
import '../providers/main_search_focus_provider.dart';
import '../providers/navigator_visibility_provider.dart';
import '../providers/reader_keyboard_bridge_provider.dart';
import '../providers/overlay_stack_provider.dart';
import '../providers/search_mode_provider.dart';
import '../providers/search_provider.dart';
import '../providers/search_results_focus_provider.dart';
import '../providers/tab_lifecycle_provider.dart';
import '../providers/tab_provider.dart';
import '../widgets/settings/settings_dialog.dart';
import 'app_navigator_key.dart';
import 'search_result_stops.dart';
import 'shortcut_guards.dart';
import 'shortcut_intents.dart';

/// Closes the topmost overlay on the LIFO stack.
///
/// `isEnabled` returns false when the stack is empty so the ESC keystroke
/// bubbles past us (lets nested widgets — e.g. a future dialog with its own
/// ESC handler — still take precedence).
class DismissTopOverlayAction extends ContextAction<DismissTopOverlayIntent> {
  final WidgetRef ref;
  DismissTopOverlayAction(this.ref);

  @override
  Object? invoke(DismissTopOverlayIntent intent, [BuildContext? context]) {
    ref.read(overlayStackProvider.notifier).dismissTop();
    return null;
  }

  @override
  bool isEnabled(DismissTopOverlayIntent intent, [BuildContext? context]) {
    return ref.read(overlayStackProvider).isNotEmpty;
  }
}

/// Opens the in-page search bar for the currently active tab — or, when it's
/// already visible, snaps focus back to its input (Chrome / VS Code muscle
/// memory) instead of bluntly re-running the idempotent open.
///
/// Suppressed when the main FTS search bar holds focus, so Ctrl/Cmd+F
/// doesn't yank a typing user out of the global search — and when a
/// non-Reader section is showing, so the shortcut can't open the search
/// bar inside the hidden Reader (openSearch() is provider state, which,
/// unlike focus, isn't blocked by IndexedStack).
class OpenInPageSearchAction extends ContextAction<OpenInPageSearchIntent> {
  final WidgetRef ref;
  OpenInPageSearchAction(this.ref);

  @override
  Object? invoke(OpenInPageSearchIntent intent, [BuildContext? context]) {
    final isVisible = ref.read(activeInPageSearchStateProvider).isVisible;
    if (isVisible) {
      // Already open — jump focus back to the existing input. Mirrors
      // OpenMainSearchAction. The node is owned by the provider (the bar just
      // borrows it), so it's always available while the bar is mounted.
      ref.read(inPageSearchFocusNodeProvider).requestFocus();
    } else {
      ref.read(inPageSearchStatesProvider.notifier).openSearch();
    }
    return null;
  }

  @override
  bool isEnabled(OpenInPageSearchIntent intent, [BuildContext? context]) {
    if (ref.read(selectedAppSectionProvider) != AppSection.reader) {
      // In-page search lives in the Reader — don't mutate it invisibly.
      return false;
    }
    final searchBarNode = ref.read(mainSearchFocusNodeProvider);
    if (searchBarNode != null && searchBarNode.hasFocus) {
      // Main FTS bar is focused — let the user keep typing.
      return false;
    }
    return true;
  }
}

/// Moves keyboard focus into the main FTS search bar.
///
/// Works from inside any other widget (including another text field), but
/// only while the Reader shows: on phones it would otherwise open search mode
/// in the hidden Reader.
class OpenMainSearchAction extends ContextAction<OpenMainSearchIntent> {
  final WidgetRef ref;
  OpenMainSearchAction(this.ref);

  @override
  bool isEnabled(OpenMainSearchIntent intent, [BuildContext? context]) =>
      ref.read(selectedAppSectionProvider) == AppSection.reader;

  @override
  Object? invoke(OpenMainSearchIntent intent, [BuildContext? context]) {
    final node = ref.read(mainSearchFocusNodeProvider);
    if (node != null) {
      node.requestFocus();
    } else {
      // On phones the field shows only in search mode; it takes focus as it
      // opens.
      ref.read(searchModeProvider.notifier).state = true;
    }
    return null;
  }
}

/// Closes the currently active reader tab.
///
/// Delegates to the existing [closeTabProvider] so the X-button and the
/// shortcut share one code path (per-tab state cleanup, navigator sync,
/// and the previous-tab-becomes-active behaviour all come for free).
///
/// `isEnabled` returns false when no tab is open so Cmd+W bubbles past us
/// rather than calling close on index `-1`.
class CloseActiveTabAction extends ContextAction<CloseActiveTabIntent> {
  final WidgetRef ref;
  CloseActiveTabAction(this.ref);

  @override
  Object? invoke(CloseActiveTabIntent intent, [BuildContext? context]) {
    final activeIndex = ref.read(activeTabIndexProvider);
    if (activeIndex < 0) return null;
    ref.read(closeTabProvider)(activeIndex);
    return null;
  }

  @override
  bool isEnabled(CloseActiveTabIntent intent, [BuildContext? context]) {
    // Not while typing: Ctrl+Alt is AltGr, which types characters.
    return ref.read(activeTabIndexProvider) >= 0 && !isTypingInTextBox();
  }
}

/// Copies the current selection to the clipboard.
///
/// Resolution order:
///   1. Ask the currently focused widget to handle `CopySelectionTextIntent`
///      via `Actions.maybeInvoke`. `SelectableRegion` and `EditableText`
///      both register a handler — so a focused TextField or in-focus
///      SelectionArea keeps its native behaviour and wins.
///   2. If nothing handled it (typical on web when the focus tree drops
///      out of the SelectableRegion), fall back to `lastSelectedTextProvider`
///      — the text the user most recently highlighted in a reader pane.
///
/// This is the action that actually fixes Ctrl+C on web.
class SmartCopyAction extends ContextAction<SmartCopyIntent> {
  final WidgetRef ref;
  SmartCopyAction(this.ref);

  @override
  Object? invoke(SmartCopyIntent intent, [BuildContext? context]) {
    // 1. Native path: let the focused widget's own CopySelectionTextIntent
    //    action handle it if it can.
    final focusedContext = FocusManager.instance.primaryFocus?.context;
    if (focusedContext != null) {
      final handled = Actions.maybeInvoke(
        focusedContext,
        CopySelectionTextIntent.copy,
      );
      if (handled != null) {
        return null;
      }
    }

    // 2. Fallback path: copy the last text the user highlighted in a
    //    reader SelectionArea, even if focus has since moved away.
    final text = ref.read(lastSelectedTextProvider);
    if (text != null && text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
    }
    return null;
  }
}

/// Opens the Settings dialog on the intent's tab.
///
/// Disabled while Settings is already open. Opens through [appNavigatorKey]'s
/// overlay, whose context sits below the `Navigator`; `AppShortcuts` doesn't.
class OpenSettingsAction extends ContextAction<OpenSettingsIntent> {
  final WidgetRef ref;
  OpenSettingsAction(this.ref);

  @override
  bool isEnabled(OpenSettingsIntent intent, [BuildContext? context]) =>
      appNavigatorKey.currentState?.overlay != null &&
      !ref
          .read(overlayStackProvider)
          .any((o) => o.id == SettingsDialog.overlayId);

  @override
  Object? invoke(OpenSettingsIntent intent, [BuildContext? context]) {
    final overlayContext = appNavigatorKey.currentState!.overlay!.context;
    unawaited(SettingsDialog.show(overlayContext, initial: intent.tab));
    return null;
  }
}

/// Steps the text size like the reader menu's slider: 0.1 a press, rounded to
/// the slider's 0.05 grid so steps never drift, inside the notifier's limits.
class TextSizeAction extends ContextAction<TextSizeIntent> {
  final WidgetRef ref;
  TextSizeAction(this.ref);

  static const double _step = 0.1;

  @override
  Object? invoke(TextSizeIntent intent, [BuildContext? context]) {
    final notifier = ref.read(fontScaleProvider.notifier);
    final scale = ref.read(fontScaleProvider);
    double snap(double value) => (value * 20).round() / 20;
    switch (intent.change) {
      case TextSizeChange.bigger:
        unawaited(notifier.setScale(snap(scale + _step)));
      case TextSizeChange.smaller:
        unawaited(notifier.setScale(snap(scale - _step)));
      case TextSizeChange.normal:
        unawaited(notifier.reset());
    }
    return null;
  }
}

/// Shows or hides the navigator. A reader key: needs the Reader, with nothing
/// open over it.
class ToggleNavigatorAction extends ContextAction<ToggleNavigatorIntent> {
  final WidgetRef ref;
  ToggleNavigatorAction(this.ref);

  @override
  bool isEnabled(ToggleNavigatorIntent intent, [BuildContext? context]) =>
      readerKeysAllowed(ref);

  @override
  Object? invoke(ToggleNavigatorIntent intent, [BuildContext? context]) {
    final visible = ref.read(navigatorVisibleProvider.notifier);
    visible.state = !visible.state;
    return null;
  }
}

/// Moves to the next or previous reader tab, wrapping at the ends as Chrome
/// does. A reader key, and not while typing (Ctrl+Alt is AltGr).
class SwitchTabAction extends ContextAction<SwitchTabIntent> {
  final WidgetRef ref;
  SwitchTabAction(this.ref);

  @override
  bool isEnabled(SwitchTabIntent intent, [BuildContext? context]) =>
      readerKeysAllowed(ref) &&
      !isTypingInTextBox() &&
      ref.read(tabsProvider).length >= 2;

  @override
  Object? invoke(SwitchTabIntent intent, [BuildContext? context]) {
    final count = ref.read(tabsProvider).length;
    final active = ref.read(activeTabIndexProvider);
    ref.read(switchTabProvider)((active + intent.offset) % count);
    return null;
  }
}

/// Sets the active tab's layout through the same path as the Layout menu, so
/// the choice is remembered for new tabs too.
class SetLayoutAction extends ContextAction<SetLayoutIntent> {
  final WidgetRef ref;
  SetLayoutAction(this.ref);

  @override
  bool isEnabled(SetLayoutIntent intent, [BuildContext? context]) =>
      readerKeysAllowed(ref) &&
      !isTypingInTextBox() &&
      ref.read(activeTabIndexProvider) >= 0;

  @override
  Object? invoke(SetLayoutIntent intent, [BuildContext? context]) {
    ref.read(updateActiveTabLayoutProvider)(intent.layout);
    return null;
  }
}

/// Steps to the neighbouring sutta through the mounted reader, which runs the
/// toolbar buttons' own code. Nothing at the corpus edge, or while typing.
class StepSuttaAction extends ContextAction<StepSuttaIntent> {
  final WidgetRef ref;
  StepSuttaAction(this.ref);

  @override
  bool isEnabled(StepSuttaIntent intent, [BuildContext? context]) =>
      readerKeysAllowed(ref) &&
      !isTypingInTextBox() &&
      (ref.read(readerKeyboardBridgeProvider).handle?.canStep(intent.step) ??
          false);

  @override
  Object? invoke(StepSuttaIntent intent, [BuildContext? context]) {
    ref.read(readerKeyboardBridgeProvider).handle?.step(intent.step);
    return null;
  }
}

/// Scrolls the reader — only when focus is in the reader's text or on
/// nothing. On a navigator row, a tab or a button the arrows keep their usual
/// job of moving focus, and in a text box they move the caret.
class ScrollReaderAction extends ContextAction<ScrollReaderIntent> {
  final WidgetRef ref;

  /// `AppShortcuts`' fallback node: focus there is focus on nothing.
  final FocusNode idleFocus;

  ScrollReaderAction(this.ref, this.idleFocus);

  @override
  bool isEnabled(ScrollReaderIntent intent, [BuildContext? context]) {
    final handle = ref.read(readerKeyboardBridgeProvider).handle;
    if (handle == null || !readerKeysAllowed(ref) || isTypingInTextBox()) {
      return false;
    }
    final primary = FocusManager.instance.primaryFocus;
    final idle =
        primary == null || primary is FocusScopeNode || primary == idleFocus;
    return idle || handle.hasFocus;
  }

  @override
  Object? invoke(ScrollReaderIntent intent, [BuildContext? context]) {
    ref
        .read(readerKeyboardBridgeProvider)
        .handle
        ?.scroll(intent.direction, intent.type);
    return null;
  }
}

/// Moves from the main search box to the first result, while the results
/// panel shows and has something to focus.
class MoveIntoSearchResultsAction
    extends ContextAction<MoveIntoSearchResultsIntent> {
  final WidgetRef ref;
  MoveIntoSearchResultsAction(this.ref);

  @override
  bool isEnabled(MoveIntoSearchResultsIntent intent, [BuildContext? context]) =>
      (ref.read(mainSearchFocusNodeProvider)?.hasFocus ?? false) &&
      ref.read(searchStateProvider).isResultsPanelVisible &&
      searchResultStops(ref.read(searchResultsFocusNodeProvider)).isNotEmpty;

  @override
  Object? invoke(MoveIntoSearchResultsIntent intent, [BuildContext? context]) {
    final stops = searchResultStops(ref.read(searchResultsFocusNodeProvider));
    _focusStop(stops.first, ScrollPositionAlignmentPolicy.keepVisibleAtEnd);
    return null;
  }
}

/// Moves to the next result. On the last one it stays — still handled, so
/// the key doesn't fall through and scroll the reader.
class NextSearchResultAction extends ContextAction<NextSearchResultIntent> {
  final WidgetRef ref;
  NextSearchResultAction(this.ref);

  @override
  bool isEnabled(NextSearchResultIntent intent, [BuildContext? context]) =>
      ref.read(searchResultsFocusNodeProvider).hasFocus;

  @override
  Object? invoke(NextSearchResultIntent intent, [BuildContext? context]) {
    final stops = searchResultStops(ref.read(searchResultsFocusNodeProvider));
    final at = stops.indexOf(FocusManager.instance.primaryFocus!);
    if (at + 1 < stops.length) {
      _focusStop(stops[at + 1], ScrollPositionAlignmentPolicy.keepVisibleAtEnd);
    }
    return null;
  }
}

/// Moves to the previous result, or from the first back to the search box.
class PreviousSearchResultAction
    extends ContextAction<PreviousSearchResultIntent> {
  final WidgetRef ref;
  PreviousSearchResultAction(this.ref);

  @override
  bool isEnabled(PreviousSearchResultIntent intent, [BuildContext? context]) =>
      ref.read(searchResultsFocusNodeProvider).hasFocus;

  @override
  Object? invoke(PreviousSearchResultIntent intent, [BuildContext? context]) {
    final stops = searchResultStops(ref.read(searchResultsFocusNodeProvider));
    final at = stops.indexOf(FocusManager.instance.primaryFocus!);
    if (at > 0) {
      _focusStop(
        stops[at - 1],
        ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    } else {
      ref.read(mainSearchFocusNodeProvider)?.requestFocus();
    }
    return null;
  }
}

/// Focuses a search result and scrolls only as far as needed to show it, as
/// Flutter's own Tab traversal does — a result already in view stays put.
void _focusStop(FocusNode stop, ScrollPositionAlignmentPolicy policy) =>
    FocusTraversalPolicy.defaultTraversalRequestFocusCallback(
      stop,
      alignmentPolicy: policy,
    );
