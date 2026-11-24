// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchState {

/// Current search query text (raw user input)
 String get rawQueryText;/// Effective query text (sanitized + converted to Sinhala if Singlish)
/// This is computed once when query changes and used for:
/// - Repository searches (via SearchQuery)
/// - UI highlighting (avoids re-conversion per result row)
 String get effectiveQueryText;/// Recent search history
 List<RecentSearch> get recentSearches;/// Currently selected category in results view
 SearchResultType get selectedResultType;/// Categorized results for "Top Results" tab (grouped by category)
/// null = invalid query (didn't search); an error = the search failed.
/// Loading is [isLoading], not this.
 AsyncValue<GroupedSearchResult?> get groupedResults;/// Full results for the selected category (async state)
/// null = invalid query (didn't search), [] = valid query with no results
 AsyncValue<List<SearchResult>?> get fullResults;/// Whether results are currently loading
 bool get isLoading;/// Selected editions to search (empty = default to BJT)
 Set<String> get selectedEditions;/// Whether to search in Pali text
 bool get searchInPali;/// Whether to search in Sinhala text
 bool get searchInSinhala;/// Search scope using tree node keys (e.g., 'sp', 'dn', 'kn-dhp').
///
/// Empty set = search all content (no scope filter applied).
/// Non-empty = search only within the selected scope (OR logic).
///
/// This is set by:
/// - Quick filter chips (e.g., clicking "Sutta" sets {'sp'})
/// - Refine dialog tree selection (e.g., {'dn', 'mn'})
 Set<String> get scope;/// Whether to search as a phrase (consecutive words) or separate words.
/// - true (DEFAULT) = phrase search (words must be adjacent)
/// - false = separate-word search (words within proximity distance)
 bool get isPhraseSearch;/// Whether to ignore proximity and search anywhere in the same text unit.
/// Only applies when [isPhraseSearch] is false.
/// - true = search for words anywhere in the text (uses very large proximity)
/// - false (DEFAULT) = use [proximityDistance] for proximity constraint
 bool get isAnywhereInText;/// Proximity distance for multi-word separate-word queries.
/// Only applies when [isPhraseSearch] is false and [isAnywhereInText] is false.
/// Default 10 = words within 10 tokens (NEAR/10).
/// Range: 1-100.
 int get proximityDistance;/// Whether the panel was dismissed (user clicked result or close button)
/// Panel reopens when user focuses the search bar again
 bool get isPanelDismissed;/// Whether exact match is enabled (default: false = prefix matching)
/// When false: "සති" matches "සතිපට්ඨානය", "සතිපට්ඨාන", etc.
/// When true: "සති" matches only "සති" exactly
 bool get isExactMatch;/// Result counts per category (for tab badges)
/// Updated independently from categorized results
 Map<SearchResultType, int> get countByResultType;/// Tracks which FTS result groups are expanded (by nodeKey)
/// Used to show/hide secondary matches in grouped FTS results
 Set<String> get expandedFTSGroups;/// Definition results showing their full meaning (by result id)
 Set<String> get expandedDefinitions;/// Dictionary IDs selected for filtering (e.g., {'BUS', 'MS'} for Sinhala).
/// Empty set = "All" (no filter applied).
///
/// Single source of truth for both quick chips and refine dialog,
/// following the same pattern as [scope] for title/FTS filters.
 Set<String> get selectedDictionaryIds;
