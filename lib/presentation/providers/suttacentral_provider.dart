import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisdom_shared/wisdom_shared.dart';

import '../../data/datasources/suttacentral_concordance_datasource.dart';
import 'tab_provider.dart' show activeNodeKeyProvider;

// The SuttaCentral↔BJT concordance, shared by search (the reference jump),
// research (citations) and the reader (Open on SuttaCentral).

/// Datasource that loads the committed SuttaCentral↔BJT concordance asset.
final suttaCentralConcordanceDataSourceProvider =
    Provider<SuttaCentralConcordanceDataSource>(
  (ref) => SuttaCentralConcordanceDataSourceImpl(),
);

/// The pure [SuttaCentralRefResolver], built once from the loaded concordance.
///
/// Async because the asset load is async. Readers treat "not loaded yet" (or a
/// load error) as "no resolver": FTS keeps working, and the jump row, the
/// citation link and the Share menu row simply don't show.
final suttaCentralRefResolverProvider = FutureProvider<SuttaCentralRefResolver>(
  (ref) => ref.watch(suttaCentralConcordanceDataSourceProvider).load(),
);

/// The active tab's page on SuttaCentral, or null when the tab's node has no
/// counterpart there (or the concordance hasn't loaded).
final activeSuttaCentralUrlProvider = Provider<Uri?>((ref) {
  final nodeKey = ref.watch(activeNodeKeyProvider);
  final resolver = ref.watch(suttaCentralRefResolverProvider).valueOrNull;
  if (nodeKey == null || resolver == null) return null;
  return resolver.suttaCentralUrl(nodeKey);
});

/// How the Share menu names each SuttaCentral translator, the same in every
/// app language. A translator missing here is shown without a name.
const _translatorNames = {
  'bodhi': 'Ven. Bodhi',
  'sujato': 'Ven. Sujato',
  'brahmali': 'Ven. Brahmali',
};

/// Who translated the English that Open on SuttaCentral opens for the active
/// tab, or null when it opens no translation.
final activeSuttaCentralTranslatorProvider = Provider<String?>((ref) {
  final nodeKey = ref.watch(activeNodeKeyProvider);
  final resolver = ref.watch(suttaCentralRefResolverProvider).valueOrNull;
  if (nodeKey == null || resolver == null) return null;
  return _translatorNames[resolver.suttaCentralTranslator(nodeKey)];
});
