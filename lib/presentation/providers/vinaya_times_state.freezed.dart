// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vinaya_times_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VinayaTimesState {

/// The device clock, to the minute.
 DateTime get now;/// Aruṇa, midday and sunset of the city's calendar day.
 DateTime get dawn; DateTime get midday; DateTime get sunset;/// Sunrise of the city's calendar day. Only the card's sky is anchored
/// on it, never on aruṇa, which moves with the Dawn setting.
 DateTime get sunrise;/// The moon's altitude in degrees at [now]; negative while it is down.
 double get moonAltitude;/// The aruṇa that ends the current vikāla, or the coming one.
 DateTime get vikalaEnds;/// The sunset that began this night, or the one that begins the next.
/// The night runs from here to [vikalaEnds].
 DateTime get nightStart;/// The current day, which runs aruṇa to aruṇa, as a UTC-midnight date.
 DateTime get buddhistDay;/// The uposathas on or after [buddhistDay], soonest first; empty past the
/// calendar's end.
 List<UposathaDay> get uposathas;
/// Create a copy of VinayaTimesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VinayaTimesStateCopyWith<VinayaTimesState> get copyWith => _$VinayaTimesStateCopyWithImpl<VinayaTimesState>(this as VinayaTimesState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VinayaTimesState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VinayaTimesState&&(identical(other.now, _this.now) || other.now == _this.now)&&(identical(other.dawn, _this.dawn) || other.dawn == _this.dawn)&&(identical(other.midday, _this.midday) || other.midday == _this.midday)&&(identical(other.sunset, _this.sunset) || other.sunset == _this.sunset)&&(identical(other.sunrise, _this.sunrise) || other.sunrise == _this.sunrise)&&(identical(other.moonAltitude, _this.moonAltitude) || other.moonAltitude == _this.moonAltitude)&&(identical(other.vikalaEnds, _this.vikalaEnds) || other.vikalaEnds == _this.vikalaEnds)&&(identical(other.nightStart, _this.nightStart) || other.nightStart == _this.nightStart)&&(identical(other.buddhistDay, _this.buddhistDay) || other.buddhistDay == _this.buddhistDay)&&const DeepCollectionEquality().equals(other.uposathas, _this.uposathas));
}


@override
int get hashCode {
  final _this = this as VinayaTimesState;
  return Object.hash(runtimeType,_this.now,_this.dawn,_this.midday,_this.sunset,_this.sunrise,_this.moonAltitude,_this.vikalaEnds,_this.nightStart,_this.buddhistDay,const DeepCollectionEquality().hash(_this.uposathas));
}

@override
String toString() {
  final _this = this as VinayaTimesState;
  return 'VinayaTimesState(now: ${_this.now}, dawn: ${_this.dawn}, midday: ${_this.midday}, sunset: ${_this.sunset}, sunrise: ${_this.sunrise}, moonAltitude: ${_this.moonAltitude}, vikalaEnds: ${_this.vikalaEnds}, nightStart: ${_this.nightStart}, buddhistDay: ${_this.buddhistDay}, uposathas: ${_this.uposathas})';
}


}

/// @nodoc
abstract mixin class $VinayaTimesStateCopyWith<$Res>  {
  factory $VinayaTimesStateCopyWith(VinayaTimesState value, $Res Function(VinayaTimesState) _then) = _$VinayaTimesStateCopyWithImpl;
@useResult
$Res call({
 DateTime now, DateTime dawn, DateTime midday, DateTime sunset, DateTime sunrise, double moonAltitude, DateTime vikalaEnds, DateTime nightStart, DateTime buddhistDay, List<UposathaDay> uposathas
});




}
/// @nodoc
class _$VinayaTimesStateCopyWithImpl<$Res>
    implements $VinayaTimesStateCopyWith<$Res> {
  _$VinayaTimesStateCopyWithImpl(this._self, this._then);

  final VinayaTimesState _self;
  final $Res Function(VinayaTimesState) _then;

/// Create a copy of VinayaTimesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? now = null,Object? dawn = null,Object? midday = null,Object? sunset = null,Object? sunrise = null,Object? moonAltitude = null,Object? vikalaEnds = null,Object? nightStart = null,Object? buddhistDay = null,Object? uposathas = null,}) {
  return _then(VinayaTimesState(
now: null == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as DateTime,dawn: null == dawn ? _self.dawn : dawn // ignore: cast_nullable_to_non_nullable
as DateTime,midday: null == midday ? _self.midday : midday // ignore: cast_nullable_to_non_nullable
as DateTime,sunset: null == sunset ? _self.sunset : sunset // ignore: cast_nullable_to_non_nullable
as DateTime,sunrise: null == sunrise ? _self.sunrise : sunrise // ignore: cast_nullable_to_non_nullable
as DateTime,moonAltitude: null == moonAltitude ? _self.moonAltitude : moonAltitude // ignore: cast_nullable_to_non_nullable
as double,vikalaEnds: null == vikalaEnds ? _self.vikalaEnds : vikalaEnds // ignore: cast_nullable_to_non_nullable
as DateTime,nightStart: null == nightStart ? _self.nightStart : nightStart // ignore: cast_nullable_to_non_nullable
as DateTime,buddhistDay: null == buddhistDay ? _self.buddhistDay : buddhistDay // ignore: cast_nullable_to_non_nullable
as DateTime,uposathas: null == uposathas ? _self.uposathas : uposathas // ignore: cast_nullable_to_non_nullable
as List<UposathaDay>,
  ));
}

}