/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchStateCopyWith<SearchState> get copyWith => _$SearchStateCopyWithImpl<SearchState>(this as SearchState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SearchState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchState&&(identical(other.rawQueryText, _this.rawQueryText) || other.rawQueryText == _this.rawQueryText)&&(identical(other.effectiveQueryText, _this.effectiveQueryText) || other.effectiveQueryText == _this.effectiveQueryText)&&const DeepCollectionEquality().equals(other.recentSearches, _this.recentSearches)&&(identical(other.selectedResultType, _this.selectedResultType) || other.selectedResultType == _this.selectedResultType)&&(identical(other.groupedResults, _this.groupedResults) || other.groupedResults == _this.groupedResults)&&(identical(other.fullResults, _this.fullResults) || other.fullResults == _this.fullResults)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&const DeepCollectionEquality().equals(other.selectedEditions, _this.selectedEditions)&&(identical(other.searchInPali, _this.searchInPali) || other.searchInPali == _this.searchInPali)&&(identical(other.searchInSinhala, _this.searchInSinhala) || other.searchInSinhala == _this.searchInSinhala)&&const DeepCollectionEquality().equals(other.scope, _this.scope)&&(identical(other.isPhraseSearch, _this.isPhraseSearch) || other.isPhraseSearch == _this.isPhraseSearch)&&(identical(other.isAnywhereInText, _this.isAnywhereInText) || other.isAnywhereInText == _this.isAnywhereInText)&&(identical(other.proximityDistance, _this.proximityDistance) || other.proximityDistance == _this.proximityDistance)&&(identical(other.isPanelDismissed, _this.isPanelDismissed) || other.isPanelDismissed == _this.isPanelDismissed)&&(identical(other.isExactMatch, _this.isExactMatch) || other.isExactMatch == _this.isExactMatch)&&const DeepCollectionEquality().equals(other.countByResultType, _this.countByResultType)&&const DeepCollectionEquality().equals(other.expandedFTSGroups, _this.expandedFTSGroups)&&const DeepCollectionEquality().equals(other.expandedDefinitions, _this.expandedDefinitions)&&const DeepCollectionEquality().equals(other.selectedDictionaryIds, _this.selectedDictionaryIds));
}


@override
int get hashCode {
  final _this = this as SearchState;
  return Object.hashAll([runtimeType,_this.rawQueryText,_this.effectiveQueryText,const DeepCollectionEquality().hash(_this.recentSearches),_this.selectedResultType,_this.groupedResults,_this.fullResults,_this.isLoading,const DeepCollectionEquality().hash(_this.selectedEditions),_this.searchInPali,_this.searchInSinhala,const DeepCollectionEquality().hash(_this.scope),_this.isPhraseSearch,_this.isAnywhereInText,_this.proximityDistance,_this.isPanelDismissed,_this.isExactMatch,const DeepCollectionEquality().hash(_this.countByResultType),const DeepCollectionEquality().hash(_this.expandedFTSGroups),const DeepCollectionEquality().hash(_this.expandedDefinitions),const DeepCollectionEquality().hash(_this.selectedDictionaryIds)]);
}

@override
String toString() {
  final _this = this as SearchState;
  return 'SearchState(rawQueryText: ${_this.rawQueryText}, effectiveQueryText: ${_this.effectiveQueryText}, recentSearches: ${_this.recentSearches}, selectedResultType: ${_this.selectedResultType}, groupedResults: ${_this.groupedResults}, fullResults: ${_this.fullResults}, isLoading: ${_this.isLoading}, selectedEditions: ${_this.selectedEditions}, searchInPali: ${_this.searchInPali}, searchInSinhala: ${_this.searchInSinhala}, scope: ${_this.scope}, isPhraseSearch: ${_this.isPhraseSearch}, isAnywhereInText: ${_this.isAnywhereInText}, proximityDistance: ${_this.proximityDistance}, isPanelDismissed: ${_this.isPanelDismissed}, isExactMatch: ${_this.isExactMatch}, countByResultType: ${_this.countByResultType}, expandedFTSGroups: ${_this.expandedFTSGroups}, expandedDefinitions: ${_this.expandedDefinitions}, selectedDictionaryIds: ${_this.selectedDictionaryIds})';
}


}

