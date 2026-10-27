import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/core/constants/constants.dart';
import 'package:the_wisdom_project/data/services/scope_filter_service.dart';

/// One scope key's test: the node itself, then its subtree.
const kPair = '(m.nodeKey = ? OR m.nodeKey LIKE ?)';

void main() {
  group('ScopeFilterService -', () {
    group('buildWhereClause', () {
      // Test 1: Empty scope returns null (no filter)
      test('should return null when scope set is empty', () {
        // ACT
        final whereClause = ScopeFilterService.buildWhereClause({});

        // ASSERT - null means "search all content"
        expect(whereClause, isNull);
      });

      // Test 2: Single node key generates correct SQL
      test('should generate SQL with single condition for single node', () {
        // ACT
        final whereClause = ScopeFilterService.buildWhereClause({
          TipitakaNodeKeys.vinayaPitaka,
        });

        // ASSERT
        expect(whereClause, equals('($kPair)'));
      });

      // Test 3: Multiple node keys generate OR logic
      test('should generate SQL with OR conditions for multiple nodes', () {
        // ACT
        final whereClause = ScopeFilterService.buildWhereClause({
          TipitakaNodeKeys.suttaPitaka,
          TipitakaNodeKeys.suttaAtthakatha,
        });

        // ASSERT - 5 keys for sp + 5 for atta-sp = 10 OR-ed pairs
        expect(whereClause, contains('OR'));
        expect(
          whereClause,
          equals('(${List.filled(10, kPair).join(' OR ')})'),
        );
      });

      // Test 4: Specific nikaya keys
      test('should generate SQL for specific nikaya keys', () {
        // ACT
        final whereClause = ScopeFilterService.buildWhereClause({
          TipitakaNodeKeys.dighaNikaya,
          TipitakaNodeKeys.majjhimaNikaya,
        });

        // ASSERT - 2 keys = 2 OR-ed pairs
        expect(whereClause, contains('OR'));
        expect(whereClause, equals('($kPair OR $kPair)'));
      });

      // Test 5: Custom table alias and column name
      test('should use custom table alias and column name', () {
        // ACT
        final whereClause = ScopeFilterService.buildWhereClause(
          {TipitakaNodeKeys.vinayaPitaka},
          tableAlias: 'meta',
          columnName: 'node_key',
        );

        // ASSERT
        expect(
          whereClause,
          equals('((meta.node_key = ? OR meta.node_key LIKE ?))'),
        );
      });
    });

    group('getWhereParams', () {
      // Test 6: Empty scope returns empty params
      test('should return empty list when scope set is empty', () {
        // ACT
        final params = ScopeFilterService.getWhereParams({});

        // ASSERT
        expect(params, isEmpty);
      });

      // Test 7: Single node key returns the key and its subtree pattern
      test('should return exact key then subtree pattern for single node', () {
        // ACT
        final params = ScopeFilterService.getWhereParams({
          TipitakaNodeKeys.vinayaPitaka,
        });

        // ASSERT - the node's own rows, plus everything under it
        expect(params, equals(['vp', 'vp-%']));
      });

      // Test 8: Sutta Pitaka expands to nikaya keys
      test('should return all nikaya params for sp key', () {
        // ACT
        final params = ScopeFilterService.getWhereParams({
          TipitakaNodeKeys.suttaPitaka,
        });

        // ASSERT
        expect(
          params,
          equals([
            'dn', 'dn-%', //
            'mn', 'mn-%',
            'sn', 'sn-%',
            'an', 'an-%',
            'kn', 'kn-%',
          ]),
        );
      });

      // Test 9: Multiple node keys return all params
      test('should return all params in pairs for multiple nodes', () {
        // ACT
        final params = ScopeFilterService.getWhereParams({
          TipitakaNodeKeys.dighaNikaya,
          TipitakaNodeKeys.majjhimaNikaya,
        });

        // ASSERT
        expect(params, equals(['dn', 'dn-%', 'mn', 'mn-%']));
      });

      // Test 10: Commentary expansion
      test('should expand atta-sp to commentary params', () {
        // ACT
        final params = ScopeFilterService.getWhereParams({
          TipitakaNodeKeys.suttaAtthakatha,
        });

        // ASSERT
        expect(
          params,
          equals([
            'atta-dn', 'atta-dn-%', //
            'atta-mn', 'atta-mn-%',
            'atta-sn', 'atta-sn-%',
            'atta-an', 'atta-an-%',
            'atta-kn', 'atta-kn-%',
          ]),
        );
      });
    });
  });
}
