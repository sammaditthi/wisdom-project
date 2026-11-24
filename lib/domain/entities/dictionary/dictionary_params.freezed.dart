// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dictionary_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DictionaryLookupParams {

/// The word to look up
 String get word;/// Whether to require exact match (no prefix matching)
/// Default false = prefix matching enabled
 bool get exactMatch;/// Filter to specific dictionary IDs, empty = all
 Set<String> get dictionaryIds;/// Maximum number of results to return
 int get limit;
/// Create a copy of DictionaryLookupParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DictionaryLookupParamsCopyWith<DictionaryLookupParams> get copyWith => _$DictionaryLookupParamsCopyWithImpl<DictionaryLookupParams>(this as DictionaryLookupParams, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DictionaryLookupParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DictionaryLookupParams&&(identical(other.word, _this.word) || other.word == _this.word)&&(identical(other.exactMatch, _this.exactMatch) || other.exactMatch == _this.exactMatch)&&const DeepCollectionEquality().equals(other.dictionaryIds, _this.dictionaryIds)&&(identical(other.limit, _this.limit) || other.limit == _this.limit));
}


@override
int get hashCode {
  final _this = this as DictionaryLookupParams;
  return Object.hash(runtimeType,_this.word,_this.exactMatch,const DeepCollectionEquality().hash(_this.dictionaryIds),_this.limit);
}

@override
String toString() {
  final _this = this as DictionaryLookupParams;
  return 'DictionaryLookupParams(word: ${_this.word}, exactMatch: ${_this.exactMatch}, dictionaryIds: ${_this.dictionaryIds}, limit: ${_this.limit})';
}


}

/// @nodoc
abstract mixin class $DictionaryLookupParamsCopyWith<$Res>  {
  factory $DictionaryLookupParamsCopyWith(DictionaryLookupParams value, $Res Function(DictionaryLookupParams) _then) = _$DictionaryLookupParamsCopyWithImpl;
@useResult
$Res call({
 String word, bool exactMatch, Set<String> dictionaryIds, int limit
});




}
/// @nodoc
class _$DictionaryLookupParamsCopyWithImpl<$Res>
    implements $DictionaryLookupParamsCopyWith<$Res> {
  _$DictionaryLookupParamsCopyWithImpl(this._self, this._then);

  final DictionaryLookupParams _self;
  final $Res Function(DictionaryLookupParams) _then;

/// Create a copy of DictionaryLookupParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? word = null,Object? exactMatch = null,Object? dictionaryIds = null,Object? limit = null,}) {
  return _then(DictionaryLookupParams(
word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,exactMatch: null == exactMatch ? _self.exactMatch : exactMatch // ignore: cast_nullable_to_non_nullable
as bool,dictionaryIds: null == dictionaryIds ? _self.dictionaryIds : dictionaryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DictionaryLookupParams].
extension DictionaryLookupParamsPatterns on DictionaryLookupParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DictionaryLookupParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DictionaryLookupParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DictionaryLookupParams value)  $default,){
final _that = this;
switch (_that) {
case _DictionaryLookupParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DictionaryLookupParams value)?  $default,){
final _that = this;
switch (_that) {
case _DictionaryLookupParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String word,  bool exactMatch,  Set<String> dictionaryIds,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DictionaryLookupParams() when $default != null:
return $default(_that.word,_that.exactMatch,_that.dictionaryIds,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String word,  bool exactMatch,  Set<String> dictionaryIds,  int limit)  $default,) {final _that = this;
switch (_that) {
case _DictionaryLookupParams():
return $default(_that.word,_that.exactMatch,_that.dictionaryIds,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String word,  bool exactMatch,  Set<String> dictionaryIds,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _DictionaryLookupParams() when $default != null:
return $default(_that.word,_that.exactMatch,_that.dictionaryIds,_that.limit);case _:
  return null;

}
}

}

/// @nodoc


class _DictionaryLookupParams implements DictionaryLookupParams {
  const _DictionaryLookupParams({required this.word, this.exactMatch = false,  Set<String> dictionaryIds = const {}, this.limit = 50}): _dictionaryIds = dictionaryIds;
  

/// The word to look up
@override final  String word;
/// Whether to require exact match (no prefix matching)
/// Default false = prefix matching enabled
@override@JsonKey() final  bool exactMatch;
/// Filter to specific dictionary IDs, empty = all
 final  Set<String> _dictionaryIds;
/// Filter to specific dictionary IDs, empty = all
@override@JsonKey() Set<String> get dictionaryIds {
  if (_dictionaryIds is EqualUnmodifiableSetView) return _dictionaryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_dictionaryIds);
}

/// Maximum number of results to return
@override@JsonKey() final  int limit;

/// Create a copy of DictionaryLookupParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DictionaryLookupParamsCopyWith<_DictionaryLookupParams> get copyWith => __$DictionaryLookupParamsCopyWithImpl<_DictionaryLookupParams>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DictionaryLookupParams&&(identical(other.word, word) || other.word == word)&&(identical(other.exactMatch, exactMatch) || other.exactMatch == exactMatch)&&const DeepCollectionEquality().equals(other.dictionaryIds, _dictionaryIds)&&(identical(other.limit, limit) || other.limit == limit));
}


