import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/domain/entities/content/content_language.dart';
import 'package:the_wisdom_project/domain/entities/navigation/tipitaka_tree_node.dart';

// Test plan 1.3 — `getDisplayName` language fallback. Some nodes (e.g.
// ap-pat / Paṭṭhāna) lack a Sinhala translation. When the chosen language's
// name is empty, the node must fall back to the other language rather than
// render a blank label. The happy path (both names present) is obvious and
// intentionally not tested.
void main() {
  // Minimal node factory — only the fields under test vary.
  TipitakaTreeNode node(
      {required String paliName, required String sinhalaName}) {
    return TipitakaTreeNode(
      nodeKey: 'test-key',
      paliName: paliName,
      sinhalaName: sinhalaName,
      hierarchyLevel: 0,
      entryPageIndex: 0,
      entryIndexInPage: 0,
    );
  }

  group('TipitakaTreeNode.getDisplayName fallback -', () {
    test('Pali requested but paliName empty → falls back to sinhalaName', () {
      final n = node(paliName: '', sinhalaName: 'දික් සඟිය');

      expect(n.getDisplayName(ContentLanguage.pali), equals('දික් සඟිය'));
    });

    test('Sinhala requested but sinhalaName empty → falls back to paliName',
        () {
      // The real-world ap-pat / Paṭṭhāna case: no Sinhala translation exists.
      final n = node(paliName: 'පට්ඨාන', sinhalaName: '');

      expect(n.getDisplayName(ContentLanguage.sinhala), equals('පට්ඨාන'));
    });
  });

  // Title search ranks canon, then commentary, then treatises on these two
  // getters. Real key shapes, roots included: the treatise root is a bare
  // 'anya', and canon 'an-' keys share its first two letters.
  group('TipitakaTreeNode collection -', () {
    TipitakaTreeNode keyed(String nodeKey) =>
        node(paliName: '', sinhalaName: '').copyWith(nodeKey: nodeKey);

    test('commentary keys, roots included, are commentary only', () {
      for (final key in ['atta-vp', 'atta-sp', 'atta-ap', 'atta-dn-1-1']) {
        expect(keyed(key).isCommentary, isTrue, reason: key);
        expect(keyed(key).isTreatise, isFalse, reason: key);
      }
    });

    test('treatise keys, the bare root included, are treatises only', () {
      for (final key in ['anya', 'anya-vm']) {
        expect(keyed(key).isTreatise, isTrue, reason: key);
        expect(keyed(key).isCommentary, isFalse, reason: key);
      }
    });

    test('canon keys are neither', () {
      for (final key in ['vp', 'sp', 'ap', 'dn-1-1', 'an-1-1']) {
        expect(keyed(key).isCommentary, isFalse, reason: key);
        expect(keyed(key).isTreatise, isFalse, reason: key);
      }
    });
  });
}
