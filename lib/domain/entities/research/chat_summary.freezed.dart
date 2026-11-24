// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatSummary {
  /// Stable id — also the suffix of the transcript's storage key.
  String get id;

  /// Display title: the chat's first user question (ellipsized by the UI).
  String get title;

  /// Last activity — drives newest-first ordering and the relative
  /// timestamp ("2 hours ago") in the list.
  DateTime get updatedAt;

  /// The Fast/Thinking tier this chat last sent a question under, so
  /// reopening it restores the same tier (a chat is remembered per-tier,
  /// unlike the "always Fast" new-chat default). Defaults to
  /// [ResearchMode.fast], which also covers chats saved before this field
  /// existed (the key is simply absent → Fast on read).
  ResearchMode get mode;

  /// Create a copy of ChatSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChatSummaryCopyWith<ChatSummary> get copyWith =>
      _$ChatSummaryCopyWithImpl<ChatSummary>(this as ChatSummary, _$identity);

  /// Serializes this ChatSummary to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    final _this = this as ChatSummary;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChatSummary &&
            (identical(other.id, _this.id) || other.id == _this.id) &&
            (identical(other.title, _this.title) ||
                other.title == _this.title) &&
            (identical(other.updatedAt, _this.updatedAt) ||
                other.updatedAt == _this.updatedAt) &&
            (identical(other.mode, _this.mode) || other.mode == _this.mode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    final _this = this as ChatSummary;
    return Object.hash(
        runtimeType, _this.id, _this.title, _this.updatedAt, _this.mode);
  }

  @override
  String toString() {
    final _this = this as ChatSummary;
    return 'ChatSummary(id: ${_this.id}, title: ${_this.title}, updatedAt: ${_this.updatedAt}, mode: ${_this.mode})';
  }
}

/// @nodoc
abstract mixin class $ChatSummaryCopyWith<$Res> {
  factory $ChatSummaryCopyWith(
          ChatSummary value, $Res Function(ChatSummary) _then) =
      _$ChatSummaryCopyWithImpl;
  @useResult
  $Res call({String id, String title, DateTime updatedAt, ResearchMode mode});
}

/// @nodoc
class _$ChatSummaryCopyWithImpl<$Res> implements $ChatSummaryCopyWith<$Res> {
  _$ChatSummaryCopyWithImpl(this._self, this._then);

  final ChatSummary _self;
  final $Res Function(ChatSummary) _then;

  /// Create a copy of ChatSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? updatedAt = null,
    Object? mode = null,
  }) {
    return _then(ChatSummary(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      mode: null == mode
          ? _self.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as ResearchMode,
    ));
  }
}

/// Adds pattern-matching-related methods to [ChatSummary].
extension ChatSummaryPatterns on ChatSummary {
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
    TResult Function(_ChatSummary value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatSummary() when $default != null:
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
    TResult Function(_ChatSummary value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatSummary():
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
    TResult? Function(_ChatSummary value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatSummary() when $default != null:
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
    TResult Function(
            String id, String title, DateTime updatedAt, ResearchMode mode)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatSummary() when $default != null:
        return $default(_that.id, _that.title, _that.updatedAt, _that.mode);
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
    TResult Function(
            String id, String title, DateTime updatedAt, ResearchMode mode)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatSummary():
        return $default(_that.id, _that.title, _that.updatedAt, _that.mode);
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
    TResult? Function(
            String id, String title, DateTime updatedAt, ResearchMode mode)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatSummary() when $default != null:
        return $default(_that.id, _that.title, _that.updatedAt, _that.mode);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ChatSummary implements ChatSummary {
  const _ChatSummary(
      {required this.id,
      required this.title,
      required this.updatedAt,
      this.mode = ResearchMode.fast});
  factory _ChatSummary.fromJson(Map<String, dynamic> json) =>
      _$ChatSummaryFromJson(json);

  /// Stable id — also the suffix of the transcript's storage key.
  @override
  final String id;

  /// Display title: the chat's first user question (ellipsized by the UI).
  @override
  final String title;

  /// Last activity — drives newest-first ordering and the relative
  /// timestamp ("2 hours ago") in the list.
  @override
  final DateTime updatedAt;

  /// The Fast/Thinking tier this chat last sent a question under, so
  /// reopening it restores the same tier (a chat is remembered per-tier,
  /// unlike the "always Fast" new-chat default). Defaults to
  /// [ResearchMode.fast], which also covers chats saved before this field
  /// existed (the key is simply absent → Fast on read).
  @override
  @JsonKey()
  final ResearchMode mode;

  /// Create a copy of ChatSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChatSummaryCopyWith<_ChatSummary> get copyWith =>
      __$ChatSummaryCopyWithImpl<_ChatSummary>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ChatSummaryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChatSummary &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.mode, mode) || other.mode == mode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(runtimeType, id, title, updatedAt, mode);
  }

  @override
  String toString() {
    return 'ChatSummary(id: $id, title: $title, updatedAt: $updatedAt, mode: $mode)';
  }
}

/// @nodoc
abstract mixin class _$ChatSummaryCopyWith<$Res>
    implements $ChatSummaryCopyWith<$Res> {
  factory _$ChatSummaryCopyWith(
          _ChatSummary value, $Res Function(_ChatSummary) _then) =
      __$ChatSummaryCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String title, DateTime updatedAt, ResearchMode mode});
}

/// @nodoc
class __$ChatSummaryCopyWithImpl<$Res> implements _$ChatSummaryCopyWith<$Res> {
  __$ChatSummaryCopyWithImpl(this._self, this._then);

  final _ChatSummary _self;
  final $Res Function(_ChatSummary) _then;

  /// Create a copy of ChatSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? updatedAt = null,
    Object? mode = null,
  }) {
    return _then(_ChatSummary(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      mode: null == mode
          ? _self.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as ResearchMode,
    ));
  }
}

// dart format on
