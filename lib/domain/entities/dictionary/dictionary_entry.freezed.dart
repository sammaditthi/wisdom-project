// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dictionary_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DictionaryEntry {

/// Database row ID
 int get id;/// The Pali word (in Sinhala script)
 String get word;/// Dictionary identifier (e.g., 'DPD', 'PTS', 'BUS')
 String get dictionaryId;/// The meaning/definition (HTML content)
 String get meaning;/// Target language of the definition ('en' or 'si')
 String get targetLanguage;/// Source language of the word ('pali' or 'sinhala')
 String get sourceLanguage;/// Priority ranking for ordering (higher = more important)
 int get rank;/// Optional relevance score from FTS search
 double? get relevanceScore;
/// Create a copy of DictionaryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DictionaryEntryCopyWith<DictionaryEntry> get copyWith => _$DictionaryEntryCopyWithImpl<DictionaryEntry>(this as DictionaryEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DictionaryEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DictionaryEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.word, _this.word) || other.word == _this.word)&&(identical(other.dictionaryId, _this.dictionaryId) || other.dictionaryId == _this.dictionaryId)&&(identical(other.meaning, _this.meaning) || other.meaning == _this.meaning)&&(identical(other.targetLanguage, _this.targetLanguage) || other.targetLanguage == _this.targetLanguage)&&(identical(other.sourceLanguage, _this.sourceLanguage) || other.sourceLanguage == _this.sourceLanguage)&&(identical(other.rank, _this.rank) || other.rank == _this.rank)&&(identical(other.relevanceScore, _this.relevanceScore) || other.relevanceScore == _this.relevanceScore));
}


@override
int get hashCode {
  final _this = this as DictionaryEntry;
  return Object.hash(runtimeType,_this.id,_this.word,_this.dictionaryId,_this.meaning,_this.targetLanguage,_this.sourceLanguage,_this.rank,_this.relevanceScore);
}

@override
String toString() {
  final _this = this as DictionaryEntry;
  return 'DictionaryEntry(id: ${_this.id}, word: ${_this.word}, dictionaryId: ${_this.dictionaryId}, meaning: ${_this.meaning}, targetLanguage: ${_this.targetLanguage}, sourceLanguage: ${_this.sourceLanguage}, rank: ${_this.rank}, relevanceScore: ${_this.relevanceScore})';
}


}

