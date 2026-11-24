// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tipitaka_tree_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TipitakaTreeNode {

/// Unique key identifying this node in the tree structure
 String get nodeKey;/// Display name in Pali language
 String get paliName;/// Display name in Sinhala language
 String get sinhalaName;/// The hierarchical level/depth of this node in the tree (0 = root)
 int get hierarchyLevel;/// Index of the entry's page in the content file
 int get entryPageIndex;/// Index of the entry within the page
 int get entryIndexInPage;/// Key of the parent node (null for root nodes)
 String? get parentNodeKey;/// ID of the content file associated with this node (null for container nodes)
 String? get contentFileId;/// List of child nodes (empty for leaf nodes)
 List<TipitakaTreeNode> get childNodes;/// Indicates whether audio is available for this content
 bool get hasAudioAvailable;
/// Create a copy of TipitakaTreeNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TipitakaTreeNodeCopyWith<TipitakaTreeNode> get copyWith => _$TipitakaTreeNodeCopyWithImpl<TipitakaTreeNode>(this as TipitakaTreeNode, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TipitakaTreeNode;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TipitakaTreeNode&&(identical(other.nodeKey, _this.nodeKey) || other.nodeKey == _this.nodeKey)&&(identical(other.paliName, _this.paliName) || other.paliName == _this.paliName)&&(identical(other.sinhalaName, _this.sinhalaName) || other.sinhalaName == _this.sinhalaName)&&(identical(other.hierarchyLevel, _this.hierarchyLevel) || other.hierarchyLevel == _this.hierarchyLevel)&&(identical(other.entryPageIndex, _this.entryPageIndex) || other.entryPageIndex == _this.entryPageIndex)&&(identical(other.entryIndexInPage, _this.entryIndexInPage) || other.entryIndexInPage == _this.entryIndexInPage)&&(identical(other.parentNodeKey, _this.parentNodeKey) || other.parentNodeKey == _this.parentNodeKey)&&(identical(other.contentFileId, _this.contentFileId) || other.contentFileId == _this.contentFileId)&&const DeepCollectionEquality().equals(other.childNodes, _this.childNodes)&&(identical(other.hasAudioAvailable, _this.hasAudioAvailable) || other.hasAudioAvailable == _this.hasAudioAvailable));
}


@override
int get hashCode {
  final _this = this as TipitakaTreeNode;
  return Object.hash(runtimeType,_this.nodeKey,_this.paliName,_this.sinhalaName,_this.hierarchyLevel,_this.entryPageIndex,_this.entryIndexInPage,_this.parentNodeKey,_this.contentFileId,const DeepCollectionEquality().hash(_this.childNodes),_this.hasAudioAvailable);
}

@override
String toString() {
  final _this = this as TipitakaTreeNode;
  return 'TipitakaTreeNode(nodeKey: ${_this.nodeKey}, paliName: ${_this.paliName}, sinhalaName: ${_this.sinhalaName}, hierarchyLevel: ${_this.hierarchyLevel}, entryPageIndex: ${_this.entryPageIndex}, entryIndexInPage: ${_this.entryIndexInPage}, parentNodeKey: ${_this.parentNodeKey}, contentFileId: ${_this.contentFileId}, childNodes: ${_this.childNodes}, hasAudioAvailable: ${_this.hasAudioAvailable})';
}


}

