import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:the_wisdom_project/domain/entities/failure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_wisdom_project/presentation/providers/document_provider.dart';
import 'package:the_wisdom_project/presentation/providers/reader_keyboard_bridge_provider.dart';
import 'package:the_wisdom_project/presentation/widgets/reader/multi_pane_reader_widget.dart';

import '../../helpers/mocks.mocks.dart';
import '../../helpers/test_data.dart';
import '../../helpers/pump_app.dart';

void main() {
  late MockBJTDocumentRepository mockRepository;

  setUp(() {
    mockRepository = MockBJTDocumentRepository();
  });

  // ============================================================
  // Empty State Tests
  // ============================================================
  group('Empty state', () {
    testWidgets('should show placeholder when no content selected',
        (tester) async {
      // ACT - No tab open, so the active unit resolves to null
      await tester.pumpApp(
        const MultiPaneReaderWidget(),
        overrides: [
          TestProviderOverrides.bjtDocumentRepository(mockRepository),
        ],
      );
      await tester.pump();

      // ASSERT
      expect(
        find.text('Select a text from the navigator to begin reading'),
        findsOneWidget,
      );
      // The "select a sutta" hint shows the Urna Hair Relic emblem
      // (Image.asset) as its leading visual, not a Material icon.
      expect(find.byType(Image), findsOneWidget);
    });
  });

  // ============================================================
  // Keyboard bridge (keyboard-shortcuts-sheet.md: sutta and scroll keys)
  // ============================================================
  group('Keyboard bridge', () {
    testWidgets('the reader attaches to the keyboard bridge while mounted',
        (tester) async {
      final overrides = [
        TestProviderOverrides.bjtDocumentRepository(mockRepository),
      ];
      await tester.pumpApp(const MultiPaneReaderWidget(), overrides: overrides);
      await tester.pump();

      final bridge = ProviderScope.containerOf(
        tester.element(find.byType(MultiPaneReaderWidget)),
      ).read(readerKeyboardBridgeProvider);
      expect(bridge.handle, isNotNull);

      await tester.pumpApp(const SizedBox(), overrides: overrides);
      expect(bridge.handle, isNull);
    });

    // A held key repeats faster than one scroll animation. Each press adds
    // to where the last one was heading, so none of it is lost.
    testWidgets('a press during a key scroll adds a full line', (tester) async {
      when(mockRepository.loadDocument('dn-1')).thenAnswer(
        (_) async => Right(TestData.sampleDocument),
      );
      // Short, so the sample text scrolls.
      tester.view.physicalSize = const Size(800, 200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpApp(
        const MultiPaneReaderWidget(),
        overrides: [
          TestProviderOverrides.bjtDocumentRepository(mockRepository),
          ..._readingDn1(),
        ],
      );
      await tester.pumpAndSettle();

      final reader = ProviderScope.containerOf(
        tester.element(find.byType(MultiPaneReaderWidget)),
      ).read(readerKeyboardBridgeProvider).handle!;
      final position = tester
          .stateList<ScrollableState>(find.byType(Scrollable))
          .map((s) => s.position)
          .singleWhere((p) => p.axis == Axis.vertical);
      expect(position.maxScrollExtent, greaterThan(100));

      reader.scroll(AxisDirection.down, ScrollIncrementType.line);
      await tester.pump(const Duration(milliseconds: 30));
      reader.scroll(AxisDirection.down, ScrollIncrementType.line);
      await tester.pumpAndSettle();

      expect(position.pixels, 100);

      // The other way mid-scroll: up from where the page is, not on top of
      // the pending ↓.
      position.jumpTo(0);
      await tester.pump();
      reader.scroll(AxisDirection.down, ScrollIncrementType.line);
      reader.scroll(AxisDirection.down, ScrollIncrementType.line);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 30));
      final atUp = position.pixels;
      expect(atUp, greaterThan(0));
      reader.scroll(AxisDirection.up, ScrollIncrementType.line);
      await tester.pumpAndSettle();

      expect(position.pixels, lessThan(atUp));
    });
  });

  // ============================================================
  // Error State Tests
  // ============================================================
  group('Error state', () {
    testWidgets('should show error when document loading fails',
        (tester) async {
      // ARRANGE - Mock repository to return a Failure wrapped in Either
      when(mockRepository.loadDocument('dn-1')).thenAnswer(
        (_) async => const Left(
          Failure.dataLoadFailure(
            message: 'Failed to load document',
            error: 'Network error',
          ),
        ),
      );

      // ACT
      await tester.pumpApp(
        const MultiPaneReaderWidget(),
        overrides: [
          TestProviderOverrides.bjtDocumentRepository(mockRepository),
          ..._readingDn1(),
        ],
      );
      await tester.pumpAndSettle();

      // ASSERT
      expect(find.text('Error loading content'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  // ============================================================
  // Content Loading Tests
  // ============================================================
  group('Content loading', () {
    testWidgets('should show loading indicator initially', (tester) async {
      // ARRANGE - Set up a delayed response with Either<Failure, BJTDocument>
      when(mockRepository.loadDocument('dn-1')).thenAnswer(
        (_) async {
          await Future.delayed(Duration.zero);
          return Right(TestData.sampleDocument);
        },
      );

      // ACT
      await tester.pumpApp(
        const MultiPaneReaderWidget(),
        overrides: [
          TestProviderOverrides.bjtDocumentRepository(mockRepository),
          ..._readingDn1(),
        ],
      );

      // Initial pump shows loading
      await tester.pump();

      // ASSERT
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Clean up
      await tester.pumpAndSettle();
    });

    testWidgets('should hide placeholder when content loads', (tester) async {
      // ARRANGE - Mock repository to return successful Either
      when(mockRepository.loadDocument('dn-1'))
          .thenAnswer((_) async => Right(TestData.sampleDocument));

      // ACT
      await tester.pumpApp(
        const MultiPaneReaderWidget(),
        overrides: [
          TestProviderOverrides.bjtDocumentRepository(mockRepository),
          ..._readingDn1(),
        ],
      );
      await tester.pumpAndSettle();

      // ASSERT - Placeholder should be gone
      expect(
        find.text('Select a text from the navigator to begin reading'),
        findsNothing,
      );
    });
  });
}

/// The reader as a real tab leaves it: a unit resolved for `dn-1`, and the
/// file it names.
List<Override> _readingDn1() => [
      activeReaderUnitProvider
          .overrideWith((ref) => AsyncValue.data(TestData.readerUnit('dn-1'))),
      activeContentFileIdProvider.overrideWith((ref) => 'dn-1'),
    ];
