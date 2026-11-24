// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bjt_section.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BJTSection {

/// ISO 639-1 language code ('pi' for Pali, 'si' for Sinhala)
 String get languageCode;/// List of entries in this section
 List<Entry> get entries;/// List of footnotes for this section
 List<String> get footnotes;
/// Create a copy of BJTSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BJTSectionCopyWith<BJTSection> get copyWith => _$BJTSectionCopyWithImpl<BJTSection>(this as BJTSection, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BJTSection;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BJTSection&&(identical(other.languageCode, _this.languageCode) || other.languageCode == _this.languageCode)&&const DeepCollectionEquality().equals(other.entries, _this.entries)&&const DeepCollectionEquality().equals(other.footnotes, _this.footnotes));
}


@override
int get hashCode {
  final _this = this as BJTSection;
  return Object.hash(runtimeType,_this.languageCode,const DeepCollectionEquality().hash(_this.entries),const DeepCollectionEquality().hash(_this.footnotes));
}

@override
String toString() {
  final _this = this as BJTSection;
  return 'BJTSection(languageCode: ${_this.languageCode}, entries: ${_this.entries}, footnotes: ${_this.footnotes})';
}


}

/// @nodoc
abstract mixin class $BJTSectionCopyWith<$Res>  {
  factory $BJTSectionCopyWith(BJTSection value, $Res Function(BJTSection) _then) = _$BJTSectionCopyWithImpl;
@useResult
$Res call({
 String languageCode, List<Entry> entries, List<String> footnotes
});




}
/// @nodoc
class _$BJTSectionCopyWithImpl<$Res>
    implements $BJTSectionCopyWith<$Res> {
  _$BJTSectionCopyWithImpl(this._self, this._then);

  final BJTSection _self;
  final $Res Function(BJTSection) _then;

/// Create a copy of BJTSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? languageCode = null,Object? entries = null,Object? footnotes = null,}) {
  return _then(BJTSection(
languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<Entry>,footnotes: null == footnotes ? _self.footnotes : footnotes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [BJTSection].
extension BJTSectionPatterns on BJTSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BJTSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BJTSection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BJTSection value)  $default,){
final _that = this;
switch (_that) {
case _BJTSection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BJTSection value)?  $default,){
final _that = this;
switch (_that) {
case _BJTSection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String languageCode,  List<Entry> entries,  List<String> footnotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BJTSection() when $default != null:
return $default(_that.languageCode,_that.entries,_that.footnotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String languageCode,  List<Entry> entries,  List<String> footnotes)  $default,) {final _that = this;
switch (_that) {
case _BJTSection():
return $default(_that.languageCode,_that.entries,_that.footnotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String languageCode,  List<Entry> entries,  List<String> footnotes)?  $default,) {final _that = this;
switch (_that) {
case _BJTSection() when $default != null:
return $default(_that.languageCode,_that.entries,_that.footnotes);case _:
  return null;

}
}

}

/// @nodoc


class _BJTSection extends BJTSection {
  const _BJTSection({required this.languageCode,  List<Entry> entries = const [],  List<String> footnotes = const []}): _entries = entries,_footnotes = footnotes,super._();
  

/// ISO 639-1 language code ('pi' for Pali, 'si' for Sinhala)
@override final  String languageCode;
/// List of entries in this section
 final  List<Entry> _entries;
/// List of entries in this section
@override@JsonKey() List<Entry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

/// List of footnotes for this section
 final  List<String> _footnotes;
/// List of footnotes for this section
@override@JsonKey() List<String> get footnotes {
  if (_footnotes is EqualUnmodifiableListView) return _footnotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_footnotes);
}


/// Create a copy of BJTSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BJTSectionCopyWith<_BJTSection> get copyWith => __$BJTSectionCopyWithImpl<_BJTSection>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BJTSection&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&const DeepCollectionEquality().equals(other.entries, _entries)&&const DeepCollectionEquality().equals(other.footnotes, _footnotes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,languageCode,const DeepCollectionEquality().hash(_entries),const DeepCollectionEquality().hash(_footnotes));
}

@override
String toString() {
    return 'BJTSection(languageCode: $languageCode, entries: $entries, footnotes: $footnotes)';
}


}

/// @nodoc
abstract mixin class _$BJTSectionCopyWith<$Res> implements $BJTSectionCopyWith<$Res> {
  factory _$BJTSectionCopyWith(_BJTSection value, $Res Function(_BJTSection) _then) = __$BJTSectionCopyWithImpl;
@override @useResult
$Res call({
 String languageCode, List<Entry> entries, List<String> footnotes
});




}
/// @nodoc
class __$BJTSectionCopyWithImpl<$Res>
    implements _$BJTSectionCopyWith<$Res> {
  __$BJTSectionCopyWithImpl(this._self, this._then);

  final _BJTSection _self;
  final $Res Function(_BJTSection) _then;

/// Create a copy of BJTSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? languageCode = null,Object? entries = null,Object? footnotes = null,}) {
  return _then(_BJTSection(
languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<Entry>,footnotes: null == footnotes ? _self._footnotes : footnotes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
