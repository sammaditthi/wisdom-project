import 'package:test/test.dart';
import 'package:wisdom_shared/wisdom_shared.dart';

// Guards the shared node-key rule that scope filtering is built on: which keys
// a ticked node stands for, and whether a row's key sits inside it. These moved
// here from the app's ScopeOperations test when its delegating wrappers went.
void main() {
  group('ScopePatterns.getKeysForNodeKey', () {
    test('expands sp to nikaya keys', () {
      expect(
        ScopePatterns.getKeysForNodeKey(TipitakaNodeKeys.suttaPitaka),
        equals(['dn', 'mn', 'sn', 'an', 'kn']),
      );
    });

    test('expands atta-sp to commentary keys', () {
      expect(
        ScopePatterns.getKeysForNodeKey(TipitakaNodeKeys.suttaAtthakatha),
        equals(['atta-dn', 'atta-mn', 'atta-sn', 'atta-an', 'atta-kn']),
      );
    });

    test('returns the key itself for the roots that need no expanding', () {
      expect(ScopePatterns.getKeysForNodeKey(TipitakaNodeKeys.vinayaPitaka),
          equals(['vp']));
      expect(ScopePatterns.getKeysForNodeKey(TipitakaNodeKeys.abhidhammaPitaka),
          equals(['ap']));
      expect(ScopePatterns.getKeysForNodeKey(TipitakaNodeKeys.treatises),
          equals(['anya']));
    });

    test('returns the key itself for a node inside a branch', () {
      expect(ScopePatterns.getKeysForNodeKey(TipitakaNodeKeys.dighaNikaya),
          equals(['dn']));
      expect(ScopePatterns.getKeysForNodeKey('dn-1'), equals(['dn-1']));
    });
  });

  group('ScopePatterns.getKeysForScope', () {
    test('returns empty list when scope set is empty (no filter)', () {
      expect(ScopePatterns.getKeysForScope({}), isEmpty);
    });

    test('expands and combines the keys of every selected node', () {
      final keys = ScopePatterns.getKeysForScope({
        TipitakaNodeKeys.suttaPitaka,
        TipitakaNodeKeys.vinayaPitaka,
      });
      expect(keys, containsAll(['dn', 'mn', 'sn', 'an', 'kn', 'vp']));
      expect(keys.length, equals(6)); // 5 sutta + 1 vinaya
    });

    test('keeps keys that need no expanding as they are', () {
      expect(
        ScopePatterns.getKeysForScope(
            {TipitakaNodeKeys.dighaNikaya, TipitakaNodeKeys.majjhimaNikaya}),
        equals(['dn', 'mn']),
      );
      expect(ScopePatterns.getKeysForScope({'dn-1'}), equals(['dn-1']));
    });
  });

  group('ScopePatterns.matchesNodeKey', () {
    test('a node matches itself', () {
      expect(ScopePatterns.matchesNodeKey('dn-1', 'dn-1'), isTrue);
    });

    test('a descendant matches across any depth', () {
      expect(ScopePatterns.matchesNodeKey('dn-1-2', 'dn-1'), isTrue);
      expect(ScopePatterns.matchesNodeKey('dn-1-2-3', 'dn-1'), isTrue);
    });

    test('the hyphen boundary separates a sibling from a child', () {
      // 'atta-an-10' is the tenth sibling of 'atta-an-1', not a child of it.
      // A bare startsWith would swallow it; the corpus has many such pairs.
      expect(ScopePatterns.matchesNodeKey('atta-an-10', 'atta-an-1'), isFalse);
      expect(ScopePatterns.matchesNodeKey('atta-an-1-2', 'atta-an-1'), isTrue);
    });

    test('an ancestor does not match its own descendant', () {
      expect(ScopePatterns.matchesNodeKey('dn', 'dn-1'), isFalse);
    });
  });
}
