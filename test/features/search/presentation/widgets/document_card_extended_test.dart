import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindvault/features/search/domain/entities/document.dart';
import 'package:mindvault/features/search/presentation/widgets/document_card.dart';

void main() {
  group('DocumentCard Extended Tests', () {
    late Document testDocument;

    setUp(() {
      testDocument = Document(
        id: 1,
        title: 'Test Document',
        content: 'This is test content for the document',
        category: 'Test Category',
        tags: const ['flutter', 'test', 'widget'],
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 2),
      );
    });

    Widget createDocumentCard({
      Document? document,
      bool isSelected = false,
      bool isSelectable = false,
      String? searchQuery,
      VoidCallback? onSelectionToggle,
      VoidCallback? onEdit,
      VoidCallback? onDelete,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DocumentCard(
            document: document ?? testDocument,
            isSelected: isSelected,
            isSelectable: isSelectable,
            searchQuery: searchQuery,
            onSelectionToggle: onSelectionToggle,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ),
      );
    }

    group('Document Display', () {
      testWidgets('displays document title prominently', (WidgetTester tester) async {
        await tester.pumpWidget(createDocumentCard());

        final titleFinder = find.text('Test Document');
        expect(titleFinder, findsOneWidget);

        // Verify title styling (should be prominent)
        final titleWidget = tester.widget<Text>(titleFinder);
        expect(titleWidget.style?.fontWeight, FontWeight.bold);
      });

      testWidgets('displays document category', (WidgetTester tester) async {
        await tester.pumpWidget(createDocumentCard());

        expect(find.text('Test Category'), findsOneWidget);
      });

      testWidgets('displays content preview', (WidgetTester tester) async {
        await tester.pumpWidget(createDocumentCard());

        // Should show at least part of the content
        expect(find.textContaining('This is test content'), findsOneWidget);
      });

      testWidgets('displays all tags as chips', (WidgetTester tester) async {
        await tester.pumpWidget(createDocumentCard());

        expect(find.text('flutter'), findsOneWidget);
        expect(find.text('test'), findsOneWidget);
        expect(find.text('widget'), findsOneWidget);

        // Should display tags as Chip widgets
        expect(find.byType(Chip), findsNWidgets(3));
      });

      testWidgets('displays creation and update dates', (WidgetTester tester) async {
        await tester.pumpWidget(createDocumentCard());

        // Should show some date information (format may vary)
        expect(find.byIcon(Icons.calendar_today), findsAtLeastNWidgets(1));
      });

      testWidgets('handles document with null category', (WidgetTester tester) async {
        final documentWithoutCategory = Document(
          id: 1,
          title: 'No Category Doc',
          content: 'Content',
          category: null,
          tags: const [],
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        await tester.pumpWidget(createDocumentCard(document: documentWithoutCategory));

        expect(find.text('No Category Doc'), findsOneWidget);
        // Should not crash when category is null
        expect(tester.takeException(), isNull);
      });

      testWidgets('handles document with empty tags', (WidgetTester tester) async {
        final documentWithoutTags = Document(
          id: 1,
          title: 'No Tags Doc',
          content: 'Content',
          category: 'Category',
          tags: const [],
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        await tester.pumpWidget(createDocumentCard(document: documentWithoutTags));

        expect(find.text('No Tags Doc'), findsOneWidget);
        expect(find.byType(Chip), findsNothing);
      });

      testWidgets('truncates long content appropriately', (WidgetTester tester) async {
        final longContentDocument = Document(
          id: 1,
          title: 'Long Content Doc',
          content: 'This is a very long content that should be truncated when displayed in the card preview. ' * 10,
          category: 'Long',
          tags: const ['long'],
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        await tester.pumpWidget(createDocumentCard(document: longContentDocument));

        expect(find.text('Long Content Doc'), findsOneWidget);
        // Content should be present but truncated (exact truncation depends on implementation)
        expect(find.textContaining('This is a very long content'), findsOneWidget);
      });
    });

    group('Interaction Handling', () {
      testWidgets('navigates to details when card is tapped (not selectable)', (WidgetTester tester) async {
        await tester.pumpWidget(createDocumentCard(
          isSelectable: false,
        ));

        await tester.tap(find.byType(DocumentCard));
        await tester.pumpAndSettle();

        // Should attempt to navigate (though navigation will fail in test without proper setup)
        // The important thing is that the tap is handled without error
        expect(tester.takeException(), isNull);
      });

      testWidgets('calls onSelectionToggle when in selectable mode', (WidgetTester tester) async {
        bool selectionToggled = false;

        await tester.pumpWidget(createDocumentCard(
          isSelectable: true,
          onSelectionToggle: () => selectionToggled = true,
        ));

        await tester.tap(find.byType(DocumentCard));
        expect(selectionToggled, isTrue);
      });

      testWidgets('shows selection indicator when selected', (WidgetTester tester) async {
        await tester.pumpWidget(createDocumentCard(
          isSelected: true,
          isSelectable: true,
        ));

        // Should show some visual indication of selection
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('shows different indicator when selectable but not selected', (WidgetTester tester) async {
        await tester.pumpWidget(createDocumentCard(
          isSelected: false,
          isSelectable: true,
        ));

        // Should show unselected indicator
        expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
      });

      testWidgets('does not show selection indicators when not selectable', (WidgetTester tester) async {
        await tester.pumpWidget(createDocumentCard(
          isSelectable: false,
        ));

        expect(find.byIcon(Icons.check_circle), findsNothing);
        expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
      });
    });

    group('Visual States', () {
      testWidgets('applies selected styling when selected', (WidgetTester tester) async {
        await tester.pumpWidget(createDocumentCard(
          isSelected: true,
          isSelectable: true,
        ));

        // Card should have different appearance when selected
        final card = tester.widget<Card>(find.byType(Card));
        expect(card, isNotNull);
        // Selected cards typically have different elevation or color
      });

      testWidgets('applies hover effect on desktop platforms', (WidgetTester tester) async {
        await tester.pumpWidget(createDocumentCard());

        // Should have InkWell or similar for touch feedback
        expect(find.byType(InkWell), findsOneWidget);
      });

      testWidgets('has proper card elevation and styling', (WidgetTester tester) async {
        await tester.pumpWidget(createDocumentCard());

        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, greaterThan(0));
        expect(card.margin, isNotNull);
      });
    });

    group('Layout and Responsiveness', () {
      testWidgets('maintains proper spacing between elements', (WidgetTester tester) async {
        await tester.pumpWidget(createDocumentCard());

        // Should have proper padding and spacing
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });

      testWidgets('handles very long titles gracefully', (WidgetTester tester) async {
        final longTitleDocument = Document(
          id: 1,
          title: 'This is a very long title that might overflow ' * 5,
          content: 'Content',
          category: 'Long Title',
          tags: const ['long'],
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        await tester.pumpWidget(createDocumentCard(document: longTitleDocument));

        // Should not overflow or cause rendering issues
        expect(tester.takeException(), isNull);
        expect(find.textContaining('This is a very long title'), findsOneWidget);
      });

      testWidgets('adapts to different screen sizes', (WidgetTester tester) async {
        // Test with different screen sizes
        await tester.binding.setSurfaceSize(const Size(800, 600));
        await tester.pumpWidget(createDocumentCard());
        expect(find.byType(DocumentCard), findsOneWidget);

        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(createDocumentCard());
        expect(find.byType(DocumentCard), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('provides proper semantics for screen readers', (WidgetTester tester) async {
        await tester.pumpWidget(createDocumentCard());

        // Should have semantic labels for accessibility
        expect(find.byType(Semantics), findsAtLeastNWidgets(1));
      });

      testWidgets('supports keyboard navigation', (WidgetTester tester) async {
        await tester.pumpWidget(createDocumentCard());

        // Should be focusable for keyboard navigation
        final inkWell = tester.widget<InkWell>(find.byType(InkWell));
        expect(inkWell.focusNode, isNotNull);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles navigation gracefully in normal mode', (WidgetTester tester) async {
        await tester.pumpWidget(createDocumentCard());

        // Should not crash when tapped in normal mode
        await tester.tap(find.byType(DocumentCard));
        expect(tester.takeException(), isNull);
      });

      testWidgets('handles null onSelectionToggle callback gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(createDocumentCard(
          isSelectable: true,
          onSelectionToggle: null,
        ));

        // Should not crash when onSelectionToggle is null
        await tester.tap(find.byType(DocumentCard));
        expect(tester.takeException(), isNull);
      });

      testWidgets('handles document with very recent dates', (WidgetTester tester) async {
        final recentDocument = Document(
          id: 1,
          title: 'Recent Doc',
          content: 'Content',
          category: 'Recent',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(createDocumentCard(document: recentDocument));

        expect(find.text('Recent Doc'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}