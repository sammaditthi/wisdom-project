import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/l10n/app_localizations.dart';
import '../../core/theme/app_typography.dart';
import '../../data/database/database_installation.dart';
import '../providers/database_install_provider.dart';
import '../widgets/common/app_emblem.dart';

/// Megabytes as a download shows them: 1 MB = 1,000,000 bytes, which is what
/// the browser and the operating system report.
const int _bytesPerMb = 1000000;

/// The emblem's gap above the middle of the window. `#boot` in web/index.html
/// uses the same number, so the emblem holds still when Flutter takes over.
const double _emblemGap = 24;

/// Covers the app until its databases are installed.
///
/// Only web installs anything — it downloads its databases on a first visit.
/// On native [DatabaseInstallation] is ready from the first frame, so [child]
/// is what builds and this costs a provider read.
class DatabaseInstallGate extends ConsumerWidget {
  const DatabaseInstallGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reading it starts the install.
    final status = ref.watch(databaseInstallProvider);
    if (status.phase == DatabaseInstallPhase.ready) return child;
    return DatabaseInstallScreen(
      status: status,
      onRetry: () => ref.read(databaseInstallProvider.notifier).retry(),
    );
  }
}

/// What the gate shows: one [DatabaseInstallStatus], in the four shapes it
/// comes in.
class DatabaseInstallScreen extends StatelessWidget {
  const DatabaseInstallScreen({
    super.key,
    required this.status,
    required this.onRetry,
  });

  final DatabaseInstallStatus status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _EmblemLayout(
          below: switch (status.phase) {
            DatabaseInstallPhase.failed =>
              _Failure(failure: status.failure, onRetry: onRetry),
            DatabaseInstallPhase.installing => _Progress(status: status),
            // `ready` never reaches here — the gate shows the app instead.
            DatabaseInstallPhase.checking ||
            DatabaseInstallPhase.ready =>
              const _Preparing(),
          },
        ),
      ),
    );
  }
}

/// The emblem with [below] under it, placed like `#boot` in web/index.html:
/// the emblem's bottom edge [_emblemGap] above the middle, [below] from the
/// middle down. Only [below] changes between phases, so the emblem stays put.
/// In a window too short for that, the whole screen scrolls.
class _EmblemLayout extends StatelessWidget {
  const _EmblemLayout({required this.below});

  final Widget below;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: SizedBox(
          width: constraints.maxWidth,
          child: Column(
            children: [
              SizedBox(
                height: math.max(
                  0,
                  constraints.maxHeight / 2 - _emblemGap - AppEmblem.size,
                ),
              ),
              const AppEmblem(),
              const SizedBox(height: _emblemGap),
              below,
            ],
          ),
        ),
      ),
    );
  }
}

/// The download itself: how far it has got, and why it is happening at all.
class _Progress extends StatelessWidget {
  const _Progress({required this.status});

  final DatabaseInstallStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = context.typography;
    // Both null until the size is known, which leaves the bar indeterminate.
    final double? fraction = status.fraction;
    final String? progress = fraction == null
        ? null
        : l10n.databaseInstallProgress(
            // Floored, so 100% means every byte is in. Opening the databases
            // and fetching the tree follow, with the bar full.
            (fraction * 100).floor(),
            status.received ~/ _bytesPerMb,
            status.total ~/ _bytesPerMb,
          );

    return _Panel(
      children: [
        Text(
          l10n.databaseInstallTitle,
          style: typography.emptyStateMessage,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _Bar(value: fraction, label: l10n.databaseInstallTitle),
        if (progress != null) ...[
          const SizedBox(height: 8),
          Text(progress, style: typography.resultSubtitle),
        ],
        const SizedBox(height: 16),
        Text(
          l10n.databaseInstallDescription,
          style: typography.resultSubtitle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Before the download starts: the bar and the line as `#boot` in
/// web/index.html shows them, in the same language, so the HTML loader hands
/// over without a jump.
class _Preparing extends StatelessWidget {
  const _Preparing();

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context).databaseInstallPreparing;
    return _Panel(
      children: [
        _Bar(value: null, label: label),
        const SizedBox(height: 12),
        Text(
          label,
          style: context.typography.emptyStateMessage,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// The column under the emblem: as wide as `#boot .below` in web/index.html.
class _Panel extends StatelessWidget {
  const _Panel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

/// The install's bar, the same in every phase and as `#boot .bar` in
/// web/index.html. Indeterminate while [value] is null.
class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.label});

  final double? value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      minHeight: 6,
      borderRadius: const BorderRadius.all(Radius.circular(3)),
      // No semanticsValue: Flutter fills it with this same bare percentage,
      // clamped (`progress_indicator.dart`). The megabytes are read from the
      // line below, a `Text` like any other.
      semanticsLabel: label,
    );
  }
}

/// A stopped install, in the three shapes a reader can do something about.
class _Failure extends StatelessWidget {
  const _Failure({required this.failure, required this.onRetry});

  final DatabaseInstallFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final kind = failure?.kind ?? DatabaseInstallFailureKind.other;

    final (String title, String description) = switch (kind) {
      DatabaseInstallFailureKind.unsupportedBrowser => (
          l10n.databaseInstallUnsupportedTitle,
          l10n.databaseInstallUnsupportedDescription,
        ),
      DatabaseInstallFailureKind.outOfSpace => (
          l10n.databaseInstallOutOfSpaceTitle,
          l10n.databaseInstallOutOfSpaceDescription,
        ),
      DatabaseInstallFailureKind.download ||
      DatabaseInstallFailureKind.other =>
        (
          l10n.databaseInstallFailedTitle,
          l10n.databaseInstallFailedDescription
        ),
    };

    final typography = context.typography;
    return _Panel(
      children: [
        Text(title,
            style: typography.errorMessage, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(
          description,
          style: typography.resultSubtitle,
          textAlign: TextAlign.center,
        ),
        // Nothing about this browser would change on a second try, so it gets
        // no button. Everything else does.
        if (kind != DatabaseInstallFailureKind.unsupportedBrowser) ...[
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(l10n.databaseInstallRetry),
          ),
        ],
        // The raw message, for the reader who reports what they saw. Left out
        // where the message above already says everything.
        if (failure != null && _showsDetail(kind)) ...[
          const SizedBox(height: 16),
          _Detail(message: failure!.message),
        ],
      ],
    );
  }

  static bool _showsDetail(DatabaseInstallFailureKind kind) =>
      kind == DatabaseInstallFailureKind.download ||
      kind == DatabaseInstallFailureKind.other;
}

class _Detail extends StatelessWidget {
  const _Detail({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SelectableText(
      message,
      textAlign: TextAlign.center,
      maxLines: 3,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