/// @nodoc
abstract mixin class $SearchStateCopyWith<$Res>  {
  factory $SearchStateCopyWith(SearchState value, $Res Function(SearchState) _then) = _$SearchStateCopyWithImpl;
@useResult
$Res call({
 String rawQueryText, String effectiveQueryText, List<RecentSearch> recentSearches, SearchResultType selectedResultType, AsyncValue<GroupedSearchResult?> groupedResults, AsyncValue<List<SearchResult>?> fullResults, bool isLoading, Set<String> selectedEditions, bool searchInPali, bool searchInSinhala, Set<String> scope, bool isPhraseSearch, bool isAnywhereInText, int proximityDistance, bool isPanelDismissed, bool isExactMatch, Map<SearchResultType, int> countByResultType, Set<String> expandedFTSGroups, Set<String> expandedDefinitions, Set<String> selectedDictionaryIds
});




}
/// @nodoc
class _$SearchStateCopyWithImpl<$Res>
    implements $SearchStateCopyWith<$Res> {
  _$SearchStateCopyWithImpl(this._self, this._then);

  final SearchState _self;
  final $Res Function(SearchState) _then;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rawQueryText = null,Object? effectiveQueryText = null,Object? recentSearches = null,Object? selectedResultType = null,Object? groupedResults = null,Object? fullResults = null,Object? isLoading = null,Object? selectedEditions = null,Object? searchInPali = null,Object? searchInSinhala = null,Object? scope = null,Object? isPhraseSearch = null,Object? isAnywhereInText = null,Object? proximityDistance = null,Object? isPanelDismissed = null,Object? isExactMatch = null,Object? countByResultType = null,Object? expandedFTSGroups = null,Object? expandedDefinitions = null,Object? selectedDictionaryIds = null,}) {
  return _then(SearchState(
rawQueryText: null == rawQueryText ? _self.rawQueryText : rawQueryText // ignore: cast_nullable_to_non_nullable
as String,effectiveQueryText: null == effectiveQueryText ? _self.effectiveQueryText : effectiveQueryText // ignore: cast_nullable_to_non_nullable
as String,recentSearches: null == recentSearches ? _self.recentSearches : recentSearches // ignore: cast_nullable_to_non_nullable
as List<RecentSearch>,selectedResultType: null == selectedResultType ? _self.selectedResultType : selectedResultType // ignore: cast_nullable_to_non_nullable
as SearchResultType,groupedResults: null == groupedResults ? _self.groupedResults : groupedResults // ignore: cast_nullable_to_non_nullable
as AsyncValue<GroupedSearchResult?>,fullResults: null == fullResults ? _self.fullResults : fullResults // ignore: cast_nullable_to_non_nullable
as AsyncValue<List<SearchResult>?>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,selectedEditions: null == selectedEditions ? _self.selectedEditions : selectedEditions // ignore: cast_nullable_to_non_nullable
as Set<String>,searchInPali: null == searchInPali ? _self.searchInPali : searchInPali // ignore: cast_nullable_to_non_nullable
as bool,searchInSinhala: null == searchInSinhala ? _self.searchInSinhala : searchInSinhala // ignore: cast_nullable_to_non_nullable
as bool,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as Set<String>,isPhraseSearch: null == isPhraseSearch ? _self.isPhraseSearch : isPhraseSearch // ignore: cast_nullable_to_non_nullable
as bool,isAnywhereInText: null == isAnywhereInText ? _self.isAnywhereInText : isAnywhereInText // ignore: cast_nullable_to_non_nullable
as bool,proximityDistance: null == proximityDistance ? _self.proximityDistance : proximityDistance // ignore: cast_nullable_to_non_nullable
as int,isPanelDismissed: null == isPanelDismissed ? _self.isPanelDismissed : isPanelDismissed // ignore: cast_nullable_to_non_nullable
as bool,isExactMatch: null == isExactMatch ? _self.isExactMatch : isExactMatch // ignore: cast_nullable_to_non_nullable
as bool,countByResultType: null == countByResultType ? _self.countByResultType : countByResultType // ignore: cast_nullable_to_non_nullable
as Map<SearchResultType, int>,expandedFTSGroups: null == expandedFTSGroups ? _self.expandedFTSGroups : expandedFTSGroups // ignore: cast_nullable_to_non_nullable
as Set<String>,expandedDefinitions: null == expandedDefinitions ? _self.expandedDefinitions : expandedDefinitions // ignore: cast_nullable_to_non_nullable
as Set<String>,selectedDictionaryIds: null == selectedDictionaryIds ? _self.selectedDictionaryIds : selectedDictionaryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchState].
extension SearchStatePatterns on SearchState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchState value)  $default,){
final _that = this;
switch (_that) {
case _SearchState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchState value)?  $default,){
final _that = this;
switch (_that) {
case _SearchState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rawQueryText,  String effectiveQueryText,  List<RecentSearch> recentSearches,  SearchResultType selectedResultType,  AsyncValue<GroupedSearchResult?> groupedResults,  AsyncValue<List<SearchResult>?> fullResults,  bool isLoading,  Set<String> selectedEditions,  bool searchInPali,  bool searchInSinhala,  Set<String> scope,  bool isPhraseSearch,  bool isAnywhereInText,  int proximityDistance,  bool isPanelDismissed,  bool isExactMatch,  Map<SearchResultType, int> countByResultType,  Set<String> expandedFTSGroups,  Set<String> expandedDefinitions,  Set<String> selectedDictionaryIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchState() when $default != null:
return $default(_that.rawQueryText,_that.effectiveQueryText,_that.recentSearches,_that.selectedResultType,_that.groupedResults,_that.fullResults,_that.isLoading,_that.selectedEditions,_that.searchInPali,_that.searchInSinhala,_that.scope,_that.isPhraseSearch,_that.isAnywhereInText,_that.proximityDistance,_that.isPanelDismissed,_that.isExactMatch,_that.countByResultType,_that.expandedFTSGroups,_that.expandedDefinitions,_that.selectedDictionaryIds);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rawQueryText,  String effectiveQueryText,  List<RecentSearch> recentSearches,  SearchResultType selectedResultType,  AsyncValue<GroupedSearchResult?> groupedResults,  AsyncValue<List<SearchResult>?> fullResults,  bool isLoading,  Set<String> selectedEditions,  bool searchInPali,  bool searchInSinhala,  Set<String> scope,  bool isPhraseSearch,  bool isAnywhereInText,  int proximityDistance,  bool isPanelDismissed,  bool isExactMatch,  Map<SearchResultType, int> countByResultType,  Set<String> expandedFTSGroups,  Set<String> expandedDefinitions,  Set<String> selectedDictionaryIds)  $default,) {final _that = this;
switch (_that) {
case _SearchState():
return $default(_that.rawQueryText,_that.effectiveQueryText,_that.recentSearches,_that.selectedResultType,_that.groupedResults,_that.fullResults,_that.isLoading,_that.selectedEditions,_that.searchInPali,_that.searchInSinhala,_that.scope,_that.isPhraseSearch,_that.isAnywhereInText,_that.proximityDistance,_that.isPanelDismissed,_that.isExactMatch,_that.countByResultType,_that.expandedFTSGroups,_that.expandedDefinitions,_that.selectedDictionaryIds);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rawQueryText,  String effectiveQueryText,  List<RecentSearch> recentSearches,  SearchResultType selectedResultType,  AsyncValue<GroupedSearchResult?> groupedResults,  AsyncValue<List<SearchResult>?> fullResults,  bool isLoading,  Set<String> selectedEditions,  bool searchInPali,  bool searchInSinhala,  Set<String> scope,  bool isPhraseSearch,  bool isAnywhereInText,  int proximityDistance,  bool isPanelDismissed,  bool isExactMatch,  Map<SearchResultType, int> countByResultType,  Set<String> expandedFTSGroups,  Set<String> expandedDefinitions,  Set<String> selectedDictionaryIds)?  $default,) {final _that = this;
switch (_that) {
case _SearchState() when $default != null:
return $default(_that.rawQueryText,_that.effectiveQueryText,_that.recentSearches,_that.selectedResultType,_that.groupedResults,_that.fullResults,_that.isLoading,_that.selectedEditions,_that.searchInPali,_that.searchInSinhala,_that.scope,_that.isPhraseSearch,_that.isAnywhereInText,_that.proximityDistance,_that.isPanelDismissed,_that.isExactMatch,_that.countByResultType,_that.expandedFTSGroups,_that.expandedDefinitions,_that.selectedDictionaryIds);case _:
  return null;

}
}

}

