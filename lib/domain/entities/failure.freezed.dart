// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Failure {

 String get message;
/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FailureCopyWith<Failure> get copyWith => _$FailureCopyWithImpl<Failure>(this as Failure, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Failure;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Failure&&(identical(other.message, _this.message) || other.message == _this.message));
}


@override
int get hashCode {
  final _this = this as Failure;
  return Object.hash(runtimeType,_this.message);
}

@override
String toString() {
  final _this = this as Failure;
  return 'Failure(message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $FailureCopyWith<$Res>  {
  factory $FailureCopyWith(Failure value, $Res Function(Failure) _then) = _$FailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$FailureCopyWithImpl<$Res>
    implements $FailureCopyWith<$Res> {
  _$FailureCopyWithImpl(this._self, this._then);

  final Failure _self;
  final $Res Function(Failure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Failure].
extension FailurePatterns on Failure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DataLoadFailure value)?  dataLoadFailure,TResult Function( DataParseFailure value)?  dataParseFailure,TResult Function( NotFoundFailure value)?  notFoundFailure,TResult Function( InvalidOperationFailure value)?  invalidOperationFailure,TResult Function( UnexpectedFailure value)?  unexpectedFailure,TResult Function( ApiFailure value)?  apiFailure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DataLoadFailure() when dataLoadFailure != null:
return dataLoadFailure(_that);case DataParseFailure() when dataParseFailure != null:
return dataParseFailure(_that);case NotFoundFailure() when notFoundFailure != null:
return notFoundFailure(_that);case InvalidOperationFailure() when invalidOperationFailure != null:
return invalidOperationFailure(_that);case UnexpectedFailure() when unexpectedFailure != null:
return unexpectedFailure(_that);case ApiFailure() when apiFailure != null:
return apiFailure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DataLoadFailure value)  dataLoadFailure,required TResult Function( DataParseFailure value)  dataParseFailure,required TResult Function( NotFoundFailure value)  notFoundFailure,required TResult Function( InvalidOperationFailure value)  invalidOperationFailure,required TResult Function( UnexpectedFailure value)  unexpectedFailure,required TResult Function( ApiFailure value)  apiFailure,}){
final _that = this;
switch (_that) {
case DataLoadFailure():
return dataLoadFailure(_that);case DataParseFailure():
return dataParseFailure(_that);case NotFoundFailure():
return notFoundFailure(_that);case InvalidOperationFailure():
return invalidOperationFailure(_that);case UnexpectedFailure():
return unexpectedFailure(_that);case ApiFailure():
return apiFailure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DataLoadFailure value)?  dataLoadFailure,TResult? Function( DataParseFailure value)?  dataParseFailure,TResult? Function( NotFoundFailure value)?  notFoundFailure,TResult? Function( InvalidOperationFailure value)?  invalidOperationFailure,TResult? Function( UnexpectedFailure value)?  unexpectedFailure,TResult? Function( ApiFailure value)?  apiFailure,}){
final _that = this;
switch (_that) {
case DataLoadFailure() when dataLoadFailure != null:
return dataLoadFailure(_that);case DataParseFailure() when dataParseFailure != null:
return dataParseFailure(_that);case NotFoundFailure() when notFoundFailure != null:
return notFoundFailure(_that);case InvalidOperationFailure() when invalidOperationFailure != null:
return invalidOperationFailure(_that);case UnexpectedFailure() when unexpectedFailure != null:
return unexpectedFailure(_that);case ApiFailure() when apiFailure != null:
return apiFailure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String message,  Object? error)?  dataLoadFailure,TResult Function( String message,  Object? error)?  dataParseFailure,TResult Function( String message)?  notFoundFailure,TResult Function( String message)?  invalidOperationFailure,TResult Function( String message,  Object? error)?  unexpectedFailure,TResult Function( String message,  ApiErrorType type,  Object? error)?  apiFailure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DataLoadFailure() when dataLoadFailure != null:
return dataLoadFailure(_that.message,_that.error);case DataParseFailure() when dataParseFailure != null:
return dataParseFailure(_that.message,_that.error);case NotFoundFailure() when notFoundFailure != null:
return notFoundFailure(_that.message);case InvalidOperationFailure() when invalidOperationFailure != null:
return invalidOperationFailure(_that.message);case UnexpectedFailure() when unexpectedFailure != null:
return unexpectedFailure(_that.message,_that.error);case ApiFailure() when apiFailure != null:
return apiFailure(_that.message,_that.type,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String message,  Object? error)  dataLoadFailure,required TResult Function( String message,  Object? error)  dataParseFailure,required TResult Function( String message)  notFoundFailure,required TResult Function( String message)  invalidOperationFailure,required TResult Function( String message,  Object? error)  unexpectedFailure,required TResult Function( String message,  ApiErrorType type,  Object? error)  apiFailure,}) {final _that = this;
switch (_that) {
case DataLoadFailure():
return dataLoadFailure(_that.message,_that.error);case DataParseFailure():
return dataParseFailure(_that.message,_that.error);case NotFoundFailure():
return notFoundFailure(_that.message);case InvalidOperationFailure():
return invalidOperationFailure(_that.message);case UnexpectedFailure():
return unexpectedFailure(_that.message,_that.error);case ApiFailure():
return apiFailure(_that.message,_that.type,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String message,  Object? error)?  dataLoadFailure,TResult? Function( String message,  Object? error)?  dataParseFailure,TResult? Function( String message)?  notFoundFailure,TResult? Function( String message)?  invalidOperationFailure,TResult? Function( String message,  Object? error)?  unexpectedFailure,TResult? Function( String message,  ApiErrorType type,  Object? error)?  apiFailure,}) {final _that = this;
switch (_that) {
case DataLoadFailure() when dataLoadFailure != null:
return dataLoadFailure(_that.message,_that.error);case DataParseFailure() when dataParseFailure != null:
return dataParseFailure(_that.message,_that.error);case NotFoundFailure() when notFoundFailure != null:
return notFoundFailure(_that.message);case InvalidOperationFailure() when invalidOperationFailure != null:
return invalidOperationFailure(_that.message);case UnexpectedFailure() when unexpectedFailure != null:
return unexpectedFailure(_that.message,_that.error);case ApiFailure() when apiFailure != null:
return apiFailure(_that.message,_that.type,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class DataLoadFailure extends Failure {
  const DataLoadFailure({required this.message, this.error}): super._();
  

@override final  String message;
 final  Object? error;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DataLoadFailureCopyWith<DataLoadFailure> get copyWith => _$DataLoadFailureCopyWithImpl<DataLoadFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DataLoadFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.error, error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message,const DeepCollectionEquality().hash(error));
}

@override
String toString() {
    return 'Failure.dataLoadFailure(message: $message, error: $error)';
}


}

/// @nodoc
abstract mixin class $DataLoadFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $DataLoadFailureCopyWith(DataLoadFailure value, $Res Function(DataLoadFailure) _then) = _$DataLoadFailureCopyWithImpl;
@override @useResult
$Res call({
 String message, Object? error
});




}
/// @nodoc
class _$DataLoadFailureCopyWithImpl<$Res>
    implements $DataLoadFailureCopyWith<$Res> {
  _$DataLoadFailureCopyWithImpl(this._self, this._then);

  final DataLoadFailure _self;
  final $Res Function(DataLoadFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? error = freezed,}) {
  return _then(DataLoadFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error ,
  ));
}


}

