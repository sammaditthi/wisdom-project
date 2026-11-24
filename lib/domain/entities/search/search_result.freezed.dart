// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchResult {

/// Unique identifier for this result
 String get id;/// Edition this result came from (e.g., 'bjt', 'sc')
 String get editionId;/// Category this result belongs to (title, content, or definition)
 SearchResultType get resultType;/// Title of the sutta/document
 String get title;/// Subtitle showing the navigation path (e.g., "Dīgha Nikāya > Sīlakkhandhavagga")
 String get subtitle;/// The actual text that matched the search query
 String get matchedText;/// Text before the match (for context preview)
 String get contextBefore;/// Text after the match (for context preview)
 String get contextAfter;/// File ID for navigation (e.g., "dn-1")
 String get contentFileId;/// Page index where the match is located
 int get pageIndex;/// Entry index within the page
 int get entryIndex;/// Reference to the tree node
 String get nodeKey;/// Language of the matched text
 String get language;/// Relevance score for ranking (optional)
 double? get relevanceScore;
/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchResultCopyWith<SearchResult> get copyWith => _$SearchResultCopyWithImpl<SearchResult>(this as SearchResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SearchResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchResult&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.editionId, _this.editionId) || other.editionId == _this.editionId)&&(identical(other.resultType, _this.resultType) || other.resultType == _this.resultType)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.subtitle, _this.subtitle) || other.subtitle == _this.subtitle)&&(identical(other.matchedText, _this.matchedText) || other.matchedText == _this.matchedText)&&(identical(other.contextBefore, _this.contextBefore) || other.contextBefore == _this.contextBefore)&&(identical(other.contextAfter, _this.contextAfter) || other.contextAfter == _this.contextAfter)&&(identical(other.contentFileId, _this.contentFileId) || other.contentFileId == _this.contentFileId)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex)&&(identical(other.entryIndex, _this.entryIndex) || other.entryIndex == _this.entryIndex)&&(identical(other.nodeKey, _this.nodeKey) || other.nodeKey == _this.nodeKey)&&(identical(other.language, _this.language) || other.language == _this.language)&&(identical(other.relevanceScore, _this.relevanceScore) || other.relevanceScore == _this.relevanceScore));
}


@override
int get hashCode {
  final _this = this as SearchResult;
  return Object.hash(runtimeType,_this.id,_this.editionId,_this.resultType,_this.title,_this.subtitle,_this.matchedText,_this.contextBefore,_this.contextAfter,_this.contentFileId,_this.pageIndex,_this.entryIndex,_this.nodeKey,_this.language,_this.relevanceScore);
}

@override
String toString() {
  final _this = this as SearchResult;
  return 'SearchResult(id: ${_this.id}, editionId: ${_this.editionId}, resultType: ${_this.resultType}, title: ${_this.title}, subtitle: ${_this.subtitle}, matchedText: ${_this.matchedText}, contextBefore: ${_this.contextBefore}, contextAfter: ${_this.contextAfter}, contentFileId: ${_this.contentFileId}, pageIndex: ${_this.pageIndex}, entryIndex: ${_this.entryIndex}, nodeKey: ${_this.nodeKey}, language: ${_this.language}, relevanceScore: ${_this.relevanceScore})';
}


}