/// @nodoc


class _SearchState extends SearchState {
  const _SearchState({this.rawQueryText = '', this.effectiveQueryText = '',  List<RecentSearch> recentSearches = const [], this.selectedResultType = SearchResultType.topResults, this.groupedResults = const AsyncValue.data(null), this.fullResults = const AsyncValue.data(null), this.isLoading = false,  Set<String> selectedEditions = const {}, this.searchInPali = true, this.searchInSinhala = true,  Set<String> scope = const {}, this.isPhraseSearch = true, this.isAnywhereInText = false, this.proximityDistance = 10, this.isPanelDismissed = false, this.isExactMatch = false,  Map<SearchResultType, int> countByResultType = const {},  Set<String> expandedFTSGroups = const {},  Set<String> expandedDefinitions = const {},  Set<String> selectedDictionaryIds = const {}}): _recentSearches = recentSearches,_selectedEditions = selectedEditions,_scope = scope,_countByResultType = countByResultType,_expandedFTSGroups = expandedFTSGroups,_expandedDefinitions = expandedDefinitions,_selectedDictionaryIds = selectedDictionaryIds,super._();
  

/// Current search query text (raw user input)
@override@JsonKey() final  String rawQueryText;
/// Effective query text (sanitized + converted to Sinhala if Singlish)
/// This is computed once when query changes and used for:
/// - Repository searches (via SearchQuery)
/// - UI highlighting (avoids re-conversion per result row)
@override@JsonKey() final  String effectiveQueryText;
/// Recent search history
 final  List<RecentSearch> _recentSearches;
/// Recent search history
@override@JsonKey() List<RecentSearch> get recentSearches {
  if (_recentSearches is EqualUnmodifiableListView) return _recentSearches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentSearches);
}

