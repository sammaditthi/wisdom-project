// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sammaditthi';

  @override
  String get readerTitle => 'Reader';

  @override
  String get showNavigator => 'Show navigator';

  @override
  String get hideNavigator => 'Hide navigator';

  @override
  String get layoutPaliOnly => 'Pali only';

  @override
  String get layoutSinhalaOnly => 'Sinhala only';

  @override
  String currentLayout(String name) {
    return 'Layout: $name';
  }

  @override
  String get layoutSideBySide => 'Side by side';

  @override
  String get layoutStacked => 'Stacked';

  @override
  String get paliLanguageLabel => 'Pāli';

  @override
  String get sinhalaLanguageLabel => 'සිංහල';

  @override
  String get loading => 'Loading...';

  @override
  String get errorLoadingContent => 'Error loading content';

  @override
  String get errorLoadingTree => 'Error loading navigation tree';

  @override
  String get searchPlaceholder => 'Search Tipitaka...';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get expandAll => 'Expand all';

  @override
  String get collapseAll => 'Collapse all';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get appLanguage => 'App language';

  @override
  String get contentLanguage => 'Content language';

  @override
  String get paliLetters => 'Pali letters';

  @override
  String get paliStandardLigatures => 'Standard ligatures';

  @override
  String get paliSpecialLetters => 'Special Pali letters';

  @override
  String get paliTouching => 'Touching letters';

  @override
  String get appLayout => 'App layout';

  @override
  String get hideNavigationBar => 'Hide navigation bar';

  @override
  String get fontSize => 'Font size';

  @override
  String get fontSizeSmall => 'Small';

  @override
  String get fontSizeMedium => 'Medium';

  @override
  String get fontSizeLarge => 'Large';

  @override
  String get fontSizeExtraLarge => 'Extra large';

  @override
  String get close => 'Close';

  @override
  String get searchHint => 'Search';

  @override
  String get isExactMatchToggle => 'Exact word match';

  @override
  String get refineSearch => 'Refine search';

  @override
  String get refine => 'Refine';

  @override
  String get expand => 'Expand';

  @override
  String get collapse => 'Collapse';

  @override
  String get scope => 'Scope';

  @override
  String get searchLanguageLabel => 'Language';

  @override
  String get searchTabTopResults => 'Top Results';

  @override
  String get searchTabTitles => 'Titles';

  @override
  String get searchTabFullText => 'Full Text';

  @override
  String get searchTabDefinitions => 'Definitions';

  @override
  String get searchTabReference => 'Reference';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get removeRecentSearch => 'Remove from recent searches';

  @override
  String viewMore(int count) {
    return 'View $count more';
  }

  @override
  String get showLess => 'Show less';

  @override
  String get seeAll => 'See all';

  @override
  String viewingResults(int shown, int total) {
    return 'Viewing $shown out of $total results';
  }

  @override
  String get reset => 'Reset';

  @override
  String get clear => 'Clear';

  @override
  String get clearAll => 'Clear all';

  @override
  String get scopeAll => 'All';

  @override
  String get scopeSutta => 'Sutta';

  @override
  String get scopeVinaya => 'Vinaya';

  @override
  String get scopeAbhidhamma => 'Abhidhamma';

  @override
  String get scopeCommentaries => 'Commentaries';

  @override
  String get scopeOther => 'Other';

  @override
  String get anywhereInText => 'Anywhere in the same text';

  @override
  String get openSearch => 'Search';

  @override
  String get matchOptions => 'Match options';

  @override
  String get matchEachWord => 'How each word matches';

  @override
  String get matchStartsWith => 'Starts with';

  @override
  String get matchStartsWithHint => 'Finds the word and its longer forms';

  @override
  String get matchWholeWord => 'Exact word';

  @override
  String get matchWholeWordHint => 'Finds only the exact word';

  @override
  String get matchHowWordsSit => 'How words sit together';

  @override
  String get matchPhrase => 'As a phrase';

  @override
  String get matchPhraseHint => 'Finds the words together, in the order typed';

  @override
  String get matchPhraseShort => 'Phrase';

  @override
  String get matchAnywhereHint => 'Finds the words in any order';

  @override
  String get matchAnywhereShort => 'Anywhere';

  @override
  String get matchNear => 'Near each other';

  @override
  String get matchNearHint => 'Finds the words close together';

  @override
  String matchNearShort(int count) {
    return 'Gap $count';
  }

  @override
  String matchNearWithin(int count) {
    return 'Within $count words';
  }

  @override
  String get smallerGap => 'Smaller gap';

  @override
  String get largerGap => 'Larger gap';

  @override
  String get resetToDefault => 'Reset to default';

  @override
  String get noDefinitionsFound => 'No definitions found';

  @override
  String get dictionaryLookup => 'Dictionary';

  @override
  String get errorLoadingDefinitions => 'Error loading definitions';

  @override
  String get commentary => 'Commentary';

  @override
  String get rootText => 'Root text';

  @override
  String get scrollToBeginning => 'Go to beginning';

  @override
  String goToSutta(String name) {
    return 'Go to: $name';
  }

  @override
  String get findInPage => 'Find in page';

  @override
  String get noInPageMatches => '0 / 0';

  @override
  String get previousMatch => 'Previous match';

  @override
  String get nextMatch => 'Next match';

  @override
  String get backspace => 'Backspace';

  @override
  String get dictFilterAll => 'All';

  @override
  String get dictFilterSinhala => 'Sinhala';

  @override
  String get dictFilterEnglish => 'English';

  @override
  String get dictRefineTitle => 'Refine dictionaries';

  @override
  String get dictRefineSectionLabel => 'DICTIONARIES';

  @override
  String get done => 'Done';

  @override
  String get readMore => 'Read more';

  @override
  String get couldNotOpenLink => 'Could not open link';

  @override
  String get statusOfflineTitle => 'Cannot reach the server';

  @override
  String get statusOfflineDescription => 'Check your connection and try again.';

  @override
  String get errorLoadingSearch => 'Error loading results';

  @override
  String get statusErrorDescription => 'Please try again in a moment.';

  @override
  String get statusInvalidQuery => 'Enter a valid search query';

  @override
  String statusNoResultsForCategory(String category) {
    return 'No $category found';
  }

  @override
  String get statusSelectSuttaToRead =>
      'Select a text from the navigator to begin reading';

  @override
  String get statusNoContentToDisplay => 'No content to display';

  @override
  String get statusNoTreeContent => 'No content available';

  @override
  String get navHome => 'Home';

  @override
  String get navReader => 'Reader';

  @override
  String get navResearch => 'Research';

  @override
  String get navNotes => 'Notes';

  @override
  String get researchNewChat => 'New chat';

  @override
  String get researchEmptyState => 'Ask anything about the Pali Canon.';

  @override
  String get researchInputHint => 'Ask a question about the suttas…';

  @override
  String get researchSend => 'Send';

  @override
  String get researchModeFast => 'Fast';

  @override
  String get researchModeFastHint => 'Fastest answers';

  @override
  String get researchModeThinking => 'Thinking';

  @override
  String get researchModeThinkingHint => 'Deeper reasoning';

  @override
  String get researchModeTooltip => 'Answer mode';

  @override
  String get researchBusyFast => 'Answering…';

  @override
  String get researchBusyThinking => 'Thinking…';

  @override
  String get researchCitedSource => 'Cited source';

  @override
  String get researchMatchedPassage => 'Matched passage · SuttaCentral';

  @override
  String get researchOtherSources => 'Other sources';

  @override
  String get researchOpenInReader => 'Open in reader';

  @override
  String get researchCitationNotLinked =>
      'This source isn\'t linked to this edition yet.';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get researchRetry => 'Retry';

  @override
  String get researchErrorOffline =>
      'Couldn\'t connect. Check your internet and try again.';

  @override
  String get researchErrorTimeout =>
      'This is taking longer than usual. Please try again.';

  @override
  String get researchErrorRateLimited =>
      'Research has had a lot of questions just now. Please try again in a few minutes.';

  @override
  String get researchErrorRateLimitedThinking =>
      'Research has had a lot of questions just now. Try again in a few minutes, or switch to Fast mode.';

  @override
  String get researchErrorServiceBusy =>
      'Research is busy right now. Please try again in a moment.';

  @override
  String get researchErrorNotAuthorised =>
      'Research isn\'t available right now. Please try again later.';

  @override
  String get researchErrorCannotAnswer =>
      'I couldn\'t find an answer to that in the canon. Try rephrasing, or ask about a specific teaching.';

  @override
  String get researchErrorServerError =>
      'Something went wrong on our end. Please try again.';

  @override
  String get researchErrorResourceLimit =>
      'That answer took too much to finish. Please try again — a simpler question may help.';

  @override
  String get researchQuestionNotAnswered =>
      'This question wasn\'t answered yet.';

  @override
  String get researchRecent => 'Recent';

  @override
  String get researchNoRecentChats => 'No chats yet';

  @override
  String get researchChatLimitReached =>
      'This chat has reached its length limit. Start a new chat to continue.';

  @override
  String get researchDeleteChat => 'Delete chat';

  @override
  String get relativeTimeJustNow => 'Just now';

  @override
  String relativeTimeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String relativeTimeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get relativeTimeYesterday => 'Yesterday';

  @override
  String relativeTimeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
    );
    return '$_temp0';
  }

  @override
  String get databaseInstallTitle => 'Downloading the texts';

  @override
  String get databaseInstallDescription =>
      'The texts and the dictionary are saved on this device, so they open quickly and work without an internet connection. The app opens when the download finishes.';

  @override
  String get databaseInstallPreparing => 'Getting ready…';

  @override
  String databaseInstallProgress(int percent, int received, int total) {
    return '$percent% · $received MB of $total MB';
  }

  @override
  String get databaseInstallUnsupportedTitle =>
      'This browser cannot store the texts';

  @override
  String get databaseInstallUnsupportedDescription =>
      'Chrome and Edge are supported today.';

  @override
  String get databaseInstallOutOfSpaceTitle => 'Not enough space';

  @override
  String get databaseInstallOutOfSpaceDescription =>
      'There is not enough space on this device for the texts. Free some space and try again.';

  @override
  String get databaseInstallFailedTitle => 'The download did not finish';

  @override
  String get databaseInstallFailedDescription =>
      'Check your connection and try again. To reset, open Chrome\'s site settings → Delete data.';

  @override
  String get databaseInstallRetry => 'Try again';

  @override
  String get readInApp => 'Read in the app';

  @override
  String get moreOptions => 'More options';

  @override
  String get share => 'Share';

  @override
  String get openAsWebPage => 'Open as web page';

  @override
  String get readerSettings => 'Reader settings';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsAnumodana => 'Anumodanā';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSample => 'Sample';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeDarkComingSoon => 'A dark theme is coming soon.';

  @override
  String get appLanguageHint => 'Menus, buttons and messages.';

  @override
  String get contentLanguageHint =>
      'Names of books and suttas in the navigator, tabs, breadcrumbs and search.';

  @override
  String get paliLettersHint =>
      'How joined letters look wherever Pali appears.';

  @override
  String get anumodanaLineage => 'The Bhāṇaka lineage';

  @override
  String get anumodanaLineageBody =>
      'To the lineages of reciters who held the Tipiṭaka in memory and passed it on, generation by generation.';

  @override
  String get anumodanaTextSources => 'Text sources';

  @override
  String get anumodanaBjtUse => 'The Pali text and its Sinhala translation.';

  @override
  String get anumodanaTipitakaLkUse =>
      'The digital edition the text and commentaries come from. Buddha Jayanti Pali text under CC BY-ND 4.0.';

  @override
  String get anumodanaSuttaCentralUse =>
      'The English translations Research quotes, and the sutta numbers search understands. CC0 1.0.';

  @override
  String get anumodanaDictionaries => 'Dictionaries';

  @override
  String get anumodanaDictionariesHint =>
      'Tap a Pali word to look it up, or search under Definitions. Listed alphabetically.';

  @override
  String get anumodanaDictGroupSinhala => 'Pali – Sinhala';

  @override
  String get anumodanaDictGroupEnglish => 'Pali – English';

  @override
  String get anumodanaDpdLicence =>
      'Bodhirasa Bhikkhu, Digital Pāḷi Dictionary v0.2.20250709. CC BY-NC-SA 4.0.';

  @override
  String get anumodanaThanks => 'Thanks';

  @override
  String get anumodanaThanksBody =>
      'To everyone who gave their time, skill and advice to build this app.';

  @override
  String get anumodanaLicences => 'Licences';

  @override
  String get openSourceLicences => 'Open-source licences';

  @override
  String get settingsAbout => 'About';

  @override
  String get versionLabel => 'Version';

  @override
  String openLinkTo(String name) {
    return 'Open $name';
  }
}
