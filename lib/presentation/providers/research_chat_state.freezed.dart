// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'research_chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ResearchChatState {
  /// Id of the saved chat this transcript belongs to, or null for a fresh
  /// chat that hasn't sent its first message yet (unsent chats are never
  /// persisted, so "New chat" spam can't pollute the Recent list).
  String? get sessionId;

  /// Full transcript, oldest first. Assistant turns carry their citations.
  List<ChatMessage> get messages;

  /// True while a question is in flight — disables the send button (a real
  /// client-side cost guardrail) and shows the busy row.
  bool get isLoading;

  /// The Fast/Thinking mode the in-flight request is running under, pinned at
  /// send time. The busy row's label ("Answering…" / "Thinking…") reads THIS,
  /// not the live global mode, so flipping the switch mid-request can't
  /// relabel the answer already running (mirrors how send() pins the mode it
  /// sends to the backend). Only meaningful while [isLoading]; not persisted —
  /// openChat restores it from the pending-session map, defaulting to fast.
  ResearchMode get inFlightMode;

  /// User-facing error message from the last attempt, or null. Kept as an
  /// English fallback / for logging; the chat view prefers [errorType] and
  /// re-localises by category (see research_error_messages.dart).
  String? get error;

  /// Category of the last error, or null. Drives the localised message and
  /// whether the chat view offers a Retry (see [ApiErrorType]).
  ApiErrorType? get errorType;

  /// Create a copy of ResearchChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ResearchChatStateCopyWith<ResearchChatState> get copyWith =>
      _$ResearchChatStateCopyWithImpl<ResearchChatState>(
          this as ResearchChatState, _$identity);

  @override
  bool operator ==(Object other) {
    final _this = this as ResearchChatState;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ResearchChatState &&
            (identical(other.sessionId, _this.sessionId) ||
                other.sessionId == _this.sessionId) &&
            const DeepCollectionEquality()
                .equals(other.messages, _this.messages) &&
            (identical(other.isLoading, _this.isLoading) ||
                other.isLoading == _this.isLoading) &&
            (identical(other.inFlightMode, _this.inFlightMode) ||
                other.inFlightMode == _this.inFlightMode) &&
            (identical(other.error, _this.error) ||
                other.error == _this.error) &&
            (identical(other.errorType, _this.errorType) ||
                other.errorType == _this.errorType));
  }

  @override
  int get hashCode {
    final _this = this as ResearchChatState;
    return Object.hash(
        runtimeType,
        _this.sessionId,
        const DeepCollectionEquality().hash(_this.messages),
        _this.isLoading,
        _this.inFlightMode,
        _this.error,
        _this.errorType);
  }

  @override
  String toString() {
    final _this = this as ResearchChatState;
    return 'ResearchChatState(sessionId: ${_this.sessionId}, messages: ${_this.messages}, isLoading: ${_this.isLoading}, inFlightMode: ${_this.inFlightMode}, error: ${_this.error}, errorType: ${_this.errorType})';
  }
}

/// @nodoc
abstract mixin class $ResearchChatStateCopyWith<$Res> {
  factory $ResearchChatStateCopyWith(
          ResearchChatState value, $Res Function(ResearchChatState) _then) =
      _$ResearchChatStateCopyWithImpl;
  @useResult
  $Res call(
      {String? sessionId,
      List<ChatMessage> messages,
      bool isLoading,
      ResearchMode inFlightMode,
      String? error,
      ApiErrorType? errorType});
}