/// Currently selected category in results view
@override@JsonKey() final  SearchResultType selectedResultType;
/// Categorized results for "Top Results" tab (grouped by category)
/// null = invalid query (didn't search); an error = the search failed.
/// Loading is [isLoading], not this.
@override@JsonKey() final  AsyncValue<GroupedSearchResult?> groupedResults;
/// Full results for the selected category (async state)
/// null = invalid query (didn't search), [] = valid query with no results
@override@JsonKey() final  AsyncValue<List<SearchResult>?> fullResults;
/// Whether results are currently loading
@override@JsonKey() final  bool isLoading;
/// Selected editions to search (empty = default to BJT)
 final  Set<String> _selectedEditions;
/// Selected editions to search (empty = default to BJT)
@override@JsonKey() Set<String> get selectedEditions {
  if (_selectedEditions is EqualUnmodifiableSetView) return _selectedEditions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedEditions);
}

/// Whether to search in Pali text
@override@JsonKey() final  bool searchInPali;
/// Whether to search in Sinhala text
@override@JsonKey() final  bool searchInSinhala;
/// Search scope using tree node keys (e.g., 'sp', 'dn', 'kn-dhp').
///
/// Empty set = search all content (no scope filter applied).
/// Non-empty = search only within the selected scope (OR logic).
///
/// This is set by:
/// - Quick filter chips (e.g., clicking "Sutta" sets {'sp'})
/// - Refine dialog tree selection (e.g., {'dn', 'mn'})
 final  Set<String> _scope;
