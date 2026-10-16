import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/bjt_content_datasource.dart';
import '../../data/datasources/bjt_content_local_datasource.dart';
import '../../data/datasources/bjt_document_datasource.dart';
import '../../data/datasources/bjt_document_local_datasource.dart';
import '../../data/repositories/bjt_document_repository_impl.dart';
import '../../domain/entities/bjt/bjt_document.dart';
import '../../domain/entities/content/text_layer.dart';
import '../../domain/entities/reader/document_slice.dart';
import '../../domain/entities/reader/reader_unit.dart';
import '../../domain/repositories/bjt_document_repository.dart';
import '../../domain/usecases/load_bjt_document_usecase.dart';
import 'reader_unit_provider.dart';
import 'tab_provider.dart';

/// Page text out of `bjt_content`, for the reader and for search snippets.
///
/// One implementation on every platform: native reads its copy of `bjt.db`,
/// web reads the copy it downloaded into OPFS.
final bjtContentDataSourceProvider = Provider<BJTContentDataSource>((ref) {
  return BJTContentLocalDataSourceImpl();
});

// Datasource provider
final bjtDocumentDataSourceProvider = Provider<BJTDocumentDataSource>((ref) {
  return BJTDocumentLocalDataSourceImpl(
    contentDataSource: ref.watch(bjtContentDataSourceProvider),
  );
});

// Repository provider
final bjtDocumentRepositoryProvider = Provider<BJTDocumentRepository>((ref) {
  final dataSource = ref.watch(bjtDocumentDataSourceProvider);
  return BJTDocumentRepositoryImpl(dataSource);
});

// Use case provider
final loadBJTDocumentUseCaseProvider = Provider<LoadBJTDocumentUseCase>((ref) {
  final repository = ref.watch(bjtDocumentRepositoryProvider);
  return LoadBJTDocumentUseCase(repository);
});

/// Which pages of which file to load: a unit's span, or one page for a
/// preview. `lastPage` null runs to the end of the file.
///
/// A record, so two requests for the same span are the same family key and
/// share one load.
typedef DocumentRequest = ({String fileId, int firstPage, int? lastPage});

/// The request that loads exactly what [unit] renders, and no more.
DocumentRequest requestFor(ReaderUnit unit) {
  final span = unit.range.pageSpan;
  return (
    fileId: unit.contentFileId,
    firstPage: span.firstPage,
    lastPage: span.lastPage,
  );
}

/// One page of a file, for a preview that shows a few entries of it.
DocumentRequest requestForPage(String fileId, int pageIndex) =>
    (fileId: fileId, firstPage: pageIndex, lastPage: pageIndex);

// BJT document provider (loads the pages one request names)
// Uses autoDispose to clean up when no listeners remain.
// keepAlive() caches successful loads; failed loads can be retried.
final bjtDocumentProvider = FutureProvider.autoDispose
    .family<BJTDocument, DocumentRequest>((ref, request) async {
  final useCase = ref.watch(loadBJTDocumentUseCaseProvider);
  final result = await useCase.execute(
    request.fileId,
    firstPage: request.firstPage,
    lastPage: request.lastPage,
  );

  return result.fold(
    (failure) => throw Exception(failure.userMessage),
    (document) {
      ref.keepAlive(); // Cache successful loads
      return document;
    },
  );
});

// ============================================================================
// CONTENT STATE
// Everything the reader shows is derived from the active tab's node key:
//   activeNodeKeyProvider → activeReaderUnitProvider → the file and the span
//     → activeDocumentRequestProvider → currentBJTDocumentProvider
//       → activeDocumentSliceProvider
// The tab stores no coordinates, so nothing here can disagree with the
// resolver about where a unit starts or stops.
// ============================================================================