/// @nodoc
class _$ResearchChatStateCopyWithImpl<$Res>
    implements $ResearchChatStateCopyWith<$Res> {
  _$ResearchChatStateCopyWithImpl(this._self, this._then);

  final ResearchChatState _self;
  final $Res Function(ResearchChatState) _then;

  /// Create a copy of ResearchChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = freezed,
    Object? messages = null,
    Object? isLoading = null,
    Object? inFlightMode = null,
    Object? error = freezed,
    Object? errorType = freezed,
  }) {
    return _then(ResearchChatState(
      sessionId: freezed == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      messages: null == messages
          ? _self.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<ChatMessage>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      inFlightMode: null == inFlightMode
          ? _self.inFlightMode
          : inFlightMode // ignore: cast_nullable_to_non_nullable
              as ResearchMode,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      errorType: freezed == errorType
          ? _self.errorType
          : errorType // ignore: cast_nullable_to_non_nullable
              as ApiErrorType?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ResearchChatState].
extension ResearchChatStatePatterns on ResearchChatState {
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
    TResult Function(_ResearchChatState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ResearchChatState() when $default != null:
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
    TResult Function(_ResearchChatState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ResearchChatState():
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
    TResult? Function(_ResearchChatState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ResearchChatState() when $default != null:
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
            String? sessionId,
            List<ChatMessage> messages,
            bool isLoading,
            ResearchMode inFlightMode,
            String? error,
            ApiErrorType? errorType)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ResearchChatState() when $default != null:
        return $default(_that.sessionId, _that.messages, _that.isLoading,
            _that.inFlightMode, _that.error, _that.errorType);
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
            String? sessionId,
            List<ChatMessage> messages,
            bool isLoading,
            ResearchMode inFlightMode,
            String? error,
            ApiErrorType? errorType)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ResearchChatState():
        return $default(_that.sessionId, _that.messages, _that.isLoading,
            _that.inFlightMode, _that.error, _that.errorType);
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
            String? sessionId,
            List<ChatMessage> messages,
            bool isLoading,
            ResearchMode inFlightMode,
            String? error,
            ApiErrorType? errorType)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ResearchChatState() when $default != null:
        return $default(_that.sessionId, _that.messages, _that.isLoading,
            _that.inFlightMode, _that.error, _that.errorType);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ResearchChatState extends ResearchChatState {
  const _ResearchChatState(
      {this.sessionId,
      List<ChatMessage> messages = const [],
      this.isLoading = false,
      this.inFlightMode = ResearchMode.fast,
      this.error,
      this.errorType})
      : _messages = messages,
        super._();

  /// Id of the saved chat this transcript belongs to, or null for a fresh
  /// chat that hasn't sent its first message yet (unsent chats are never
  /// persisted, so "New chat" spam can't pollute the Recent list).
  @override
  final String? sessionId;

  /// Full transcript, oldest first. Assistant turns carry their citations.
  final List<ChatMessage> _messages;

  /// Full transcript, oldest first. Assistant turns carry their citations.
  @override
  @JsonKey()
  List<ChatMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  /// True while a question is in flight — disables the send button (a real
  /// client-side cost guardrail) and shows the busy row.
  @override
  @JsonKey()
  final bool isLoading;

  /// The Fast/Thinking mode the in-flight request is running under, pinned at
  /// send time. The busy row's label ("Answering…" / "Thinking…") reads THIS,
  /// not the live global mode, so flipping the switch mid-request can't
  /// relabel the answer already running (mirrors how send() pins the mode it
  /// sends to the backend). Only meaningful while [isLoading]; not persisted —
  /// openChat restores it from the pending-session map, defaulting to fast.
  @override
  @JsonKey()
  final ResearchMode inFlightMode;

  /// User-facing error message from the last attempt, or null. Kept as an
  /// English fallback / for logging; the chat view prefers [errorType] and
  /// re-localises by category (see research_error_messages.dart).
  @override
  final String? error;

  /// Category of the last error, or null. Drives the localised message and
  /// whether the chat view offers a Retry (see [ApiErrorType]).
  @override
  final ApiErrorType? errorType;

  /// Create a copy of ResearchChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ResearchChatStateCopyWith<_ResearchChatState> get copyWith =>
      __$ResearchChatStateCopyWithImpl<_ResearchChatState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ResearchChatState &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            const DeepCollectionEquality().equals(other.messages, _messages) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.inFlightMode, inFlightMode) ||
                other.inFlightMode == inFlightMode) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.errorType, errorType) ||
                other.errorType == errorType));
  }

  @override
  int get hashCode {
    return Object.hash(
        runtimeType,
        sessionId,
        const DeepCollectionEquality().hash(_messages),
        isLoading,
        inFlightMode,
        error,
        errorType);
  }

  @override
  String toString() {
    return 'ResearchChatState(sessionId: $sessionId, messages: $messages, isLoading: $isLoading, inFlightMode: $inFlightMode, error: $error, errorType: $errorType)';
  }
}

/// @nodoc
abstract mixin class _$ResearchChatStateCopyWith<$Res>
    implements $ResearchChatStateCopyWith<$Res> {
  factory _$ResearchChatStateCopyWith(
          _ResearchChatState value, $Res Function(_ResearchChatState) _then) =
      __$ResearchChatStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? sessionId,
      List<ChatMessage> messages,
      bool isLoading,
      ResearchMode inFlightMode,
      String? error,
      ApiErrorType? errorType});
}

/// @nodoc
class __$ResearchChatStateCopyWithImpl<$Res>
    implements _$ResearchChatStateCopyWith<$Res> {
  __$ResearchChatStateCopyWithImpl(this._self, this._then);

  final _ResearchChatState _self;
  final $Res Function(_ResearchChatState) _then;

  /// Create a copy of ResearchChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sessionId = freezed,
    Object? messages = null,
    Object? isLoading = null,
    Object? inFlightMode = null,
    Object? error = freezed,
    Object? errorType = freezed,
  }) {
    return _then(_ResearchChatState(
      sessionId: freezed == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      messages: null == messages
          ? _self._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<ChatMessage>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      inFlightMode: null == inFlightMode
          ? _self.inFlightMode
          : inFlightMode // ignore: cast_nullable_to_non_nullable
              as ResearchMode,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      errorType: freezed == errorType
          ? _self.errorType
          : errorType // ignore: cast_nullable_to_non_nullable
              as ApiErrorType?,
    ));
  }
}

// dart format on
