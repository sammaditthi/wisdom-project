import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'keyboard_bindings.dart';
import 'shortcut_actions.dart';
import 'shortcut_intents.dart';

/// Top-level keyboard shortcut wrapper.
///
/// Mount this once near the root of the widget tree (inside
/// `MaterialApp.builder`). It:
///   1. Installs a [Focus] node so key events have somewhere to land before
///      any user widget has been clicked. Without this, on a fresh route
///      with no focused widget, Shortcuts would never receive events.
///   2. Installs a [Shortcuts] widget mapping default key combos → Intents.
///   3. Installs an [Actions] widget binding those Intents → Action
///      instances that read Riverpod providers via [WidgetRef].
///
/// ## Why focus-tree ancestry matters
///
/// Key events bubble UP the focus tree from the primary-focused widget. Any
/// [Shortcuts] / [Actions] widget that's an ancestor of the focused node
/// can handle them, with **deeper widgets winning first**. Mounting this
/// at the app root means:
///   - Deep widgets (TextField's internal Copy handler, SelectableRegion's
///     own Shortcuts) keep working — they're closer to focus, they win.
///   - When NOTHING deeper handles a key, our global bindings catch it.
///
/// That's why ESC works from anywhere (search bar, panel, reader, empty
/// space), Ctrl+F works in-place, and Ctrl+C has a fallback for the web
/// focus-tree quirk.
class AppShortcuts extends ConsumerStatefulWidget {
  final Widget child;

  const AppShortcuts({super.key, required this.child});

  @override
  ConsumerState<AppShortcuts> createState() => _AppShortcutsState();
}

class _AppShortcutsState extends ConsumerState<AppShortcuts> {
  /// The fallback node below. Focus on it means focus is on nothing, which
  /// lets the arrow keys scroll the reader.
  final FocusNode _idleFocus = FocusNode(debugLabel: 'AppShortcuts idle');

  /// Built once: activators have no `==`, so a new map each build would make
  /// `Shortcuts` index every key again.
  final Map<ShortcutActivator, Intent> _shortcuts =
      shortcutMap(defaultTargetPlatform);

  @override
  void dispose() {
    _idleFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: _shortcuts,
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissTopOverlayIntent: DismissTopOverlayAction(ref),
          OpenInPageSearchIntent: OpenInPageSearchAction(ref),
          OpenMainSearchIntent: OpenMainSearchAction(ref),
          CloseActiveTabIntent: CloseActiveTabAction(ref),
          SmartCopyIntent: SmartCopyAction(ref),
          OpenSettingsIntent: OpenSettingsAction(ref),
          TextSizeIntent: TextSizeAction(ref),
          SwitchTabIntent: SwitchTabAction(ref),
          SetLayoutIntent: SetLayoutAction(ref),
          ToggleNavigatorIntent: ToggleNavigatorAction(ref),
          StepSuttaIntent: StepSuttaAction(ref),
          ScrollReaderIntent: ScrollReaderAction(ref, _idleFocus),
          MoveIntoSearchResultsIntent:
              MoveIntoSearchResultsAction(ref, _idleFocus),
          BackToSearchBoxIntent: BackToSearchBoxAction(ref),
          NextSearchResultIntent: NextSearchResultAction(ref),
          PreviousSearchResultIntent: PreviousSearchResultAction(ref),
          // A key used by several entries maps to PrioritizedIntents.
          PrioritizedIntents: PrioritizedAction(),
        },
        // Autofocused fallback node. Holds focus only when no other widget
        // is focused (e.g. on a fresh route before any tap); as soon as the
        // user clicks anything, focus moves there naturally. Without this,
        // Shortcuts above would have no focus path to receive events from
        // on initial render.
        child: Focus(
          focusNode: _idleFocus,
          autofocus: true,
          // skipTraversal keeps this invisible to Tab-key focus traversal —
          // pressing Tab still walks through real interactive widgets.
          skipTraversal: true,
          child: widget.child,
        ),
      ),
    );
  }
}
