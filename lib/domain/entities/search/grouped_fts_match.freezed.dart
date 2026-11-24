// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grouped_fts_match.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GroupedFTSMatch {

/// First match shown in collapsed view
 SearchResult get primaryMatch;/// Additional matches (shown when expanded)
 List<SearchResult> get secondaryMatches;
/// Create a copy of GroupedFTSMatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupedFTSMatchCopyWith<GroupedFTSMatch> get copyWith => _$GroupedFTSMatchCopyWithImpl<GroupedFTSMatch>(this as GroupedFTSMatch, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GroupedFTSMatch;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupedFTSMatch&&(identical(other.primaryMatch, _this.primaryMatch) || other.primaryMatch == _this.primaryMatch)&&const DeepCollectionEquality().equals(other.secondaryMatches, _this.secondaryMatches));
}


@override
int get hashCode {
  final _this = this as GroupedFTSMatch;
  return Object.hash(runtimeType,_this.primaryMatch,const DeepCollectionEquality().hash(_this.secondaryMatches));
}

@override
String toString() {
  final _this = this as GroupedFTSMatch;
  return 'GroupedFTSMatch(primaryMatch: ${_this.primaryMatch}, secondaryMatches: ${_this.secondaryMatches})';
}


}

/// @nodoc
abstract mixin class $GroupedFTSMatchCopyWith<$Res>  {
  factory $GroupedFTSMatchCopyWith(GroupedFTSMatch value, $Res Function(GroupedFTSMatch) _then) = _$GroupedFTSMatchCopyWithImpl;
@useResult
$Res call({
 SearchResult primaryMatch, List<SearchResult> secondaryMatches
});


$SearchResultCopyWith<$Res> get primaryMatch;

}
/// @nodoc
class _$GroupedFTSMatchCopyWithImpl<$Res>
    implements $GroupedFTSMatchCopyWith<$Res> {
  _$GroupedFTSMatchCopyWithImpl(this._self, this._then);

  final GroupedFTSMatch _self;
  final $Res Function(GroupedFTSMatch) _then;

/// Create a copy of GroupedFTSMatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? primaryMatch = null,Object? secondaryMatches = null,}) {
  return _then(GroupedFTSMatch(
primaryMatch: null == primaryMatch ? _self.primaryMatch : primaryMatch // ignore: cast_nullable_to_non_nullable
as SearchResult,secondaryMatches: null == secondaryMatches ? _self.secondaryMatches : secondaryMatches // ignore: cast_nullable_to_non_nullable
as List<SearchResult>,
  ));
}
/// Create a copy of GroupedFTSMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchResultCopyWith<$Res> get primaryMatch {
  
  return $SearchResultCopyWith<$Res>(_self.primaryMatch, (value) {
    return _then(_self.copyWith(primaryMatch: value));
  });
}
}


/// Adds pattern-matching-related methods to [GroupedFTSMatch].
extension GroupedFTSMatchPatterns on GroupedFTSMatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupedFTSMatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupedFTSMatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupedFTSMatch value)  $default,){
final _that = this;
switch (_that) {
case _GroupedFTSMatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupedFTSMatch value)?  $default,){
final _that = this;
switch (_that) {
case _GroupedFTSMatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SearchResult primaryMatch,  List<SearchResult> secondaryMatches)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupedFTSMatch() when $default != null:
return $default(_that.primaryMatch,_that.secondaryMatches);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SearchResult primaryMatch,  List<SearchResult> secondaryMatches)  $default,) {final _that = this;
switch (_that) {
case _GroupedFTSMatch():
return $default(_that.primaryMatch,_that.secondaryMatches);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SearchResult primaryMatch,  List<SearchResult> secondaryMatches)?  $default,) {final _that = this;
switch (_that) {
case _GroupedFTSMatch() when $default != null:
return $default(_that.primaryMatch,_that.secondaryMatches);case _:
  return null;

}
}

}

/// @nodoc


class _GroupedFTSMatch extends GroupedFTSMatch {
  const _GroupedFTSMatch({required this.primaryMatch,  List<SearchResult> secondaryMatches = const []}): _secondaryMatches = secondaryMatches,super._();
  

/// First match shown in collapsed view
@override final  SearchResult primaryMatch;
/// Additional matches (shown when expanded)
 final  List<SearchResult> _secondaryMatches;
/// Additional matches (shown when expanded)
@override@JsonKey() List<SearchResult> get secondaryMatches {
  if (_secondaryMatches is EqualUnmodifiableListView) return _secondaryMatches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_secondaryMatches);
}


/// Create a copy of GroupedFTSMatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupedFTSMatchCopyWith<_GroupedFTSMatch> get copyWith => __$GroupedFTSMatchCopyWithImpl<_GroupedFTSMatch>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupedFTSMatch&&(identical(other.primaryMatch, primaryMatch) || other.primaryMatch == primaryMatch)&&const DeepCollectionEquality().equals(other.secondaryMatches, _secondaryMatches));
}


@override
int get hashCode {
    return Object.hash(runtimeType,primaryMatch,const DeepCollectionEquality().hash(_secondaryMatches));
}

@override
String toString() {
    return 'GroupedFTSMatch(primaryMatch: $primaryMatch, secondaryMatches: $secondaryMatches)';
}


}

/// @nodoc
abstract mixin class _$GroupedFTSMatchCopyWith<$Res> implements $GroupedFTSMatchCopyWith<$Res> {
  factory _$GroupedFTSMatchCopyWith(_GroupedFTSMatch value, $Res Function(_GroupedFTSMatch) _then) = __$GroupedFTSMatchCopyWithImpl;
@override @useResult
$Res call({
 SearchResult primaryMatch, List<SearchResult> secondaryMatches
});


@override $SearchResultCopyWith<$Res> get primaryMatch;

}
/// @nodoc
class __$GroupedFTSMatchCopyWithImpl<$Res>
    implements _$GroupedFTSMatchCopyWith<$Res> {
  __$GroupedFTSMatchCopyWithImpl(this._self, this._then);

  final _GroupedFTSMatch _self;
  final $Res Function(_GroupedFTSMatch) _then;

/// Create a copy of GroupedFTSMatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? primaryMatch = null,Object? secondaryMatches = null,}) {
  return _then(_GroupedFTSMatch(
primaryMatch: null == primaryMatch ? _self.primaryMatch : primaryMatch // ignore: cast_nullable_to_non_nullable
as SearchResult,secondaryMatches: null == secondaryMatches ? _self._secondaryMatches : secondaryMatches // ignore: cast_nullable_to_non_nullable
as List<SearchResult>,
  ));
}

/// Create a copy of GroupedFTSMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchResultCopyWith<$Res> get primaryMatch {
  
  return $SearchResultCopyWith<$Res>(_self.primaryMatch, (value) {
    return _then(_self.copyWith(primaryMatch: value));
  });
}
}

// dart format on
