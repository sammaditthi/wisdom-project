// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'citation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Citation {

/// SuttaCentral uid, e.g. "sn15.3" or "pli-tv-bu-vb-np18".
 String get uid;/// Human-readable reference shown to the user, e.g. "SN 15.3".
 String get ref;/// Sutta heading minus the ref prefix, e.g. "Chapter One A Mustard Seed".
/// Shown bold next to [ref]; null when the chunk carried no heading.
 String? get title;/// "canon" today; "note" reserved for Sujato's notes (design §5.2).
/// Kept from day one so adding notes later needs no contract change.
 String get kind;/// SuttaCentral English source span that grounded this point — the "why it
/// was cited" provenance shown in the peek sheet. Matched query terms are
/// wrapped in `**…**` (rendered bold); see `make_snippet` on the server.
/// Deep links are NOT on the wire (`deeplink` removed 2026-07-18 — the
/// server could never resolve them): the app resolves [uid] → BJT nodeKey
/// client-side via the shared resolver.
 String? get snippet;
/// Create a copy of Citation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CitationCopyWith<Citation> get copyWith => _$CitationCopyWithImpl<Citation>(this as Citation, _$identity);

  /// Serializes this Citation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Citation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Citation&&(identical(other.uid, _this.uid) || other.uid == _this.uid)&&(identical(other.ref, _this.ref) || other.ref == _this.ref)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.snippet, _this.snippet) || other.snippet == _this.snippet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Citation;
  return Object.hash(runtimeType,_this.uid,_this.ref,_this.title,_this.kind,_this.snippet);
}

@override
String toString() {
  final _this = this as Citation;
  return 'Citation(uid: ${_this.uid}, ref: ${_this.ref}, title: ${_this.title}, kind: ${_this.kind}, snippet: ${_this.snippet})';
}


}

/// @nodoc
abstract mixin class $CitationCopyWith<$Res>  {
  factory $CitationCopyWith(Citation value, $Res Function(Citation) _then) = _$CitationCopyWithImpl;
@useResult
$Res call({
 String uid, String ref, String? title, String kind, String? snippet
});




}
/// @nodoc
class _$CitationCopyWithImpl<$Res>
    implements $CitationCopyWith<$Res> {
  _$CitationCopyWithImpl(this._self, this._then);

  final Citation _self;
  final $Res Function(Citation) _then;

/// Create a copy of Citation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? ref = null,Object? title = freezed,Object? kind = null,Object? snippet = freezed,}) {
  return _then(Citation(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,snippet: freezed == snippet ? _self.snippet : snippet // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Citation].
extension CitationPatterns on Citation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Citation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Citation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Citation value)  $default,){
final _that = this;
switch (_that) {
case _Citation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Citation value)?  $default,){
final _that = this;
switch (_that) {
case _Citation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String ref,  String? title,  String kind,  String? snippet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Citation() when $default != null:
return $default(_that.uid,_that.ref,_that.title,_that.kind,_that.snippet);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String ref,  String? title,  String kind,  String? snippet)  $default,) {final _that = this;
switch (_that) {
case _Citation():
return $default(_that.uid,_that.ref,_that.title,_that.kind,_that.snippet);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String ref,  String? title,  String kind,  String? snippet)?  $default,) {final _that = this;
switch (_that) {
case _Citation() when $default != null:
return $default(_that.uid,_that.ref,_that.title,_that.kind,_that.snippet);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Citation implements Citation {
  const _Citation({required this.uid, required this.ref, this.title, this.kind = 'canon', this.snippet});
  factory _Citation.fromJson(Map<String, dynamic> json) => _$CitationFromJson(json);

/// SuttaCentral uid, e.g. "sn15.3" or "pli-tv-bu-vb-np18".
@override final  String uid;
/// Human-readable reference shown to the user, e.g. "SN 15.3".
@override final  String ref;
/// Sutta heading minus the ref prefix, e.g. "Chapter One A Mustard Seed".
/// Shown bold next to [ref]; null when the chunk carried no heading.
@override final  String? title;
/// "canon" today; "note" reserved for Sujato's notes (design §5.2).
/// Kept from day one so adding notes later needs no contract change.
@override@JsonKey() final  String kind;
/// SuttaCentral English source span that grounded this point — the "why it
/// was cited" provenance shown in the peek sheet. Matched query terms are
/// wrapped in `**…**` (rendered bold); see `make_snippet` on the server.
/// Deep links are NOT on the wire (`deeplink` removed 2026-07-18 — the
/// server could never resolve them): the app resolves [uid] → BJT nodeKey
/// client-side via the shared resolver.
@override final  String? snippet;

/// Create a copy of Citation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CitationCopyWith<_Citation> get copyWith => __$CitationCopyWithImpl<_Citation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CitationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Citation&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.title, title) || other.title == title)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.snippet, snippet) || other.snippet == snippet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,uid,ref,title,kind,snippet);
}

@override
String toString() {
    return 'Citation(uid: $uid, ref: $ref, title: $title, kind: $kind, snippet: $snippet)';
}


}

/// @nodoc
abstract mixin class _$CitationCopyWith<$Res> implements $CitationCopyWith<$Res> {
  factory _$CitationCopyWith(_Citation value, $Res Function(_Citation) _then) = __$CitationCopyWithImpl;
@override @useResult
$Res call({
 String uid, String ref, String? title, String kind, String? snippet
});




}
/// @nodoc
class __$CitationCopyWithImpl<$Res>
    implements _$CitationCopyWith<$Res> {
  __$CitationCopyWithImpl(this._self, this._then);

  final _Citation _self;
  final $Res Function(_Citation) _then;

/// Create a copy of Citation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? ref = null,Object? title = freezed,Object? kind = null,Object? snippet = freezed,}) {
  return _then(_Citation(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,snippet: freezed == snippet ? _self.snippet : snippet // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
