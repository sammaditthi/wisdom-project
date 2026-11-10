import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_section_provider.dart';
import '../providers/overlay_stack_provider.dart';
import '../widgets/app/overlay_stack_sync.dart';
import 'app_navigator_key.dart';

/// True while a text box has focus. Keys that would type into it, or that it
/// uses for editing, then go to the box (spec rule 4).
bool isTypingInTextBox() {
  final context = FocusManager.instance.primaryFocus?.context;
  return context != null &&
      context.findAncestorStateOfType<EditableTextState>() != null;
}

/// True when reader keys may act: the Reader shows, no route sits over it
/// (a dialog, or a popup menu, which is not on the overlay stack), and
/// nothing is open over it but the find bar or the dictionary sheet (spec
/// rule 5).
bool readerKeysAllowed(WidgetRef ref) =>
    ref.read(selectedAppSectionProvider) == AppSection.reader &&
    !(appNavigatorKey.currentState?.canPop() ?? false) &&
    ref
        .read(overlayStackProvider)
        .every((o) => _alongsideReaderKeys.contains(o.id));

/// Overlays that leave the reader keys working.
const _alongsideReaderKeys = {
  OverlayStackSync.inPageSearchOverlayId,
  OverlayStackSync.dictionaryOverlayId,
};
