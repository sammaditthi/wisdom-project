// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchQuery {

/// The search query text
 String get queryText;/// Whether to require exact word match (no prefix matching)
/// Default false = prefix matching enabled (e.g., "සති" matches "සතිපට්ඨානය")
 bool get isExactMatch;/// Editions to search within (e.g., {'bjt', 'sc'})
/// If empty, searches all available editions
 Set<String> get editionIds;/// Whether to search in Pali text
 bool get searchInPali;/// Whether to search in Sinhala text
 bool get searchInSinhala;/// Search scope using tree node keys (e.g., 'sp', 'dn', 'kn-dhp').
///
/// Empty set = search all content (no scope filter applied).
/// Non-empty = search only within the selected scope (OR logic).
///
/// Examples:
/// - {} = search everything
/// - {'sp'} = search only Sutta Pitaka
/// - {'dn', 'mn'} = search Digha Nikaya OR Majjhima Nikaya
/// - {'atta-vp', 'atta-sp', 'atta-ap'} = search all Commentaries
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
 int get proximityDistance;/// Dictionary IDs to filter definitions by (e.g., {'BUS', 'MS'} for Sinhala).
/// Empty set = no restriction (search all dictionaries).
 Set<String> get selectedDictionaryIds;/// Maximum number of results to return
 int get limit;/// Offset for pagination
 int get offset;
/// Create a copy of SearchQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchQueryCopyWith<SearchQuery> get copyWith => _$SearchQueryCopyWithImpl<SearchQuery>(this as SearchQuery, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SearchQuery;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchQuery&&(identical(other.queryText, _this.queryText) || other.queryText == _this.queryText)&&(identical(other.isExactMatch, _this.isExactMatch) || other.isExactMatch == _this.isExactMatch)&&const DeepCollectionEquality().equals(other.editionIds, _this.editionIds)&&(identical(other.searchInPali, _this.searchInPali) || other.searchInPali == _this.searchInPali)&&(identical(other.searchInSinhala, _this.searchInSinhala) || other.searchInSinhala == _this.searchInSinhala)&&const DeepCollectionEquality().equals(other.scope, _this.scope)&&(identical(other.isPhraseSearch, _this.isPhraseSearch) || other.isPhraseSearch == _this.isPhraseSearch)&&(identical(other.isAnywhereInText, _this.isAnywhereInText) || other.isAnywhereInText == _this.isAnywhereInText)&&(identical(other.proximityDistance, _this.proximityDistance) || other.proximityDistance == _this.proximityDistance)&&const DeepCollectionEquality().equals(other.selectedDictionaryIds, _this.selectedDictionaryIds)&&(identical(other.limit, _this.limit) || other.limit == _this.limit)&&(identical(other.offset, _this.offset) || other.offset == _this.offset));
}


@override
int get hashCode {
  final _this = this as SearchQuery;
  return Object.hash(runtimeType,_this.queryText,_this.isExactMatch,const DeepCollectionEquality().hash(_this.editionIds),_this.searchInPali,_this.searchInSinhala,const DeepCollectionEquality().hash(_this.scope),_this.isPhraseSearch,_this.isAnywhereInText,_this.proximityDistance,const DeepCollectionEquality().hash(_this.selectedDictionaryIds),_this.limit,_this.offset);
}

@override
String toString() {
  final _this = this as SearchQuery;
  return 'SearchQuery(queryText: ${_this.queryText}, isExactMatch: ${_this.isExactMatch}, editionIds: ${_this.editionIds}, searchInPali: ${_this.searchInPali}, searchInSinhala: ${_this.searchInSinhala}, scope: ${_this.scope}, isPhraseSearch: ${_this.isPhraseSearch}, isAnywhereInText: ${_this.isAnywhereInText}, proximityDistance: ${_this.proximityDistance}, selectedDictionaryIds: ${_this.selectedDictionaryIds}, limit: ${_this.limit}, offset: ${_this.offset})';
}


}

