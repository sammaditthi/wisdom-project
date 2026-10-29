import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/core/utils/singlish_transliterator.dart';

void main() {
  group('SinglishTransliterator', () {
    late SinglishTransliterator transliterator;

    setUp(() {
      transliterator = SinglishTransliterator.instance;
    });

    group('convert()', () {
      test('empty string returns empty', () {
        expect(transliterator.convert(''), '');
      });

      test('Sinhala text returns as-is', () {
        expect(transliterator.convert('සති'), 'සති');
        expect(transliterator.convert('ධර්ම'), 'ධර්ම');
      });

      test('basic consonant + vowel combinations', () {
        final cases = {
          'ka': 'ක',
          'ki': 'කි',
          'ku': 'කු',
          'ko': 'කො',
          'ke': 'කෙ',
          'kaa': 'කා',
          'kii': 'කී',
          'kuu': 'කූ',
        };
        for (final entry in cases.entries) {
          expect(transliterator.convert(entry.key), entry.value,
              reason: '${entry.key} should convert to ${entry.value}');
        }
      });

      test('case-sensitive consonant disambiguation', () {
        final cases = {
          'ta': 'ට', // lowercase t = retroflex
          'tha': 'ත', // lowercase th = dental
          'Ta': 'ඨ', // uppercase T = retroflex aspirated
          'Tha': 'ථ', // uppercase Th = dental aspirated
          'da': 'ඩ', // lowercase d = retroflex
          'dha': 'ද', // lowercase dh = dental
          'Da': 'ඪ', // uppercase D = retroflex aspirated
          'Dha': 'ධ', // uppercase Dh = dental aspirated
        };
        for (final entry in cases.entries) {
          expect(transliterator.convert(entry.key), entry.value,
              reason: '${entry.key} should convert to ${entry.value}');
        }
      });

      group('critical search words', () {
        test('sathi (mindfulness) with th -> ත', () {
          expect(transliterator.convert('sathi'), 'සති');
        });

        test('saThi (different) with Th -> ථ', () {
          expect(transliterator.convert('saThi'), 'සථි');
        });

        test('dharma with dh -> ද', () {
          expect(transliterator.convert('dharma'), 'දර්ම');
        });

        test('Dharma with Dh -> ධ (aspirated)', () {
          expect(transliterator.convert('Dharma'), 'ධර්ම');
        });

        test('buddha contains බු', () {
          final result = transliterator.convert('buddha');
          expect(result.contains('බු'), true);
        });

        test('nibbana starts with නි', () {
          final result = transliterator.convert('nibbana');
          expect(result.startsWith('නි'), true);
        });
      });

      test('standalone vowels', () {
        final cases = {
          'a': 'අ',
          'i': 'ඉ',
          'u': 'උ',
          'e': 'එ',
          'o': 'ඔ',
        };
        for (final entry in cases.entries) {
          expect(transliterator.convert(entry.key), entry.value,
              reason: '${entry.key} should convert to ${entry.value}');
        }
      });

      test('trailing consonant gets hal', () {
        expect(transliterator.convert('sat'), 'සට්');
      });

      test('other consonants (sh, Sh, ch, Ch)', () {
        final cases = {
          'sha': 'ශ',
          'Sha': 'ෂ',
          'cha': 'ච',
          'Cha': 'ඡ',
        };
        for (final entry in cases.entries) {
          expect(transliterator.convert(entry.key), entry.value,
              reason: '${entry.key} should convert to ${entry.value}');
        }
      });

      test('c is ච, and ch/Ch still win over it', () {
        // Romanized Pali spells ච as `c` (cakka, citta, pañca). The UCSC
        // scheme this came from has only ch/Ch, so a bare `c` used to survive
        // every pass as a Latin letter.
        final cases = {
          'ca': 'ච',
          'cakka': 'චක්ක',
          'cha': 'ච',
          'Cha': 'ඡ',
        };
        for (final entry in cases.entries) {
          expect(transliterator.convert(entry.key), entry.value,
              reason: '${entry.key} should convert to ${entry.value}');
        }
      });

      test('rakaransha patterns', () {
        expect(transliterator.convert('kra'), 'ක්‍ර');
        expect(transliterator.convert('pra'), 'ප්‍ර');
        expect(transliterator.convert('kri'), 'ක්‍රි');
        expect(transliterator.convert('kree'), 'ක්‍රී');
      });

      test('special modifiers (ru/ruu)', () {
        expect(transliterator.convert('kru'), 'කෘ');
        expect(transliterator.convert('kruu'), 'කෲ');
      });

      group('multi-word and mixed input', () {
        test('multi-word input', () {
          final result = transliterator.convert('sathi pattana');
          expect(result, contains('සති'));
        });

        test('preserves numbers', () {
          expect(transliterator.convert('sathi 123'), contains('123'));
          expect(transliterator.convert('12345'), '12345');
        });

        test('preserves punctuation', () {
          expect(transliterator.convert('sathi, dharma.'), contains(','));
          expect(transliterator.convert('sathi, dharma.'), contains('.'));
        });
      });

      group('special Pali characters', () {
        test('anusvara (~n → ං)', () {
          final result = transliterator.convert('sa~nga');
          expect(result, contains('ං'));
        });

        test('visarga (~h → ඃ)', () {
          final result = transliterator.convert('du~hkha');
          expect(result, contains('ඃ'));
        });

        test('repaya (R → the hook over the next consonant)', () {
          // Typed before the consonant it rides on, and the ZWJ is what makes
          // a font draw the hook instead of a visible hal.
          expect(transliterator.convert('vaRgaya'), 'වර්\u200Dගය');
          // The plain spelling is untouched — and is the same word to search,
          // which drops the joiner from both sides.
          expect(transliterator.convert('vargaya'), 'වර්ගය');
        });

        test('~R keeps its R', () {
          // `~R` is replaced before the bare `R`, or the escape would lose it.
          expect(transliterator.convert('~RdhDhi'), 'ඍද්ධි');
        });

        test('standalone special chars', () {
          expect(transliterator.convert('~n'), 'ං');
          expect(transliterator.convert('~h'), 'ඃ');
        });
      });
    });

    group('isSinglishQuery()', () {
      test('returns true for ASCII letters', () {
        expect(transliterator.isSinglishQuery('hello'), true);
        expect(transliterator.isSinglishQuery('sathi'), true);
        expect(transliterator.isSinglishQuery('Dharma'), true);
      });

      test('returns false for Sinhala text', () {
        expect(transliterator.isSinglishQuery('සති'), false);
        expect(transliterator.isSinglishQuery('ධර්ම'), false);
      });

      test('returns true for mixed text', () {
        expect(transliterator.isSinglishQuery('සති sathi'), true);
      });
    });
  });
}