/// Adds pattern-matching-related methods to [VinayaTimesState].
extension VinayaTimesStatePatterns on VinayaTimesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VinayaTimesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VinayaTimesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VinayaTimesState value)  $default,){
final _that = this;
switch (_that) {
case _VinayaTimesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VinayaTimesState value)?  $default,){
final _that = this;
switch (_that) {
case _VinayaTimesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime now,  DateTime dawn,  DateTime midday,  DateTime sunset,  DateTime sunrise,  double moonAltitude,  DateTime vikalaEnds,  DateTime nightStart,  DateTime buddhistDay,  List<UposathaDay> uposathas)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VinayaTimesState() when $default != null:
return $default(_that.now,_that.dawn,_that.midday,_that.sunset,_that.sunrise,_that.moonAltitude,_that.vikalaEnds,_that.nightStart,_that.buddhistDay,_that.uposathas);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime now,  DateTime dawn,  DateTime midday,  DateTime sunset,  DateTime sunrise,  double moonAltitude,  DateTime vikalaEnds,  DateTime nightStart,  DateTime buddhistDay,  List<UposathaDay> uposathas)  $default,) {final _that = this;
switch (_that) {
case _VinayaTimesState():
return $default(_that.now,_that.dawn,_that.midday,_that.sunset,_that.sunrise,_that.moonAltitude,_that.vikalaEnds,_that.nightStart,_that.buddhistDay,_that.uposathas);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime now,  DateTime dawn,  DateTime midday,  DateTime sunset,  DateTime sunrise,  double moonAltitude,  DateTime vikalaEnds,  DateTime nightStart,  DateTime buddhistDay,  List<UposathaDay> uposathas)?  $default,) {final _that = this;
switch (_that) {
case _VinayaTimesState() when $default != null:
return $default(_that.now,_that.dawn,_that.midday,_that.sunset,_that.sunrise,_that.moonAltitude,_that.vikalaEnds,_that.nightStart,_that.buddhistDay,_that.uposathas);case _:
  return null;

}
}

}

/// @nodoc


class _VinayaTimesState extends VinayaTimesState {
  const _VinayaTimesState({required this.now, required this.dawn, required this.midday, required this.sunset, required this.sunrise, required this.moonAltitude, required this.vikalaEnds, required this.nightStart, required this.buddhistDay, required  List<UposathaDay> uposathas}): _uposathas = uposathas,super._();
  

/// The device clock, to the minute.
@override final  DateTime now;
/// Aruṇa, midday and sunset of the city's calendar day.
@override final  DateTime dawn;
@override final  DateTime midday;
@override final  DateTime sunset;
/// Sunrise of the city's calendar day. Only the card's sky is anchored
/// on it, never on aruṇa, which moves with the Dawn setting.
@override final  DateTime sunrise;
/// The moon's altitude in degrees at [now]; negative while it is down.
@override final  double moonAltitude;
/// The aruṇa that ends the current vikāla, or the coming one.
@override final  DateTime vikalaEnds;
/// The sunset that began this night, or the one that begins the next.
/// The night runs from here to [vikalaEnds].
@override final  DateTime nightStart;
/// The current day, which runs aruṇa to aruṇa, as a UTC-midnight date.
@override final  DateTime buddhistDay;
/// The uposathas on or after [buddhistDay], soonest first; empty past the
/// calendar's end.
 final  List<UposathaDay> _uposathas;
/// The uposathas on or after [buddhistDay], soonest first; empty past the
/// calendar's end.
@override List<UposathaDay> get uposathas {
  if (_uposathas is EqualUnmodifiableListView) return _uposathas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_uposathas);
}