/// @nodoc
abstract mixin class $TipitakaTreeNodeCopyWith<$Res>  {
  factory $TipitakaTreeNodeCopyWith(TipitakaTreeNode value, $Res Function(TipitakaTreeNode) _then) = _$TipitakaTreeNodeCopyWithImpl;
@useResult
$Res call({
 String nodeKey, String paliName, String sinhalaName, int hierarchyLevel, int entryPageIndex, int entryIndexInPage, String? parentNodeKey, String? contentFileId, List<TipitakaTreeNode> childNodes, bool hasAudioAvailable
});




}
/// @nodoc
class _$TipitakaTreeNodeCopyWithImpl<$Res>
    implements $TipitakaTreeNodeCopyWith<$Res> {
  _$TipitakaTreeNodeCopyWithImpl(this._self, this._then);

  final TipitakaTreeNode _self;
  final $Res Function(TipitakaTreeNode) _then;

/// Create a copy of TipitakaTreeNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nodeKey = null,Object? paliName = null,Object? sinhalaName = null,Object? hierarchyLevel = null,Object? entryPageIndex = null,Object? entryIndexInPage = null,Object? parentNodeKey = freezed,Object? contentFileId = freezed,Object? childNodes = null,Object? hasAudioAvailable = null,}) {
  return _then(TipitakaTreeNode(
nodeKey: null == nodeKey ? _self.nodeKey : nodeKey // ignore: cast_nullable_to_non_nullable
as String,paliName: null == paliName ? _self.paliName : paliName // ignore: cast_nullable_to_non_nullable
as String,sinhalaName: null == sinhalaName ? _self.sinhalaName : sinhalaName // ignore: cast_nullable_to_non_nullable
as String,hierarchyLevel: null == hierarchyLevel ? _self.hierarchyLevel : hierarchyLevel // ignore: cast_nullable_to_non_nullable
as int,entryPageIndex: null == entryPageIndex ? _self.entryPageIndex : entryPageIndex // ignore: cast_nullable_to_non_nullable
as int,entryIndexInPage: null == entryIndexInPage ? _self.entryIndexInPage : entryIndexInPage // ignore: cast_nullable_to_non_nullable
as int,parentNodeKey: freezed == parentNodeKey ? _self.parentNodeKey : parentNodeKey // ignore: cast_nullable_to_non_nullable
as String?,contentFileId: freezed == contentFileId ? _self.contentFileId : contentFileId // ignore: cast_nullable_to_non_nullable
as String?,childNodes: null == childNodes ? _self.childNodes : childNodes // ignore: cast_nullable_to_non_nullable
as List<TipitakaTreeNode>,hasAudioAvailable: null == hasAudioAvailable ? _self.hasAudioAvailable : hasAudioAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TipitakaTreeNode].
extension TipitakaTreeNodePatterns on TipitakaTreeNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TipitakaTreeNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TipitakaTreeNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TipitakaTreeNode value)  $default,){
final _that = this;
switch (_that) {
case _TipitakaTreeNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TipitakaTreeNode value)?  $default,){
final _that = this;
switch (_that) {
case _TipitakaTreeNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nodeKey,  String paliName,  String sinhalaName,  int hierarchyLevel,  int entryPageIndex,  int entryIndexInPage,  String? parentNodeKey,  String? contentFileId,  List<TipitakaTreeNode> childNodes,  bool hasAudioAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TipitakaTreeNode() when $default != null:
return $default(_that.nodeKey,_that.paliName,_that.sinhalaName,_that.hierarchyLevel,_that.entryPageIndex,_that.entryIndexInPage,_that.parentNodeKey,_that.contentFileId,_that.childNodes,_that.hasAudioAvailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nodeKey,  String paliName,  String sinhalaName,  int hierarchyLevel,  int entryPageIndex,  int entryIndexInPage,  String? parentNodeKey,  String? contentFileId,  List<TipitakaTreeNode> childNodes,  bool hasAudioAvailable)  $default,) {final _that = this;
switch (_that) {
case _TipitakaTreeNode():
return $default(_that.nodeKey,_that.paliName,_that.sinhalaName,_that.hierarchyLevel,_that.entryPageIndex,_that.entryIndexInPage,_that.parentNodeKey,_that.contentFileId,_that.childNodes,_that.hasAudioAvailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nodeKey,  String paliName,  String sinhalaName,  int hierarchyLevel,  int entryPageIndex,  int entryIndexInPage,  String? parentNodeKey,  String? contentFileId,  List<TipitakaTreeNode> childNodes,  bool hasAudioAvailable)?  $default,) {final _that = this;
switch (_that) {
case _TipitakaTreeNode() when $default != null:
return $default(_that.nodeKey,_that.paliName,_that.sinhalaName,_that.hierarchyLevel,_that.entryPageIndex,_that.entryIndexInPage,_that.parentNodeKey,_that.contentFileId,_that.childNodes,_that.hasAudioAvailable);case _:
  return null;

}
}

}

/// @nodoc


class _TipitakaTreeNode extends TipitakaTreeNode {
  const _TipitakaTreeNode({required this.nodeKey, required this.paliName, required this.sinhalaName, required this.hierarchyLevel, required this.entryPageIndex, required this.entryIndexInPage, this.parentNodeKey, this.contentFileId,  List<TipitakaTreeNode> childNodes = const [], this.hasAudioAvailable = false}): _childNodes = childNodes,super._();
  

/// Unique key identifying this node in the tree structure
@override final  String nodeKey;
/// Display name in Pali language
@override final  String paliName;
/// Display name in Sinhala language
@override final  String sinhalaName;
/// The hierarchical level/depth of this node in the tree (0 = root)
@override final  int hierarchyLevel;
/// Index of the entry's page in the content file
@override final  int entryPageIndex;
/// Index of the entry within the page
@override final  int entryIndexInPage;
/// Key of the parent node (null for root nodes)
@override final  String? parentNodeKey;
/// ID of the content file associated with this node (null for container nodes)
@override final  String? contentFileId;
/// List of child nodes (empty for leaf nodes)
 final  List<TipitakaTreeNode> _childNodes;
/// List of child nodes (empty for leaf nodes)
@override@JsonKey() List<TipitakaTreeNode> get childNodes {
  if (_childNodes is EqualUnmodifiableListView) return _childNodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_childNodes);
}

/// Indicates whether audio is available for this content
@override@JsonKey() final  bool hasAudioAvailable;

/// Create a copy of TipitakaTreeNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TipitakaTreeNodeCopyWith<_TipitakaTreeNode> get copyWith => __$TipitakaTreeNodeCopyWithImpl<_TipitakaTreeNode>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TipitakaTreeNode&&(identical(other.nodeKey, nodeKey) || other.nodeKey == nodeKey)&&(identical(other.paliName, paliName) || other.paliName == paliName)&&(identical(other.sinhalaName, sinhalaName) || other.sinhalaName == sinhalaName)&&(identical(other.hierarchyLevel, hierarchyLevel) || other.hierarchyLevel == hierarchyLevel)&&(identical(other.entryPageIndex, entryPageIndex) || other.entryPageIndex == entryPageIndex)&&(identical(other.entryIndexInPage, entryIndexInPage) || other.entryIndexInPage == entryIndexInPage)&&(identical(other.parentNodeKey, parentNodeKey) || other.parentNodeKey == parentNodeKey)&&(identical(other.contentFileId, contentFileId) || other.contentFileId == contentFileId)&&const DeepCollectionEquality().equals(other.childNodes, _childNodes)&&(identical(other.hasAudioAvailable, hasAudioAvailable) || other.hasAudioAvailable == hasAudioAvailable));
}