/// @nodoc
abstract mixin class $DictionaryEntryCopyWith<$Res>  {
  factory $DictionaryEntryCopyWith(DictionaryEntry value, $Res Function(DictionaryEntry) _then) = _$DictionaryEntryCopyWithImpl;
@useResult
$Res call({
 int id, String word, String dictionaryId, String meaning, String targetLanguage, String sourceLanguage, int rank, double? relevanceScore
});




}
/// @nodoc
class _$DictionaryEntryCopyWithImpl<$Res>
    implements $DictionaryEntryCopyWith<$Res> {
  _$DictionaryEntryCopyWithImpl(this._self, this._then);

  final DictionaryEntry _self;
  final $Res Function(DictionaryEntry) _then;

/// Create a copy of DictionaryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? word = null,Object? dictionaryId = null,Object? meaning = null,Object? targetLanguage = null,Object? sourceLanguage = null,Object? rank = null,Object? relevanceScore = freezed,}) {
  return _then(DictionaryEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,dictionaryId: null == dictionaryId ? _self.dictionaryId : dictionaryId // ignore: cast_nullable_to_non_nullable
as String,meaning: null == meaning ? _self.meaning : meaning // ignore: cast_nullable_to_non_nullable
as String,targetLanguage: null == targetLanguage ? _self.targetLanguage : targetLanguage // ignore: cast_nullable_to_non_nullable
as String,sourceLanguage: null == sourceLanguage ? _self.sourceLanguage : sourceLanguage // ignore: cast_nullable_to_non_nullable
as String,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,relevanceScore: freezed == relevanceScore ? _self.relevanceScore : relevanceScore // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [DictionaryEntry].
extension DictionaryEntryPatterns on DictionaryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DictionaryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DictionaryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DictionaryEntry value)  $default,){
final _that = this;
switch (_that) {
case _DictionaryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DictionaryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _DictionaryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String word,  String dictionaryId,  String meaning,  String targetLanguage,  String sourceLanguage,  int rank,  double? relevanceScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DictionaryEntry() when $default != null:
return $default(_that.id,_that.word,_that.dictionaryId,_that.meaning,_that.targetLanguage,_that.sourceLanguage,_that.rank,_that.relevanceScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String word,  String dictionaryId,  String meaning,  String targetLanguage,  String sourceLanguage,  int rank,  double? relevanceScore)  $default,) {final _that = this;
switch (_that) {
case _DictionaryEntry():
return $default(_that.id,_that.word,_that.dictionaryId,_that.meaning,_that.targetLanguage,_that.sourceLanguage,_that.rank,_that.relevanceScore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String word,  String dictionaryId,  String meaning,  String targetLanguage,  String sourceLanguage,  int rank,  double? relevanceScore)?  $default,) {final _that = this;
switch (_that) {
case _DictionaryEntry() when $default != null:
return $default(_that.id,_that.word,_that.dictionaryId,_that.meaning,_that.targetLanguage,_that.sourceLanguage,_that.rank,_that.relevanceScore);case _:
  return null;

}
}

}

/// @nodoc


class _DictionaryEntry implements DictionaryEntry {
  const _DictionaryEntry({required this.id, required this.word, required this.dictionaryId, required this.meaning, required this.targetLanguage, required this.sourceLanguage, this.rank = 0, this.relevanceScore});
  

/// Database row ID
@override final  int id;
/// The Pali word (in Sinhala script)
@override final  String word;
/// Dictionary identifier (e.g., 'DPD', 'PTS', 'BUS')
@override final  String dictionaryId;
/// The meaning/definition (HTML content)
@override final  String meaning;
/// Target language of the definition ('en' or 'si')
@override final  String targetLanguage;
/// Source language of the word ('pali' or 'sinhala')
@override final  String sourceLanguage;
/// Priority ranking for ordering (higher = more important)
@override@JsonKey() final  int rank;
/// Optional relevance score from FTS search
@override final  double? relevanceScore;

/// Create a copy of DictionaryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DictionaryEntryCopyWith<_DictionaryEntry> get copyWith => __$DictionaryEntryCopyWithImpl<_DictionaryEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DictionaryEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.word, word) || other.word == word)&&(identical(other.dictionaryId, dictionaryId) || other.dictionaryId == dictionaryId)&&(identical(other.meaning, meaning) || other.meaning == meaning)&&(identical(other.targetLanguage, targetLanguage) || other.targetLanguage == targetLanguage)&&(identical(other.sourceLanguage, sourceLanguage) || other.sourceLanguage == sourceLanguage)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.relevanceScore, relevanceScore) || other.relevanceScore == relevanceScore));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,word,dictionaryId,meaning,targetLanguage,sourceLanguage,rank,relevanceScore);
}

@override
String toString() {
    return 'DictionaryEntry(id: $id, word: $word, dictionaryId: $dictionaryId, meaning: $meaning, targetLanguage: $targetLanguage, sourceLanguage: $sourceLanguage, rank: $rank, relevanceScore: $relevanceScore)';
}


}

/// @nodoc
abstract mixin class _$DictionaryEntryCopyWith<$Res> implements $DictionaryEntryCopyWith<$Res> {
  factory _$DictionaryEntryCopyWith(_DictionaryEntry value, $Res Function(_DictionaryEntry) _then) = __$DictionaryEntryCopyWithImpl;
@override @useResult
$Res call({
 int id, String word, String dictionaryId, String meaning, String targetLanguage, String sourceLanguage, int rank, double? relevanceScore
});




}
/// @nodoc
class __$DictionaryEntryCopyWithImpl<$Res>
    implements _$DictionaryEntryCopyWith<$Res> {
  __$DictionaryEntryCopyWithImpl(this._self, this._then);

  final _DictionaryEntry _self;
  final $Res Function(_DictionaryEntry) _then;

/// Create a copy of DictionaryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? word = null,Object? dictionaryId = null,Object? meaning = null,Object? targetLanguage = null,Object? sourceLanguage = null,Object? rank = null,Object? relevanceScore = freezed,}) {
  return _then(_DictionaryEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,dictionaryId: null == dictionaryId ? _self.dictionaryId : dictionaryId // ignore: cast_nullable_to_non_nullable
as String,meaning: null == meaning ? _self.meaning : meaning // ignore: cast_nullable_to_non_nullable
as String,targetLanguage: null == targetLanguage ? _self.targetLanguage : targetLanguage // ignore: cast_nullable_to_non_nullable
as String,sourceLanguage: null == sourceLanguage ? _self.sourceLanguage : sourceLanguage // ignore: cast_nullable_to_non_nullable
as String,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,relevanceScore: freezed == relevanceScore ? _self.relevanceScore : relevanceScore // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
