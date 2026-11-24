// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bjt_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BJTPage {

/// The printed page of the Pali side. Null where no printed page can be
/// checked (commentaries, treatises). See `printedPages` in wisdom_shared.
 int? get pageNumber;/// The printed page of the Sinhala side, facing the Pali. Also null with
/// no Sinhala text (Paṭṭhāna is Pali only).
 int? get sinhalaPageNumber;/// Pali section for this page
 BJTSection get paliSection;/// Sinhala section for this page
 BJTSection get sinhalaSection;
/// Create a copy of BJTPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BJTPageCopyWith<BJTPage> get copyWith => _$BJTPageCopyWithImpl<BJTPage>(this as BJTPage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BJTPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BJTPage&&(identical(other.pageNumber, _this.pageNumber) || other.pageNumber == _this.pageNumber)&&(identical(other.sinhalaPageNumber, _this.sinhalaPageNumber) || other.sinhalaPageNumber == _this.sinhalaPageNumber)&&(identical(other.paliSection, _this.paliSection) || other.paliSection == _this.paliSection)&&(identical(other.sinhalaSection, _this.sinhalaSection) || other.sinhalaSection == _this.sinhalaSection));
}


@override
int get hashCode {
  final _this = this as BJTPage;
  return Object.hash(runtimeType,_this.pageNumber,_this.sinhalaPageNumber,_this.paliSection,_this.sinhalaSection);
}

@override
String toString() {
  final _this = this as BJTPage;
  return 'BJTPage(pageNumber: ${_this.pageNumber}, sinhalaPageNumber: ${_this.sinhalaPageNumber}, paliSection: ${_this.paliSection}, sinhalaSection: ${_this.sinhalaSection})';
}


}

/// @nodoc
abstract mixin class $BJTPageCopyWith<$Res>  {
  factory $BJTPageCopyWith(BJTPage value, $Res Function(BJTPage) _then) = _$BJTPageCopyWithImpl;
@useResult
$Res call({
 int? pageNumber, int? sinhalaPageNumber, BJTSection paliSection, BJTSection sinhalaSection
});


$BJTSectionCopyWith<$Res> get paliSection;$BJTSectionCopyWith<$Res> get sinhalaSection;

}
/// @nodoc
class _$BJTPageCopyWithImpl<$Res>
    implements $BJTPageCopyWith<$Res> {
  _$BJTPageCopyWithImpl(this._self, this._then);

  final BJTPage _self;
  final $Res Function(BJTPage) _then;

/// Create a copy of BJTPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pageNumber = freezed,Object? sinhalaPageNumber = freezed,Object? paliSection = null,Object? sinhalaSection = null,}) {
  return _then(BJTPage(
pageNumber: freezed == pageNumber ? _self.pageNumber : pageNumber // ignore: cast_nullable_to_non_nullable
as int?,sinhalaPageNumber: freezed == sinhalaPageNumber ? _self.sinhalaPageNumber : sinhalaPageNumber // ignore: cast_nullable_to_non_nullable
as int?,paliSection: null == paliSection ? _self.paliSection : paliSection // ignore: cast_nullable_to_non_nullable
as BJTSection,sinhalaSection: null == sinhalaSection ? _self.sinhalaSection : sinhalaSection // ignore: cast_nullable_to_non_nullable
as BJTSection,
  ));
}
/// Create a copy of BJTPage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BJTSectionCopyWith<$Res> get paliSection {
  
  return $BJTSectionCopyWith<$Res>(_self.paliSection, (value) {
    return _then(_self.copyWith(paliSection: value));
  });
}/// Create a copy of BJTPage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BJTSectionCopyWith<$Res> get sinhalaSection {
  
  return $BJTSectionCopyWith<$Res>(_self.sinhalaSection, (value) {
    return _then(_self.copyWith(sinhalaSection: value));
  });
}
}


/// Adds pattern-matching-related methods to [BJTPage].
extension BJTPagePatterns on BJTPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BJTPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BJTPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BJTPage value)  $default,){
final _that = this;
switch (_that) {
case _BJTPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BJTPage value)?  $default,){
final _that = this;
switch (_that) {
case _BJTPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? pageNumber,  int? sinhalaPageNumber,  BJTSection paliSection,  BJTSection sinhalaSection)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BJTPage() when $default != null:
return $default(_that.pageNumber,_that.sinhalaPageNumber,_that.paliSection,_that.sinhalaSection);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? pageNumber,  int? sinhalaPageNumber,  BJTSection paliSection,  BJTSection sinhalaSection)  $default,) {final _that = this;
switch (_that) {
case _BJTPage():
return $default(_that.pageNumber,_that.sinhalaPageNumber,_that.paliSection,_that.sinhalaSection);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? pageNumber,  int? sinhalaPageNumber,  BJTSection paliSection,  BJTSection sinhalaSection)?  $default,) {final _that = this;
switch (_that) {
case _BJTPage() when $default != null:
return $default(_that.pageNumber,_that.sinhalaPageNumber,_that.paliSection,_that.sinhalaSection);case _:
  return null;

}
}

}

