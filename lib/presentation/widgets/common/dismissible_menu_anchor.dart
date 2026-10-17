import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/overlay_stack_provider.dart';

/// Space between a button and its menu.
const double _menuGap = 4;

extension MenuControllerToggle on MenuController {
  void toggle() => isOpen ? close() : open();
}

/// A [MenuAnchor] on the ESC overlay stack while open, so ESC closes the menu
/// before anything under it. Its look comes from `ThemeData.menuTheme`.
///
/// [visible] false closes an open menu, for a button that fades out.
/// [endAlignedWidth] gives the menu that fixed width with its right edge on
/// the button's; otherwise it starts at the button's left edge. Either way it
/// opens below the button, or above where there is no room below.
class DismissibleMenuAnchor extends ConsumerStatefulWidget {
  final String overlayId;
  final List<Widget> menuChildren;
  final Widget Function(
    BuildContext context,
    MenuController controller,
    FocusNode focusNode,
  ) builder;
  final bool visible;
  final double? endAlignedWidth;

  const DismissibleMenuAnchor({
    super.key,
    required this.overlayId,
    required this.menuChildren,
    required this.builder,
    this.visible = true,
    this.endAlignedWidth,
  });

  @override
  ConsumerState<DismissibleMenuAnchor> createState() =>
      _DismissibleMenuAnchorState();
}

class _DismissibleMenuAnchorState extends ConsumerState<DismissibleMenuAnchor> {
  final _controller = MenuController();
  // Lets the arrow keys move from the button into the menu.
  final _buttonFocusNode = FocusNode(debugLabel: 'DismissibleMenuAnchor');

  // Captured in initState: dispose() can't use `ref`.
  late final OverlayStackNotifier _overlayStack;

  @override
  void initState() {
    super.initState();
    _overlayStack = ref.read(overlayStackProvider.notifier);
  }

  @override
  void didUpdateWidget(DismissibleMenuAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Closing updates the overlay stack, which can't change mid-build.
    if (oldWidget.visible && !widget.visible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.close();
      });
    }
  }

  @override
  void dispose() {
    // A menu closed because its button went away doesn't call onClose, and
    // Riverpod forbids changing a provider while the tree is torn down.
    final stack = _overlayStack;
    final id = widget.overlayId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (stack.mounted) stack.remove(id);
    });
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.endAlignedWidth;
    return MenuAnchor(
      controller: _controller,
      childFocusNode: _buttonFocusNode,
      alignmentOffset: Offset(width == null ? 0 : -width, _menuGap),
      style: width == null
          ? null
          : const MenuStyle(alignment: AlignmentDirectional.bottomEnd),
      onOpen: () => _overlayStack.push(
        DismissibleOverlay(id: widget.overlayId, dismiss: _controller.close),
      ),
      onClose: () => _overlayStack.remove(widget.overlayId),
      // A sized box, not MenuStyle's sizes: compact density (desktop, web)
      // shrinks a menu's minimum width, which would undo the alignment.
      menuChildren: width == null
          ? widget.menuChildren
          : [
              SizedBox(
                width: width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widget.menuChildren,
                ),
              ),
            ],
      builder: (context, controller, _) =>
          widget.builder(context, controller, _buttonFocusNode),
    );
  }
}
