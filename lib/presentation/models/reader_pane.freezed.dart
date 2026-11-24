// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reader_pane.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReaderPane {
  /// Unique identifier for this pane instance
  /// Generated as UUID when creating a new pane
  String get paneId;

  /// Reference to the TextLayer being displayed
  /// Format: "{fileId}-{languageCode}-{scriptCode}[-{translator}]"
  /// Examples: 'dn1-pi-sinh', 'dn1-si-sinh', 'mn1-en-latn-sujato'
  String get layerId;

  /// Whether this pane is currently visible
  /// Hidden panes preserve their state but don't render
  bool get isVisible;

  /// Create a copy of ReaderPane
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReaderPaneCopyWith<ReaderPane> get copyWith =>
      _$ReaderPaneCopyWithImpl<ReaderPane>(this as ReaderPane, _$identity);

  /// Serializes this ReaderPane to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    final _this = this as ReaderPane;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ReaderPane &&
            (identical(other.paneId, _this.paneId) ||
                other.paneId == _this.paneId) &&
            (identical(other.layerId, _this.layerId) ||
                other.layerId == _this.layerId) &&
            (identical(other.isVisible, _this.isVisible) ||
                other.isVisible == _this.isVisible));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    final _this = this as ReaderPane;
    return Object.hash(
        runtimeType, _this.paneId, _this.layerId, _this.isVisible);
  }

  @override
  String toString() {
    final _this = this as ReaderPane;
    return 'ReaderPane(paneId: ${_this.paneId}, layerId: ${_this.layerId}, isVisible: ${_this.isVisible})';
  }
}

/// @nodoc
abstract mixin class $ReaderPaneCopyWith<$Res> {
  factory $ReaderPaneCopyWith(
          ReaderPane value, $Res Function(ReaderPane) _then) =
      _$ReaderPaneCopyWithImpl;
  @useResult
  $Res call({String paneId, String layerId, bool isVisible});
}

/// @nodoc
class _$ReaderPaneCopyWithImpl<$Res> implements $ReaderPaneCopyWith<$Res> {
  _$ReaderPaneCopyWithImpl(this._self, this._then);

  final ReaderPane _self;
  final $Res Function(ReaderPane) _then;

  /// Create a copy of ReaderPane
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paneId = null,
    Object? layerId = null,
    Object? isVisible = null,
  }) {
    return _then(ReaderPane(
      paneId: null == paneId
          ? _self.paneId
          : paneId // ignore: cast_nullable_to_non_nullable
              as String,
      layerId: null == layerId
          ? _self.layerId
          : layerId // ignore: cast_nullable_to_non_nullable
              as String,
      isVisible: null == isVisible
          ? _self.isVisible
          : isVisible // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [ReaderPane].
extension ReaderPanePatterns on ReaderPane {
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
    TResult Function(_ReaderPane value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ReaderPane() when $default != null:
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
    TResult Function(_ReaderPane value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReaderPane():
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
    TResult? Function(_ReaderPane value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReaderPane() when $default != null:
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
    TResult Function(String paneId, String layerId, bool isVisible)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ReaderPane() when $default != null:
        return $default(_that.paneId, _that.layerId, _that.isVisible);
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
    TResult Function(String paneId, String layerId, bool isVisible) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReaderPane():
        return $default(_that.paneId, _that.layerId, _that.isVisible);
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
    TResult? Function(String paneId, String layerId, bool isVisible)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReaderPane() when $default != null:
        return $default(_that.paneId, _that.layerId, _that.isVisible);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ReaderPane implements ReaderPane {
  const _ReaderPane(
      {required this.paneId, required this.layerId, this.isVisible = true});
  factory _ReaderPane.fromJson(Map<String, dynamic> json) =>
      _$ReaderPaneFromJson(json);

  /// Unique identifier for this pane instance
  /// Generated as UUID when creating a new pane
  @override
  final String paneId;

  /// Reference to the TextLayer being displayed
  /// Format: "{fileId}-{languageCode}-{scriptCode}[-{translator}]"
  /// Examples: 'dn1-pi-sinh', 'dn1-si-sinh', 'mn1-en-latn-sujato'
  @override
  final String layerId;

  /// Whether this pane is currently visible
  /// Hidden panes preserve their state but don't render
  @override
  @JsonKey()
  final bool isVisible;

  /// Create a copy of ReaderPane
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReaderPaneCopyWith<_ReaderPane> get copyWith =>
      __$ReaderPaneCopyWithImpl<_ReaderPane>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ReaderPaneToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ReaderPane &&
            (identical(other.paneId, paneId) || other.paneId == paneId) &&
            (identical(other.layerId, layerId) || other.layerId == layerId) &&
            (identical(other.isVisible, isVisible) ||
                other.isVisible == isVisible));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(runtimeType, paneId, layerId, isVisible);
  }

  @override
  String toString() {
    return 'ReaderPane(paneId: $paneId, layerId: $layerId, isVisible: $isVisible)';
  }
}

/// @nodoc
abstract mixin class _$ReaderPaneCopyWith<$Res>
    implements $ReaderPaneCopyWith<$Res> {
  factory _$ReaderPaneCopyWith(
          _ReaderPane value, $Res Function(_ReaderPane) _then) =
      __$ReaderPaneCopyWithImpl;
  @override
  @useResult
  $Res call({String paneId, String layerId, bool isVisible});
}

/// @nodoc
class __$ReaderPaneCopyWithImpl<$Res> implements _$ReaderPaneCopyWith<$Res> {
  __$ReaderPaneCopyWithImpl(this._self, this._then);

  final _ReaderPane _self;
  final $Res Function(_ReaderPane) _then;

  /// Create a copy of ReaderPane
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? paneId = null,
    Object? layerId = null,
    Object? isVisible = null,
  }) {
    return _then(_ReaderPane(
      paneId: null == paneId
          ? _self.paneId
          : paneId // ignore: cast_nullable_to_non_nullable
              as String,
      layerId: null == layerId
          ? _self.layerId
          : layerId // ignore: cast_nullable_to_non_nullable
              as String,
      isVisible: null == isVisible
          ? _self.isVisible
          : isVisible // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