/// @nodoc


class _BJTPage extends BJTPage {
  const _BJTPage({required this.pageNumber, required this.sinhalaPageNumber, required this.paliSection, required this.sinhalaSection}): super._();
  

/// The printed page of the Pali side. Null where no printed page can be
/// checked (commentaries, treatises). See `printedPages` in wisdom_shared.
@override final  int? pageNumber;
/// The printed page of the Sinhala side, facing the Pali. Also null with
/// no Sinhala text (Paṭṭhāna is Pali only).
@override final  int? sinhalaPageNumber;
/// Pali section for this page
@override final  BJTSection paliSection;
/// Sinhala section for this page
@override final  BJTSection sinhalaSection;

/// Create a copy of BJTPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BJTPageCopyWith<_BJTPage> get copyWith => __$BJTPageCopyWithImpl<_BJTPage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BJTPage&&(identical(other.pageNumber, pageNumber) || other.pageNumber == pageNumber)&&(identical(other.sinhalaPageNumber, sinhalaPageNumber) || other.sinhalaPageNumber == sinhalaPageNumber)&&(identical(other.paliSection, paliSection) || other.paliSection == paliSection)&&(identical(other.sinhalaSection, sinhalaSection) || other.sinhalaSection == sinhalaSection));
}


@override
int get hashCode {
    return Object.hash(runtimeType,pageNumber,sinhalaPageNumber,paliSection,sinhalaSection);
}

@override
String toString() {
    return 'BJTPage(pageNumber: $pageNumber, sinhalaPageNumber: $sinhalaPageNumber, paliSection: $paliSection, sinhalaSection: $sinhalaSection)';
}


}

/// @nodoc
abstract mixin class _$BJTPageCopyWith<$Res> implements $BJTPageCopyWith<$Res> {
  factory _$BJTPageCopyWith(_BJTPage value, $Res Function(_BJTPage) _then) = __$BJTPageCopyWithImpl;
@override @useResult
$Res call({
 int? pageNumber, int? sinhalaPageNumber, BJTSection paliSection, BJTSection sinhalaSection
});


@override $BJTSectionCopyWith<$Res> get paliSection;@override $BJTSectionCopyWith<$Res> get sinhalaSection;

}
/// @nodoc
class __$BJTPageCopyWithImpl<$Res>
    implements _$BJTPageCopyWith<$Res> {
  __$BJTPageCopyWithImpl(this._self, this._then);

  final _BJTPage _self;
  final $Res Function(_BJTPage) _then;

/// Create a copy of BJTPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pageNumber = freezed,Object? sinhalaPageNumber = freezed,Object? paliSection = null,Object? sinhalaSection = null,}) {
  return _then(_BJTPage(
pageNumber: freezed == pageNumber ? _self.pageNumber : pageNumber // ignore: cast_nullable_to_non_nullable
as int?,sinhalaPageNumber: freezed == sinhalaPageNumber ? _self.sinhalaPageNumber : sinhalaPageNumber // ignore: cast_nullable_to_non_nullable
as int?,paliSection: null == paliSection ? _self.paliSection : paliSection // ignore: cast_nullable_to_non_nullable
as BJTSection,sinhalaSection: null == sinhalaSection ? _self.sinhalaSection : sinhalaSection // ignore: cast_nullable_to_non_nullable
as BJTSection,
  ));
}

/// Create a copy of BJTPage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BJTSectionCopyWith<$Res> get paliSection {
  
  return $BJTSectionCopyWith<$Res>(_self.paliSection, (value) {
    return _then(_self.copyWith(paliSection: value));
  });
}/// Create a copy of BJTPage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BJTSectionCopyWith<$Res> get sinhalaSection {
  
  return $BJTSectionCopyWith<$Res>(_self.sinhalaSection, (value) {
    return _then(_self.copyWith(sinhalaSection: value));
  });
}
}

// dart format on
