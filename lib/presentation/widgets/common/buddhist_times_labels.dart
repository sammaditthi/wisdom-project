import '../../../core/localization/l10n/app_localizations.dart';
import '../../../domain/entities/buddhist_times/city.dart';
import '../../../domain/entities/buddhist_times/dawn_method.dart';
import '../../../domain/entities/buddhist_times/uposatha_day.dart';

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
        MoonPhase.fullMoon => l10n.buddhistTimesFullMoon,
        MoonPhase.newMoon => l10n.buddhistTimesNewMoon,
      };
}
