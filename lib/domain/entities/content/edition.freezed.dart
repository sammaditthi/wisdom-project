// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Edition {

/// Unique identifier for this edition
/// Examples: 'bjt', 'suttacentral', 'pts'
 String get editionId;/// Human-readable display name
/// Examples: 'Buddha Jayanti Tripitaka', 'SuttaCentral', 'Pali Text Society'
 String get displayName;/// Short abbreviation for UI display
/// Examples: 'BJT', 'SC', 'PTS'
 String get abbreviation;/// Type of edition (local files vs remote API)
 EditionType get type;/// Language codes available in this edition
/// Uses ISO 639-1 codes: 'pi' (Pali), 'si' (Sinhala), 'en' (English), etc.
 List<String> get availableLanguages;
/// Create a copy of Edition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditionCopyWith<Edition> get copyWith => _$EditionCopyWithImpl<Edition>(this as Edition, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Edition;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Edition&&(identical(other.editionId, _this.editionId) || other.editionId == _this.editionId)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.abbreviation, _this.abbreviation) || other.abbreviation == _this.abbreviation)&&(identical(other.type, _this.type) || other.type == _this.type)&&const DeepCollectionEquality().equals(other.availableLanguages, _this.availableLanguages));
}


@override
int get hashCode {
  final _this = this as Edition;
  return Object.hash(runtimeType,_this.editionId,_this.displayName,_this.abbreviation,_this.type,const DeepCollectionEquality().hash(_this.availableLanguages));
}

@override
String toString() {
  final _this = this as Edition;
  return 'Edition(editionId: ${_this.editionId}, displayName: ${_this.displayName}, abbreviation: ${_this.abbreviation}, type: ${_this.type}, availableLanguages: ${_this.availableLanguages})';
}


}

/// @nodoc
abstract mixin class $EditionCopyWith<$Res>  {
  factory $EditionCopyWith(Edition value, $Res Function(Edition) _then) = _$EditionCopyWithImpl;
@useResult
$Res call({
 String editionId, String displayName, String abbreviation, EditionType type, List<String> availableLanguages
});




}
/// @nodoc
class _$EditionCopyWithImpl<$Res>
    implements $EditionCopyWith<$Res> {
  _$EditionCopyWithImpl(this._self, this._then);

  final Edition _self;
  final $Res Function(Edition) _then;

/// Create a copy of Edition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? editionId = null,Object? displayName = null,Object? abbreviation = null,Object? type = null,Object? availableLanguages = null,}) {
  return _then(Edition(
editionId: null == editionId ? _self.editionId : editionId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,abbreviation: null == abbreviation ? _self.abbreviation : abbreviation // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EditionType,availableLanguages: null == availableLanguages ? _self.availableLanguages : availableLanguages // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Edition].
extension EditionPatterns on Edition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Edition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Edition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Edition value)  $default,){
final _that = this;
switch (_that) {
case _Edition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Edition value)?  $default,){
final _that = this;
switch (_that) {
case _Edition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String editionId,  String displayName,  String abbreviation,  EditionType type,  List<String> availableLanguages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Edition() when $default != null:
return $default(_that.editionId,_that.displayName,_that.abbreviation,_that.type,_that.availableLanguages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String editionId,  String displayName,  String abbreviation,  EditionType type,  List<String> availableLanguages)  $default,) {final _that = this;
switch (_that) {
case _Edition():
return $default(_that.editionId,_that.displayName,_that.abbreviation,_that.type,_that.availableLanguages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String editionId,  String displayName,  String abbreviation,  EditionType type,  List<String> availableLanguages)?  $default,) {final _that = this;
switch (_that) {
case _Edition() when $default != null:
return $default(_that.editionId,_that.displayName,_that.abbreviation,_that.type,_that.availableLanguages);case _:
  return null;

}
}

}

/// @nodoc


class _Edition implements Edition {
  const _Edition({required this.editionId, required this.displayName, required this.abbreviation, required this.type,  List<String> availableLanguages = const []}): _availableLanguages = availableLanguages;
  

/// Unique identifier for this edition
/// Examples: 'bjt', 'suttacentral', 'pts'
@override final  String editionId;
/// Human-readable display name
/// Examples: 'Buddha Jayanti Tripitaka', 'SuttaCentral', 'Pali Text Society'
@override final  String displayName;
/// Short abbreviation for UI display
/// Examples: 'BJT', 'SC', 'PTS'
@override final  String abbreviation;
/// Type of edition (local files vs remote API)
@override final  EditionType type;
/// Language codes available in this edition
/// Uses ISO 639-1 codes: 'pi' (Pali), 'si' (Sinhala), 'en' (English), etc.
 final  List<String> _availableLanguages;
/// Language codes available in this edition
/// Uses ISO 639-1 codes: 'pi' (Pali), 'si' (Sinhala), 'en' (English), etc.
@override@JsonKey() List<String> get availableLanguages {
  if (_availableLanguages is EqualUnmodifiableListView) return _availableLanguages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableLanguages);
}


/// Create a copy of Edition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditionCopyWith<_Edition> get copyWith => __$EditionCopyWithImpl<_Edition>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Edition&&(identical(other.editionId, editionId) || other.editionId == editionId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.abbreviation, abbreviation) || other.abbreviation == abbreviation)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.availableLanguages, _availableLanguages));
}


@override
int get hashCode {
    return Object.hash(runtimeType,editionId,displayName,abbreviation,type,const DeepCollectionEquality().hash(_availableLanguages));
}

@override
String toString() {
    return 'Edition(editionId: $editionId, displayName: $displayName, abbreviation: $abbreviation, type: $type, availableLanguages: $availableLanguages)';
}


}

/// @nodoc
abstract mixin class _$EditionCopyWith<$Res> implements $EditionCopyWith<$Res> {
  factory _$EditionCopyWith(_Edition value, $Res Function(_Edition) _then) = __$EditionCopyWithImpl;
@override @useResult
$Res call({
 String editionId, String displayName, String abbreviation, EditionType type, List<String> availableLanguages
});




}
/// @nodoc
class __$EditionCopyWithImpl<$Res>
    implements _$EditionCopyWith<$Res> {
  __$EditionCopyWithImpl(this._self, this._then);

  final _Edition _self;
  final $Res Function(_Edition) _then;

/// Create a copy of Edition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? editionId = null,Object? displayName = null,Object? abbreviation = null,Object? type = null,Object? availableLanguages = null,}) {
  return _then(_Edition(
editionId: null == editionId ? _self.editionId : editionId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,abbreviation: null == abbreviation ? _self.abbreviation : abbreviation // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EditionType,availableLanguages: null == availableLanguages ? _self._availableLanguages : availableLanguages // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