/// @nodoc
abstract mixin class $SearchResultCopyWith<$Res>  {
  factory $SearchResultCopyWith(SearchResult value, $Res Function(SearchResult) _then) = _$SearchResultCopyWithImpl;
@useResult
$Res call({
 String id, String editionId, SearchResultType resultType, String title, String subtitle, String matchedText, String contextBefore, String contextAfter, String contentFileId, int pageIndex, int entryIndex, String nodeKey, String language, double? relevanceScore
});




}
/// @nodoc
class _$SearchResultCopyWithImpl<$Res>
    implements $SearchResultCopyWith<$Res> {
  _$SearchResultCopyWithImpl(this._self, this._then);

  final SearchResult _self;
  final $Res Function(SearchResult) _then;

/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? editionId = null,Object? resultType = null,Object? title = null,Object? subtitle = null,Object? matchedText = null,Object? contextBefore = null,Object? contextAfter = null,Object? contentFileId = null,Object? pageIndex = null,Object? entryIndex = null,Object? nodeKey = null,Object? language = null,Object? relevanceScore = freezed,}) {
  return _then(SearchResult(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,editionId: null == editionId ? _self.editionId : editionId // ignore: cast_nullable_to_non_nullable
as String,resultType: null == resultType ? _self.resultType : resultType // ignore: cast_nullable_to_non_nullable
as SearchResultType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,matchedText: null == matchedText ? _self.matchedText : matchedText // ignore: cast_nullable_to_non_nullable
as String,contextBefore: null == contextBefore ? _self.contextBefore : contextBefore // ignore: cast_nullable_to_non_nullable
as String,contextAfter: null == contextAfter ? _self.contextAfter : contextAfter // ignore: cast_nullable_to_non_nullable
as String,contentFileId: null == contentFileId ? _self.contentFileId : contentFileId // ignore: cast_nullable_to_non_nullable
as String,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,entryIndex: null == entryIndex ? _self.entryIndex : entryIndex // ignore: cast_nullable_to_non_nullable
as int,nodeKey: null == nodeKey ? _self.nodeKey : nodeKey // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,relevanceScore: freezed == relevanceScore ? _self.relevanceScore : relevanceScore // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchResult].
extension SearchResultPatterns on SearchResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchResult value)  $default,){
final _that = this;
switch (_that) {
case _SearchResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String editionId,  SearchResultType resultType,  String title,  String subtitle,  String matchedText,  String contextBefore,  String contextAfter,  String contentFileId,  int pageIndex,  int entryIndex,  String nodeKey,  String language,  double? relevanceScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
return $default(_that.id,_that.editionId,_that.resultType,_that.title,_that.subtitle,_that.matchedText,_that.contextBefore,_that.contextAfter,_that.contentFileId,_that.pageIndex,_that.entryIndex,_that.nodeKey,_that.language,_that.relevanceScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String editionId,  SearchResultType resultType,  String title,  String subtitle,  String matchedText,  String contextBefore,  String contextAfter,  String contentFileId,  int pageIndex,  int entryIndex,  String nodeKey,  String language,  double? relevanceScore)  $default,) {final _that = this;
switch (_that) {
case _SearchResult():
return $default(_that.id,_that.editionId,_that.resultType,_that.title,_that.subtitle,_that.matchedText,_that.contextBefore,_that.contextAfter,_that.contentFileId,_that.pageIndex,_that.entryIndex,_that.nodeKey,_that.language,_that.relevanceScore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String editionId,  SearchResultType resultType,  String title,  String subtitle,  String matchedText,  String contextBefore,  String contextAfter,  String contentFileId,  int pageIndex,  int entryIndex,  String nodeKey,  String language,  double? relevanceScore)?  $default,) {final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
return $default(_that.id,_that.editionId,_that.resultType,_that.title,_that.subtitle,_that.matchedText,_that.contextBefore,_that.contextAfter,_that.contentFileId,_that.pageIndex,_that.entryIndex,_that.nodeKey,_that.language,_that.relevanceScore);case _:
  return null;

}
}

}

/// @nodoc


class _SearchResult extends SearchResult {
  const _SearchResult({required this.id, required this.editionId, required this.resultType, required this.title, required this.subtitle, required this.matchedText, this.contextBefore = '', this.contextAfter = '', required this.contentFileId, required this.pageIndex, required this.entryIndex, required this.nodeKey, required this.language, this.relevanceScore}): super._();
  

/// Unique identifier for this result
@override final  String id;
/// Edition this result came from (e.g., 'bjt', 'sc')
@override final  String editionId;
/// Category this result belongs to (title, content, or definition)
@override final  SearchResultType resultType;
/// Title of the sutta/document
@override final  String title;
/// Subtitle showing the navigation path (e.g., "Dīgha Nikāya > Sīlakkhandhavagga")
@override final  String subtitle;
/// The actual text that matched the search query
@override final  String matchedText;
/// Text before the match (for context preview)
@override@JsonKey() final  String contextBefore;
/// Text after the match (for context preview)
@override@JsonKey() final  String contextAfter;
/// File ID for navigation (e.g., "dn-1")
@override final  String contentFileId;
/// Page index where the match is located
@override final  int pageIndex;
/// Entry index within the page
@override final  int entryIndex;
/// Reference to the tree node
@override final  String nodeKey;
/// Language of the matched text
@override final  String language;
/// Relevance score for ranking (optional)
@override final  double? relevanceScore;

/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchResultCopyWith<_SearchResult> get copyWith => __$SearchResultCopyWithImpl<_SearchResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchResult&&(identical(other.id, id) || other.id == id)&&(identical(other.editionId, editionId) || other.editionId == editionId)&&(identical(other.resultType, resultType) || other.resultType == resultType)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.matchedText, matchedText) || other.matchedText == matchedText)&&(identical(other.contextBefore, contextBefore) || other.contextBefore == contextBefore)&&(identical(other.contextAfter, contextAfter) || other.contextAfter == contextAfter)&&(identical(other.contentFileId, contentFileId) || other.contentFileId == contentFileId)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex)&&(identical(other.entryIndex, entryIndex) || other.entryIndex == entryIndex)&&(identical(other.nodeKey, nodeKey) || other.nodeKey == nodeKey)&&(identical(other.language, language) || other.language == language)&&(identical(other.relevanceScore, relevanceScore) || other.relevanceScore == relevanceScore));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,editionId,resultType,title,subtitle,matchedText,contextBefore,contextAfter,contentFileId,pageIndex,entryIndex,nodeKey,language,relevanceScore);
}

