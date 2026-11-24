// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reader_tab.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReaderTab {
  /// Short label for tab display (truncated if needed)
  String get label;

  /// Full name for tooltip or expanded view
  String get fullName;

  /// The node this tab reads. Its subtree is the unit. Null only for a tab
  /// with no content.
  String? get nodeKey;

  /// The row scroll offset 0 sits on, as a document coordinate: what a
  /// search hit or a `?e=` link named, or where the reader re-anchored.
  /// Null is the unit's top. It never moves the unit, which is [nodeKey]'s.
  int? get anchorPageIndex;
  int? get anchorEntryIndex;

  /// Pali name of the node for reference
  String? get paliName;

  /// Sinhala name of the node for reference
  String? get sinhalaName;

  /// Universal text identifier (e.g., 'dn1', 'mn100', 'sn1-1')
  /// This is edition-agnostic and used for cross-edition alignment
  /// Nullable for backward compatibility - derived from contentFileId if needed
  String? get textId;

  /// List of panes to display in this tab
  /// Each pane shows one TextLayer (edition + language + script combination)
  /// Empty list means using legacy dual-pane mode (Pali + Sinhala)
  /// Nullable for backward compatibility
  List<ReaderPane> get panes;

  /// Reader layout mode for this tab (per-tab setting)
  /// Defaults to paliOnly for portrait mode, can be changed by user
  ReaderLayout get layout;

  /// Split ratio for side-by-side layout (0.0 to 1.0)
  /// Represents the proportion of width for the left (Pali) pane
  double get splitRatio;

  /// Last known scroll offset in pixels, measured from the anchor row
  /// (negative above it). Persisted so a reload resumes where reading stopped.
  double get scrollOffset;

  /// Create a copy of ReaderTab
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReaderTabCopyWith<ReaderTab> get copyWith =>
      _$ReaderTabCopyWithImpl<ReaderTab>(this as ReaderTab, _$identity);

  /// Serializes this ReaderTab to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    final _this = this as ReaderTab;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ReaderTab &&
            (identical(other.label, _this.label) ||
                other.label == _this.label) &&
            (identical(other.fullName, _this.fullName) ||
                other.fullName == _this.fullName) &&
            (identical(other.nodeKey, _this.nodeKey) ||
                other.nodeKey == _this.nodeKey) &&
            (identical(other.anchorPageIndex, _this.anchorPageIndex) ||
                other.anchorPageIndex == _this.anchorPageIndex) &&
            (identical(other.anchorEntryIndex, _this.anchorEntryIndex) ||
                other.anchorEntryIndex == _this.anchorEntryIndex) &&
            (identical(other.paliName, _this.paliName) ||
                other.paliName == _this.paliName) &&
            (identical(other.sinhalaName, _this.sinhalaName) ||
                other.sinhalaName == _this.sinhalaName) &&
            (identical(other.textId, _this.textId) ||
                other.textId == _this.textId) &&
            const DeepCollectionEquality().equals(other.panes, _this.panes) &&
            (identical(other.layout, _this.layout) ||
                other.layout == _this.layout) &&
            (identical(other.splitRatio, _this.splitRatio) ||
                other.splitRatio == _this.splitRatio) &&
            (identical(other.scrollOffset, _this.scrollOffset) ||
                other.scrollOffset == _this.scrollOffset));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    final _this = this as ReaderTab;
    return Object.hash(
        runtimeType,
        _this.label,
        _this.fullName,
        _this.nodeKey,
        _this.anchorPageIndex,
        _this.anchorEntryIndex,
        _this.paliName,
        _this.sinhalaName,
        _this.textId,
        const DeepCollectionEquality().hash(_this.panes),
        _this.layout,
        _this.splitRatio,
        _this.scrollOffset);
  }

  @override
  String toString() {
    final _this = this as ReaderTab;
    return 'ReaderTab(label: ${_this.label}, fullName: ${_this.fullName}, nodeKey: ${_this.nodeKey}, anchorPageIndex: ${_this.anchorPageIndex}, anchorEntryIndex: ${_this.anchorEntryIndex}, paliName: ${_this.paliName}, sinhalaName: ${_this.sinhalaName}, textId: ${_this.textId}, panes: ${_this.panes}, layout: ${_this.layout}, splitRatio: ${_this.splitRatio}, scrollOffset: ${_this.scrollOffset})';
  }
}