/// The bounded unit the active tab is reading.
///
/// Async because the resolver is: the reader shows its loading state until the
/// tree is up, the same way it already waited on the content file. Null inside
/// the data case means "this tab has no unit" — no tab open, or a key the tree
/// has never heard of.
final activeReaderUnitProvider = Provider<AsyncValue<ReaderUnit?>>((ref) {
  final nodeKey = ref.watch(activeNodeKeyProvider);
  // Answered without the resolver, so a session with no tab open never builds
  // it and the "select a sutta" hint is not held behind a spinner.
  if (nodeKey == null) return const AsyncValue.data(null);
  return ref
      .watch(readerUnitResolverProvider)
      .whenData((resolver) => resolver.unitFor(nodeKey));
});

/// The content file the active tab's unit lives in — derived, never stored.
///
/// Nothing in `lib/` reads it since the reader moved to
/// [activeDocumentRequestProvider]; it stays because it is what the navigation
/// tests assert the active tab landed on.
final activeContentFileIdProvider = Provider<String?>((ref) {
  return ref.watch(activeReaderUnitProvider).valueOrNull?.contentFileId;
});

/// The pages the active tab's unit needs — null when it has no unit.
final activeDocumentRequestProvider = Provider<DocumentRequest?>((ref) {
  final unit = ref.watch(activeReaderUnitProvider).valueOrNull;
  if (unit == null || unit.contentFileId.trim().isEmpty) return null;
  return requestFor(unit);
});

// Current BJT document provider — only the active unit's pages, not its file.
final currentBJTDocumentProvider = Provider<AsyncValue<BJTDocument?>>((ref) {
  final request = ref.watch(activeDocumentRequestProvider);

  if (request == null) {
    return const AsyncValue.data(null);
  }

  // Return the AsyncValue directly to properly propagate loading/error states
  return ref.watch(bjtDocumentProvider(request));
});

/// The unit's span cut out of the loaded document — the pages the panes build.
///
/// This is the whole of what replaced `pageStart`/`pageEnd`: the reader is
/// handed a finite list once, and `AnchoredPageList` builds it lazily.
/// Null while either half is still loading, or when the tab has no unit.
final activeDocumentSliceProvider = Provider<DocumentSlice?>((ref) {
  final unit = ref.watch(activeReaderUnitProvider).valueOrNull;
  final document = ref.watch(currentBJTDocumentProvider).valueOrNull;
  if (unit == null || document == null) return null;
  return DocumentSlice.of(document, unit.range);
});

/// The active tab's anchor row — where scroll offset 0 sits — or null for
/// the unit's top.
final activeAnchorProvider =
    Provider<(int, int)?>((ref) => ref.watch(activeTabProvider)?.anchor);

// Note: Reader layout is now per-tab, stored in ReaderTab.layout
// Access via activeReaderLayoutProvider in tab_provider.dart
// Update via updateActiveTabLayoutProvider in tab_provider.dart

// ============================================================================
// TextLayer Providers (Multi-Edition Foundation)
// ============================================================================

/// Converts current BJTDocument to TextLayers
/// This demonstrates the foundation for multi-edition support
final currentTextLayersProvider = Provider<List<TextLayer>>((ref) {
  final contentAsync = ref.watch(currentBJTDocumentProvider);

  return contentAsync.when(
    data: (document) {
      if (document == null) return [];

      // Convert page-based BJTDocument to segment-based TextLayers
      // This creates two layers: BJT Pali (Sinhala script) and BJT Sinhala
      final layers = document.toTextLayers();

      return layers;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Example provider showing available layers for current content
/// In the future, this will include SuttaCentral, PTS, etc.
final availableLayersProvider = Provider<List<Map<String, String>>>((ref) {
  final layers = ref.watch(currentTextLayersProvider);

  return layers
      .map((layer) => {
            'layerId': layer.layerId,
            'displayName': layer.displayName,
            'editionId': layer.editionId,
            'languageCode': layer.languageCode,
            'scriptCode': layer.scriptCode,
            'segmentCount': layer.segmentCount.toString(),
          })
      .toList();
});