@override
int get hashCode {
    return Object.hash(runtimeType,word,exactMatch,const DeepCollectionEquality().hash(_dictionaryIds),limit);
}

@override
String toString() {
    return 'DictionaryLookupParams(word: $word, exactMatch: $exactMatch, dictionaryIds: $dictionaryIds, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$DictionaryLookupParamsCopyWith<$Res> implements $DictionaryLookupParamsCopyWith<$Res> {
  factory _$DictionaryLookupParamsCopyWith(_DictionaryLookupParams value, $Res Function(_DictionaryLookupParams) _then) = __$DictionaryLookupParamsCopyWithImpl;
@override @useResult
$Res call({
 String word, bool exactMatch, Set<String> dictionaryIds, int limit
});




}
/// @nodoc
class __$DictionaryLookupParamsCopyWithImpl<$Res>
    implements _$DictionaryLookupParamsCopyWith<$Res> {
  __$DictionaryLookupParamsCopyWithImpl(this._self, this._then);

  final _DictionaryLookupParams _self;
  final $Res Function(_DictionaryLookupParams) _then;

/// Create a copy of DictionaryLookupParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? word = null,Object? exactMatch = null,Object? dictionaryIds = null,Object? limit = null,}) {
  return _then(_DictionaryLookupParams(
word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,exactMatch: null == exactMatch ? _self.exactMatch : exactMatch // ignore: cast_nullable_to_non_nullable
as bool,dictionaryIds: null == dictionaryIds ? _self._dictionaryIds : dictionaryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$DictionarySearchParams {

/// The search query text
 String get query;/// Whether to require exact word match (no prefix matching)
 bool get isExactMatch;/// Filter to specific dictionary IDs, empty = all
 Set<String> get dictionaryIds;/// Maximum number of results to return
 int get limit;
/// Create a copy of DictionarySearchParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DictionarySearchParamsCopyWith<DictionarySearchParams> get copyWith => _$DictionarySearchParamsCopyWithImpl<DictionarySearchParams>(this as DictionarySearchParams, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DictionarySearchParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DictionarySearchParams&&(identical(other.query, _this.query) || other.query == _this.query)&&(identical(other.isExactMatch, _this.isExactMatch) || other.isExactMatch == _this.isExactMatch)&&const DeepCollectionEquality().equals(other.dictionaryIds, _this.dictionaryIds)&&(identical(other.limit, _this.limit) || other.limit == _this.limit));
}


@override
int get hashCode {
  final _this = this as DictionarySearchParams;
  return Object.hash(runtimeType,_this.query,_this.isExactMatch,const DeepCollectionEquality().hash(_this.dictionaryIds),_this.limit);
}

@override
String toString() {
  final _this = this as DictionarySearchParams;
  return 'DictionarySearchParams(query: ${_this.query}, isExactMatch: ${_this.isExactMatch}, dictionaryIds: ${_this.dictionaryIds}, limit: ${_this.limit})';
}


}

/// @nodoc
abstract mixin class $DictionarySearchParamsCopyWith<$Res>  {
  factory $DictionarySearchParamsCopyWith(DictionarySearchParams value, $Res Function(DictionarySearchParams) _then) = _$DictionarySearchParamsCopyWithImpl;
@useResult
$Res call({
 String query, bool isExactMatch, Set<String> dictionaryIds, int limit
});




}
/// @nodoc
class _$DictionarySearchParamsCopyWithImpl<$Res>
    implements $DictionarySearchParamsCopyWith<$Res> {
  _$DictionarySearchParamsCopyWithImpl(this._self, this._then);

  final DictionarySearchParams _self;
  final $Res Function(DictionarySearchParams) _then;

/// Create a copy of DictionarySearchParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? isExactMatch = null,Object? dictionaryIds = null,Object? limit = null,}) {
  return _then(DictionarySearchParams(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,isExactMatch: null == isExactMatch ? _self.isExactMatch : isExactMatch // ignore: cast_nullable_to_non_nullable
as bool,dictionaryIds: null == dictionaryIds ? _self.dictionaryIds : dictionaryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DictionarySearchParams].
extension DictionarySearchParamsPatterns on DictionarySearchParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DictionarySearchParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DictionarySearchParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DictionarySearchParams value)  $default,){
final _that = this;
switch (_that) {
case _DictionarySearchParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DictionarySearchParams value)?  $default,){
final _that = this;
switch (_that) {
case _DictionarySearchParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  bool isExactMatch,  Set<String> dictionaryIds,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DictionarySearchParams() when $default != null:
return $default(_that.query,_that.isExactMatch,_that.dictionaryIds,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  bool isExactMatch,  Set<String> dictionaryIds,  int limit)  $default,) {final _that = this;
switch (_that) {
case _DictionarySearchParams():
return $default(_that.query,_that.isExactMatch,_that.dictionaryIds,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  bool isExactMatch,  Set<String> dictionaryIds,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _DictionarySearchParams() when $default != null:
return $default(_that.query,_that.isExactMatch,_that.dictionaryIds,_that.limit);case _:
  return null;

}
}

}

/// @nodoc


class _DictionarySearchParams implements DictionarySearchParams {
  const _DictionarySearchParams({required this.query, this.isExactMatch = false,  Set<String> dictionaryIds = const {}, this.limit = 50}): _dictionaryIds = dictionaryIds;
  

/// The search query text
@override final  String query;
/// Whether to require exact word match (no prefix matching)
@override@JsonKey() final  bool isExactMatch;
/// Filter to specific dictionary IDs, empty = all
 final  Set<String> _dictionaryIds;
/// Filter to specific dictionary IDs, empty = all
@override@JsonKey() Set<String> get dictionaryIds {
  if (_dictionaryIds is EqualUnmodifiableSetView) return _dictionaryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_dictionaryIds);
}

/// Maximum number of results to return
@override@JsonKey() final  int limit;

/// Create a copy of DictionarySearchParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DictionarySearchParamsCopyWith<_DictionarySearchParams> get copyWith => __$DictionarySearchParamsCopyWithImpl<_DictionarySearchParams>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DictionarySearchParams&&(identical(other.query, query) || other.query == query)&&(identical(other.isExactMatch, isExactMatch) || other.isExactMatch == isExactMatch)&&const DeepCollectionEquality().equals(other.dictionaryIds, _dictionaryIds)&&(identical(other.limit, limit) || other.limit == limit));
}


@override
int get hashCode {
    return Object.hash(runtimeType,query,isExactMatch,const DeepCollectionEquality().hash(_dictionaryIds),limit);
}

@override
String toString() {
    return 'DictionarySearchParams(query: $query, isExactMatch: $isExactMatch, dictionaryIds: $dictionaryIds, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$DictionarySearchParamsCopyWith<$Res> implements $DictionarySearchParamsCopyWith<$Res> {
  factory _$DictionarySearchParamsCopyWith(_DictionarySearchParams value, $Res Function(_DictionarySearchParams) _then) = __$DictionarySearchParamsCopyWithImpl;
@override @useResult
$Res call({
 String query, bool isExactMatch, Set<String> dictionaryIds, int limit
});




}
/// @nodoc
class __$DictionarySearchParamsCopyWithImpl<$Res>
    implements _$DictionarySearchParamsCopyWith<$Res> {
  __$DictionarySearchParamsCopyWithImpl(this._self, this._then);

  final _DictionarySearchParams _self;
  final $Res Function(_DictionarySearchParams) _then;

/// Create a copy of DictionarySearchParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? isExactMatch = null,Object? dictionaryIds = null,Object? limit = null,}) {
  return _then(_DictionarySearchParams(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,isExactMatch: null == isExactMatch ? _self.isExactMatch : isExactMatch // ignore: cast_nullable_to_non_nullable
as bool,dictionaryIds: null == dictionaryIds ? _self._dictionaryIds : dictionaryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
