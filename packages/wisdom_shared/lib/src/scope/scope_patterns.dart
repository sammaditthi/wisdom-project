import '../constants/tipitaka_node_keys.dart';

/// Pure node-key logic for Tipitaka scope filtering.
///
/// A scope is a set of tree node keys; a row belongs to it when the row's own
/// node key sits at or under one of them. The shared single source of truth
/// for that rule, used by the app and the static site generator.
///
/// Scope is *not* expressed as filenames: a node's text often sits in an
/// ancestor's file (one file can hold a whole commentary), so a filename
/// cannot say which node a row belongs to.
class ScopePatterns {
  ScopePatterns._();

  /// Root keys whose children don't carry the parent's key as a prefix.
  ///
  /// Tree ancestry is otherwise exactly key-prefix ancestry, so only these two
  /// need expanding: the nikayas under 'sp' are keyed 'dn', 'mn', … not 'sp-…',
  /// and likewise their commentaries under 'atta-sp'.
  static const Map<String, List<String>> expandedKeys = {
    TipitakaNodeKeys.suttaPitaka: [
      TipitakaNodeKeys.dighaNikaya,
      TipitakaNodeKeys.majjhimaNikaya,
      TipitakaNodeKeys.samyuttaNikaya,
      TipitakaNodeKeys.anguttaraNikaya,
      TipitakaNodeKeys.khuddakaNikaya,
    ],
    TipitakaNodeKeys.suttaAtthakatha: [
      'atta-${TipitakaNodeKeys.dighaNikaya}',
      'atta-${TipitakaNodeKeys.majjhimaNikaya}',
      'atta-${TipitakaNodeKeys.samyuttaNikaya}',
      'atta-${TipitakaNodeKeys.anguttaraNikaya}',
      'atta-${TipitakaNodeKeys.khuddakaNikaya}',
    ],
  };

  /// The node keys [nodeKey] stands for — itself, or its [expandedKeys] list.
  ///
  /// - 'dn' -> ['dn']
  /// - 'sp' -> ['dn', 'mn', 'sn', 'an', 'kn']
  static List<String> getKeysForNodeKey(String nodeKey) =>
      expandedKeys[nodeKey] ?? [nodeKey];

  /// The node keys a whole scope stands for.
  ///
  /// Returns empty for an empty [searchScope] (no filter = search all).
  static List<String> getKeysForScope(Set<String> searchScope) {
    if (searchScope.isEmpty) return const [];
    return searchScope.expand(getKeysForNodeKey).toList();
  }

  /// Does [nodeKey] sit at or under [scopeKey]?
  ///
  /// Keys are hyphen paths, so a descendant is the ancestor's key plus '-…'.
  /// The hyphen boundary carries the whole rule: 'atta-an-10' is a sibling of
  /// 'atta-an-1', not a child of it.
  ///
  /// `ScopeFilterSql.buildWhereClause` states the same rule as SQL for the
  /// database, so the two have to change together.
  static bool matchesNodeKey(String nodeKey, String scopeKey) =>
      nodeKey == scopeKey || nodeKey.startsWith('$scopeKey-');

  /// Check if [childNodeKey] is covered by (sits at or under) [ancestorNodeKey].
  ///
  /// Examples:
  /// - isNodeCoveredBy('dn', 'sp') -> true (dn is one of sp's expanded keys)
  /// - isNodeCoveredBy('dn-1', 'dn') -> true (dn-1 sits under dn)
  /// - isNodeCoveredBy('mn', 'dn') -> false
  /// - isNodeCoveredBy('sp', 'sp') -> true (a node covers itself)
  static bool isNodeCoveredBy(String childNodeKey, String ancestorNodeKey) {
    final ancestorKeys = getKeysForNodeKey(ancestorNodeKey);

    return getKeysForNodeKey(childNodeKey).every(
      (childKey) => ancestorKeys.any(
        (ancestorKey) => matchesNodeKey(childKey, ancestorKey),
      ),
    );
  }

  /// Find which of the [candidateAncestors] cover the given [nodeKey].
  ///
  /// Returns the set of ancestor keys that cover the node.
  /// A node covers itself (e.g., 'sp' is covered by {'sp'}).
  static Set<String> findCoveringAncestors(
    String nodeKey,
    Set<String> candidateAncestors,
  ) {
    return candidateAncestors
        .where((ancestor) => isNodeCoveredBy(nodeKey, ancestor))
        .toSet();
  }
}
