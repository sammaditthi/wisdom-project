import 'package:test/test.dart';
import 'package:wisdom_shared/wisdom_shared.dart';

// Typed references (`docs/todo/search/sutta-references-plan.md`, Part A).
void main() {
  group('parseRef', () {
    test('reads the typed forms', () {
      expect(SuttaCentralRefResolver.parseRef('SN 15.3'), 'sn15.3');
      expect(SuttaCentralRefResolver.parseRef('sn15.3'), 'sn15.3');
      // Bodhi and dhammatalks.org write a colon.
      expect(SuttaCentralRefResolver.parseRef('SN 15:3'), 'sn15.3');
      // A book name with one space.
      expect(SuttaCentralRefResolver.parseRef('Tha Ap 1'), 'tha-ap1');
      expect(
        SuttaCentralRefResolver.parseRef('Bu Pj 1'),
        'pli-tv-bu-vb-pj1',
      );
      // A range as SuttaCentral writes it.
      expect(SuttaCentralRefResolver.parseRef('Dhp 1-20'), 'dhp1-20');
    });
  });

  test('every spelling in canonBooks reads back', () {
    for (final book in canonBooks) {
      // Two books sharing a spelling ("Sn" as an alias of Snp) fail here.
      for (final name in [book.name, ...book.aliases]) {
        expect(
          SuttaCentralRefResolver.parseRef('$name 1'),
          '${book.uidPrefix}1',
          reason: name,
        );
      }
      // `snp1` must not read as SN + "p1".
      expect(
        SuttaCentralRefResolver.displayRef('${book.uidPrefix}1'),
        '${book.name} 1',
        reason: book.name,
      );
    }
  });

  test('isBookName ignores case and knows only the table', () {
    expect(SuttaCentralRefResolver.isBookName('SN'), isTrue);
    expect(SuttaCentralRefResolver.isBookName('dhp'), isTrue);
    expect(SuttaCentralRefResolver.isBookName('Tha Ap'), isTrue);
    // Left out of the table on purpose.
    expect(SuttaCentralRefResolver.isBookName('KN'), isFalse);
    expect(SuttaCentralRefResolver.isBookName('Mil'), isFalse);
  });

  test('resolve opens the uid itself, else the range holding it', () {
    const resolver = SuttaCentralRefResolver({
      'sn15.3': 'sn-2-3-1-3',
      'dhp1-20': 'kn-dhp-1',
      'dhp21-32': 'kn-dhp-2',
      'an1.1-10': 'an-1-1',
    });

    expect(resolver.resolve('sn15.3'), (uid: 'sn15.3', nodeKey: 'sn-2-3-1-3'));
    expect(resolver.resolve('dhp1-20'), (uid: 'dhp1-20', nodeKey: 'kn-dhp-1'));
    // Both ends of a range are inside it.
    expect(resolver.resolve('dhp1'), (uid: 'dhp1-20', nodeKey: 'kn-dhp-1'));
    expect(resolver.resolve('dhp20'), (uid: 'dhp1-20', nodeKey: 'kn-dhp-1'));
    expect(resolver.resolve('dhp21'), (uid: 'dhp21-32', nodeKey: 'kn-dhp-2'));
    // A research answer that names "AN 1.1" opens the chapter holding it.
    expect(resolver.resolve('an1.1'), (uid: 'an1.1-10', nodeKey: 'an-1-1'));
    expect(resolver.resolve('an1.5'), (uid: 'an1.1-10', nodeKey: 'an-1-1'));
    expect(resolver.resolve('dhp999'), isNull);
    // No number: nothing to look for in a range.
    expect(resolver.resolve('pli-tv-bu-pm'), isNull);
  });

  test('nodeKeyForUid is exact: a number inside a range is a miss', () {
    const resolver = SuttaCentralRefResolver({'dhp1-20': 'kn-dhp-1'});

    expect(resolver.nodeKeyForUid('dhp1-20'), 'kn-dhp-1');
    expect(resolver.nodeKeyForUid('dhp5'), isNull);
  });
}
