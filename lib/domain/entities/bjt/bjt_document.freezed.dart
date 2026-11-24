// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bjt_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BJTDocument {
  /// The unique identifier for this document (filename without extension)
  String get fileId;

  /// List of pages containing the text
  List<BJTPage> get pages;

  /// Edition identifier - always 'bjt' for this class
  String get editionId;

  /// Index of `pages.first` in the whole file. Non-zero when only part of the
  /// file was loaded, which is what the reader asks for: everything that
  /// names a position — entry keys, search hits, deep links — is absolute,
  /// so this is what maps those onto [pages].
  int get firstPageIndex;

  /// Create a copy of BJTDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BJTDocumentCopyWith<BJTDocument> get copyWith =>
      _$BJTDocumentCopyWithImpl<BJTDocument>(this as BJTDocument, _$identity);

  @override
  bool operator ==(Object other) {
    final _this = this as BJTDocument;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BJTDocument &&
            (identical(other.fileId, _this.fileId) ||
                other.fileId == _this.fileId) &&
            const DeepCollectionEquality().equals(other.pages, _this.pages) &&
            (identical(other.editionId, _this.editionId) ||
                other.editionId == _this.editionId) &&
            (identical(other.firstPageIndex, _this.firstPageIndex) ||
                other.firstPageIndex == _this.firstPageIndex));
  }

  @override
  int get hashCode {
    final _this = this as BJTDocument;
    return Object.hash(
        runtimeType,
        _this.fileId,
        const DeepCollectionEquality().hash(_this.pages),
        _this.editionId,
        _this.firstPageIndex);
  }

  @override
  String toString() {
    final _this = this as BJTDocument;
    return 'BJTDocument(fileId: ${_this.fileId}, pages: ${_this.pages}, editionId: ${_this.editionId}, firstPageIndex: ${_this.firstPageIndex})';
  }
}

/// @nodoc
abstract mixin class $BJTDocumentCopyWith<$Res> {
  factory $BJTDocumentCopyWith(
          BJTDocument value, $Res Function(BJTDocument) _then) =
      _$BJTDocumentCopyWithImpl;
  @useResult
  $Res call(
      {String fileId,
      List<BJTPage> pages,
      String editionId,
      int firstPageIndex});
}

/// @nodoc
class _$BJTDocumentCopyWithImpl<$Res> implements $BJTDocumentCopyWith<$Res> {
  _$BJTDocumentCopyWithImpl(this._self, this._then);

  final BJTDocument _self;
  final $Res Function(BJTDocument) _then;

  /// Create a copy of BJTDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileId = null,
    Object? pages = null,
    Object? editionId = null,
    Object? firstPageIndex = null,
  }) {
    return _then(BJTDocument(
      fileId: null == fileId
          ? _self.fileId
          : fileId // ignore: cast_nullable_to_non_nullable
              as String,
      pages: null == pages
          ? _self.pages
          : pages // ignore: cast_nullable_to_non_nullable
              as List<BJTPage>,
      editionId: null == editionId
          ? _self.editionId
          : editionId // ignore: cast_nullable_to_non_nullable
              as String,
      firstPageIndex: null == firstPageIndex
          ? _self.firstPageIndex
          : firstPageIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [BJTDocument].
extension BJTDocumentPatterns on BJTDocument {
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
    TResult Function(_BJTDocument value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BJTDocument() when $default != null:
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
    TResult Function(_BJTDocument value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BJTDocument():
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
    TResult? Function(_BJTDocument value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BJTDocument() when $default != null:
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
    TResult Function(String fileId, List<BJTPage> pages, String editionId,
            int firstPageIndex)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BJTDocument() when $default != null:
        return $default(
            _that.fileId, _that.pages, _that.editionId, _that.firstPageIndex);
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
    TResult Function(String fileId, List<BJTPage> pages, String editionId,
            int firstPageIndex)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BJTDocument():
        return $default(
            _that.fileId, _that.pages, _that.editionId, _that.firstPageIndex);
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
    TResult? Function(String fileId, List<BJTPage> pages, String editionId,
            int firstPageIndex)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BJTDocument() when $default != null:
        return $default(
            _that.fileId, _that.pages, _that.editionId, _that.firstPageIndex);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _BJTDocument extends BJTDocument {
  const _BJTDocument(
      {required this.fileId,
      List<BJTPage> pages = const [],
      this.editionId = 'bjt',
      this.firstPageIndex = 0})
      : _pages = pages,
        super._();

  /// The unique identifier for this document (filename without extension)
  @override
  final String fileId;

  /// List of pages containing the text
  final List<BJTPage> _pages;

  /// List of pages containing the text
  @override
  @JsonKey()
  List<BJTPage> get pages {
    if (_pages is EqualUnmodifiableListView) return _pages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pages);
  }

  /// Edition identifier - always 'bjt' for this class
  @override
  @JsonKey()
  final String editionId;

  /// Index of `pages.first` in the whole file. Non-zero when only part of the
  /// file was loaded, which is what the reader asks for: everything that
  /// names a position — entry keys, search hits, deep links — is absolute,
  /// so this is what maps those onto [pages].
  @override
  @JsonKey()
  final int firstPageIndex;

  /// Create a copy of BJTDocument
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BJTDocumentCopyWith<_BJTDocument> get copyWith =>
      __$BJTDocumentCopyWithImpl<_BJTDocument>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BJTDocument &&
            (identical(other.fileId, fileId) || other.fileId == fileId) &&
            const DeepCollectionEquality().equals(other.pages, _pages) &&
            (identical(other.editionId, editionId) ||
                other.editionId == editionId) &&
            (identical(other.firstPageIndex, firstPageIndex) ||
                other.firstPageIndex == firstPageIndex));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, fileId,
        const DeepCollectionEquality().hash(_pages), editionId, firstPageIndex);
  }

  @override
  String toString() {
    return 'BJTDocument(fileId: $fileId, pages: $pages, editionId: $editionId, firstPageIndex: $firstPageIndex)';
  }
}

/// @nodoc
abstract mixin class _$BJTDocumentCopyWith<$Res>
    implements $BJTDocumentCopyWith<$Res> {
  factory _$BJTDocumentCopyWith(
          _BJTDocument value, $Res Function(_BJTDocument) _then) =
      __$BJTDocumentCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String fileId,
      List<BJTPage> pages,
      String editionId,
      int firstPageIndex});
}

/// @nodoc
class __$BJTDocumentCopyWithImpl<$Res> implements _$BJTDocumentCopyWith<$Res> {
  __$BJTDocumentCopyWithImpl(this._self, this._then);

  final _BJTDocument _self;
  final $Res Function(_BJTDocument) _then;

  /// Create a copy of BJTDocument
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? fileId = null,
    Object? pages = null,
    Object? editionId = null,
    Object? firstPageIndex = null,
  }) {
    return _then(_BJTDocument(
      fileId: null == fileId
          ? _self.fileId
          : fileId // ignore: cast_nullable_to_non_nullable
              as String,
      pages: null == pages
          ? _self._pages
          : pages // ignore: cast_nullable_to_non_nullable
              as List<BJTPage>,
      editionId: null == editionId
          ? _self.editionId
          : editionId // ignore: cast_nullable_to_non_nullable
              as String,
      firstPageIndex: null == firstPageIndex
          ? _self.firstPageIndex
          : firstPageIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
