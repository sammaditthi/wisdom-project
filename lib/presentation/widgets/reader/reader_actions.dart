import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../models/reader_layout.dart';
import '../../providers/parallel_text_provider.dart';
import '../../providers/tab_provider.dart'
    show activeReaderLayoutProvider, updateActiveTabLayoutProvider;
import 'reader_link_actions.dart';

/// Where one of the step actions goes, named by the sutta it steps to.
typedef ReaderStepTarget = ({String name, VoidCallback onTap});

/// The reader's actions fall into these groups, in this order. Presenters put
/// a divider between two groups.
enum ReaderActionGroup { view, reading, outward }

/// One entry in the reader's action list. The toolbar and the scrolled menu
/// draw the same list, each in its own way.
sealed class ReaderAction {
  final ReaderActionGroup group;

  const ReaderAction(this.group);
}

/// A plain action: one tap does it.
class ReaderCommand extends ReaderAction {
  final IconData icon;

  /// The menu row's text.
  final String label;

  /// A small line above [label] in a menu row, e.g. "Previous".
  final String? caption;

  /// The toolbar button's tooltip; [label] when null.
  final String? tooltip;

  final VoidCallback onSelected;

  const ReaderCommand({
    required ReaderActionGroup group,
    required this.icon,
    required this.label,
    required this.onSelected,
    this.caption,
    this.tooltip,
  }) : super(group);
}

/// The layout picker: a choice among [ReaderLayout.values], not a command.
class ReaderLayoutChoice extends ReaderAction {
  final ReaderLayout current;
  final ValueChanged<ReaderLayout> onChanged;

  const ReaderLayoutChoice({
    required this.current,
    required this.onChanged,
  }) : super(ReaderActionGroup.view);
}

/// One row in a [ReaderActionMenu].
typedef ReaderMenuItem = ({
  IconData icon,
  String label,
  VoidCallback onSelected,
});

/// An action that opens a menu of further commands (Share).
class ReaderActionMenu extends ReaderAction {
  final IconData icon;
  final String label;
  final List<ReaderMenuItem> items;

  const ReaderActionMenu({
    required ReaderActionGroup group,
    required this.icon,
    required this.label,
    required this.items,
  }) : super(group);
}

/// The reader's actions for the active tab, in order. Call from `build`.
///
/// A step action is left out when there is no sutta that way. Go to beginning
/// is included only when [onScrollToBeginning] is given: at the top of a sutta
/// it has nothing to do.
List<ReaderAction> buildReaderActions(
  BuildContext context,
  WidgetRef ref, {
  required VoidCallback onSearch,
  ReaderStepTarget? previous,
  ReaderStepTarget? next,
  VoidCallback? onScrollToBeginning,
}) {
  final l10n = AppLocalizations.of(context);
  final targetNode = ref.watch(parallelTextNodeProvider);
  final isCommentary = ref.watch(isCommentaryProvider);
  final currentLayout = ref.watch(activeReaderLayoutProvider);

  ReaderCommand step(ReaderStepTarget target, IconData icon, String caption) =>
      ReaderCommand(
        group: ReaderActionGroup.reading,
        icon: icon,
        label: target.name,
        caption: caption,
        tooltip: l10n.goToSutta(target.name),
        onSelected: target.onTap,
      );

  return [
    ReaderLayoutChoice(
      current: currentLayout,
      onChanged: (layout) => ref.read(updateActiveTabLayoutProvider)(layout),
    ),
    ReaderCommand(
      group: ReaderActionGroup.view,
      icon: Icons.search,
      label: l10n.findInPage,
      onSelected: onSearch,
    ),
    // Commentary/Root text toggle — only when there is a parallel text
    if (targetNode != null)
      ReaderCommand(
        group: ReaderActionGroup.reading,
        // The tree's icon for a text, in both directions.
        icon: Symbols.description_sharp,
        label: isCommentary ? l10n.rootText : l10n.commentary,
        onSelected: () => ref.read(openParallelTextProvider)(
          isPortraitMode: ResponsiveUtils.shouldDefaultToSingleColumn(context),
        ),
      ),
    if (previous != null)
      step(previous, Icons.skip_previous, l10n.previousSutta),
    if (next != null) step(next, Icons.skip_next, l10n.nextSutta),
    if (onScrollToBeginning != null)
      ReaderCommand(
        group: ReaderActionGroup.outward,
        icon: Icons.vertical_align_top,
        label: l10n.scrollToBeginning,
        onSelected: onScrollToBeginning,
      ),
    ReaderActionMenu(
      group: ReaderActionGroup.outward,
      icon: Icons.adaptive.share,
      label: l10n.share,
      items: [
        (
          icon: Icons.content_copy,
          label: l10n.copyLink,
          onSelected: () => copyActiveTabLink(context, ref),
        ),
        if (kIsWeb)
          (
            icon: Icons.open_in_new,
            label: l10n.openAsWebPage,
            onSelected: () => openAsWebPage(context, ref),
          ),
      ],
    ),
  ];
}
