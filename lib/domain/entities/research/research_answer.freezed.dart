// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'research_answer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ResearchAnswer {

/// The answer prose, in the same language as the question. Carries inline
/// `[[cite:uid]]` markers at each grounded span — the answer renderer
/// (`research_answer_view.dart`) parses these into tappable citation chips.
/// Also uses the small Markdown subset `**bold**` / `*italic*` / `- ` bullets.
 String get answer;/// "si" | "en".
 String get lang;/// Sources the answer is grounded on (may be empty).
 List<Citation> get citations;/// Which Gemini model generated the answer (e.g. "gemini-2.5-flash";
/// "stub" for canned replies). Shown quietly in the UI for the curious.
/// Nullable: a backend from before this field simply doesn't send it.
 String? get model;
/// Create a copy of ResearchAnswer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResearchAnswerCopyWith<ResearchAnswer> get copyWith => _$ResearchAnswerCopyWithImpl<ResearchAnswer>(this as ResearchAnswer, _$identity);

  /// Serializes this ResearchAnswer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ResearchAnswer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResearchAnswer&&(identical(other.answer, _this.answer) || other.answer == _this.answer)&&(identical(other.lang, _this.lang) || other.lang == _this.lang)&&const DeepCollectionEquality().equals(other.citations, _this.citations)&&(identical(other.model, _this.model) || other.model == _this.model));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ResearchAnswer;
  return Object.hash(runtimeType,_this.answer,_this.lang,const DeepCollectionEquality().hash(_this.citations),_this.model);
}

@override
String toString() {
  final _this = this as ResearchAnswer;
  return 'ResearchAnswer(answer: ${_this.answer}, lang: ${_this.lang}, citations: ${_this.citations}, model: ${_this.model})';
}


}

/// @nodoc
abstract mixin class $ResearchAnswerCopyWith<$Res>  {
  factory $ResearchAnswerCopyWith(ResearchAnswer value, $Res Function(ResearchAnswer) _then) = _$ResearchAnswerCopyWithImpl;
@useResult
$Res call({
 String answer, String lang, List<Citation> citations, String? model
});




}
/// @nodoc
class _$ResearchAnswerCopyWithImpl<$Res>
    implements $ResearchAnswerCopyWith<$Res> {
  _$ResearchAnswerCopyWithImpl(this._self, this._then);

  final ResearchAnswer _self;
  final $Res Function(ResearchAnswer) _then;

/// Create a copy of ResearchAnswer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? answer = null,Object? lang = null,Object? citations = null,Object? model = freezed,}) {
  return _then(ResearchAnswer(
answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,citations: null == citations ? _self.citations : citations // ignore: cast_nullable_to_non_nullable
as List<Citation>,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ResearchAnswer].
extension ResearchAnswerPatterns on ResearchAnswer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResearchAnswer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResearchAnswer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResearchAnswer value)  $default,){
final _that = this;
switch (_that) {
case _ResearchAnswer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResearchAnswer value)?  $default,){
final _that = this;
switch (_that) {
case _ResearchAnswer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String answer,  String lang,  List<Citation> citations,  String? model)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResearchAnswer() when $default != null:
return $default(_that.answer,_that.lang,_that.citations,_that.model);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String answer,  String lang,  List<Citation> citations,  String? model)  $default,) {final _that = this;
switch (_that) {
case _ResearchAnswer():
return $default(_that.answer,_that.lang,_that.citations,_that.model);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String answer,  String lang,  List<Citation> citations,  String? model)?  $default,) {final _that = this;
switch (_that) {
case _ResearchAnswer() when $default != null:
return $default(_that.answer,_that.lang,_that.citations,_that.model);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResearchAnswer implements ResearchAnswer {
  const _ResearchAnswer({required this.answer, required this.lang,  List<Citation> citations = const [], this.model}): _citations = citations;
  factory _ResearchAnswer.fromJson(Map<String, dynamic> json) => _$ResearchAnswerFromJson(json);

/// The answer prose, in the same language as the question. Carries inline
/// `[[cite:uid]]` markers at each grounded span — the answer renderer
/// (`research_answer_view.dart`) parses these into tappable citation chips.
/// Also uses the small Markdown subset `**bold**` / `*italic*` / `- ` bullets.
@override final  String answer;
/// "si" | "en".
@override final  String lang;
/// Sources the answer is grounded on (may be empty).
 final  List<Citation> _citations;
/// Sources the answer is grounded on (may be empty).
@override@JsonKey() List<Citation> get citations {
  if (_citations is EqualUnmodifiableListView) return _citations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_citations);
}

/// Which Gemini model generated the answer (e.g. "gemini-2.5-flash";
/// "stub" for canned replies). Shown quietly in the UI for the curious.
/// Nullable: a backend from before this field simply doesn't send it.
@override final  String? model;

/// Create a copy of ResearchAnswer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResearchAnswerCopyWith<_ResearchAnswer> get copyWith => __$ResearchAnswerCopyWithImpl<_ResearchAnswer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResearchAnswerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResearchAnswer&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.lang, lang) || other.lang == lang)&&const DeepCollectionEquality().equals(other.citations, _citations)&&(identical(other.model, model) || other.model == model));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,answer,lang,const DeepCollectionEquality().hash(_citations),model);
}

@override
String toString() {
    return 'ResearchAnswer(answer: $answer, lang: $lang, citations: $citations, model: $model)';
}


}

/// @nodoc
abstract mixin class _$ResearchAnswerCopyWith<$Res> implements $ResearchAnswerCopyWith<$Res> {
  factory _$ResearchAnswerCopyWith(_ResearchAnswer value, $Res Function(_ResearchAnswer) _then) = __$ResearchAnswerCopyWithImpl;
@override @useResult
$Res call({
 String answer, String lang, List<Citation> citations, String? model
});




}
/// @nodoc
class __$ResearchAnswerCopyWithImpl<$Res>
    implements _$ResearchAnswerCopyWith<$Res> {
  __$ResearchAnswerCopyWithImpl(this._self, this._then);

  final _ResearchAnswer _self;
  final $Res Function(_ResearchAnswer) _then;

/// Create a copy of ResearchAnswer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? answer = null,Object? lang = null,Object? citations = null,Object? model = freezed,}) {
  return _then(_ResearchAnswer(
answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,citations: null == citations ? _self._citations : citations // ignore: cast_nullable_to_non_nullable
as List<Citation>,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
