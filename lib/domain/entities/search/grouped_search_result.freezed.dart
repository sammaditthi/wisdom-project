// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grouped_search_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupedSearchResult {
  /// Results grouped by result type (limited preview, e.g., max 3 per result type)
  Map<SearchResultType, List<SearchResult>> get resultsByType;

  /// Create a copy of GroupedSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GroupedSearchResultCopyWith<GroupedSearchResult> get copyWith =>
      _$GroupedSearchResultCopyWithImpl<GroupedSearchResult>(
          this as GroupedSearchResult, _$identity);

  @override
  bool operator ==(Object other) {
    final _this = this as GroupedSearchResult;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GroupedSearchResult &&
            const DeepCollectionEquality()
                .equals(other.resultsByType, _this.resultsByType));
  }

  @override
  int get hashCode {
    final _this = this as GroupedSearchResult;
    return Object.hash(
        runtimeType, const DeepCollectionEquality().hash(_this.resultsByType));
  }

  @override
  String toString() {
    final _this = this as GroupedSearchResult;
    return 'GroupedSearchResult(resultsByType: ${_this.resultsByType})';
  }
}

/// @nodoc
abstract mixin class $GroupedSearchResultCopyWith<$Res> {
  factory $GroupedSearchResultCopyWith(
          GroupedSearchResult value, $Res Function(GroupedSearchResult) _then) =
      _$GroupedSearchResultCopyWithImpl;
  @useResult
  $Res call({Map<SearchResultType, List<SearchResult>> resultsByType});
}

/// @nodoc
class _$GroupedSearchResultCopyWithImpl<$Res>
    implements $GroupedSearchResultCopyWith<$Res> {
  _$GroupedSearchResultCopyWithImpl(this._self, this._then);

  final GroupedSearchResult _self;
  final $Res Function(GroupedSearchResult) _then;

  /// Create a copy of GroupedSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? resultsByType = null,
  }) {
    return _then(GroupedSearchResult(
      resultsByType: null == resultsByType
          ? _self.resultsByType
          : resultsByType // ignore: cast_nullable_to_non_nullable
              as Map<SearchResultType, List<SearchResult>>,
    ));
  }
}

/// Adds pattern-matching-related methods to [GroupedSearchResult].
extension GroupedSearchResultPatterns on GroupedSearchResult {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_GroupedSearchResult value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupedSearchResult() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_GroupedSearchResult value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupedSearchResult():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_GroupedSearchResult value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupedSearchResult() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(Map<SearchResultType, List<SearchResult>> resultsByType)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupedSearchResult() when $default != null:
        return $default(_that.resultsByType);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(Map<SearchResultType, List<SearchResult>> resultsByType)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupedSearchResult():
        return $default(_that.resultsByType);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(Map<SearchResultType, List<SearchResult>> resultsByType)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupedSearchResult() when $default != null:
        return $default(_that.resultsByType);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _GroupedSearchResult extends GroupedSearchResult {
  const _GroupedSearchResult(
      {required Map<SearchResultType, List<SearchResult>> resultsByType})
      : _resultsByType = resultsByType,
        super._();

  /// Results grouped by result type (limited preview, e.g., max 3 per result type)
  final Map<SearchResultType, List<SearchResult>> _resultsByType;

  /// Results grouped by result type (limited preview, e.g., max 3 per result type)
  @override
  Map<SearchResultType, List<SearchResult>> get resultsByType {
    if (_resultsByType is EqualUnmodifiableMapView) return _resultsByType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_resultsByType);
  }

  /// Create a copy of GroupedSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GroupedSearchResultCopyWith<_GroupedSearchResult> get copyWith =>
      __$GroupedSearchResultCopyWithImpl<_GroupedSearchResult>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GroupedSearchResult &&
            const DeepCollectionEquality()
                .equals(other.resultsByType, _resultsByType));
  }

  @override
  int get hashCode {
    return Object.hash(
        runtimeType, const DeepCollectionEquality().hash(_resultsByType));
  }

  @override
  String toString() {
    return 'GroupedSearchResult(resultsByType: $resultsByType)';
  }
}

/// @nodoc
abstract mixin class _$GroupedSearchResultCopyWith<$Res>
    implements $GroupedSearchResultCopyWith<$Res> {
  factory _$GroupedSearchResultCopyWith(_GroupedSearchResult value,
          $Res Function(_GroupedSearchResult) _then) =
      __$GroupedSearchResultCopyWithImpl;
  @override
  @useResult
  $Res call({Map<SearchResultType, List<SearchResult>> resultsByType});
}

/// @nodoc
class __$GroupedSearchResultCopyWithImpl<$Res>
    implements _$GroupedSearchResultCopyWith<$Res> {
  __$GroupedSearchResultCopyWithImpl(this._self, this._then);

  final _GroupedSearchResult _self;
  final $Res Function(_GroupedSearchResult) _then;

  /// Create a copy of GroupedSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? resultsByType = null,
  }) {
    return _then(_GroupedSearchResult(
      resultsByType: null == resultsByType
          ? _self._resultsByType
          : resultsByType // ignore: cast_nullable_to_non_nullable
              as Map<SearchResultType, List<SearchResult>>,
    ));
  }
}

// dart format on
