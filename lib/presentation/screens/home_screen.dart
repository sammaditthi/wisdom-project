import 'package:material_ui/material_ui.dart';

import '../../core/localization/l10n/app_localizations.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive_utils.dart';
import '../widgets/home/today_card.dart';

/// The Home section: a heading and the Today card, in one centred column.
/// Hidden from the navigation until `kEnableHome` is on.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// The column's width cap, so the card does not stretch across a wide window.
  static const _maxWidth = 720.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gutter = ResponsiveUtils.isTabletOrDesktop(context) ? 32.0 : 16.0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: gutter, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.navHome, style: context.typography.dialogTitle),
                  const SizedBox(height: 20),
                  const TodayCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