/// @nodoc
abstract mixin class $SearchQueryCopyWith<$Res>  {
  factory $SearchQueryCopyWith(SearchQuery value, $Res Function(SearchQuery) _then) = _$SearchQueryCopyWithImpl;
@useResult
$Res call({
 String queryText, bool isExactMatch, Set<String> editionIds, bool searchInPali, bool searchInSinhala, Set<String> scope, bool isPhraseSearch, bool isAnywhereInText, int proximityDistance, Set<String> selectedDictionaryIds, int limit, int offset
});




}
/// @nodoc
class _$SearchQueryCopyWithImpl<$Res>
    implements $SearchQueryCopyWith<$Res> {
  _$SearchQueryCopyWithImpl(this._self, this._then);

  final SearchQuery _self;
  final $Res Function(SearchQuery) _then;

/// Create a copy of SearchQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? queryText = null,Object? isExactMatch = null,Object? editionIds = null,Object? searchInPali = null,Object? searchInSinhala = null,Object? scope = null,Object? isPhraseSearch = null,Object? isAnywhereInText = null,Object? proximityDistance = null,Object? selectedDictionaryIds = null,Object? limit = null,Object? offset = null,}) {
  return _then(SearchQuery(
queryText: null == queryText ? _self.queryText : queryText // ignore: cast_nullable_to_non_nullable
as String,isExactMatch: null == isExactMatch ? _self.isExactMatch : isExactMatch // ignore: cast_nullable_to_non_nullable
as bool,editionIds: null == editionIds ? _self.editionIds : editionIds // ignore: cast_nullable_to_non_nullable
as Set<String>,searchInPali: null == searchInPali ? _self.searchInPali : searchInPali // ignore: cast_nullable_to_non_nullable
as bool,searchInSinhala: null == searchInSinhala ? _self.searchInSinhala : searchInSinhala // ignore: cast_nullable_to_non_nullable
as bool,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as Set<String>,isPhraseSearch: null == isPhraseSearch ? _self.isPhraseSearch : isPhraseSearch // ignore: cast_nullable_to_non_nullable
as bool,isAnywhereInText: null == isAnywhereInText ? _self.isAnywhereInText : isAnywhereInText // ignore: cast_nullable_to_non_nullable
as bool,proximityDistance: null == proximityDistance ? _self.proximityDistance : proximityDistance // ignore: cast_nullable_to_non_nullable
as int,selectedDictionaryIds: null == selectedDictionaryIds ? _self.selectedDictionaryIds : selectedDictionaryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchQuery].
extension SearchQueryPatterns on SearchQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchQuery value)  $default,){
final _that = this;
switch (_that) {
case _SearchQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchQuery value)?  $default,){
final _that = this;
switch (_that) {
case _SearchQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String queryText,  bool isExactMatch,  Set<String> editionIds,  bool searchInPali,  bool searchInSinhala,  Set<String> scope,  bool isPhraseSearch,  bool isAnywhereInText,  int proximityDistance,  Set<String> selectedDictionaryIds,  int limit,  int offset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchQuery() when $default != null:
return $default(_that.queryText,_that.isExactMatch,_that.editionIds,_that.searchInPali,_that.searchInSinhala,_that.scope,_that.isPhraseSearch,_that.isAnywhereInText,_that.proximityDistance,_that.selectedDictionaryIds,_that.limit,_that.offset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String queryText,  bool isExactMatch,  Set<String> editionIds,  bool searchInPali,  bool searchInSinhala,  Set<String> scope,  bool isPhraseSearch,  bool isAnywhereInText,  int proximityDistance,  Set<String> selectedDictionaryIds,  int limit,  int offset)  $default,) {final _that = this;
switch (_that) {
case _SearchQuery():
return $default(_that.queryText,_that.isExactMatch,_that.editionIds,_that.searchInPali,_that.searchInSinhala,_that.scope,_that.isPhraseSearch,_that.isAnywhereInText,_that.proximityDistance,_that.selectedDictionaryIds,_that.limit,_that.offset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String queryText,  bool isExactMatch,  Set<String> editionIds,  bool searchInPali,  bool searchInSinhala,  Set<String> scope,  bool isPhraseSearch,  bool isAnywhereInText,  int proximityDistance,  Set<String> selectedDictionaryIds,  int limit,  int offset)?  $default,) {final _that = this;
switch (_that) {
case _SearchQuery() when $default != null:
return $default(_that.queryText,_that.isExactMatch,_that.editionIds,_that.searchInPali,_that.searchInSinhala,_that.scope,_that.isPhraseSearch,_that.isAnywhereInText,_that.proximityDistance,_that.selectedDictionaryIds,_that.limit,_that.offset);case _:
  return null;

}
}

}

/// @nodoc


class _SearchQuery implements SearchQuery {
  const _SearchQuery({required this.queryText, this.isExactMatch = false,  Set<String> editionIds = const {}, this.searchInPali = true, this.searchInSinhala = true,  Set<String> scope = const {}, this.isPhraseSearch = true, this.isAnywhereInText = false, this.proximityDistance = 10,  Set<String> selectedDictionaryIds = const {}, this.limit = 50, this.offset = 0}): _editionIds = editionIds,_scope = scope,_selectedDictionaryIds = selectedDictionaryIds;
  

/// The search query text
@override final  String queryText;
/// Whether to require exact word match (no prefix matching)
/// Default false = prefix matching enabled (e.g., "සති" matches "සතිපට්ඨානය")
@override@JsonKey() final  bool isExactMatch;
/// Editions to search within (e.g., {'bjt', 'sc'})
/// If empty, searches all available editions
 final  Set<String> _editionIds;
/// Editions to search within (e.g., {'bjt', 'sc'})
/// If empty, searches all available editions
@override@JsonKey() Set<String> get editionIds {
  if (_editionIds is EqualUnmodifiableSetView) return _editionIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_editionIds);
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
/// Examples:
/// - {} = search everything
/// - {'sp'} = search only Sutta Pitaka
/// - {'dn', 'mn'} = search Digha Nikaya OR Majjhima Nikaya
/// - {'atta-vp', 'atta-sp', 'atta-ap'} = search all Commentaries
 final  Set<String> _scope;
/// Search scope using tree node keys (e.g., 'sp', 'dn', 'kn-dhp').
///
/// Empty set = search all content (no scope filter applied).
/// Non-empty = search only within the selected scope (OR logic).
///
/// Examples:
/// - {} = search everything
/// - {'sp'} = search only Sutta Pitaka
/// - {'dn', 'mn'} = search Digha Nikaya OR Majjhima Nikaya
/// - {'atta-vp', 'atta-sp', 'atta-ap'} = search all Commentaries
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
/// Dictionary IDs to filter definitions by (e.g., {'BUS', 'MS'} for Sinhala).
/// Empty set = no restriction (search all dictionaries).
 final  Set<String> _selectedDictionaryIds;
/// Dictionary IDs to filter definitions by (e.g., {'BUS', 'MS'} for Sinhala).
/// Empty set = no restriction (search all dictionaries).
@override@JsonKey() Set<String> get selectedDictionaryIds {
  if (_selectedDictionaryIds is EqualUnmodifiableSetView) return _selectedDictionaryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedDictionaryIds);
}

/// Maximum number of results to return
@override@JsonKey() final  int limit;
/// Offset for pagination
@override@JsonKey() final  int offset;

/// Create a copy of SearchQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchQueryCopyWith<_SearchQuery> get copyWith => __$SearchQueryCopyWithImpl<_SearchQuery>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchQuery&&(identical(other.queryText, queryText) || other.queryText == queryText)&&(identical(other.isExactMatch, isExactMatch) || other.isExactMatch == isExactMatch)&&const DeepCollectionEquality().equals(other.editionIds, _editionIds)&&(identical(other.searchInPali, searchInPali) || other.searchInPali == searchInPali)&&(identical(other.searchInSinhala, searchInSinhala) || other.searchInSinhala == searchInSinhala)&&const DeepCollectionEquality().equals(other.scope, _scope)&&(identical(other.isPhraseSearch, isPhraseSearch) || other.isPhraseSearch == isPhraseSearch)&&(identical(other.isAnywhereInText, isAnywhereInText) || other.isAnywhereInText == isAnywhereInText)&&(identical(other.proximityDistance, proximityDistance) || other.proximityDistance == proximityDistance)&&const DeepCollectionEquality().equals(other.selectedDictionaryIds, _selectedDictionaryIds)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.offset, offset) || other.offset == offset));
}


