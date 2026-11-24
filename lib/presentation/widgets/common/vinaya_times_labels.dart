import 'package:intl/intl.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../domain/entities/vinaya_times/city.dart';
import '../../../domain/entities/vinaya_times/dawn_method.dart';
import '../../../domain/entities/vinaya_times/uposatha_day.dart';

// The domain enums carry no words; these give each value its ARB string. The
// exhaustive switches mean a new value won't compile until it has one.

extension CityLabel on City {
  String label(AppLocalizations l10n) => switch (this) {
    City.colombo => l10n.cityColombo,
    City.kandy => l10n.cityKandy,
    City.galle => l10n.cityGalle,
    City.kurunegala => l10n.cityKurunegala,
    City.anuradhapura => l10n.cityAnuradhapura,
    City.jaffna => l10n.cityJaffna,
    City.trincomalee => l10n.cityTrincomalee,
    City.batticaloa => l10n.cityBatticaloa,
  };
}

extension DawnMethodLabel on DawnMethod {
  String label(AppLocalizations l10n) => switch (this) {
    DawnMethod.paAuk => l10n.dawnMethodPaAuk,
    DawnMethod.naUyana => l10n.dawnMethodNaUyana,
    DawnMethod.civilTwilight => l10n.dawnMethodCivilTwilight,
    DawnMethod.sunrise => l10n.dawnMethodSunrise,
  };

  /// How the method reckons dawn, in a few words.
  String rule(AppLocalizations l10n) => switch (this) {
    DawnMethod.paAuk => l10n.dawnMethodPaAukRule,
    DawnMethod.naUyana => l10n.dawnMethodNaUyanaRule,
    DawnMethod.civilTwilight => l10n.dawnMethodCivilTwilightRule,
    DawnMethod.sunrise => l10n.dawnMethodSunriseRule,
  };
}

extension MoonPhaseLabel on MoonPhase {
  String label(AppLocalizations l10n) => switch (this) {
    MoonPhase.fullMoon => l10n.vinayaTimesFullMoon,
    MoonPhase.newMoon => l10n.vinayaTimesNewMoon,
  };
}

// Sun times are instants, shown as the device clock reads them.
final _clock = DateFormat('HH:mm');
String clockTime(DateTime instant) => _clock.format(instant.toLocal());
