import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/data/database/local_database.dart';
import 'package:wisdom_shared/wisdom_shared.dart';

/// "Anywhere in the same text" against a REAL FTS5 engine, driving the same
/// [FtsSameTextSql] the datasource sends — no second copy of the SQL here.
///
/// The bug pinned below: FTS5's AND holds only inside one indexed row, and a
/// row is one entry, so `අනාථපිණ්ඩිකො සැරියුත්` found just the commentary
/// paragraph carrying both words. The sutta keeps the Pali name in its heading
/// and the Sinhala name in its prose, so no single entry of it ever matched.
void main() {
  late LocalDatabase db;

  // The index's own tokenchars, the whole Sinhala block, so a word keeps its
  // combining marks. Built from the range rather than pasted: one invisible
  // character in a literal would quietly retokenize every row.
  final tokenchars =
      String.fromCharCodes([for (var c = 0x0D80; c <= 0x0DFF; c++) c]);

  const anathapindiko = 'අනාථපිණ්ඩිකො';
  const sariyut = 'සැරියුත්';
  // In the sutta's closing line only, so a third word narrows to it alone.
  const palamu = 'පළමු';

  var nextId = 1;

  /// One indexed entry, ids handed out in document order like `bjt-populate.js`.
  Future<void> entry({
    required String filename,
    required String eind,
    required String language,
    required String nodeKey,
    required String text,
    String type = 'paragraph',
  }) async {
    final id = nextId++;
    await db.customStatement(
      'INSERT INTO bjt_fts(rowid, text) VALUES (?, ?)',
      [id, text],
    );
    await db.customStatement(
      'INSERT INTO bjt_meta VALUES (?, ?, ?, ?, ?, ?, ?)',
      [id, filename, eind, language, type, 0, nodeKey],
    );
  }

  setUp(() async {
    db = LocalDatabase(NativeDatabase.memory());
    nextId = 1;
    await db.customStatement(
      // content='' like the real index: the text is stored zlib'd elsewhere,
      // so nothing can select it back out of here.
      'CREATE VIRTUAL TABLE bjt_fts USING fts5(text, content=\'\', '
      'tokenize="unicode61 tokenchars \'$tokenchars\'");',
    );
    await db.customStatement('''
      CREATE TABLE bjt_meta (
        id INTEGER PRIMARY KEY,
        filename TEXT, eind TEXT, language TEXT,
        type TEXT, level INTEGER, nodeKey TEXT
      );
    ''');

    // The reported sutta: the Pali name only in the heading and the closing
    // line, the Sinhala name only in the prose between them.
    await entry(
      filename: 'mn-3-5',
      eind: '0-2',
      language: 'sinh',
      nodeKey: 'mn-3-5-1',
      type: 'heading',
      text: '$anathapindikoවාද සූත්‍රය',
    );
    await entry(
      filename: 'mn-3-5',
      eind: '0-3',
      language: 'sinh',
      nodeKey: 'mn-3-5-1',
      text: 'යළි ආයුෂ්මත් $sariyut තෙරුන් කරා එළැඹැ',
    );
    await entry(
      filename: 'mn-3-5',
      eind: '4-9',
      language: 'sinh',
      nodeKey: 'mn-3-5-1',
      type: 'centered',
      text: 'පළමු වැනි $anathapindikoවාද සූත්‍ර යි.',
    );

    // Its commentary: one paragraph quotes the Pali lemma and glosses in
    // Sinhala, so this was the only thing the old per-row AND could find.
    await entry(
      filename: 'atta-mn-3',
      eind: '174-5',
      language: 'sinh',
      nodeKey: 'atta-mn-3-5-1',
      text: '$sariyut තෙරුන්ගේ ද ගුණ කියා අථ ඛො $anathapindikoති යනාදිය',
    );

    // Only the first word: must not qualify on its own.
    await entry(
      filename: 'an-5',
      eind: '34-3',
      language: 'sinh',
      nodeKey: 'an-5-1-5-1',
      text: 'අථ ඛො $anathapindiko ගහපති',
    );

    // One sutta, one word on each language side: the sides are separate texts.
    await entry(
      filename: 'dn-1',
      eind: '0-0',
      language: 'pali',
      nodeKey: 'dn-1-1',
      text: 'අථ ඛො $anathapindiko ගහපති',
    );
    await entry(
      filename: 'dn-1',
      eind: '0-1',
      language: 'sinh',
      nodeKey: 'dn-1-1',
      text: 'ආයුෂ්මත් $sariyut තෙරණුවෝ',
    );
  });

  tearDown(() async => db.close());

  List<String> wordsFor(String query) => FtsSameTextSql.wordQueries(
        query,
        isExactMatch: false,
        isPhraseSearch: false,
        isAnywhereInText: true,
      )!;

  Future<List<Map<String, dynamic>>> sameText(
    String query, {
    String? language,
    Set<String> scope = const {},
    int limit = 50,
    int offset = 0,
  }) async {
    final statement = FtsSameTextSql.search(
      ftsTable: 'bjt_fts',
      metaTable: 'bjt_meta',
      wordQueries: wordsFor(query),
      scope: scope,
      language: language,
      limit: limit,
      offset: offset,
    );
    return db.rawQuery(statement.sql, statement.args);
  }

  Future<List<String>> matchedNodeKeys(
    String query, {
    String? language,
    Set<String> scope = const {},
  }) async {
    final rows = await sameText(query, language: language, scope: scope);
    return [for (final row in rows) row['nodeKey'] as String];
  }

  Future<int> countSameText(String query, {String? language}) async {
    final statement = FtsSameTextSql.count(
      ftsTable: 'bjt_fts',
      metaTable: 'bjt_meta',
      wordQueries: wordsFor(query),
      language: language,
    );
    final rows = await db.rawQuery(statement.sql, statement.args);
    return rows.first['count'] as int;
  }

  /// The single MATCH this mode used to send, where both words had to land in
  /// the same entry.
  Future<List<String>> perRowAnd(String query) async {
    final rows = await db.rawQuery(
      'SELECT m.nodeKey FROM bjt_fts JOIN bjt_meta m ON bjt_fts.rowid = m.id '
      'WHERE bjt_fts MATCH ?',
      [buildFtsQuery(query, isPhraseSearch: false, isAnywhereInText: true)],
    );
    return [for (final row in rows) row['nodeKey'] as String];
  }

  group('the bug', () {
    test('the old per-row AND found only the commentary', () async {
      expect(
        await perRowAnd('$anathapindiko $sariyut'),
        ['atta-mn-3-5-1'],
      );
    });

    test('words in different entries of one sutta now match', () async {
      expect(
        await matchedNodeKeys('$anathapindiko $sariyut'),
        containsAll(['mn-3-5-1', 'atta-mn-3-5-1']),
      );
    });
  });

  group('what still must not match', () {
    test('a sutta carrying only one of the words', () async {
      expect(
        await matchedNodeKeys('$anathapindiko $sariyut'),
        isNot(contains('an-5-1-5-1')),
      );
    });

    test('one word on each language side of the same sutta', () async {
      expect(
        await matchedNodeKeys('$anathapindiko $sariyut'),
        isNot(contains('dn-1-1')),
      );
    });
  });

  group('the row each match comes back as', () {
    test('is the first word\'s first hit', () async {
      final rows = await sameText('$anathapindiko $sariyut');
      final sutta = rows.firstWhere((row) => row['nodeKey'] == 'mn-3-5-1');
      // 0-2 and 4-9 both hold the first word; 0-2 comes first.
      expect(sutta['eind'], '0-2');
    });

    test('follows the word order typed', () async {
      final rows = await sameText('$sariyut $anathapindiko');
      final sutta = rows.firstWhere((row) => row['nodeKey'] == 'mn-3-5-1');
      expect(sutta['eind'], '0-3');
    });

    test('is one row per sutta and language side', () async {
      final keys = await matchedNodeKeys('$anathapindiko $sariyut');
      expect(keys.toSet().length, keys.length);
    });

    test('is still the first word\'s first hit with a third word', () async {
      // The commentary has the first two words but not පළමු, so it drops out.
      final rows = await sameText('$anathapindiko $sariyut $palamu');
      expect([for (final row in rows) row['nodeKey']], ['mn-3-5-1']);
      expect(rows.single['eind'], '0-2');
    });
  });

  group('paging', () {
    test('walks the ranked list without repeating or dropping a sutta',
        () async {
      const query = '$anathapindiko $sariyut';
      final all = await matchedNodeKeys(query);
      expect(all.length, greaterThan(1));
      final paged = <String>[];
      for (var offset = 0; offset < all.length; offset++) {
        final page = await sameText(query, limit: 1, offset: offset);
        paged.add(page.single['nodeKey'] as String);
      }
      expect(paged, all);
    });
  });

  group('filters', () {
    test('the count matches the rows the search returns', () async {
      expect(
        await countSameText('$anathapindiko $sariyut'),
        (await matchedNodeKeys('$anathapindiko $sariyut')).length,
      );
    });

    test('a language filter applies to every word', () async {
      expect(await matchedNodeKeys('$anathapindiko $sariyut', language: 'pali'),
          isEmpty);
      expect(
          await countSameText('$anathapindiko $sariyut', language: 'pali'), 0);
    });

    test('a scope filter applies to every word', () async {
      expect(
        await matchedNodeKeys('$anathapindiko $sariyut', scope: {'mn'}),
        ['mn-3-5-1'],
      );
    });
  });

  group('which queries take this path at all', () {
    test('a multi-word Anywhere search does', () {
      expect(
        FtsSameTextSql.wordQueries(
          '$anathapindiko $sariyut',
          isExactMatch: false,
          isPhraseSearch: false,
          isAnywhereInText: true,
        ),
        ['$anathapindiko*', '$sariyut*'],
      );
    });

    test('Whole word drops the wildcards', () {
      expect(
        FtsSameTextSql.wordQueries(
          '$anathapindiko $sariyut',
          isExactMatch: true,
          isPhraseSearch: false,
          isAnywhereInText: true,
        ),
        [anathapindiko, sariyut],
      );
    });

    test('one word does not: there is nothing to intersect', () {
      expect(
        FtsSameTextSql.wordQueries(
          anathapindiko,
          isExactMatch: false,
          isPhraseSearch: false,
          isAnywhereInText: true,
        ),
        isNull,
      );
    });

    test('As a phrase and Near each other do not', () {
      const query = '$anathapindiko $sariyut';
      expect(
        FtsSameTextSql.wordQueries(
          query,
          isExactMatch: false,
          isPhraseSearch: true,
          isAnywhereInText: false,
        ),
        isNull,
      );
      expect(
        FtsSameTextSql.wordQueries(
          query,
          isExactMatch: false,
          isPhraseSearch: false,
          isAnywhereInText: false,
        ),
        isNull,
      );
    });
  });
}
