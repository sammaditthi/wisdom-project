import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_section_provider.dart';
import '../providers/overlay_stack_provider.dart';
import '../widgets/app/overlay_stack_sync.dart';

/// True while a text box has focus. Keys that would type into it, or that it
/// uses for editing, then go to the box (spec rule 4).
bool isTypingInTextBox() {
  final context = FocusManager.instance.primaryFocus?.context;
  return context != null &&
      context.findAncestorStateOfType<EditableTextState>() != null;
}

/// True when reader keys may act: the Reader shows and nothing is open over
/// it except the in-page find bar (spec rule 5).
bool readerKeysAllowed(WidgetRef ref) =>
    ref.read(selectedAppSectionProvider) == AppSection.reader &&
    ref
        .read(overlayStackProvider)
        .every((o) => o.id == OverlayStackSync.inPageSearchOverlayId);
