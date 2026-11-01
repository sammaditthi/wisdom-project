/// The tab-limit message, mounted as `main.dart` mounts it: in MaterialApp's
/// builder, above whatever the app is showing.
///
/// Which opens are refused is `tab_provider_test.dart`'s question. This is the
/// other half: a refusal reaches the user.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/core/localization/l10n/app_localizations.dart';
import 'package:the_wisdom_project/data/database/database_installation.dart';
import 'package:the_wisdom_project/presentation/providers/tab_provider.dart';
import 'package:the_wisdom_project/presentation/screens/database_install_screen.dart';
import 'package:the_wisdom_project/presentation/widgets/app/tab_limit_message.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const message = 'You have 50 tabs open. Close one before opening another.';

  Future<ProviderContainer> pumpWith(WidgetTester tester, Widget home) async {
    final container = createTestContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => TabLimitMessage(child: child!),
          home: home,
        ),
      ),
    );
    return container;
  }

  testWidgets('shows when an open is refused', (tester) async {
    final container = await pumpWith(tester, const Scaffold());
    expect(find.text(message), findsNothing);

    container.read(tabLimitReachedProvider.notifier).state++;
    await tester.pumpAndSettle();

    expect(find.text(message), findsOneWidget);
  });

  testWidgets('shows while "Getting ready" still covers the app',
      (tester) async {
    // A web start link opens as soon as the tree loads, which can be before
    // the gate lets AppShell build.
    final container = await pumpWith(
      tester,
      DatabaseInstallScreen(
        status:
            const DatabaseInstallStatus(phase: DatabaseInstallPhase.checking),
        onRetry: () {},
      ),
    );

    container.read(tabLimitReachedProvider.notifier).state++;
    // Not pumpAndSettle: the screen's progress bar never stops.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(message), findsOneWidget);
  });
}