/// @nodoc


class DataParseFailure extends Failure {
  const DataParseFailure({required this.message, this.error}): super._();
  

@override final  String message;
 final  Object? error;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DataParseFailureCopyWith<DataParseFailure> get copyWith => _$DataParseFailureCopyWithImpl<DataParseFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DataParseFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.error, error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message,const DeepCollectionEquality().hash(error));
}

@override
String toString() {
    return 'Failure.dataParseFailure(message: $message, error: $error)';
}


}

/// @nodoc
abstract mixin class $DataParseFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $DataParseFailureCopyWith(DataParseFailure value, $Res Function(DataParseFailure) _then) = _$DataParseFailureCopyWithImpl;
@override @useResult
$Res call({
 String message, Object? error
});




}
/// @nodoc
class _$DataParseFailureCopyWithImpl<$Res>
    implements $DataParseFailureCopyWith<$Res> {
  _$DataParseFailureCopyWithImpl(this._self, this._then);

  final DataParseFailure _self;
  final $Res Function(DataParseFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? error = freezed,}) {
  return _then(DataParseFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error ,
  ));
}


}

/// @nodoc


class NotFoundFailure extends Failure {
  const NotFoundFailure({required this.message}): super._();
  

@override final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotFoundFailureCopyWith<NotFoundFailure> get copyWith => _$NotFoundFailureCopyWithImpl<NotFoundFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NotFoundFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'Failure.notFoundFailure(message: $message)';
}


}