@override
String toString() {
    return 'SearchResult(id: $id, editionId: $editionId, resultType: $resultType, title: $title, subtitle: $subtitle, matchedText: $matchedText, contextBefore: $contextBefore, contextAfter: $contextAfter, contentFileId: $contentFileId, pageIndex: $pageIndex, entryIndex: $entryIndex, nodeKey: $nodeKey, language: $language, relevanceScore: $relevanceScore)';
}


}

/// @nodoc
abstract mixin class _$SearchResultCopyWith<$Res> implements $SearchResultCopyWith<$Res> {
  factory _$SearchResultCopyWith(_SearchResult value, $Res Function(_SearchResult) _then) = __$SearchResultCopyWithImpl;
@override @useResult
$Res call({
 String id, String editionId, SearchResultType resultType, String title, String subtitle, String matchedText, String contextBefore, String contextAfter, String contentFileId, int pageIndex, int entryIndex, String nodeKey, String language, double? relevanceScore
});




}
/// @nodoc
class __$SearchResultCopyWithImpl<$Res>
    implements _$SearchResultCopyWith<$Res> {
  __$SearchResultCopyWithImpl(this._self, this._then);

  final _SearchResult _self;
  final $Res Function(_SearchResult) _then;

/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? editionId = null,Object? resultType = null,Object? title = null,Object? subtitle = null,Object? matchedText = null,Object? contextBefore = null,Object? contextAfter = null,Object? contentFileId = null,Object? pageIndex = null,Object? entryIndex = null,Object? nodeKey = null,Object? language = null,Object? relevanceScore = freezed,}) {
  return _then(_SearchResult(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,editionId: null == editionId ? _self.editionId : editionId // ignore: cast_nullable_to_non_nullable
as String,resultType: null == resultType ? _self.resultType : resultType // ignore: cast_nullable_to_non_nullable
as SearchResultType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,matchedText: null == matchedText ? _self.matchedText : matchedText // ignore: cast_nullable_to_non_nullable
as String,contextBefore: null == contextBefore ? _self.contextBefore : contextBefore // ignore: cast_nullable_to_non_nullable
as String,contextAfter: null == contextAfter ? _self.contextAfter : contextAfter // ignore: cast_nullable_to_non_nullable
as String,contentFileId: null == contentFileId ? _self.contentFileId : contentFileId // ignore: cast_nullable_to_non_nullable
as String,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,entryIndex: null == entryIndex ? _self.entryIndex : entryIndex // ignore: cast_nullable_to_non_nullable
as int,nodeKey: null == nodeKey ? _self.nodeKey : nodeKey // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,relevanceScore: freezed == relevanceScore ? _self.relevanceScore : relevanceScore // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
