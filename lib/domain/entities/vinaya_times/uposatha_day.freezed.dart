// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'uposatha_day.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UposathaDay {
  /// The calendar day, as a UTC-midnight date.
  DateTime get date => throw _privateConstructorUsedError;
  MoonPhase get phase => throw _privateConstructorUsedError;

  /// Days in the fortnight this uposatha closes: 14 or 15.
  int get fortnightDays => throw _privateConstructorUsedError;

  /// Create a copy of UposathaDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UposathaDayCopyWith<UposathaDay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UposathaDayCopyWith<$Res> {
  factory $UposathaDayCopyWith(
          UposathaDay value, $Res Function(UposathaDay) then) =
      _$UposathaDayCopyWithImpl<$Res, UposathaDay>;
  @useResult
  $Res call({DateTime date, MoonPhase phase, int fortnightDays});
}

/// @nodoc
class _$UposathaDayCopyWithImpl<$Res, $Val extends UposathaDay>
    implements $UposathaDayCopyWith<$Res> {
  _$UposathaDayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UposathaDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? phase = null,
    Object? fortnightDays = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as MoonPhase,
      fortnightDays: null == fortnightDays
          ? _value.fortnightDays
          : fortnightDays // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UposathaDayImplCopyWith<$Res>
    implements $UposathaDayCopyWith<$Res> {
  factory _$$UposathaDayImplCopyWith(
          _$UposathaDayImpl value, $Res Function(_$UposathaDayImpl) then) =
      __$$UposathaDayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, MoonPhase phase, int fortnightDays});
}

/// @nodoc
class __$$UposathaDayImplCopyWithImpl<$Res>
    extends _$UposathaDayCopyWithImpl<$Res, _$UposathaDayImpl>
    implements _$$UposathaDayImplCopyWith<$Res> {
  __$$UposathaDayImplCopyWithImpl(
      _$UposathaDayImpl _value, $Res Function(_$UposathaDayImpl) _then)
      : super(_value, _then);

  /// Create a copy of UposathaDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? phase = null,
    Object? fortnightDays = null,
  }) {
    return _then(_$UposathaDayImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as MoonPhase,
      fortnightDays: null == fortnightDays
          ? _value.fortnightDays
          : fortnightDays // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$UposathaDayImpl implements _UposathaDay {
  const _$UposathaDayImpl(
      {required this.date, required this.phase, required this.fortnightDays});

  /// The calendar day, as a UTC-midnight date.
  @override
  final DateTime date;
  @override
  final MoonPhase phase;

  /// Days in the fortnight this uposatha closes: 14 or 15.
  @override
  final int fortnightDays;

  @override
  String toString() {
    return 'UposathaDay(date: $date, phase: $phase, fortnightDays: $fortnightDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UposathaDayImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.fortnightDays, fortnightDays) ||
                other.fortnightDays == fortnightDays));
  }

  @override
  int get hashCode => Object.hash(runtimeType, date, phase, fortnightDays);

  /// Create a copy of UposathaDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UposathaDayImplCopyWith<_$UposathaDayImpl> get copyWith =>
      __$$UposathaDayImplCopyWithImpl<_$UposathaDayImpl>(this, _$identity);
}

abstract class _UposathaDay implements UposathaDay {
  const factory _UposathaDay(
      {required final DateTime date,
      required final MoonPhase phase,
      required final int fortnightDays}) = _$UposathaDayImpl;

  /// The calendar day, as a UTC-midnight date.
  @override
  DateTime get date;
  @override
  MoonPhase get phase;

  /// Days in the fortnight this uposatha closes: 14 or 15.
  @override
  int get fortnightDays;

  /// Create a copy of UposathaDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UposathaDayImplCopyWith<_$UposathaDayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