/// @nodoc
abstract mixin class $NotFoundFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $NotFoundFailureCopyWith(NotFoundFailure value, $Res Function(NotFoundFailure) _then) = _$NotFoundFailureCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class _$NotFoundFailureCopyWithImpl<$Res>
    implements $NotFoundFailureCopyWith<$Res> {
  _$NotFoundFailureCopyWithImpl(this._self, this._then);

  final NotFoundFailure _self;
  final $Res Function(NotFoundFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(NotFoundFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class InvalidOperationFailure extends Failure {
  const InvalidOperationFailure({required this.message}): super._();
  

@override final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvalidOperationFailureCopyWith<InvalidOperationFailure> get copyWith => _$InvalidOperationFailureCopyWithImpl<InvalidOperationFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is InvalidOperationFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'Failure.invalidOperationFailure(message: $message)';
}


}

/// @nodoc
abstract mixin class $InvalidOperationFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $InvalidOperationFailureCopyWith(InvalidOperationFailure value, $Res Function(InvalidOperationFailure) _then) = _$InvalidOperationFailureCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class _$InvalidOperationFailureCopyWithImpl<$Res>
    implements $InvalidOperationFailureCopyWith<$Res> {
  _$InvalidOperationFailureCopyWithImpl(this._self, this._then);

  final InvalidOperationFailure _self;
  final $Res Function(InvalidOperationFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(InvalidOperationFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required this.message, this.error}): super._();
  

@override final  String message;
 final  Object? error;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnexpectedFailureCopyWith<UnexpectedFailure> get copyWith => _$UnexpectedFailureCopyWithImpl<UnexpectedFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UnexpectedFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.error, error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message,const DeepCollectionEquality().hash(error));
}

@override
String toString() {
    return 'Failure.unexpectedFailure(message: $message, error: $error)';
}


}

/// @nodoc
abstract mixin class $UnexpectedFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $UnexpectedFailureCopyWith(UnexpectedFailure value, $Res Function(UnexpectedFailure) _then) = _$UnexpectedFailureCopyWithImpl;
@override @useResult
$Res call({
 String message, Object? error
});




}
/// @nodoc
class _$UnexpectedFailureCopyWithImpl<$Res>
    implements $UnexpectedFailureCopyWith<$Res> {
  _$UnexpectedFailureCopyWithImpl(this._self, this._then);

  final UnexpectedFailure _self;
  final $Res Function(UnexpectedFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? error = freezed,}) {
  return _then(UnexpectedFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error ,
  ));
}


}

/// @nodoc


class ApiFailure extends Failure {
  const ApiFailure({required this.message, required this.type, this.error}): super._();
  

@override final  String message;
 final  ApiErrorType type;
 final  Object? error;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiFailureCopyWith<ApiFailure> get copyWith => _$ApiFailureCopyWithImpl<ApiFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiFailure&&(identical(other.message, message) || other.message == message)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.error, error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message,type,const DeepCollectionEquality().hash(error));
}

@override
String toString() {
    return 'Failure.apiFailure(message: $message, type: $type, error: $error)';
}


}

/// @nodoc
abstract mixin class $ApiFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $ApiFailureCopyWith(ApiFailure value, $Res Function(ApiFailure) _then) = _$ApiFailureCopyWithImpl;
@override @useResult
$Res call({
 String message, ApiErrorType type, Object? error
});




}
/// @nodoc
class _$ApiFailureCopyWithImpl<$Res>
    implements $ApiFailureCopyWith<$Res> {
  _$ApiFailureCopyWithImpl(this._self, this._then);

  final ApiFailure _self;
  final $Res Function(ApiFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? type = null,Object? error = freezed,}) {
  return _then(ApiFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ApiErrorType,error: freezed == error ? _self.error : error ,
  ));
}


}

// dart format on