@override
int get hashCode {
    return Object.hash(runtimeType,queryText,isExactMatch,const DeepCollectionEquality().hash(_editionIds),searchInPali,searchInSinhala,const DeepCollectionEquality().hash(_scope),isPhraseSearch,isAnywhereInText,proximityDistance,const DeepCollectionEquality().hash(_selectedDictionaryIds),limit,offset);
}

@override
String toString() {
    return 'SearchQuery(queryText: $queryText, isExactMatch: $isExactMatch, editionIds: $editionIds, searchInPali: $searchInPali, searchInSinhala: $searchInSinhala, scope: $scope, isPhraseSearch: $isPhraseSearch, isAnywhereInText: $isAnywhereInText, proximityDistance: $proximityDistance, selectedDictionaryIds: $selectedDictionaryIds, limit: $limit, offset: $offset)';
}


}

/// @nodoc
abstract mixin class _$SearchQueryCopyWith<$Res> implements $SearchQueryCopyWith<$Res> {
  factory _$SearchQueryCopyWith(_SearchQuery value, $Res Function(_SearchQuery) _then) = __$SearchQueryCopyWithImpl;
@override @useResult
$Res call({
 String queryText, bool isExactMatch, Set<String> editionIds, bool searchInPali, bool searchInSinhala, Set<String> scope, bool isPhraseSearch, bool isAnywhereInText, int proximityDistance, Set<String> selectedDictionaryIds, int limit, int offset
});




}
/// @nodoc
class __$SearchQueryCopyWithImpl<$Res>
    implements _$SearchQueryCopyWith<$Res> {
  __$SearchQueryCopyWithImpl(this._self, this._then);

  final _SearchQuery _self;
  final $Res Function(_SearchQuery) _then;

/// Create a copy of SearchQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? queryText = null,Object? isExactMatch = null,Object? editionIds = null,Object? searchInPali = null,Object? searchInSinhala = null,Object? scope = null,Object? isPhraseSearch = null,Object? isAnywhereInText = null,Object? proximityDistance = null,Object? selectedDictionaryIds = null,Object? limit = null,Object? offset = null,}) {
  return _then(_SearchQuery(
queryText: null == queryText ? _self.queryText : queryText // ignore: cast_nullable_to_non_nullable
as String,isExactMatch: null == isExactMatch ? _self.isExactMatch : isExactMatch // ignore: cast_nullable_to_non_nullable
as bool,editionIds: null == editionIds ? _self._editionIds : editionIds // ignore: cast_nullable_to_non_nullable
as Set<String>,searchInPali: null == searchInPali ? _self.searchInPali : searchInPali // ignore: cast_nullable_to_non_nullable
as bool,searchInSinhala: null == searchInSinhala ? _self.searchInSinhala : searchInSinhala // ignore: cast_nullable_to_non_nullable
as bool,scope: null == scope ? _self._scope : scope // ignore: cast_nullable_to_non_nullable
as Set<String>,isPhraseSearch: null == isPhraseSearch ? _self.isPhraseSearch : isPhraseSearch // ignore: cast_nullable_to_non_nullable
as bool,isAnywhereInText: null == isAnywhereInText ? _self.isAnywhereInText : isAnywhereInText // ignore: cast_nullable_to_non_nullable
as bool,proximityDistance: null == proximityDistance ? _self.proximityDistance : proximityDistance // ignore: cast_nullable_to_non_nullable
as int,selectedDictionaryIds: null == selectedDictionaryIds ? _self._selectedDictionaryIds : selectedDictionaryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
