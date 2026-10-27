import 'scope_patterns.dart';

/// Converts search scope (tree node keys) into SQL WHERE clause fragments.
///
/// Used by both the Flutter client (Drift) and the Dart server (sqlite3)
/// to filter FTS search results by Tipitaka location.
class ScopeFilterSql {
  ScopeFilterSql._();

  /// Builds SQL WHERE clause fragment for scope filtering.
  ///
  /// Returns `null` if no filter should be applied (empty scope = search all).
  ///
  /// Each scope key contributes two tests — the node itself, then its subtree —
  /// because a container node has rows of its own (its heading) as well as rows
  /// under it. A lone `LIKE 'key-%'` would drop the former.
  ///
  /// Example:
  /// ```dart
  /// buildWhereClause({'dn'})
  /// // Returns: '((m.nodeKey = ? OR m.nodeKey LIKE ?))'
  ///
  /// buildWhereClause({'sp'})
  /// // Returns the same pair OR-ed five times (dn, mn, sn, an, kn)
  /// ```
  static String? buildWhereClause(
    Set<String> searchScope, {
    String tableAlias = 'm',
    String columnName = 'nodeKey',
  }) {
    final keys = ScopePatterns.getKeysForScope(searchScope);
    if (keys.isEmpty) return null;

    final conditions = keys
        .map((_) => '($tableAlias.$columnName = ? '
            'OR $tableAlias.$columnName LIKE ?)')
        .join(' OR ');

    return '($conditions)';
  }

  /// The SQL parameters for scope filtering: per key the exact node key, then
  /// its subtree pattern. Order must match the pairs [buildWhereClause] emits.
  ///
  /// No `ESCAPE` clause: node keys are `[a-z0-9.-]` only, so they carry no
  /// `LIKE` wildcard of their own.
  ///
  /// Example:
  /// ```dart
  /// getWhereParams({'dn'})
  /// // Returns: ['dn', 'dn-%']
  /// ```
  static List<String> getWhereParams(Set<String> scope) => [
        for (final key in ScopePatterns.getKeysForScope(scope)) ...[
          key,
          '$key-%',
        ],
      ];

  /// Builds the SQL WHERE clause fragment for the language filter (the
  /// පාළි / සිංහල search toggle), or `null` when [language] is null
  /// (= search both languages, the default).
  ///
  /// Like [buildWhereClause], the column lives on the meta table, so the
  /// caller prefixes this with `' AND '` and joins that table as [tableAlias].
  ///
  /// IMPORTANT: the DB stores Sinhala as `'sinh'` (not `'sinhala'`) and Pali as
  /// `'pali'`. Keeping this clause here means that column contract lives in one
  /// place for both the Flutter client and the Dart server.
  static String? buildLanguageClause(
    String? language, {
    String tableAlias = 'm',
    String columnName = 'language',
  }) {
    if (language == null) return null;
    return '$tableAlias.$columnName = ?';
  }

  /// The bound parameter(s) for the language filter: a single-element list with
  /// the DB language code, or empty when [language] is null (no filter).
  static List<String> getLanguageParams(String? language) =>
      language == null ? const [] : [language];
}
