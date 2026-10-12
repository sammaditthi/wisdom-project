import 'package:flutter/material.dart';

import 'mouse_drag_scroll.dart';

/// One sideways-scrolling row of chips. A mouse can drag it too.
class PillChipRow extends StatelessWidget {
  final List<Widget> children;

  const PillChipRow({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return MouseDragScroll(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // The last chip ends 12px from the edge, as the first starts (the
        // panel header's 8px gap plus this 4).
        padding: const EdgeInsetsDirectional.only(start: 4, end: 12),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: children.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        // Center: the list would otherwise stretch each chip to its height.
        itemBuilder: (context, index) => Center(child: children[index]),
      ),
    );
  }
}
