// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recent_search.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecentSearch {

/// The search query text
 String get queryText;/// When this search was performed
 DateTime get timestamp;
/// Create a copy of RecentSearch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentSearchCopyWith<RecentSearch> get copyWith => _$RecentSearchCopyWithImpl<RecentSearch>(this as RecentSearch, _$identity);

  /// Serializes this RecentSearch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RecentSearch;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentSearch&&(identical(other.queryText, _this.queryText) || other.queryText == _this.queryText)&&(identical(other.timestamp, _this.timestamp) || other.timestamp == _this.timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RecentSearch;
  return Object.hash(runtimeType,_this.queryText,_this.timestamp);
}

@override
String toString() {
  final _this = this as RecentSearch;
  return 'RecentSearch(queryText: ${_this.queryText}, timestamp: ${_this.timestamp})';
}


}

/// @nodoc
abstract mixin class $RecentSearchCopyWith<$Res>  {
  factory $RecentSearchCopyWith(RecentSearch value, $Res Function(RecentSearch) _then) = _$RecentSearchCopyWithImpl;
@useResult
$Res call({
 String queryText, DateTime timestamp
});




}
/// @nodoc
class _$RecentSearchCopyWithImpl<$Res>
    implements $RecentSearchCopyWith<$Res> {
  _$RecentSearchCopyWithImpl(this._self, this._then);

  final RecentSearch _self;
  final $Res Function(RecentSearch) _then;

/// Create a copy of RecentSearch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? queryText = null,Object? timestamp = null,}) {
  return _then(RecentSearch(
queryText: null == queryText ? _self.queryText : queryText // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RecentSearch].
extension RecentSearchPatterns on RecentSearch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecentSearch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentSearch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecentSearch value)  $default,){
final _that = this;
switch (_that) {
case _RecentSearch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecentSearch value)?  $default,){
final _that = this;
switch (_that) {
case _RecentSearch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String queryText,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentSearch() when $default != null:
return $default(_that.queryText,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String queryText,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _RecentSearch():
return $default(_that.queryText,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String queryText,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _RecentSearch() when $default != null:
return $default(_that.queryText,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecentSearch implements RecentSearch {
  const _RecentSearch({required this.queryText, required this.timestamp});
  factory _RecentSearch.fromJson(Map<String, dynamic> json) => _$RecentSearchFromJson(json);

/// The search query text
@override final  String queryText;
/// When this search was performed
@override final  DateTime timestamp;

/// Create a copy of RecentSearch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentSearchCopyWith<_RecentSearch> get copyWith => __$RecentSearchCopyWithImpl<_RecentSearch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecentSearchToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentSearch&&(identical(other.queryText, queryText) || other.queryText == queryText)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,queryText,timestamp);
}

@override
String toString() {
    return 'RecentSearch(queryText: $queryText, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$RecentSearchCopyWith<$Res> implements $RecentSearchCopyWith<$Res> {
  factory _$RecentSearchCopyWith(_RecentSearch value, $Res Function(_RecentSearch) _then) = __$RecentSearchCopyWithImpl;
@override @useResult
$Res call({
 String queryText, DateTime timestamp
});




}
/// @nodoc
class __$RecentSearchCopyWithImpl<$Res>
    implements _$RecentSearchCopyWith<$Res> {
  __$RecentSearchCopyWithImpl(this._self, this._then);

  final _RecentSearch _self;
  final $Res Function(_RecentSearch) _then;

/// Create a copy of RecentSearch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? queryText = null,Object? timestamp = null,}) {
  return _then(_RecentSearch(
queryText: null == queryText ? _self.queryText : queryText // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