/// Search scope using tree node keys (e.g., 'sp', 'dn', 'kn-dhp').
///
/// Empty set = search all content (no scope filter applied).
/// Non-empty = search only within the selected scope (OR logic).
///
/// This is set by:
/// - Quick filter chips (e.g., clicking "Sutta" sets {'sp'})
/// - Refine dialog tree selection (e.g., {'dn', 'mn'})
@override@JsonKey() Set<String> get scope {
  if (_scope is EqualUnmodifiableSetView) return _scope;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_scope);
}

/// Whether to search as a phrase (consecutive words) or separate words.
/// - true (DEFAULT) = phrase search (words must be adjacent)
/// - false = separate-word search (words within proximity distance)
@override@JsonKey() final  bool isPhraseSearch;
/// Whether to ignore proximity and search anywhere in the same text unit.
/// Only applies when [isPhraseSearch] is false.
/// - true = search for words anywhere in the text (uses very large proximity)
/// - false (DEFAULT) = use [proximityDistance] for proximity constraint
@override@JsonKey() final  bool isAnywhereInText;
/// Proximity distance for multi-word separate-word queries.
/// Only applies when [isPhraseSearch] is false and [isAnywhereInText] is false.
/// Default 10 = words within 10 tokens (NEAR/10).
/// Range: 1-100.
@override@JsonKey() final  int proximityDistance;
/// Whether the panel was dismissed (user clicked result or close button)
/// Panel reopens when user focuses the search bar again
@override@JsonKey() final  bool isPanelDismissed;
/// Whether exact match is enabled (default: false = prefix matching)
/// When false: "සති" matches "සතිපට්ඨානය", "සතිපට්ඨාන", etc.
/// When true: "සති" matches only "සති" exactly
@override@JsonKey() final  bool isExactMatch;
/// Result counts per category (for tab badges)
/// Updated independently from categorized results
 final  Map<SearchResultType, int> _countByResultType;
/// Result counts per category (for tab badges)
/// Updated independently from categorized results
@override@JsonKey() Map<SearchResultType, int> get countByResultType {
  if (_countByResultType is EqualUnmodifiableMapView) return _countByResultType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_countByResultType);
}

/// Tracks which FTS result groups are expanded (by nodeKey)
/// Used to show/hide secondary matches in grouped FTS results
 final  Set<String> _expandedFTSGroups;
/// Tracks which FTS result groups are expanded (by nodeKey)
/// Used to show/hide secondary matches in grouped FTS results
@override@JsonKey() Set<String> get expandedFTSGroups {
  if (_expandedFTSGroups is EqualUnmodifiableSetView) return _expandedFTSGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_expandedFTSGroups);
}

/// Definition results showing their full meaning (by result id)
 final  Set<String> _expandedDefinitions;
/// Definition results showing their full meaning (by result id)
@override@JsonKey() Set<String> get expandedDefinitions {
  if (_expandedDefinitions is EqualUnmodifiableSetView) return _expandedDefinitions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_expandedDefinitions);
}

/// Dictionary IDs selected for filtering (e.g., {'BUS', 'MS'} for Sinhala).
/// Empty set = "All" (no filter applied).
///
/// Single source of truth for both quick chips and refine dialog,
/// following the same pattern as [scope] for title/FTS filters.
 final  Set<String> _selectedDictionaryIds;
/// Dictionary IDs selected for filtering (e.g., {'BUS', 'MS'} for Sinhala).
/// Empty set = "All" (no filter applied).
///
/// Single source of truth for both quick chips and refine dialog,
/// following the same pattern as [scope] for title/FTS filters.
@override@JsonKey() Set<String> get selectedDictionaryIds {
  if (_selectedDictionaryIds is EqualUnmodifiableSetView) return _selectedDictionaryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedDictionaryIds);
}


