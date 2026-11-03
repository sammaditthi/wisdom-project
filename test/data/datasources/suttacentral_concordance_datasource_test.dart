import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/data/datasources/suttacentral_concordance_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Proves the asset's shape and fromJson agree: a renamed `english` or
  // `reverse` key would otherwise silently become empty.
  test('the bundled sc-to-bjt.json resolves both directions', () async {
    final resolver = await SuttaCentralConcordanceDataSourceImpl().load();

    expect(resolver.nodeKeyForUid('sn15.3'), 'sn-2-3-1-3');
    expect(
      resolver.suttaCentralUrl('dn-1-1'),
      Uri.parse('https://suttacentral.net/dn1/en/bodhi'),
    );
    // The reverse entry beats the vagga uid that names this node first.
    expect(
      resolver.suttaCentralUrl('an-1-1'),
      Uri.parse('https://suttacentral.net/an1.1-10/en/sujato'),
    );
    expect(
      resolver.suttaCentralUrl('mn-1-1'),
      Uri.parse('https://suttacentral.net/mn-mulapariyayavagga'),
    );
    // Mixes two SuttaCentral divisions, so there is no single counterpart.
    expect(resolver.suttaCentralUrl('sn-2-1'), isNull);
  });
}
