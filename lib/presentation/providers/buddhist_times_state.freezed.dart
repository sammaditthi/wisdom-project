// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'buddhist_times_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BuddhistTimesState {
  /// The device clock, to the minute.
  DateTime get now => throw _privateConstructorUsedError;

  /// Aruṇa, midday and sunset of the city's calendar day.
  DateTime get dawn => throw _privateConstructorUsedError;
  DateTime get midday => throw _privateConstructorUsedError;
  DateTime get sunset => throw _privateConstructorUsedError;

  /// The aruṇa that ends the current vikāla, or the coming one.
  DateTime get vikalaEnds => throw _privateConstructorUsedError;

  /// The sunset that began this night, or the one that begins the next.
  /// The night runs from here to [vikalaEnds].
  DateTime get nightStart => throw _privateConstructorUsedError;

  /// The current day, which runs aruṇa to aruṇa, as a UTC-midnight date.
  DateTime get buddhistDay => throw _privateConstructorUsedError;

  /// The uposathas on or after [buddhistDay], soonest first; empty past the
  /// calendar's end.
  List<UposathaDay> get uposathas => throw _privateConstructorUsedError;

  /// Create a copy of BuddhistTimesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BuddhistTimesStateCopyWith<BuddhistTimesState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BuddhistTimesStateCopyWith<$Res> {
  factory $BuddhistTimesStateCopyWith(
          BuddhistTimesState value, $Res Function(BuddhistTimesState) then) =
      _$BuddhistTimesStateCopyWithImpl<$Res, BuddhistTimesState>;
  @useResult
  $Res call(
      {DateTime now,
      DateTime dawn,
      DateTime midday,
      DateTime sunset,
      DateTime vikalaEnds,
      DateTime nightStart,
      DateTime buddhistDay,
      List<UposathaDay> uposathas});
}

