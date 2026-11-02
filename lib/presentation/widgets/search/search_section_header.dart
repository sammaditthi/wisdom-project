import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';

/// Uppercase header over a group of search rows ("RECENT SEARCHES",
/// "TITLES"), with an optional link at the end ("Clear all", "See all →").
class SearchSectionHeader extends StatelessWidget {
  final String label;

  /// Usually a [SearchLinkButton].
  final Widget? action;

  const SearchSectionHeader({super.key, required this.label, this.action});

  @override
  Widget build(BuildContext context) {
    final action = this.action;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
      // Same height with or without an action; grows with large text.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 40),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: context.typography.sectionHeaderFor(label),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (action != null) action,
          ],
        ),
      ),
    );
  }
}