/// @nodoc
abstract mixin class $ReaderTabCopyWith<$Res> {
  factory $ReaderTabCopyWith(ReaderTab value, $Res Function(ReaderTab) _then) =
      _$ReaderTabCopyWithImpl;
  @useResult
  $Res call(
      {String label,
      String fullName,
      String? nodeKey,
      int? anchorPageIndex,
      int? anchorEntryIndex,
      String? paliName,
      String? sinhalaName,
      String? textId,
      List<ReaderPane> panes,
      ReaderLayout layout,
      double splitRatio,
      double scrollOffset});
}

/// @nodoc
class _$ReaderTabCopyWithImpl<$Res> implements $ReaderTabCopyWith<$Res> {
  _$ReaderTabCopyWithImpl(this._self, this._then);

  final ReaderTab _self;
  final $Res Function(ReaderTab) _then;

  /// Create a copy of ReaderTab
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? fullName = null,
    Object? nodeKey = freezed,
    Object? anchorPageIndex = freezed,
    Object? anchorEntryIndex = freezed,
    Object? paliName = freezed,
    Object? sinhalaName = freezed,
    Object? textId = freezed,
    Object? panes = null,
    Object? layout = null,
    Object? splitRatio = null,
    Object? scrollOffset = null,
  }) {
    return _then(ReaderTab(
      label: null == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _self.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      nodeKey: freezed == nodeKey
          ? _self.nodeKey
          : nodeKey // ignore: cast_nullable_to_non_nullable
              as String?,
      anchorPageIndex: freezed == anchorPageIndex
          ? _self.anchorPageIndex
          : anchorPageIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      anchorEntryIndex: freezed == anchorEntryIndex
          ? _self.anchorEntryIndex
          : anchorEntryIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      paliName: freezed == paliName
          ? _self.paliName
          : paliName // ignore: cast_nullable_to_non_nullable
              as String?,
      sinhalaName: freezed == sinhalaName
          ? _self.sinhalaName
          : sinhalaName // ignore: cast_nullable_to_non_nullable
              as String?,
      textId: freezed == textId
          ? _self.textId
          : textId // ignore: cast_nullable_to_non_nullable
              as String?,
      panes: null == panes
          ? _self.panes
          : panes // ignore: cast_nullable_to_non_nullable
              as List<ReaderPane>,
      layout: null == layout
          ? _self.layout
          : layout // ignore: cast_nullable_to_non_nullable
              as ReaderLayout,
      splitRatio: null == splitRatio
          ? _self.splitRatio
          : splitRatio // ignore: cast_nullable_to_non_nullable
              as double,
      scrollOffset: null == scrollOffset
          ? _self.scrollOffset
          : scrollOffset // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [ReaderTab].
extension ReaderTabPatterns on ReaderTab {
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
    TResult Function(_ReaderTab value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ReaderTab() when $default != null:
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
    TResult Function(_ReaderTab value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReaderTab():
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
    TResult? Function(_ReaderTab value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReaderTab() when $default != null:
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
            String label,
            String fullName,
            String? nodeKey,
            int? anchorPageIndex,
            int? anchorEntryIndex,
            String? paliName,
            String? sinhalaName,
            String? textId,
            List<ReaderPane> panes,
            ReaderLayout layout,
            double splitRatio,
            double scrollOffset)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ReaderTab() when $default != null:
        return $default(
            _that.label,
            _that.fullName,
            _that.nodeKey,
            _that.anchorPageIndex,
            _that.anchorEntryIndex,
            _that.paliName,
            _that.sinhalaName,
            _that.textId,
            _that.panes,
            _that.layout,
            _that.splitRatio,
            _that.scrollOffset);
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
            String label,
            String fullName,
            String? nodeKey,
            int? anchorPageIndex,
            int? anchorEntryIndex,
            String? paliName,
            String? sinhalaName,
            String? textId,
            List<ReaderPane> panes,
            ReaderLayout layout,
            double splitRatio,
            double scrollOffset)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReaderTab():
        return $default(
            _that.label,
            _that.fullName,
            _that.nodeKey,
            _that.anchorPageIndex,
            _that.anchorEntryIndex,
            _that.paliName,
            _that.sinhalaName,
            _that.textId,
            _that.panes,
            _that.layout,
            _that.splitRatio,
            _that.scrollOffset);
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
            String label,
            String fullName,
            String? nodeKey,
            int? anchorPageIndex,
            int? anchorEntryIndex,
            String? paliName,
            String? sinhalaName,
            String? textId,
            List<ReaderPane> panes,
            ReaderLayout layout,
            double splitRatio,
            double scrollOffset)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReaderTab() when $default != null:
        return $default(
            _that.label,
            _that.fullName,
            _that.nodeKey,
            _that.anchorPageIndex,
            _that.anchorEntryIndex,
            _that.paliName,
            _that.sinhalaName,
            _that.textId,
            _that.panes,
            _that.layout,
            _that.splitRatio,
            _that.scrollOffset);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ReaderTab extends ReaderTab {
  const _ReaderTab(
      {required this.label,
      required this.fullName,
      this.nodeKey,
      this.anchorPageIndex,
      this.anchorEntryIndex,
      this.paliName,
      this.sinhalaName,
      this.textId,
      List<ReaderPane> panes = const [],
      this.layout = ReaderLayout.paliOnly,
      this.splitRatio = 0.5,
      this.scrollOffset = 0.0})
      : assert(splitRatio >= 0.0 && splitRatio <= 1.0,
            'splitRatio must be between 0.0 and 1.0'),
        _panes = panes,
        super._();
  factory _ReaderTab.fromJson(Map<String, dynamic> json) =>
      _$ReaderTabFromJson(json);

  /// Short label for tab display (truncated if needed)
  @override
  final String label;

  /// Full name for tooltip or expanded view
  @override
  final String fullName;

  /// The node this tab reads. Its subtree is the unit. Null only for a tab
  /// with no content.
  @override
  final String? nodeKey;

  /// The row scroll offset 0 sits on, as a document coordinate: what a
  /// search hit or a `?e=` link named, or where the reader re-anchored.
  /// Null is the unit's top. It never moves the unit, which is [nodeKey]'s.
  @override
  final int? anchorPageIndex;
  @override
  final int? anchorEntryIndex;

  /// Pali name of the node for reference
  @override
  final String? paliName;

  /// Sinhala name of the node for reference
  @override
  final String? sinhalaName;

  /// Universal text identifier (e.g., 'dn1', 'mn100', 'sn1-1')
  /// This is edition-agnostic and used for cross-edition alignment
  /// Nullable for backward compatibility - derived from contentFileId if needed
  @override
  final String? textId;

  /// List of panes to display in this tab
  /// Each pane shows one TextLayer (edition + language + script combination)
  /// Empty list means using legacy dual-pane mode (Pali + Sinhala)
  /// Nullable for backward compatibility
  final List<ReaderPane> _panes;

  /// List of panes to display in this tab
  /// Each pane shows one TextLayer (edition + language + script combination)
  /// Empty list means using legacy dual-pane mode (Pali + Sinhala)
  /// Nullable for backward compatibility
  @override
  @JsonKey()
  List<ReaderPane> get panes {
    if (_panes is EqualUnmodifiableListView) return _panes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_panes);
  }

  /// Reader layout mode for this tab (per-tab setting)
  /// Defaults to paliOnly for portrait mode, can be changed by user
  @override
  @JsonKey()
  final ReaderLayout layout;

  /// Split ratio for side-by-side layout (0.0 to 1.0)
  /// Represents the proportion of width for the left (Pali) pane
  @override
  @JsonKey()
  final double splitRatio;

  /// Last known scroll offset in pixels, measured from the anchor row
  /// (negative above it). Persisted so a reload resumes where reading stopped.
  @override
  @JsonKey()
  final double scrollOffset;

  /// Create a copy of ReaderTab
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReaderTabCopyWith<_ReaderTab> get copyWith =>
      __$ReaderTabCopyWithImpl<_ReaderTab>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ReaderTabToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ReaderTab &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.nodeKey, nodeKey) || other.nodeKey == nodeKey) &&
            (identical(other.anchorPageIndex, anchorPageIndex) ||
                other.anchorPageIndex == anchorPageIndex) &&
            (identical(other.anchorEntryIndex, anchorEntryIndex) ||
                other.anchorEntryIndex == anchorEntryIndex) &&
            (identical(other.paliName, paliName) ||
                other.paliName == paliName) &&
            (identical(other.sinhalaName, sinhalaName) ||
                other.sinhalaName == sinhalaName) &&
            (identical(other.textId, textId) || other.textId == textId) &&
            const DeepCollectionEquality().equals(other.panes, _panes) &&
            (identical(other.layout, layout) || other.layout == layout) &&
            (identical(other.splitRatio, splitRatio) ||
                other.splitRatio == splitRatio) &&
            (identical(other.scrollOffset, scrollOffset) ||
                other.scrollOffset == scrollOffset));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(
        runtimeType,
        label,
        fullName,
        nodeKey,
        anchorPageIndex,
        anchorEntryIndex,
        paliName,
        sinhalaName,
        textId,
        const DeepCollectionEquality().hash(_panes),
        layout,
        splitRatio,
        scrollOffset);
  }

  @override
  String toString() {
    return 'ReaderTab(label: $label, fullName: $fullName, nodeKey: $nodeKey, anchorPageIndex: $anchorPageIndex, anchorEntryIndex: $anchorEntryIndex, paliName: $paliName, sinhalaName: $sinhalaName, textId: $textId, panes: $panes, layout: $layout, splitRatio: $splitRatio, scrollOffset: $scrollOffset)';
  }
}

