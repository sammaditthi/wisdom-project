// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'text_layer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TextLayer {

/// Unique identifier for this layer
/// Format: "{editionId}-{languageCode}-{scriptCode}[-{translator}]"
/// Examples: 'bjt-pi-sinh', 'bjt-pi-latn', 'bjt-si-sinh', 'sc-en-latn-sujato'
 String get layerId;/// Edition this layer belongs to ('bjt', 'suttacentral', 'pts')
 String get editionId;/// ISO 639-1 language code ('pi', 'si', 'en', etc.)
 String get languageCode;/// ISO 15924 script code
/// - 'sinh' = Sinhala script (සද්ධම්මං)
/// - 'latn' = Latin/Roman script (Saddhammaṁ)
/// - 'thai' = Thai script (สัทธัมมัง)
/// - 'deva' = Devanagari script (सद्धम्मं)
/// - 'mymr' = Myanmar/Burmese script
 String get scriptCode;/// Translator name (optional, primarily for SuttaCentral)
/// Examples: 'Bhikkhu Sujato', 'Bhikkhu Bodhi'
 String? get translator;/// Flattened list of entries across all pages
/// This removes the page structure to enable easier cross-edition alignment
 List<Entry> get segments;
/// Create a copy of TextLayer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextLayerCopyWith<TextLayer> get copyWith => _$TextLayerCopyWithImpl<TextLayer>(this as TextLayer, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TextLayer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextLayer&&(identical(other.layerId, _this.layerId) || other.layerId == _this.layerId)&&(identical(other.editionId, _this.editionId) || other.editionId == _this.editionId)&&(identical(other.languageCode, _this.languageCode) || other.languageCode == _this.languageCode)&&(identical(other.scriptCode, _this.scriptCode) || other.scriptCode == _this.scriptCode)&&(identical(other.translator, _this.translator) || other.translator == _this.translator)&&const DeepCollectionEquality().equals(other.segments, _this.segments));
}


@override
int get hashCode {
  final _this = this as TextLayer;
  return Object.hash(runtimeType,_this.layerId,_this.editionId,_this.languageCode,_this.scriptCode,_this.translator,const DeepCollectionEquality().hash(_this.segments));
}

@override
String toString() {
  final _this = this as TextLayer;
  return 'TextLayer(layerId: ${_this.layerId}, editionId: ${_this.editionId}, languageCode: ${_this.languageCode}, scriptCode: ${_this.scriptCode}, translator: ${_this.translator}, segments: ${_this.segments})';
}


}

/// @nodoc
abstract mixin class $TextLayerCopyWith<$Res>  {
  factory $TextLayerCopyWith(TextLayer value, $Res Function(TextLayer) _then) = _$TextLayerCopyWithImpl;
@useResult
$Res call({
 String layerId, String editionId, String languageCode, String scriptCode, String? translator, List<Entry> segments
});




}
/// @nodoc
class _$TextLayerCopyWithImpl<$Res>
    implements $TextLayerCopyWith<$Res> {
  _$TextLayerCopyWithImpl(this._self, this._then);

  final TextLayer _self;
  final $Res Function(TextLayer) _then;

/// Create a copy of TextLayer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? layerId = null,Object? editionId = null,Object? languageCode = null,Object? scriptCode = null,Object? translator = freezed,Object? segments = null,}) {
  return _then(TextLayer(
layerId: null == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String,editionId: null == editionId ? _self.editionId : editionId // ignore: cast_nullable_to_non_nullable
as String,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,scriptCode: null == scriptCode ? _self.scriptCode : scriptCode // ignore: cast_nullable_to_non_nullable
as String,translator: freezed == translator ? _self.translator : translator // ignore: cast_nullable_to_non_nullable
as String?,segments: null == segments ? _self.segments : segments // ignore: cast_nullable_to_non_nullable
as List<Entry>,
  ));
}

}