@override
int get hashCode {
    return Object.hash(runtimeType,nodeKey,paliName,sinhalaName,hierarchyLevel,entryPageIndex,entryIndexInPage,parentNodeKey,contentFileId,const DeepCollectionEquality().hash(_childNodes),hasAudioAvailable);
}

@override
String toString() {
    return 'TipitakaTreeNode(nodeKey: $nodeKey, paliName: $paliName, sinhalaName: $sinhalaName, hierarchyLevel: $hierarchyLevel, entryPageIndex: $entryPageIndex, entryIndexInPage: $entryIndexInPage, parentNodeKey: $parentNodeKey, contentFileId: $contentFileId, childNodes: $childNodes, hasAudioAvailable: $hasAudioAvailable)';
}


}

/// @nodoc
abstract mixin class _$TipitakaTreeNodeCopyWith<$Res> implements $TipitakaTreeNodeCopyWith<$Res> {
  factory _$TipitakaTreeNodeCopyWith(_TipitakaTreeNode value, $Res Function(_TipitakaTreeNode) _then) = __$TipitakaTreeNodeCopyWithImpl;
@override @useResult
$Res call({
 String nodeKey, String paliName, String sinhalaName, int hierarchyLevel, int entryPageIndex, int entryIndexInPage, String? parentNodeKey, String? contentFileId, List<TipitakaTreeNode> childNodes, bool hasAudioAvailable
});




}
/// @nodoc
class __$TipitakaTreeNodeCopyWithImpl<$Res>
    implements _$TipitakaTreeNodeCopyWith<$Res> {
  __$TipitakaTreeNodeCopyWithImpl(this._self, this._then);

  final _TipitakaTreeNode _self;
  final $Res Function(_TipitakaTreeNode) _then;

/// Create a copy of TipitakaTreeNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nodeKey = null,Object? paliName = null,Object? sinhalaName = null,Object? hierarchyLevel = null,Object? entryPageIndex = null,Object? entryIndexInPage = null,Object? parentNodeKey = freezed,Object? contentFileId = freezed,Object? childNodes = null,Object? hasAudioAvailable = null,}) {
  return _then(_TipitakaTreeNode(
nodeKey: null == nodeKey ? _self.nodeKey : nodeKey // ignore: cast_nullable_to_non_nullable
as String,paliName: null == paliName ? _self.paliName : paliName // ignore: cast_nullable_to_non_nullable
as String,sinhalaName: null == sinhalaName ? _self.sinhalaName : sinhalaName // ignore: cast_nullable_to_non_nullable
as String,hierarchyLevel: null == hierarchyLevel ? _self.hierarchyLevel : hierarchyLevel // ignore: cast_nullable_to_non_nullable
as int,entryPageIndex: null == entryPageIndex ? _self.entryPageIndex : entryPageIndex // ignore: cast_nullable_to_non_nullable
as int,entryIndexInPage: null == entryIndexInPage ? _self.entryIndexInPage : entryIndexInPage // ignore: cast_nullable_to_non_nullable
as int,parentNodeKey: freezed == parentNodeKey ? _self.parentNodeKey : parentNodeKey // ignore: cast_nullable_to_non_nullable
as String?,contentFileId: freezed == contentFileId ? _self.contentFileId : contentFileId // ignore: cast_nullable_to_non_nullable
as String?,childNodes: null == childNodes ? _self._childNodes : childNodes // ignore: cast_nullable_to_non_nullable
as List<TipitakaTreeNode>,hasAudioAvailable: null == hasAudioAvailable ? _self.hasAudioAvailable : hasAudioAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
