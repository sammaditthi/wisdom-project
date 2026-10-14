import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/l10n/app_localizations.dart';
import '../../core/utils/responsive_utils.dart';
import '../providers/app_section_provider.dart';
import 'home_screen.dart';
import 'notes_screen.dart';
import 'reader_screen.dart';
import 'research_screen.dart';

/// The sections the rail and the bottom bar offer, in display order. Home and
/// Notes are hidden for the beta; they stay in [AppSection] so nothing else
/// has to change to bring them back.
const _navSections = [AppSection.reader, AppSection.research];

/// The app's top-level shell: an icon-only [NavigationRail] on tablet/desktop
/// and a labelled bottom [NavigationBar] on mobile, switching between the
/// [_navSections].
///
/// The sections live in an [IndexedStack] so the ReaderScreen keeps its
/// state (open document tabs, tree expansion, scroll positions) while
/// another section is shown. Each section owns its own Scaffold/AppBar —
/// this shell only owns the navigation chrome.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final section = ref.watch(selectedAppSectionProvider);
    final isTabletOrDesktop = ResponsiveUtils.isTabletOrDesktop(context);

    // One spec per shown section, in _navSections order. The exhaustive
    // switch means adding a section won't compile until it gets an icon and
    // a label here. Records because the rail and the bottom bar (different
    // destination widget types) share a single definition.
    final sections = [
      for (final s in _navSections)
        switch (s) {
          AppSection.home => (
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: l10n.navHome,
            ),
          AppSection.reader => (
              icon: Icons.menu_book_outlined,
              selectedIcon: Icons.menu_book,
              label: l10n.navReader,
            ),
          AppSection.research => (
              icon: Icons.auto_awesome_outlined,
              selectedIcon: Icons.auto_awesome,
              label: l10n.navResearch,
            ),
          AppSection.notes => (
              icon: Icons.edit_note_outlined,
              selectedIcon: Icons.edit_note,
              label: l10n.navNotes,
            ),
        },
    ];

    // A position in the nav, not the enum index: with sections hidden the
    // two no longer line up.
    final navIndex = _navSections.indexOf(section);

    void selectSection(int index) {
      ref.read(selectedAppSectionProvider.notifier).state =
          _navSections[index];
    }

    return Scaffold(
      body: Row(
        children: [
          if (isTabletOrDesktop)
            NavigationRail(
              selectedIndex: navIndex,
              onDestinationSelected: selectSection,
              // Material 3 default: icons only. The labels below are still
              // read by screen readers.
              labelType: NavigationRailLabelType.none,
              destinations: [
                for (final s in sections)
                  NavigationRailDestination(
                    icon: Icon(s.icon),
                    selectedIcon: Icon(s.selectedIcon),
                    label: Text(s.label),
                  ),
              ],
            ),
          Expanded(
            child: IndexedStack(
              index: section.index,
              // Same exhaustive-switch trick: order matches AppSection.values
              // by construction. Each widget is a canonical const instance,
              // so identical instances are reused every build and the
              // IndexedStack keeps its children's state.
              children: [
                for (final s in AppSection.values)
                  switch (s) {
                    AppSection.home => const HomeScreen(),
                    AppSection.reader => const ReaderScreen(),
                    AppSection.research => const ResearchScreen(),
                    AppSection.notes => const NotesScreen(),
                  },
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isTabletOrDesktop
          ? null
          : NavigationBar(
              selectedIndex: navIndex,
              onDestinationSelected: selectSection,
              destinations: [
                for (final s in sections)
                  NavigationDestination(
                    icon: Icon(s.icon),
                    selectedIcon: Icon(s.selectedIcon),
                    label: s.label,
                  ),
              ],
            ),
    );
  }
}