/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchStateCopyWith<_SearchState> get copyWith => __$SearchStateCopyWithImpl<_SearchState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchState&&(identical(other.rawQueryText, rawQueryText) || other.rawQueryText == rawQueryText)&&(identical(other.effectiveQueryText, effectiveQueryText) || other.effectiveQueryText == effectiveQueryText)&&const DeepCollectionEquality().equals(other.recentSearches, _recentSearches)&&(identical(other.selectedResultType, selectedResultType) || other.selectedResultType == selectedResultType)&&(identical(other.groupedResults, groupedResults) || other.groupedResults == groupedResults)&&(identical(other.fullResults, fullResults) || other.fullResults == fullResults)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.selectedEditions, _selectedEditions)&&(identical(other.searchInPali, searchInPali) || other.searchInPali == searchInPali)&&(identical(other.searchInSinhala, searchInSinhala) || other.searchInSinhala == searchInSinhala)&&const DeepCollectionEquality().equals(other.scope, _scope)&&(identical(other.isPhraseSearch, isPhraseSearch) || other.isPhraseSearch == isPhraseSearch)&&(identical(other.isAnywhereInText, isAnywhereInText) || other.isAnywhereInText == isAnywhereInText)&&(identical(other.proximityDistance, proximityDistance) || other.proximityDistance == proximityDistance)&&(identical(other.isPanelDismissed, isPanelDismissed) || other.isPanelDismissed == isPanelDismissed)&&(identical(other.isExactMatch, isExactMatch) || other.isExactMatch == isExactMatch)&&const DeepCollectionEquality().equals(other.countByResultType, _countByResultType)&&const DeepCollectionEquality().equals(other.expandedFTSGroups, _expandedFTSGroups)&&const DeepCollectionEquality().equals(other.expandedDefinitions, _expandedDefinitions)&&const DeepCollectionEquality().equals(other.selectedDictionaryIds, _selectedDictionaryIds));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,rawQueryText,effectiveQueryText,const DeepCollectionEquality().hash(_recentSearches),selectedResultType,groupedResults,fullResults,isLoading,const DeepCollectionEquality().hash(_selectedEditions),searchInPali,searchInSinhala,const DeepCollectionEquality().hash(_scope),isPhraseSearch,isAnywhereInText,proximityDistance,isPanelDismissed,isExactMatch,const DeepCollectionEquality().hash(_countByResultType),const DeepCollectionEquality().hash(_expandedFTSGroups),const DeepCollectionEquality().hash(_expandedDefinitions),const DeepCollectionEquality().hash(_selectedDictionaryIds)]);
}

@override
String toString() {
    return 'SearchState(rawQueryText: $rawQueryText, effectiveQueryText: $effectiveQueryText, recentSearches: $recentSearches, selectedResultType: $selectedResultType, groupedResults: $groupedResults, fullResults: $fullResults, isLoading: $isLoading, selectedEditions: $selectedEditions, searchInPali: $searchInPali, searchInSinhala: $searchInSinhala, scope: $scope, isPhraseSearch: $isPhraseSearch, isAnywhereInText: $isAnywhereInText, proximityDistance: $proximityDistance, isPanelDismissed: $isPanelDismissed, isExactMatch: $isExactMatch, countByResultType: $countByResultType, expandedFTSGroups: $expandedFTSGroups, expandedDefinitions: $expandedDefinitions, selectedDictionaryIds: $selectedDictionaryIds)';
}


}

