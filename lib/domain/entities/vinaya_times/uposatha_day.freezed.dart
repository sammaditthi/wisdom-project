// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'uposatha_day.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UposathaDay {

/// The calendar day, as a UTC-midnight date.
 DateTime get date; MoonPhase get phase;/// Days in the fortnight this uposatha closes: 14 or 15.
 int get fortnightDays;
/// Create a copy of UposathaDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UposathaDayCopyWith<UposathaDay> get copyWith => _$UposathaDayCopyWithImpl<UposathaDay>(this as UposathaDay, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UposathaDay;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UposathaDay&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.fortnightDays, _this.fortnightDays) || other.fortnightDays == _this.fortnightDays));
}


@override
int get hashCode {
  final _this = this as UposathaDay;
  return Object.hash(runtimeType,_this.date,_this.phase,_this.fortnightDays);
}

@override
String toString() {
  final _this = this as UposathaDay;
  return 'UposathaDay(date: ${_this.date}, phase: ${_this.phase}, fortnightDays: ${_this.fortnightDays})';
}


}

/// @nodoc
abstract mixin class $UposathaDayCopyWith<$Res>  {
  factory $UposathaDayCopyWith(UposathaDay value, $Res Function(UposathaDay) _then) = _$UposathaDayCopyWithImpl;
@useResult
$Res call({
 DateTime date, MoonPhase phase, int fortnightDays
});




}
/// @nodoc
class _$UposathaDayCopyWithImpl<$Res>
    implements $UposathaDayCopyWith<$Res> {
  _$UposathaDayCopyWithImpl(this._self, this._then);

  final UposathaDay _self;
  final $Res Function(UposathaDay) _then;

/// Create a copy of UposathaDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? phase = null,Object? fortnightDays = null,}) {
  return _then(UposathaDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as MoonPhase,fortnightDays: null == fortnightDays ? _self.fortnightDays : fortnightDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UposathaDay].
extension UposathaDayPatterns on UposathaDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UposathaDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UposathaDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UposathaDay value)  $default,){
final _that = this;
switch (_that) {
case _UposathaDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UposathaDay value)?  $default,){
final _that = this;
switch (_that) {
case _UposathaDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  MoonPhase phase,  int fortnightDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UposathaDay() when $default != null:
return $default(_that.date,_that.phase,_that.fortnightDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  MoonPhase phase,  int fortnightDays)  $default,) {final _that = this;
switch (_that) {
case _UposathaDay():
return $default(_that.date,_that.phase,_that.fortnightDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  MoonPhase phase,  int fortnightDays)?  $default,) {final _that = this;
switch (_that) {
case _UposathaDay() when $default != null:
return $default(_that.date,_that.phase,_that.fortnightDays);case _:
  return null;

}
}

}

/// @nodoc


class _UposathaDay implements UposathaDay {
  const _UposathaDay({required this.date, required this.phase, required this.fortnightDays});
  

/// The calendar day, as a UTC-midnight date.
@override final  DateTime date;
@override final  MoonPhase phase;
/// Days in the fortnight this uposatha closes: 14 or 15.
@override final  int fortnightDays;

/// Create a copy of UposathaDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UposathaDayCopyWith<_UposathaDay> get copyWith => __$UposathaDayCopyWithImpl<_UposathaDay>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UposathaDay&&(identical(other.date, date) || other.date == date)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.fortnightDays, fortnightDays) || other.fortnightDays == fortnightDays));
}


@override
int get hashCode {
    return Object.hash(runtimeType,date,phase,fortnightDays);
}

@override
String toString() {
    return 'UposathaDay(date: $date, phase: $phase, fortnightDays: $fortnightDays)';
}


}

/// @nodoc
abstract mixin class _$UposathaDayCopyWith<$Res> implements $UposathaDayCopyWith<$Res> {
  factory _$UposathaDayCopyWith(_UposathaDay value, $Res Function(_UposathaDay) _then) = __$UposathaDayCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, MoonPhase phase, int fortnightDays
});




}
/// @nodoc
class __$UposathaDayCopyWithImpl<$Res>
    implements _$UposathaDayCopyWith<$Res> {
  __$UposathaDayCopyWithImpl(this._self, this._then);

  final _UposathaDay _self;
  final $Res Function(_UposathaDay) _then;

/// Create a copy of UposathaDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? phase = null,Object? fortnightDays = null,}) {
  return _then(_UposathaDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as MoonPhase,fortnightDays: null == fortnightDays ? _self.fortnightDays : fortnightDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
