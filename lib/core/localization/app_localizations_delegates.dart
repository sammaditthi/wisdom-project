import 'package:material_ui/material_ui.dart';

import 'l10n/app_localizations.dart';

// TODO(flutter#194500): once the fix is in stable, drop `header:` in l10n.yaml
// and regenerate. If AppLocalizations.localizationsDelegates then imports
// material_ui, switch main.dart and the tests back to it and delete this file.
// `git grep "TODO(flutter#194500)"` lists every other place to update.

/// The app's delegates. Not the generated `AppLocalizations.localizationsDelegates`:
/// gen-l10n in Flutter 3.50.1 builds that from flutter_localizations, whose
/// Material type material_ui doesn't read (fixed upstream in flutter#194500).
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];