/// Adds pattern-matching-related methods to [TextLayer].
extension TextLayerPatterns on TextLayer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextLayer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextLayer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextLayer value)  $default,){
final _that = this;
switch (_that) {
case _TextLayer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextLayer value)?  $default,){
final _that = this;
switch (_that) {
case _TextLayer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String layerId,  String editionId,  String languageCode,  String scriptCode,  String? translator,  List<Entry> segments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextLayer() when $default != null:
return $default(_that.layerId,_that.editionId,_that.languageCode,_that.scriptCode,_that.translator,_that.segments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String layerId,  String editionId,  String languageCode,  String scriptCode,  String? translator,  List<Entry> segments)  $default,) {final _that = this;
switch (_that) {
case _TextLayer():
return $default(_that.layerId,_that.editionId,_that.languageCode,_that.scriptCode,_that.translator,_that.segments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String layerId,  String editionId,  String languageCode,  String scriptCode,  String? translator,  List<Entry> segments)?  $default,) {final _that = this;
switch (_that) {
case _TextLayer() when $default != null:
return $default(_that.layerId,_that.editionId,_that.languageCode,_that.scriptCode,_that.translator,_that.segments);case _:
  return null;

}
}

}

/// @nodoc


class _TextLayer extends TextLayer {
  const _TextLayer({required this.layerId, required this.editionId, required this.languageCode, required this.scriptCode, this.translator,  List<Entry> segments = const []}): _segments = segments,super._();
  

/// Unique identifier for this layer
/// Format: "{editionId}-{languageCode}-{scriptCode}[-{translator}]"
/// Examples: 'bjt-pi-sinh', 'bjt-pi-latn', 'bjt-si-sinh', 'sc-en-latn-sujato'
@override final  String layerId;
/// Edition this layer belongs to ('bjt', 'suttacentral', 'pts')
@override final  String editionId;
/// ISO 639-1 language code ('pi', 'si', 'en', etc.)
@override final  String languageCode;
/// ISO 15924 script code
/// - 'sinh' = Sinhala script (සද්ධම්මං)
/// - 'latn' = Latin/Roman script (Saddhammaṁ)
/// - 'thai' = Thai script (สัทธัมมัง)
/// - 'deva' = Devanagari script (सद्धम्मं)
/// - 'mymr' = Myanmar/Burmese script
@override final  String scriptCode;
/// Translator name (optional, primarily for SuttaCentral)
/// Examples: 'Bhikkhu Sujato', 'Bhikkhu Bodhi'
@override final  String? translator;
/// Flattened list of entries across all pages
/// This removes the page structure to enable easier cross-edition alignment
 final  List<Entry> _segments;
/// Flattened list of entries across all pages
/// This removes the page structure to enable easier cross-edition alignment
@override@JsonKey() List<Entry> get segments {
  if (_segments is EqualUnmodifiableListView) return _segments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_segments);
}


/// Create a copy of TextLayer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextLayerCopyWith<_TextLayer> get copyWith => __$TextLayerCopyWithImpl<_TextLayer>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextLayer&&(identical(other.layerId, layerId) || other.layerId == layerId)&&(identical(other.editionId, editionId) || other.editionId == editionId)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.scriptCode, scriptCode) || other.scriptCode == scriptCode)&&(identical(other.translator, translator) || other.translator == translator)&&const DeepCollectionEquality().equals(other.segments, _segments));
}


@override
int get hashCode {
    return Object.hash(runtimeType,layerId,editionId,languageCode,scriptCode,translator,const DeepCollectionEquality().hash(_segments));
}

@override
String toString() {
    return 'TextLayer(layerId: $layerId, editionId: $editionId, languageCode: $languageCode, scriptCode: $scriptCode, translator: $translator, segments: $segments)';
}


}

/// @nodoc
abstract mixin class _$TextLayerCopyWith<$Res> implements $TextLayerCopyWith<$Res> {
  factory _$TextLayerCopyWith(_TextLayer value, $Res Function(_TextLayer) _then) = __$TextLayerCopyWithImpl;
@override @useResult
$Res call({
 String layerId, String editionId, String languageCode, String scriptCode, String? translator, List<Entry> segments
});




}
/// @nodoc
class __$TextLayerCopyWithImpl<$Res>
    implements _$TextLayerCopyWith<$Res> {
  __$TextLayerCopyWithImpl(this._self, this._then);

  final _TextLayer _self;
  final $Res Function(_TextLayer) _then;

/// Create a copy of TextLayer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? layerId = null,Object? editionId = null,Object? languageCode = null,Object? scriptCode = null,Object? translator = freezed,Object? segments = null,}) {
  return _then(_TextLayer(
layerId: null == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String,editionId: null == editionId ? _self.editionId : editionId // ignore: cast_nullable_to_non_nullable
as String,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,scriptCode: null == scriptCode ? _self.scriptCode : scriptCode // ignore: cast_nullable_to_non_nullable
as String,translator: freezed == translator ? _self.translator : translator // ignore: cast_nullable_to_non_nullable
as String?,segments: null == segments ? _self._segments : segments // ignore: cast_nullable_to_non_nullable
as List<Entry>,
  ));
}


}

// dart format on