/// @nodoc
abstract mixin class _$SearchStateCopyWith<$Res> implements $SearchStateCopyWith<$Res> {
  factory _$SearchStateCopyWith(_SearchState value, $Res Function(_SearchState) _then) = __$SearchStateCopyWithImpl;
@override @useResult
$Res call({
 String rawQueryText, String effectiveQueryText, List<RecentSearch> recentSearches, SearchResultType selectedResultType, AsyncValue<GroupedSearchResult?> groupedResults, AsyncValue<List<SearchResult>?> fullResults, bool isLoading, Set<String> selectedEditions, bool searchInPali, bool searchInSinhala, Set<String> scope, bool isPhraseSearch, bool isAnywhereInText, int proximityDistance, bool isPanelDismissed, bool isExactMatch, Map<SearchResultType, int> countByResultType, Set<String> expandedFTSGroups, Set<String> expandedDefinitions, Set<String> selectedDictionaryIds
});




}
/// @nodoc
class __$SearchStateCopyWithImpl<$Res>
    implements _$SearchStateCopyWith<$Res> {
  __$SearchStateCopyWithImpl(this._self, this._then);

  final _SearchState _self;
  final $Res Function(_SearchState) _then;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rawQueryText = null,Object? effectiveQueryText = null,Object? recentSearches = null,Object? selectedResultType = null,Object? groupedResults = null,Object? fullResults = null,Object? isLoading = null,Object? selectedEditions = null,Object? searchInPali = null,Object? searchInSinhala = null,Object? scope = null,Object? isPhraseSearch = null,Object? isAnywhereInText = null,Object? proximityDistance = null,Object? isPanelDismissed = null,Object? isExactMatch = null,Object? countByResultType = null,Object? expandedFTSGroups = null,Object? expandedDefinitions = null,Object? selectedDictionaryIds = null,}) {
  return _then(_SearchState(
rawQueryText: null == rawQueryText ? _self.rawQueryText : rawQueryText // ignore: cast_nullable_to_non_nullable
as String,effectiveQueryText: null == effectiveQueryText ? _self.effectiveQueryText : effectiveQueryText // ignore: cast_nullable_to_non_nullable
as String,recentSearches: null == recentSearches ? _self._recentSearches : recentSearches // ignore: cast_nullable_to_non_nullable
as List<RecentSearch>,selectedResultType: null == selectedResultType ? _self.selectedResultType : selectedResultType // ignore: cast_nullable_to_non_nullable
as SearchResultType,groupedResults: null == groupedResults ? _self.groupedResults : groupedResults // ignore: cast_nullable_to_non_nullable
as AsyncValue<GroupedSearchResult?>,fullResults: null == fullResults ? _self.fullResults : fullResults // ignore: cast_nullable_to_non_nullable
as AsyncValue<List<SearchResult>?>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,selectedEditions: null == selectedEditions ? _self._selectedEditions : selectedEditions // ignore: cast_nullable_to_non_nullable
as Set<String>,searchInPali: null == searchInPali ? _self.searchInPali : searchInPali // ignore: cast_nullable_to_non_nullable
as bool,searchInSinhala: null == searchInSinhala ? _self.searchInSinhala : searchInSinhala // ignore: cast_nullable_to_non_nullable
as bool,scope: null == scope ? _self._scope : scope // ignore: cast_nullable_to_non_nullable
as Set<String>,isPhraseSearch: null == isPhraseSearch ? _self.isPhraseSearch : isPhraseSearch // ignore: cast_nullable_to_non_nullable
as bool,isAnywhereInText: null == isAnywhereInText ? _self.isAnywhereInText : isAnywhereInText // ignore: cast_nullable_to_non_nullable
as bool,proximityDistance: null == proximityDistance ? _self.proximityDistance : proximityDistance // ignore: cast_nullable_to_non_nullable
as int,isPanelDismissed: null == isPanelDismissed ? _self.isPanelDismissed : isPanelDismissed // ignore: cast_nullable_to_non_nullable
as bool,isExactMatch: null == isExactMatch ? _self.isExactMatch : isExactMatch // ignore: cast_nullable_to_non_nullable
as bool,countByResultType: null == countByResultType ? _self._countByResultType : countByResultType // ignore: cast_nullable_to_non_nullable
as Map<SearchResultType, int>,expandedFTSGroups: null == expandedFTSGroups ? _self._expandedFTSGroups : expandedFTSGroups // ignore: cast_nullable_to_non_nullable
as Set<String>,expandedDefinitions: null == expandedDefinitions ? _self._expandedDefinitions : expandedDefinitions // ignore: cast_nullable_to_non_nullable
as Set<String>,selectedDictionaryIds: null == selectedDictionaryIds ? _self._selectedDictionaryIds : selectedDictionaryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

// dart format on
