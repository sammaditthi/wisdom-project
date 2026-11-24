import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/research/research_mode.dart';
import '../../providers/research_mode_provider.dart';
import '../common/dismissible_menu_anchor.dart';
import '../common/menu_row.dart';
import 'research_mode_ui.dart';

/// Width of the mode menu, fixed so it lines up with the chip's right edge.
const double _menuWidth = 240;

/// The Fast/Thinking mode switch in the Research composer. Tapping it opens a
/// menu of the two modes, each with a one-line hint and a check on the active
/// one. The choice applies to the current chat and is remembered per-chat
/// ([researchModeProvider] seeds it; the chat's summary stores it) — a new
/// chat always starts on Fast.
///
/// Presentation is deliberately friendly — "Fast" / "Thinking", never raw
/// Gemini model IDs. The per-tier fallback ladder stays a backend detail.
class ResearchModeSelector extends ConsumerWidget {
  const ResearchModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final mode = ref.watch(researchModeProvider);

    return DismissibleMenuAnchor(
      overlayId: 'research-mode-menu',
      endAlignedWidth: _menuWidth,
      menuChildren: [
        for (final m in ResearchMode.values)
          MenuRow(
            icon: Icon(m.icon, size: 20, color: colors.onPrimaryContainer),
            label: m.label(l10n),
            note: m.hint(l10n),
            selected: m == mode,
            onSelected: () => ref.read(researchModeProvider.notifier).set(m),
          ),
      ],
      // The resting chip: current mode + a dropdown caret. It reads as a raised
      // pill by being a step LIGHTER than the composer fill it sits inside
      // (surfaceContainerHigh). The search scope-filter chips use the same
      // fill on their darker row; unlike them, this one needs no border.
      builder: (context, controller, focusNode) => Semantics(
        button: true,
        expanded: controller.isOpen,
        child: Tooltip(
          message: l10n.researchModeTooltip,
          child: Material(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              focusNode: focusNode,
              borderRadius: BorderRadius.circular(20),
              onTap: controller.toggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(mode.icon, size: 18, color: colors.onSurfaceVariant),
                    const SizedBox(width: 6),
                    // The scope-filter chips' label style — the same token as
                    // the chips this one borrows its fill trick from, and it
                    // scales with the composer it sits in.
                    Text(mode.label(l10n), style: context.typography.chipLabel),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
