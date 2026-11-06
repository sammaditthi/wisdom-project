import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisdom_shared/wisdom_shared.dart';

import '../../domain/entities/search/search_result.dart';
import '../../domain/entities/search/search_result_type.dart';
import 'navigation_tree_provider.dart';
import 'search_provider.dart';
import 'suttacentral_provider.dart' show suttaCentralRefResolverProvider;

/// A single, high-priority "jump to this sutta" hit, produced when the current
/// search query is a canonical reference (e.g. "SN 15.3") that resolves to a
/// readable BJT node.
///
/// Returns `null` when the query isn't a reference, the concordance hasn't
/// loaded, the uid isn't mapped, or the node isn't readable content. This is a
/// pure in-memory lookup — it issues **no** database query, so it adds zero load
/// to the FTS path (resolver plan, "SQLite strategy").
///
/// The result carries the resolved node's own navigation coordinates
/// (`contentFileId` / `pageIndex` / `entryIndex`), so a tap reuses the exact
/// same open-in-tab path as every other [SearchResult] — no special-case
/// navigation wiring.
final referenceSearchResultProvider = Provider<SearchResult?>((ref) {
  final query = ref.watch(searchStateProvider.select((s) => s.rawQueryText));
  if (query.trim().isEmpty) return null;

  // valueOrNull is null while the asset is still loading or if it failed.
  final resolver = ref.watch(suttaCentralRefResolverProvider).valueOrNull;
  if (resolver == null) return null;

  final typed = SuttaCentralRefResolver.parseRef(query);
  if (typed == null) return null;

  // "Dhp 5" has no uid of its own; it opens the range holding it, dhp1-20,
  // and the row names that range.
  final target = resolver.resolve(typed);
  if (target == null) return null;
  final (:uid, :nodeKey) = target;

  final node = ref.watch(nodeByKeyProvider(nodeKey));
  if (node == null || !node.isReadableContent) return null;

  return SearchResult(
    id: 'ref:$uid',
    editionId: 'bjt',
    resultType: SearchResultType.reference,
    // The display reference ("SN 15.3") is shown as the leading badge; the tile
    // re-derives the actual sutta name + path from nodeKey via searchResultLabels.
    title: SuttaCentralRefResolver.displayRef(uid),
    subtitle: '',
    matchedText: '',
    contentFileId: node.contentFileId ?? '', // readable ⇒ non-null
    pageIndex: node.entryPageIndex,
    entryIndex: node.entryIndexInPage,
    nodeKey: nodeKey,
    language: '',
  );
});
