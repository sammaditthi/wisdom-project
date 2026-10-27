import '../scope/scope_filter_sql.dart';
import 'fts_query_builder.dart';

/// A SQL statement and the arguments its `?` placeholders take, in order.
typedef FtsStatement = ({String sql, List<Object> args});

/// SQL for "Anywhere in the same text", where the text is one sutta on one
/// language side.
///
/// FTS5's own AND matches inside a single indexed row, and a row is one entry —
/// one paragraph of one language side — so two words spread across a sutta
/// never matched. These statements match each word on its own and intersect the
/// hits by `(nodeKey, language)`.
///
/// Each surviving unit comes back as one row: the first word's first hit, the
/// entry the result opens at. `MIN(id)` finds it because ids are handed out in
/// document order (`tools/bjt-populate.js`). Ranking is that one entry's bm25,
/// so swapping the words typed can reorder the results.
class FtsSameTextSql {
  FtsSameTextSql._();

  /// The per-word expressions to intersect, or null when the query is not a
  /// multi-word "Anywhere in the same text" search — then there is nothing to
  /// intersect and the plain [buildFtsQuery] path applies.
  ///
  /// The one gate for this mode: search and count both ask here, so a badge
  /// can't be counted one way and the rows fetched another.
  static List<String>? wordQueries(
    String queryText, {
    required bool isExactMatch,
    required bool isPhraseSearch,
    required bool isAnywhereInText,
  }) {
    if (isPhraseSearch || !isAnywhereInText) return null;
    final words = ftsQueryWords(queryText);
    if (words.length < 2) return null;
    return [
      for (final word in words) ftsWordQuery(word, isExactMatch: isExactMatch),
    ];
  }

  /// The matching rows, best first — one per sutta and language side.
  static FtsStatement search({
    required String ftsTable,
    required String metaTable,
    required List<String> wordQueries,
    Set<String> scope = const {},
    String? language,
    required int limit,
    required int offset,
  }) {
    final hits = _hits(ftsTable, metaTable, wordQueries, scope, language);
    return (
      // The display columns ride along with `MIN(h.id)`: SQLite takes a bare
      // column from the row the min came from. Selecting them here rather than
      // rejoining `hits` is what keeps that CTE from being computed twice —
      // which would run every word's MATCH a second time.
      sql: '''
${hits.sql},
        anchors AS (
          SELECT MIN(h.id) AS id, h.filename AS filename, h.eind AS eind,
                 h.language AS language, h.type AS type, h.level AS level,
                 h.nodeKey AS nodeKey, h.score AS score
          FROM hits h
          JOIN units u ON h.nodeKey = u.nodeKey AND h.language = u.language
          WHERE h.w = 0
          GROUP BY h.nodeKey, h.language
        )
        SELECT id, filename, eind, language, type, level, nodeKey, score
        FROM anchors
        ORDER BY score, id
        LIMIT ? OFFSET ?
      ''',
      args: [...hits.args, limit, offset],
    );
  }

  /// How many rows [search] has to offer, for the tab badge.
  static FtsStatement count({
    required String ftsTable,
    required String metaTable,
    required List<String> wordQueries,
    Set<String> scope = const {},
    String? language,
  }) {
    final hits = _hits(ftsTable, metaTable, wordQueries, scope, language);
    return (
      sql: '${hits.sql}\n        SELECT COUNT(*) AS count FROM units',
      args: hits.args,
    );
  }

  /// The two CTEs both statements build on: `hits`, every row matching any one
  /// word and tagged with which; then `units`, the `(nodeKey, language)` pairs
  /// that matched all of them.
  static FtsStatement _hits(
    String ftsTable,
    String metaTable,
    List<String> wordQueries,
    Set<String> scope,
    String? language,
  ) {
    // Filters live on the meta table and so repeat in every branch — a word
    // out of scope must not qualify its sutta.
    final scopeClause = ScopeFilterSql.buildWhereClause(scope);
    final languageClause = ScopeFilterSql.buildLanguageClause(language);
    final filters = StringBuffer();
    if (scopeClause != null) filters.write(' AND $scopeClause');
    if (languageClause != null) filters.write(' AND $languageClause');

    final branches = <String>[];
    final args = <Object>[];
    for (var word = 0; word < wordQueries.length; word++) {
      branches.add('''
            SELECT $word AS w, m.id AS id, m.filename AS filename,
                   m.eind AS eind, m.language AS language, m.type AS type,
                   m.level AS level, m.nodeKey AS nodeKey,
                   bm25($ftsTable) AS score
            FROM $ftsTable
            JOIN $metaTable m ON $ftsTable.rowid = m.id
            WHERE $ftsTable MATCH ?$filters''');
      args
        ..add(wordQueries[word])
        ..addAll(ScopeFilterSql.getWhereParams(scope))
        ..addAll(ScopeFilterSql.getLanguageParams(language));
    }

    return (
      sql: '''
        WITH hits AS (
${branches.join('\n            UNION ALL\n')}
        ),
        units AS (
          SELECT nodeKey, language FROM hits
          GROUP BY nodeKey, language
          HAVING COUNT(DISTINCT w) = ${wordQueries.length}
        )''',
      args: args,
    );
  }
}