/// @nodoc
abstract mixin class _$ReaderTabCopyWith<$Res>
    implements $ReaderTabCopyWith<$Res> {
  factory _$ReaderTabCopyWith(
          _ReaderTab value, $Res Function(_ReaderTab) _then) =
      __$ReaderTabCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String label,
      String fullName,
      String? nodeKey,
      int? anchorPageIndex,
      int? anchorEntryIndex,
      String? paliName,
      String? sinhalaName,
      String? textId,
      List<ReaderPane> panes,
      ReaderLayout layout,
      double splitRatio,
      double scrollOffset});
}

/// @nodoc
class __$ReaderTabCopyWithImpl<$Res> implements _$ReaderTabCopyWith<$Res> {
  __$ReaderTabCopyWithImpl(this._self, this._then);

  final _ReaderTab _self;
  final $Res Function(_ReaderTab) _then;

  /// Create a copy of ReaderTab
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? label = null,
    Object? fullName = null,
    Object? nodeKey = freezed,
    Object? anchorPageIndex = freezed,
    Object? anchorEntryIndex = freezed,
    Object? paliName = freezed,
    Object? sinhalaName = freezed,
    Object? textId = freezed,
    Object? panes = null,
    Object? layout = null,
    Object? splitRatio = null,
    Object? scrollOffset = null,
  }) {
    return _then(_ReaderTab(
      label: null == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _self.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      nodeKey: freezed == nodeKey
          ? _self.nodeKey
          : nodeKey // ignore: cast_nullable_to_non_nullable
              as String?,
      anchorPageIndex: freezed == anchorPageIndex
          ? _self.anchorPageIndex
          : anchorPageIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      anchorEntryIndex: freezed == anchorEntryIndex
          ? _self.anchorEntryIndex
          : anchorEntryIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      paliName: freezed == paliName
          ? _self.paliName
          : paliName // ignore: cast_nullable_to_non_nullable
              as String?,
      sinhalaName: freezed == sinhalaName
          ? _self.sinhalaName
          : sinhalaName // ignore: cast_nullable_to_non_nullable
              as String?,
      textId: freezed == textId
          ? _self.textId
          : textId // ignore: cast_nullable_to_non_nullable
              as String?,
      panes: null == panes
          ? _self._panes
          : panes // ignore: cast_nullable_to_non_nullable
              as List<ReaderPane>,
      layout: null == layout
          ? _self.layout
          : layout // ignore: cast_nullable_to_non_nullable
              as ReaderLayout,
      splitRatio: null == splitRatio
          ? _self.splitRatio
          : splitRatio // ignore: cast_nullable_to_non_nullable
              as double,
      scrollOffset: null == scrollOffset
          ? _self.scrollOffset
          : scrollOffset // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

// dart format on