/// @nodoc
class _$BuddhistTimesStateCopyWithImpl<$Res, $Val extends BuddhistTimesState>
    implements $BuddhistTimesStateCopyWith<$Res> {
  _$BuddhistTimesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BuddhistTimesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? now = null,
    Object? dawn = null,
    Object? midday = null,
    Object? sunset = null,
    Object? vikalaEnds = null,
    Object? nightStart = null,
    Object? buddhistDay = null,
    Object? uposathas = null,
  }) {
    return _then(_value.copyWith(
      now: null == now
          ? _value.now
          : now // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dawn: null == dawn
          ? _value.dawn
          : dawn // ignore: cast_nullable_to_non_nullable
              as DateTime,
      midday: null == midday
          ? _value.midday
          : midday // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sunset: null == sunset
          ? _value.sunset
          : sunset // ignore: cast_nullable_to_non_nullable
              as DateTime,
      vikalaEnds: null == vikalaEnds
          ? _value.vikalaEnds
          : vikalaEnds // ignore: cast_nullable_to_non_nullable
              as DateTime,
      nightStart: null == nightStart
          ? _value.nightStart
          : nightStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      buddhistDay: null == buddhistDay
          ? _value.buddhistDay
          : buddhistDay // ignore: cast_nullable_to_non_nullable
              as DateTime,
      uposathas: null == uposathas
          ? _value.uposathas
          : uposathas // ignore: cast_nullable_to_non_nullable
              as List<UposathaDay>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BuddhistTimesStateImplCopyWith<$Res>
    implements $BuddhistTimesStateCopyWith<$Res> {
  factory _$$BuddhistTimesStateImplCopyWith(_$BuddhistTimesStateImpl value,
          $Res Function(_$BuddhistTimesStateImpl) then) =
      __$$BuddhistTimesStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime now,
      DateTime dawn,
      DateTime midday,
      DateTime sunset,
      DateTime vikalaEnds,
      DateTime nightStart,
      DateTime buddhistDay,
      List<UposathaDay> uposathas});
}

/// @nodoc
class __$$BuddhistTimesStateImplCopyWithImpl<$Res>
    extends _$BuddhistTimesStateCopyWithImpl<$Res, _$BuddhistTimesStateImpl>
    implements _$$BuddhistTimesStateImplCopyWith<$Res> {
  __$$BuddhistTimesStateImplCopyWithImpl(_$BuddhistTimesStateImpl _value,
      $Res Function(_$BuddhistTimesStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of BuddhistTimesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? now = null,
    Object? dawn = null,
    Object? midday = null,
    Object? sunset = null,
    Object? vikalaEnds = null,
    Object? nightStart = null,
    Object? buddhistDay = null,
    Object? uposathas = null,
  }) {
    return _then(_$BuddhistTimesStateImpl(
      now: null == now
          ? _value.now
          : now // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dawn: null == dawn
          ? _value.dawn
          : dawn // ignore: cast_nullable_to_non_nullable
              as DateTime,
      midday: null == midday
          ? _value.midday
          : midday // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sunset: null == sunset
          ? _value.sunset
          : sunset // ignore: cast_nullable_to_non_nullable
              as DateTime,
      vikalaEnds: null == vikalaEnds
          ? _value.vikalaEnds
          : vikalaEnds // ignore: cast_nullable_to_non_nullable
              as DateTime,
      nightStart: null == nightStart
          ? _value.nightStart
          : nightStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      buddhistDay: null == buddhistDay
          ? _value.buddhistDay
          : buddhistDay // ignore: cast_nullable_to_non_nullable
              as DateTime,
      uposathas: null == uposathas
          ? _value._uposathas
          : uposathas // ignore: cast_nullable_to_non_nullable
              as List<UposathaDay>,
    ));
  }
}

/// @nodoc

class _$BuddhistTimesStateImpl extends _BuddhistTimesState {
  const _$BuddhistTimesStateImpl(
      {required this.now,
      required this.dawn,
      required this.midday,
      required this.sunset,
      required this.vikalaEnds,
      required this.nightStart,
      required this.buddhistDay,
      required final List<UposathaDay> uposathas})
      : _uposathas = uposathas,
        super._();

  /// The device clock, to the minute.
  @override
  final DateTime now;

  /// Aruṇa, midday and sunset of the city's calendar day.
  @override
  final DateTime dawn;
  @override
  final DateTime midday;
  @override
  final DateTime sunset;

  /// The aruṇa that ends the current vikāla, or the coming one.
  @override
  final DateTime vikalaEnds;

  /// The sunset that began this night, or the one that begins the next.
  /// The night runs from here to [vikalaEnds].
  @override
  final DateTime nightStart;

  /// The current day, which runs aruṇa to aruṇa, as a UTC-midnight date.
  @override
  final DateTime buddhistDay;

  /// The uposathas on or after [buddhistDay], soonest first; empty past the
  /// calendar's end.
  final List<UposathaDay> _uposathas;

  /// The uposathas on or after [buddhistDay], soonest first; empty past the
  /// calendar's end.
  @override
  List<UposathaDay> get uposathas {
    if (_uposathas is EqualUnmodifiableListView) return _uposathas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_uposathas);
  }

  @override
  String toString() {
    return 'BuddhistTimesState(now: $now, dawn: $dawn, midday: $midday, sunset: $sunset, vikalaEnds: $vikalaEnds, nightStart: $nightStart, buddhistDay: $buddhistDay, uposathas: $uposathas)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BuddhistTimesStateImpl &&
            (identical(other.now, now) || other.now == now) &&
            (identical(other.dawn, dawn) || other.dawn == dawn) &&
            (identical(other.midday, midday) || other.midday == midday) &&
            (identical(other.sunset, sunset) || other.sunset == sunset) &&
            (identical(other.vikalaEnds, vikalaEnds) ||
                other.vikalaEnds == vikalaEnds) &&
            (identical(other.nightStart, nightStart) ||
                other.nightStart == nightStart) &&
            (identical(other.buddhistDay, buddhistDay) ||
                other.buddhistDay == buddhistDay) &&
            const DeepCollectionEquality()
                .equals(other._uposathas, _uposathas));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      now,
      dawn,
      midday,
      sunset,
      vikalaEnds,
      nightStart,
      buddhistDay,
      const DeepCollectionEquality().hash(_uposathas));

  /// Create a copy of BuddhistTimesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BuddhistTimesStateImplCopyWith<_$BuddhistTimesStateImpl> get copyWith =>
      __$$BuddhistTimesStateImplCopyWithImpl<_$BuddhistTimesStateImpl>(
          this, _$identity);
}

abstract class _BuddhistTimesState extends BuddhistTimesState {
  const factory _BuddhistTimesState(
      {required final DateTime now,
      required final DateTime dawn,
      required final DateTime midday,
      required final DateTime sunset,
      required final DateTime vikalaEnds,
      required final DateTime nightStart,
      required final DateTime buddhistDay,
      required final List<UposathaDay> uposathas}) = _$BuddhistTimesStateImpl;
  const _BuddhistTimesState._() : super._();

  /// The device clock, to the minute.
  @override
  DateTime get now;

  /// Aruṇa, midday and sunset of the city's calendar day.
  @override
  DateTime get dawn;
  @override
  DateTime get midday;
  @override
  DateTime get sunset;

  /// The aruṇa that ends the current vikāla, or the coming one.
  @override
  DateTime get vikalaEnds;

  /// The sunset that began this night, or the one that begins the next.
  /// The night runs from here to [vikalaEnds].
  @override
  DateTime get nightStart;

  /// The current day, which runs aruṇa to aruṇa, as a UTC-midnight date.
  @override
  DateTime get buddhistDay;

  /// The uposathas on or after [buddhistDay], soonest first; empty past the
  /// calendar's end.
  @override
  List<UposathaDay> get uposathas;

  /// Create a copy of BuddhistTimesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BuddhistTimesStateImplCopyWith<_$BuddhistTimesStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
