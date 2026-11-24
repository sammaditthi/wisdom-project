import 'package:material_ui/material_ui.dart';

import 'l10n/app_localizations.dart';

/// The app's delegates. Not the generated `AppLocalizations.localizationsDelegates`:
/// gen-l10n in Flutter 3.50.1 builds that from flutter_localizations, whose
/// Material type material_ui doesn't read (fixed upstream in flutter#194500).
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];
