// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'research_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ResearchFilters {

/// "vinaya" | "sutta" — the uid-derived basket (design §5.2).
 String? get basket;
/// Create a copy of ResearchFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResearchFiltersCopyWith<ResearchFilters> get copyWith => _$ResearchFiltersCopyWithImpl<ResearchFilters>(this as ResearchFilters, _$identity);

  /// Serializes this ResearchFilters to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ResearchFilters;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResearchFilters&&(identical(other.basket, _this.basket) || other.basket == _this.basket));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ResearchFilters;
  return Object.hash(runtimeType,_this.basket);
}

@override
String toString() {
  final _this = this as ResearchFilters;
  return 'ResearchFilters(basket: ${_this.basket})';
}


}

/// @nodoc
abstract mixin class $ResearchFiltersCopyWith<$Res>  {
  factory $ResearchFiltersCopyWith(ResearchFilters value, $Res Function(ResearchFilters) _then) = _$ResearchFiltersCopyWithImpl;
@useResult
$Res call({
 String? basket
});




}
/// @nodoc
class _$ResearchFiltersCopyWithImpl<$Res>
    implements $ResearchFiltersCopyWith<$Res> {
  _$ResearchFiltersCopyWithImpl(this._self, this._then);

  final ResearchFilters _self;
  final $Res Function(ResearchFilters) _then;

/// Create a copy of ResearchFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? basket = freezed,}) {
  return _then(ResearchFilters(
basket: freezed == basket ? _self.basket : basket // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ResearchFilters].
extension ResearchFiltersPatterns on ResearchFilters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResearchFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResearchFilters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResearchFilters value)  $default,){
final _that = this;
switch (_that) {
case _ResearchFilters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResearchFilters value)?  $default,){
final _that = this;
switch (_that) {
case _ResearchFilters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? basket)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResearchFilters() when $default != null:
return $default(_that.basket);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? basket)  $default,) {final _that = this;
switch (_that) {
case _ResearchFilters():
return $default(_that.basket);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? basket)?  $default,) {final _that = this;
switch (_that) {
case _ResearchFilters() when $default != null:
return $default(_that.basket);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResearchFilters implements ResearchFilters {
  const _ResearchFilters({this.basket});
  factory _ResearchFilters.fromJson(Map<String, dynamic> json) => _$ResearchFiltersFromJson(json);

/// "vinaya" | "sutta" — the uid-derived basket (design §5.2).
@override final  String? basket;

/// Create a copy of ResearchFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResearchFiltersCopyWith<_ResearchFilters> get copyWith => __$ResearchFiltersCopyWithImpl<_ResearchFilters>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResearchFiltersToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResearchFilters&&(identical(other.basket, basket) || other.basket == basket));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,basket);
}

@override
String toString() {
    return 'ResearchFilters(basket: $basket)';
}


}

/// @nodoc
abstract mixin class _$ResearchFiltersCopyWith<$Res> implements $ResearchFiltersCopyWith<$Res> {
  factory _$ResearchFiltersCopyWith(_ResearchFilters value, $Res Function(_ResearchFilters) _then) = __$ResearchFiltersCopyWithImpl;
@override @useResult
$Res call({
 String? basket
});




}
/// @nodoc
class __$ResearchFiltersCopyWithImpl<$Res>
    implements _$ResearchFiltersCopyWith<$Res> {
  __$ResearchFiltersCopyWithImpl(this._self, this._then);

  final _ResearchFilters _self;
  final $Res Function(_ResearchFilters) _then;

/// Create a copy of ResearchFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? basket = freezed,}) {
  return _then(_ResearchFilters(
basket: freezed == basket ? _self.basket : basket // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
