// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Entry {

/// The type of this entry (paragraph, heading, centered, etc.)
 EntryType get entryType;/// The raw text with formatting markers
/// Examples of markers: **bold**, __underline__, {footnote}
 String get rawText;/// Unique segment identifier for cross-edition alignment
/// Generated at runtime for BJT (e.g., "dn-1:bjt:0")
/// Loaded from JSON for SuttaCentral (e.g., "dn1:1.1")
 String? get segmentId;/// Optional reference to a footnote
 String? get footnoteReference;/// Hierarchy level for this entry (1-5 for heading/centered, 1-2 for gatha)
/// Higher numbers = higher in hierarchy (level 5 = book title, level 1 = sub-section)
 int? get level;
/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntryCopyWith<Entry> get copyWith => _$EntryCopyWithImpl<Entry>(this as Entry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Entry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Entry&&(identical(other.entryType, _this.entryType) || other.entryType == _this.entryType)&&(identical(other.rawText, _this.rawText) || other.rawText == _this.rawText)&&(identical(other.segmentId, _this.segmentId) || other.segmentId == _this.segmentId)&&(identical(other.footnoteReference, _this.footnoteReference) || other.footnoteReference == _this.footnoteReference)&&(identical(other.level, _this.level) || other.level == _this.level));
}


@override
int get hashCode {
  final _this = this as Entry;
  return Object.hash(runtimeType,_this.entryType,_this.rawText,_this.segmentId,_this.footnoteReference,_this.level);
}

@override
String toString() {
  final _this = this as Entry;
  return 'Entry(entryType: ${_this.entryType}, rawText: ${_this.rawText}, segmentId: ${_this.segmentId}, footnoteReference: ${_this.footnoteReference}, level: ${_this.level})';
}


}

/// @nodoc
abstract mixin class $EntryCopyWith<$Res>  {
  factory $EntryCopyWith(Entry value, $Res Function(Entry) _then) = _$EntryCopyWithImpl;
@useResult
$Res call({
 EntryType entryType, String rawText, String? segmentId, String? footnoteReference, int? level
});




}
/// @nodoc
class _$EntryCopyWithImpl<$Res>
    implements $EntryCopyWith<$Res> {
  _$EntryCopyWithImpl(this._self, this._then);

  final Entry _self;
  final $Res Function(Entry) _then;

/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entryType = null,Object? rawText = null,Object? segmentId = freezed,Object? footnoteReference = freezed,Object? level = freezed,}) {
  return _then(Entry(
entryType: null == entryType ? _self.entryType : entryType // ignore: cast_nullable_to_non_nullable
as EntryType,rawText: null == rawText ? _self.rawText : rawText // ignore: cast_nullable_to_non_nullable
as String,segmentId: freezed == segmentId ? _self.segmentId : segmentId // ignore: cast_nullable_to_non_nullable
as String?,footnoteReference: freezed == footnoteReference ? _self.footnoteReference : footnoteReference // ignore: cast_nullable_to_non_nullable
as String?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Entry].
extension EntryPatterns on Entry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Entry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Entry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Entry value)  $default,){
final _that = this;
switch (_that) {
case _Entry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Entry value)?  $default,){
final _that = this;
switch (_that) {
case _Entry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EntryType entryType,  String rawText,  String? segmentId,  String? footnoteReference,  int? level)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Entry() when $default != null:
return $default(_that.entryType,_that.rawText,_that.segmentId,_that.footnoteReference,_that.level);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EntryType entryType,  String rawText,  String? segmentId,  String? footnoteReference,  int? level)  $default,) {final _that = this;
switch (_that) {
case _Entry():
return $default(_that.entryType,_that.rawText,_that.segmentId,_that.footnoteReference,_that.level);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EntryType entryType,  String rawText,  String? segmentId,  String? footnoteReference,  int? level)?  $default,) {final _that = this;
switch (_that) {
case _Entry() when $default != null:
return $default(_that.entryType,_that.rawText,_that.segmentId,_that.footnoteReference,_that.level);case _:
  return null;

}
}

}

/// @nodoc


class _Entry extends Entry {
  const _Entry({required this.entryType, required this.rawText, this.segmentId, this.footnoteReference, this.level}): super._();
  

/// The type of this entry (paragraph, heading, centered, etc.)
@override final  EntryType entryType;
/// The raw text with formatting markers
/// Examples of markers: **bold**, __underline__, {footnote}
@override final  String rawText;
/// Unique segment identifier for cross-edition alignment
/// Generated at runtime for BJT (e.g., "dn-1:bjt:0")
/// Loaded from JSON for SuttaCentral (e.g., "dn1:1.1")
@override final  String? segmentId;
/// Optional reference to a footnote
@override final  String? footnoteReference;
/// Hierarchy level for this entry (1-5 for heading/centered, 1-2 for gatha)
/// Higher numbers = higher in hierarchy (level 5 = book title, level 1 = sub-section)
@override final  int? level;

/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntryCopyWith<_Entry> get copyWith => __$EntryCopyWithImpl<_Entry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Entry&&(identical(other.entryType, entryType) || other.entryType == entryType)&&(identical(other.rawText, rawText) || other.rawText == rawText)&&(identical(other.segmentId, segmentId) || other.segmentId == segmentId)&&(identical(other.footnoteReference, footnoteReference) || other.footnoteReference == footnoteReference)&&(identical(other.level, level) || other.level == level));
}


@override
int get hashCode {
    return Object.hash(runtimeType,entryType,rawText,segmentId,footnoteReference,level);
}

@override
String toString() {
    return 'Entry(entryType: $entryType, rawText: $rawText, segmentId: $segmentId, footnoteReference: $footnoteReference, level: $level)';
}


}

/// @nodoc
abstract mixin class _$EntryCopyWith<$Res> implements $EntryCopyWith<$Res> {
  factory _$EntryCopyWith(_Entry value, $Res Function(_Entry) _then) = __$EntryCopyWithImpl;
@override @useResult
$Res call({
 EntryType entryType, String rawText, String? segmentId, String? footnoteReference, int? level
});




}
/// @nodoc
class __$EntryCopyWithImpl<$Res>
    implements _$EntryCopyWith<$Res> {
  __$EntryCopyWithImpl(this._self, this._then);

  final _Entry _self;
  final $Res Function(_Entry) _then;

/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entryType = null,Object? rawText = null,Object? segmentId = freezed,Object? footnoteReference = freezed,Object? level = freezed,}) {
  return _then(_Entry(
entryType: null == entryType ? _self.entryType : entryType // ignore: cast_nullable_to_non_nullable
as EntryType,rawText: null == rawText ? _self.rawText : rawText // ignore: cast_nullable_to_non_nullable
as String,segmentId: freezed == segmentId ? _self.segmentId : segmentId // ignore: cast_nullable_to_non_nullable
as String?,footnoteReference: freezed == footnoteReference ? _self.footnoteReference : footnoteReference // ignore: cast_nullable_to_non_nullable
as String?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
