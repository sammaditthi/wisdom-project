import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../providers/tab_provider.dart';

/// Tells the reader an open was refused at [maxOpenTabs], for every opener.
///
/// Mounted in MaterialApp's builder, above the install gate: a web start link
/// can be refused while "Getting ready" still covers AppShell.
class TabLimitMessage extends ConsumerWidget {
  const TabLimitMessage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hide first so repeated taps don't queue up.
    ref.listen<int>(tabLimitReachedProvider, (_, __) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(
            AppLocalizations.of(context).tabLimitReached(maxOpenTabs),
          ),
        ));
    });
    return child;
  }
}
