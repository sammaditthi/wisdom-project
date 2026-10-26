// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sinhala Sinhalese (`si`).
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([String locale = 'si']) : super(locale);

  @override
  String get appTitle => 'Sammaditthi';

  @override
  String get readerTitle => 'පාඨකය';

  @override
  String get showNavigator => 'පටුන පෙන්වන්න';

  @override
  String get hideNavigator => 'පටුන සඟවන්න';

  @override
  String get layoutPaliOnly => 'පාළි පමණයි';

  @override
  String get layoutSinhalaOnly => 'සිංහල පමණයි';

  @override
  String currentLayout(String name) {
    return 'පිරිසැලසුම: $name';
  }

  @override
  String get layoutSideBySide => 'සමාන්තරව';

  @override
  String get layoutStacked => 'අනුක්‍රමිකව';

  @override
  String get paliLanguageLabel => 'පාළි';

  @override
  String get sinhalaLanguageLabel => 'සිංහල';

  @override
  String get loading => 'පූරණය වෙමින්...';

  @override
  String get errorLoadingContent => 'අන්තර්ගතය පූරණය කිරීමේ දෝෂයකි';

  @override
  String get errorLoadingTree => 'පටුන පූරණය කිරීමේ දෝෂයකි';

  @override
  String get searchPlaceholder => 'ත්‍රිපිටකයේ සොයන්න...';

  @override
  String get noResultsFound => 'ප්‍රතිඵල හමු නොවීය';

  @override
  String get expandAll => 'සියල්ල විශාල කරන්න';

  @override
  String get collapseAll => 'සියල්ල හකුළන්න';

  @override
  String get settings => 'සැකසුම්';

  @override
  String get theme => 'තේමාව';

  @override
  String get themeLight => 'ආලෝකමත්';

  @override
  String get appLanguage => 'යෙදුම් භාෂාව';

  @override
  String get contentLanguage => 'අන්තර්ගත භාෂාව';

  @override
  String get paliLetters => 'පාළි අකුරු';

  @override
  String get paliStandardLigatures => 'සුලබ බැඳි අකුරු';

  @override
  String get paliSpecialLetters => 'විශේෂ පාළි අකුරු';

  @override
  String get paliTouching => 'පාළි බැඳි අකුරු';

  @override
  String get appLayout => 'යෙදුම';

  @override
  String get hideNavigationBar => 'පැති තීරුව සඟවන්න';

  @override
  String get fontSize => 'අක්ෂර ප්‍රමාණය';

  @override
  String get fontSizeSmall => 'කුඩා';

  @override
  String get fontSizeMedium => 'මධ්‍යම';

  @override
  String get fontSizeLarge => 'විශාල';

  @override
  String get fontSizeExtraLarge => 'අතිශය විශාල';

  @override
  String get close => 'වසන්න';

  @override
  String get searchHint => 'සෙවුම් පදය ඇතුළත් කරන්න';

  @override
  String get isExactMatchToggle => 'එම වචනයම සොයන්න';

  @override
  String get refineSearch => 'සෙවුම සීමා කිරීම';

  @override
  String get refine => 'සීමා කිරීම';

  @override
  String get expand => 'ඉහළට';

  @override
  String get collapse => 'හකුළන්න';

  @override
  String get scope => 'පරාසය';

  @override
  String get searchLanguageLabel => 'සෙවුම් භාෂා සීමා කරන්න';

  @override
  String get searchTabTopResults => 'ප්‍රමුඛ ප්‍රතිඵල';

  @override
  String get searchTabTitles => 'පෙළ';

  @override
  String get searchTabFullText => 'අන්තර්ගතය';

  @override
  String get searchTabDefinitions => 'අර්ථ';

  @override
  String get searchTabReference => 'යොමුව';

  @override
  String get recentSearches => 'මෑත සෙවුම්';

  @override
  String get removeRecentSearch => 'මෑත සෙවුම්වලින් ඉවත් කරන්න';

  @override
  String viewMore(int count) {
    return 'තවත් ගැළපීම් $countක් ඇත';
  }

  @override
  String get showLess => 'හකුළන්න';

  @override
  String get seeAll => 'සියල්ල බලන්න';

  @override
  String viewingResults(int shown, int total) {
    return 'ප්‍රතිඵල $totalකින් $shownක් පෙන්වයි';
  }

  @override
  String get reset => 'යළි සකසන්න';

  @override
  String get clear => 'ඉවත් කරන්න';

  @override
  String get clearAll => 'සියල්ල ඉවත් කරන්න';

  @override
  String get scopeAll => 'සියල්ල';

  @override
  String get scopeSutta => 'සූත්‍ර';

  @override
  String get scopeVinaya => 'විනය';

  @override
  String get scopeAbhidhamma => 'අභිධර්ම';

  @override
  String get scopeCommentaries => 'අට්ඨකථා';

  @override
  String get scopeOther => 'අන්‍ය';

  @override
  String get anywhereInText => 'එකම පෙළෙහි ඕනෑම තැනක';

  @override
  String get openSearch => 'සොයන්න';

  @override
  String get matchOptions => 'ගැළපීමේ විකල්ප';

  @override
  String get matchEachWord => 'වචන ගැළපෙන ආකාරය';

  @override
  String get matchStartsWith => 'ඇරඹෙන වචන';

  @override
  String get matchStartsWithHint => 'වචනය සහ එයින් ඇරඹෙන දිගු වචන සොයයි';

  @override
  String get matchWholeWord => 'එම වචනයම';

  @override
  String get matchWholeWordHint => 'එම වචනයම පමණක් සොයයි';

  @override
  String get matchHowWordsSit => 'වචන පිහිටන ආකාරය';

  @override
  String get matchPhrase => 'වාක්‍යයක් ලෙස';

  @override
  String get matchPhraseHint => 'ලියූ පිළිවෙළටම, වාක්‍ය ඛණ්ඩයක් ලෙස සොයයි';

  @override
  String get matchPhraseShort => 'වාක්‍යය';

  @override
  String get matchAnywhereHint =>
      'ඕනෑම පිළිවෙළකින්, වෙන්වූ වචන සමූහයක් ලෙස සොයයි';

  @override
  String get matchAnywhereShort => 'ඕනෑම තැනක';

  @override
  String get matchNear => 'එකිනෙකට ආසන්නව';

  @override
  String get matchNearHint => 'එකිනෙකට ආසන්නව නිශ්චිත දුරකින් ඇති වචන සොයයි';

  @override
  String matchNearShort(int count) {
    return 'දුර $count';
  }

  @override
  String matchNearWithin(int count) {
    return 'වචන $countක් ඇතුළත';
  }

  @override
  String get smallerGap => 'පරතරය අඩු කරන්න';

  @override
  String get largerGap => 'පරතරය වැඩි කරන්න';

  @override
  String get resetToDefault => 'පෙරනිමියට යළි සකසන්න';

  @override
  String get noDefinitionsFound => 'අර්ථ දැක්වීම් හමු නොවීය';

  @override
  String get dictionaryLookup => 'ශබ්දකෝෂය';

  @override
  String get errorLoadingDefinitions => 'අර්ථ දැක්වීම් පූරණය කිරීමේ දෝෂයකි';

  @override
  String get commentary => 'අට්ඨකථාව වෙත';

  @override
  String get rootText => 'මූලය වෙත';

  @override
  String get scrollToBeginning => 'ආරම්භයට යන්න';

  @override
  String goToSutta(String name) {
    return 'වෙත යන්න: $name';
  }

  @override
  String get findInPage => 'පිටුවේ සොයන්න';

  @override
  String get noInPageMatches => '0 / 0';

  @override
  String get previousMatch => 'පෙර ගැලපීම';

  @override
  String get nextMatch => 'ඊළඟ ගැලපීම';

  @override
  String get backspace => 'අකුරු මකන්න';

  @override
  String get dictFilterAll => 'සියල්ල';

  @override
  String get dictFilterSinhala => 'සිංහල';

  @override
  String get dictFilterEnglish => 'ඉංග්‍රීසි';

  @override
  String get dictRefineTitle => 'ශබ්දකෝෂ තෝරන්න';

  @override
  String get dictRefineSectionLabel => 'ශබ්දකෝෂ';

  @override
  String get done => 'හරි';

  @override
  String get readMore => 'තව කියවන්න';

  @override
  String get couldNotOpenLink => 'සබැඳිය විවෘත කළ නොහැකිය';

  @override
  String get statusOfflineTitle => 'සේවාදායකය වෙත සම්බන්ධ විය නොහැක';

  @override
  String get statusOfflineDescription =>
      'ඔබගේ සම්බන්ධතාවය පරීක්ෂා කර නැවත උත්සාහ කරන්න.';

  @override
  String get errorLoadingSearch => 'ප්‍රතිඵල පූරණය කිරීමේ දෝෂයකි';

  @override
  String get statusErrorDescription => 'මොහොතකින් නැවත උත්සාහ කරන්න.';

  @override
  String get statusInvalidQuery => 'වලංගු සෙවුම් පදයක් ඇතුළත් කරන්න';

  @override
  String statusNoResultsForCategory(String category) {
    return '$category හමු නොවීය';
  }

  @override
  String get readerEmptyHomage => 'නමො තස්ස භගවතො අරහතො සම්මාසම්බුද්ධස්ස';

  @override
  String get statusSelectSuttaToRead => 'කියවීම ඇරඹීමට පටුනෙන් පෙළක් තෝරන්න';

  @override
  String get statusNoContentToDisplay => 'පෙන්වීමට අන්තර්ගතයක් නැත';

  @override
  String get statusNoTreeContent => 'අන්තර්ගතයක් නොමැත';

  @override
  String get navHome => 'මුල් පිටුව';

  @override
  String get navReader => 'ත්‍රිපිටකය';

  @override
  String get navResearch => 'ගවේෂණය';

  @override
  String get navNotes => 'සටහන්';

  @override
  String get researchNewChat => 'නව සංවාදය';

  @override
  String get researchEmptyState =>
      'ත්‍රිපිටකයෙන් පිළිතුරු ලබා ගැනීමට ප්‍රශ්නය යොමු කරන්න.';

  @override
  String get researchPrivacyNote =>
      'පිළිතුරු සපයන්නේ Google Gemini (free tier) ආධාරයෙනි. පෞද්ගලික තොරතුරු ඇතුළත් නොකරන්න.';

  @override
  String get researchInputHint => 'ප්‍රශ්නය යොමු කරන්න';

  @override
  String get researchSend => 'යවන්න';

  @override
  String get researchModeFast => 'වේගවත්';

  @override
  String get researchModeFastHint => 'වේගවත්ම පිළිතුරු';

  @override
  String get researchModeThinking => 'ගැඹුරු';

  @override
  String get researchModeThinkingHint => 'ගැඹුරු තර්කනය';

  @override
  String get researchModeTooltip => 'පිළිතුරු ආකාරය';

  @override
  String get researchBusyFast => 'පිළිතුරු දෙමින්…';

  @override
  String get researchBusyThinking => 'සිතමින්…';

  @override
  String get researchCitedSource => 'උපුටා දැක්වූ මූලාශ්‍රය';

  @override
  String get researchMatchedPassage => 'ගැළපෙන කොටස · SuttaCentral';

  @override
  String get researchOtherSources => 'වෙනත් මූලාශ්‍ර';

  @override
  String get researchOpenInReader => 'කියවනයේ විවෘත කරන්න';

  @override
  String get researchCitationNotLinked =>
      'මෙම මූලාශ්‍රය තවම මෙම සංස්කරණයට සම්බන්ධ කර නොමැත.';

  @override
  String get copyLink => 'සබැඳිය පිටපත් කරන්න';

  @override
  String get linkCopied => 'සබැඳිය පිටපත් විය';

  @override
  String get researchRetry => 'නැවත උත්සාහ කරන්න';

  @override
  String get researchErrorOffline =>
      'සම්බන්ධ විය නොහැකි විය. ඔබගේ අන්තර්ජාල සම්බන්ධතාව පරීක්ෂා කර නැවත උත්සාහ කරන්න.';

  @override
  String get researchErrorTimeout =>
      'මෙය සුපුරුදුට වඩා වැඩි වේලාවක් ගනිමින් පවතී. කරුණාකර නැවත උත්සාහ කරන්න.';

  @override
  String get researchErrorRateLimited =>
      'දැන් Research වෙත බොහෝ ප්‍රශ්න පැමිණ ඇත. කරුණාකර මිනිත්තු කිහිපයකින් නැවත උත්සාහ කරන්න.';

  @override
  String get researchErrorRateLimitedThinking =>
      'දැන් Research වෙත බොහෝ ප්‍රශ්න පැමිණ ඇත. මිනිත්තු කිහිපයකින් නැවත උත්සාහ කරන්න, නැතහොත් Fast ප්‍රකාරයට මාරු වන්න.';

  @override
  String get researchErrorServiceBusy =>
      'Research දැන් කාර්යබහුලයි. කරුණාකර මොහොතකින් නැවත උත්සාහ කරන්න.';

  @override
  String get researchErrorNotAuthorised =>
      'Research දැන් ලබා ගත නොහැක. කරුණාකර පසුව නැවත උත්සාහ කරන්න.';

  @override
  String get researchErrorCannotAnswer =>
      'ත්‍රිපිටකයෙන් එයට පිළිතුරක් සොයා ගත නොහැකි විය. ප්‍රශ්නය වෙනස් ආකාරයකින් අසන්න, නැතහොත් නිශ්චිත ඉගැන්වීමක් ගැන අසන්න.';

  @override
  String get researchErrorServerError =>
      'අපගේ පැත්තෙන් යම් දෝෂයක් සිදු විය. කරුණාකර නැවත උත්සාහ කරන්න.';

  @override
  String get researchErrorResourceLimit =>
      'එම පිළිතුර නිම කිරීමට වැඩි ධාරිතාවක් ගත විය. කරුණාකර නැවත උත්සාහ කරන්න — සරල ප්‍රශ්නයක් උපකාරී විය හැක.';

  @override
  String get researchQuestionNotAnswered =>
      'මෙම ප්‍රශ්නයට තවම පිළිතුරක් නොලැබුණි.';

  @override
  String get researchRecent => 'මෑත සංවාද';

  @override
  String get researchNoRecentChats => 'තවම සංවාද නොමැත';

  @override
  String get researchChatLimitReached =>
      'මෙම සංවාදය එහි දිග සීමාවට ළඟා වී ඇත. දිගටම කරගෙන යාමට නව සංවාදයක් අරඹන්න.';

  @override
  String get researchDeleteChat => 'සංවාදය මකන්න';

  @override
  String get relativeTimeJustNow => 'මේ දැන්';

  @override
  String relativeTimeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'මිනිත්තු $countකට පෙර',
      one: 'මිනිත්තුවකට පෙර',
    );
    return '$_temp0';
  }

  @override
  String relativeTimeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'පැය $countකට පෙර',
      one: 'පැයකට පෙර',
    );
    return '$_temp0';
  }

  @override
  String get relativeTimeYesterday => 'ඊයේ';

  @override
  String relativeTimeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'දින $countකට පෙර',
    );
    return '$_temp0';
  }

  @override
  String get databaseInstallTitle => 'පෙළ බාගත වෙමින් පවතී';

  @override
  String get databaseInstallDescription =>
      'පෙළ සහ ශබ්දකෝෂය මෙම උපාංගයේ ගබඩා වේ. එවිට ඉක්මනින් විවෘත වන අතර අන්තර්ජාලය නැතිවද භාවිතා කළ හැකිය. බාගත කිරීම අවසන් වූ පසු යෙදුම විවෘත වේ.';

  @override
  String get databaseInstallPreparing => 'සූදානම් වෙමින්…';

  @override
  String databaseInstallProgress(int percent, int received, int total) {
    return '$percent% · MB $total න් MB $received';
  }

  @override
  String get databaseInstallUnsupportedTitle =>
      'මෙම බ්‍රව්සරයට පෙළ ගබඩා කළ නොහැක';

  @override
  String get databaseInstallUnsupportedDescription =>
      'දැනට Chrome සහ Edge සඳහා සහය දක්වයි.';

  @override
  String get databaseInstallOutOfSpaceTitle => 'ප්‍රමාණවත් ඉඩක් නැත';

  @override
  String get databaseInstallOutOfSpaceDescription =>
      'මෙම උපාංගයේ පෙළ සඳහා ප්‍රමාණවත් ඉඩක් නොමැත. ඉඩ නිදහස් කර නැවත උත්සාහ කරන්න.';

  @override
  String get databaseInstallFailedTitle => 'බාගත කිරීම අවසන් නොවීය';

  @override
  String get databaseInstallFailedDescription =>
      'ඔබගේ සම්බන්ධතාවය පරීක්ෂා කර නැවත උත්සාහ කරන්න. යළි පිහිටුවීමට, Chrome හි site settings → Delete data විවෘත කරන්න.';

  @override
  String get databaseInstallRetry => 'නැවත උත්සාහ කරන්න';

  @override
  String get readInApp => 'යෙදුමෙන් කියවන්න';

  @override
  String get moreOptions => 'තවත් විකල්ප';

  @override
  String get share => 'බෙදාගන්න';

  @override
  String get openAsWebPage => 'සරල වෙබ් පිටුවට';

  @override
  String get readerSettings => 'කියවීම් සැකසුම්';

  @override
  String get settingsGeneral => 'සාමාන්‍ය';

  @override
  String get settingsAnumodana => 'පුණ්‍යානුමෝදනා';

  @override
  String get settingsAppearance => 'පෙනුම';

  @override
  String get settingsLanguage => 'භාෂාව';

  @override
  String get themeDark => 'අඳුරු';

  @override
  String get themeDarkComingSoon => 'අඳුරු තේමාව ඉදිරියේදී.';

  @override
  String get appLanguageHint => 'යෙදුම භාවිතා කිරීමට ඔබ කැමති භාෂාව.';

  @override
  String get contentLanguageHint => 'සූත්‍ර නාම ආදිය දිස්වීමට ඔබ කැමති භාෂාව.';

  @override
  String get paliLettersHint => 'පාළි බැඳි අකුරු පෙන්වන ආකාරය.';

  @override
  String get settingsPrivacy => 'පෞද්ගලිකත්වය';

  @override
  String get researchPrivacyDetail =>
      'ගවේෂණයේදී ප්‍රශ්නයට පිළිතුරු සෙවීම සඳහා එය Google Gemini වෙත යවනු ලැබේ. අප භාවිතා කරන නොමිලේ ස්ථරය යටතේ, එම තොරතුරු Google හි සේවාවන් වැඩිදියුණු කිරීමට යොදා ගත හැකි අතර, විශ්‍ලේෂකයන් විසින් ඒවා කියවීමට ඉඩ ඇත. පෞද්ගලික තොරතුරු ඇතුළත් නොකරන්න.';

  @override
  String get anumodanaLineage => 'භාණක පරම්පරාව';

  @override
  String get anumodanaLineageBody =>
      'ත්‍රිපිටකය කටපාඩමින් දරාගෙන පරපුරෙන් පරපුරට පවත්වාගෙන ආ භාණක පරම්පරාවට.';

  @override
  String get anumodanaTextSources => 'මූලාශ්‍ර';

  @override
  String get anumodanaTipitakaLkUse =>
      'බුද්ධ ජයන්ති පාළි පෙළ, එහි සිංහල පරිවර්තනය සහ අට්ඨකථා ලබාගත් ඩිජිටල් සංස්කරණය.\nපාළි පෙළ CC BY-ND 4.0 යටතේ.';

  @override
  String get anumodanaSuttaCentralUse =>
      'ඉංග්‍රීසි පරිවර්තන සහ සූත්‍ර අංකන ක්‍රමය.\nCC0 1.0.';

  @override
  String get anumodanaDictionaries => 'ශබ්දකෝෂ';

  @override
  String get anumodanaDictionariesHint =>
      'වචන අර්ථ බැලීමට භාවිතා කරන ශබ්දකෝෂ, අකාරාදී පිළිවෙළින්.';

  @override
  String get anumodanaDictGroupSinhala => 'පාළි – සිංහල';

  @override
  String get anumodanaDictGroupEnglish => 'පාළි – ඉංග්‍රීසි';

  @override
  String get anumodanaDpdLicence =>
      'Bodhirasa Bhikkhu, Digital Pāḷi Dictionary v0.2.20250709. CC BY-NC-SA 4.0.';

  @override
  String get anumodanaContributors => 'දායක වූ සැම';

  @override
  String get anumodanaContributorsBody =>
      'අවවාදානුශාසනා දීමෙන් හා කාලය කැප කිරීමෙන් දායක වූ සියලු දෙනාට ප්‍රඥාව වැඩීමටම උපනිශ්‍රයක් වේවා.';

  @override
  String get anumodanaLicences => 'බලපත්‍ර';

  @override
  String get openSourceLicences => 'විවෘත මූලාශ්‍ර බලපත්‍ර';

  @override
  String get settingsAbout => 'යෙදුම ගැන';

  @override
  String get versionLabel => 'අනුවාදය';

  @override
  String openLinkTo(String name) {
    return '$name විවෘත කරන්න';
  }
}