/// Create a copy of VinayaTimesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VinayaTimesStateCopyWith<_VinayaTimesState> get copyWith => __$VinayaTimesStateCopyWithImpl<_VinayaTimesState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VinayaTimesState&&(identical(other.now, now) || other.now == now)&&(identical(other.dawn, dawn) || other.dawn == dawn)&&(identical(other.midday, midday) || other.midday == midday)&&(identical(other.sunset, sunset) || other.sunset == sunset)&&(identical(other.sunrise, sunrise) || other.sunrise == sunrise)&&(identical(other.moonAltitude, moonAltitude) || other.moonAltitude == moonAltitude)&&(identical(other.vikalaEnds, vikalaEnds) || other.vikalaEnds == vikalaEnds)&&(identical(other.nightStart, nightStart) || other.nightStart == nightStart)&&(identical(other.buddhistDay, buddhistDay) || other.buddhistDay == buddhistDay)&&const DeepCollectionEquality().equals(other.uposathas, _uposathas));
}


@override
int get hashCode {
    return Object.hash(runtimeType,now,dawn,midday,sunset,sunrise,moonAltitude,vikalaEnds,nightStart,buddhistDay,const DeepCollectionEquality().hash(_uposathas));
}

@override
String toString() {
    return 'VinayaTimesState(now: $now, dawn: $dawn, midday: $midday, sunset: $sunset, sunrise: $sunrise, moonAltitude: $moonAltitude, vikalaEnds: $vikalaEnds, nightStart: $nightStart, buddhistDay: $buddhistDay, uposathas: $uposathas)';
}


}

/// @nodoc
abstract mixin class _$VinayaTimesStateCopyWith<$Res> implements $VinayaTimesStateCopyWith<$Res> {
  factory _$VinayaTimesStateCopyWith(_VinayaTimesState value, $Res Function(_VinayaTimesState) _then) = __$VinayaTimesStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime now, DateTime dawn, DateTime midday, DateTime sunset, DateTime sunrise, double moonAltitude, DateTime vikalaEnds, DateTime nightStart, DateTime buddhistDay, List<UposathaDay> uposathas
});




}
/// @nodoc
class __$VinayaTimesStateCopyWithImpl<$Res>
    implements _$VinayaTimesStateCopyWith<$Res> {
  __$VinayaTimesStateCopyWithImpl(this._self, this._then);

  final _VinayaTimesState _self;
  final $Res Function(_VinayaTimesState) _then;

/// Create a copy of VinayaTimesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? now = null,Object? dawn = null,Object? midday = null,Object? sunset = null,Object? sunrise = null,Object? moonAltitude = null,Object? vikalaEnds = null,Object? nightStart = null,Object? buddhistDay = null,Object? uposathas = null,}) {
  return _then(_VinayaTimesState(
now: null == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as DateTime,dawn: null == dawn ? _self.dawn : dawn // ignore: cast_nullable_to_non_nullable
as DateTime,midday: null == midday ? _self.midday : midday // ignore: cast_nullable_to_non_nullable
as DateTime,sunset: null == sunset ? _self.sunset : sunset // ignore: cast_nullable_to_non_nullable
as DateTime,sunrise: null == sunrise ? _self.sunrise : sunrise // ignore: cast_nullable_to_non_nullable
as DateTime,moonAltitude: null == moonAltitude ? _self.moonAltitude : moonAltitude // ignore: cast_nullable_to_non_nullable
as double,vikalaEnds: null == vikalaEnds ? _self.vikalaEnds : vikalaEnds // ignore: cast_nullable_to_non_nullable
as DateTime,nightStart: null == nightStart ? _self.nightStart : nightStart // ignore: cast_nullable_to_non_nullable
as DateTime,buddhistDay: null == buddhistDay ? _self.buddhistDay : buddhistDay // ignore: cast_nullable_to_non_nullable
as DateTime,uposathas: null == uposathas ? _self._uposathas : uposathas // ignore: cast_nullable_to_non_nullable
as List<UposathaDay>,
  ));
}


}

// dart format on
