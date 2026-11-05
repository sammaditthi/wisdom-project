import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_wisdom_project/domain/entities/navigation/tipitaka_tree_node.dart';
import 'package:the_wisdom_project/presentation/providers/navigation_tree_provider.dart';
import 'package:the_wisdom_project/presentation/providers/reference_search_provider.dart';
import 'package:the_wisdom_project/presentation/providers/search_provider.dart';
import 'package:the_wisdom_project/presentation/providers/search_state.dart';
import 'package:the_wisdom_project/presentation/providers/suttacentral_provider.dart';
import 'package:wisdom_shared/wisdom_shared.dart';

import '../../helpers/fake_search_state_notifier.dart';

void main() {
  test('"Dhp 5" jumps to the range holding it, and names that range', () async {
    final container = ProviderContainer(
      overrides: [
        searchStateProvider.overrideWith(
          (ref) => FakeSearchStateNotifier(
            const SearchState(rawQueryText: 'Dhp 5'),
          ),
        ),
        // No dhp5 uid: only the range holding verse 5.
        suttaCentralRefResolverProvider.overrideWith(
          (ref) => const SuttaCentralRefResolver({'dhp1-20': 'kn-dhp-1'}),
        ),
        nodeIndexProvider.overrideWithValue({
          'kn-dhp-1': const TipitakaTreeNode(
            nodeKey: 'kn-dhp-1',
            paliName: 'යමකවග්ගො',
            sinhalaName: 'යමක වර්ගය',
            hierarchyLevel: 3,
            entryPageIndex: 0,
            entryIndexInPage: 0,
            contentFileId: 'kn-dhp',
          ),
        }),
      ],
    );
    addTearDown(container.dispose);
    await container.read(suttaCentralRefResolverProvider.future);

    final result = container.read(referenceSearchResultProvider);

    expect(result?.nodeKey, 'kn-dhp-1');
    expect(result?.title, 'Dhp 1-20');
  });
}
