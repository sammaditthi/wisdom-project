import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/theme/app_typography.dart';
import '../../keyboard/key_cap_labels.dart';
import '../../keyboard/keyboard_bindings.dart';
import 'settings_row.dart';

/// The Keyboard shortcuts tab: every listed entry of `appShortcuts`, with the
/// keys of the platform it runs on. Read-only.
class KeyboardShortcutsPage extends StatelessWidget {
  const KeyboardShortcutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final platform = defaultTargetPlatform;
    final listed = [
      for (final s in shortcutsFor(platform))
        if (s.group != null) s,
    ];
    final groups = [
      for (final group in ShortcutGroup.values)
        if (listed.any((s) => s.group == group)) group,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(settingsGutter, 0, settingsGutter, 28),
      children: [
        for (final group in groups)
          _section(l10n, platform, group, _rows(l10n, listed, group),
              isFirst: group == groups.first),
      ],
    );
  }

  static Widget _section(
    AppLocalizations l10n,
    TargetPlatform platform,
    ShortcutGroup group,
    List<({String label, List<AppShortcut> shortcuts})> rows, {
    required bool isFirst,
  }) {
    return SettingsSection(
      title: _groupTitle(l10n, group),
      isFirst: isFirst,
      children: [
        for (final (i, row) in rows.indexed)
          SettingsRow(
            label: row.label,
            trailing: _KeyCombos(
              ways: _ways(row.shortcuts, platform),
              or: l10n.shortcutOr,
            ),
            showDivider: i < rows.length - 1,
          ),
      ],
    );
  }

  /// The row's combos, once for each way to press them: way 0 is every
  /// entry's own keys, the next ones its [AppShortcut.orKeys] or a Mac's fn
  /// arrows (`PgUp PgDn`, then `fn ↑ fn ↓`).
  static List<List<_Combo>> _ways(
    List<AppShortcut> shortcuts,
    TargetPlatform platform,
  ) {
    final perEntry = [
      for (final s in shortcuts)
        [
          ...keyCapWays(s.keys, platform, keyCap: s.keyCap),
          for (final keys in s.orKeys) ...keyCapWays(keys, platform),
        ],
    ];
    // Way n lines up every entry's nth way, so each needs as many.
    assert(perEntry.every((ways) => ways.length == perEntry.first.length));
    return [
      for (var w = 0; w < perEntry.first.length; w++)
        [for (final ways in perEntry) ways[w]],
    ];
  }

  /// One row per entry, except that consecutive entries with the same label
  /// (↑ and ↓ for Scroll) share one.
  static List<({String label, List<AppShortcut> shortcuts})> _rows(
    AppLocalizations l10n,
    List<AppShortcut> listed,
    ShortcutGroup group,
  ) {
    final rows = <({String label, List<AppShortcut> shortcuts})>[];
    for (final s in listed.where((s) => s.group == group)) {
      final label = s.label!(l10n);
      if (rows.isNotEmpty && rows.last.label == label) {
        rows.last.shortcuts.add(s);
      } else {
        rows.add((label: label, shortcuts: [s]));
      }
    }
    return rows;
  }

  static String _groupTitle(AppLocalizations l10n, ShortcutGroup group) =>
      switch (group) {
        ShortcutGroup.search => l10n.shortcutGroupSearch,
        ShortcutGroup.reader => l10n.shortcutGroupReader,
        ShortcutGroup.layout => l10n.shortcutGroupLayout,
        ShortcutGroup.app => l10n.shortcutGroupApp,
      };
}

/// A key combo as its caps, e.g. `['⌥', '⌘', 'W']`.
typedef _Combo = List<String>;

/// A row's key combos: caps within a combo sit close, combos further apart,
/// and each further way to press them comes after [or].
class _KeyCombos extends StatelessWidget {
  const _KeyCombos({required this.ways, required this.or});

  final List<List<_Combo>> ways;
  final String or;

  @override
  Widget build(BuildContext context) {
    final parts = [
      for (final (w, combos) in ways.indexed)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (w > 0) ...[
              Text(or, style: context.typography.menuSectionLabel),
              const SizedBox(width: 8),
            ],
            for (final (i, combo) in combos.indexed) ...[
              if (i > 0) const SizedBox(width: 12),
              for (final (j, cap) in combo.indexed) ...[
                if (j > 0) const SizedBox(width: 4),
                _KeyCap(cap),
              ],
            ],
          ],
        ),
    ];
    // Single keys share a line (↓ or Tab). Pairs take a line per way
    // (PgUp PgDn, then or fn ↑ fn ↓), which keeps the row narrow.
    if (ways.every((combos) => combos.length == 1)) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (w, part) in parts.indexed) ...[
            if (w > 0) const SizedBox(width: 8),
            part,
          ],
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final (w, part) in parts.indexed) ...[
          if (w > 0) const SizedBox(height: 4),
          part,
        ],
      ],
    );
  }
}

/// A key drawn as a key cap, like the design board's.
class _KeyCap extends StatelessWidget {
  const _KeyCap(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border(
          top: BorderSide(color: colors.outlineVariant),
          left: BorderSide(color: colors.outlineVariant),
          right: BorderSide(color: colors.outlineVariant),
          bottom: BorderSide(color: colors.outlineVariant, width: 2),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colors.onSurface,
        ),
      ),
    );
  }
}
