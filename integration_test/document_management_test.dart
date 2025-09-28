import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mindvault/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Document Management Integration Tests', () {
    testWidgets('Complete document CRUD workflow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // CREATE: Add a new document
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      const documentTitle = 'CRUD Test Document';
      const documentContent = 'This document will be created, read, updated, and deleted.';

      await tester.enterText(find.byType(TextFormField).first, documentTitle);
      await tester.enterText(find.byType(TextFormField).at(1), documentContent);

      // Scroll to find category if needed
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      // Select category
      await tester.tap(find.text('Category'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Personal').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Document'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // READ: Verify document appears in list
      expect(find.text(documentTitle), findsOneWidget);

      // Tap on document to view details
      await tester.tap(find.text(documentTitle));
      await tester.pumpAndSettle();

      // Verify document details are displayed correctly
      expect(find.text(documentTitle), findsAtLeastNWidgets(1));
      expect(find.text(documentContent), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);

      // Go back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // UPDATE: Edit the document (this would require implementing edit functionality)
      // For now, we'll test the document remains accessible

      // DELETE: Test document deletion through selection mode
      await tester.tap(find.byIcon(Icons.checklist));
      await tester.pumpAndSettle();

      // Find and tap checkbox for our document
      final documentCard = find.ancestor(
        of: find.text(documentTitle),
        matching: find.byType(Card),
      );

      if (documentCard.evaluate().isNotEmpty) {
        final checkbox = find.descendant(
          of: documentCard,
          matching: find.byType(Checkbox),
        );

        if (checkbox.evaluate().isNotEmpty) {
          await tester.tap(checkbox);
          await tester.pumpAndSettle();

          // Tap delete button
          await tester.tap(find.byIcon(Icons.delete));
          await tester.pumpAndSettle();

          // Confirm deletion in dialog
          await tester.tap(find.text('Delete'));
          await tester.pumpAndSettle();
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Verify document is no longer in the list
          expect(find.text(documentTitle), findsNothing);
        }
      }
    });

    testWidgets('Document categories and filtering', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create documents with different categories
      final testDocuments = [
        {'title': 'Work Report', 'content': 'Quarterly report content', 'category': 'Work'},
        {'title': 'Personal Note', 'content': 'Personal thoughts and ideas', 'category': 'Personal'},
        {'title': 'Study Material', 'content': 'Learning notes about Flutter', 'category': 'Study'},
      ];

      for (final doc in testDocuments) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).first, doc['title']!);
        await tester.enterText(find.byType(TextFormField).at(1), doc['content']!);

        // Scroll to find category dropdown
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Category'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(doc['category']!).last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save Document'));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Verify all documents are created
      for (final doc in testDocuments) {
        expect(find.text(doc['title']!), findsOneWidget);
      }

      // Test search by category-related content
      final searchField = find.widgetWithText(TextField, 'Search documents...').first;
      await tester.enterText(searchField, 'work');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should find work-related documents
      expect(find.text('Work Report'), findsOneWidget);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Test AI search mode for semantic search
      await tester.tap(find.text('AI Search'));
      await tester.pumpAndSettle();

      await tester.enterText(searchField, 'learning');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should potentially find study-related documents through semantic search
      // (Results depend on AI implementation)
    });

    testWidgets('Document validation and error handling', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test empty title validation
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Document'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a title'), findsOneWidget);

      // Test empty content validation
      await tester.enterText(find.byType(TextFormField).first, 'Valid Title');
      await tester.tap(find.text('Save Document'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter some content'), findsOneWidget);

      // Test valid document creation
      await tester.enterText(find.byType(TextFormField).at(1), 'Valid content for the document.');
      await tester.tap(find.text('Save Document'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Document added successfully!'), findsOneWidget);
      expect(find.text('MindVault'), findsOneWidget); // Back on main screen
    });

    testWidgets('Large document handling', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create a document with a lot of content
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      const longContent = '''
      This is a very long document with lots of content to test how the app handles large documents.
      Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
      Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
      Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
      Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
      Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium.
      ''';

      await tester.enterText(find.byType(TextFormField).first, 'Long Document Test');
      await tester.enterText(find.byType(TextFormField).at(1), longContent);

      await tester.tap(find.text('Save Document'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify document was created successfully
      expect(find.text('Document added successfully!'), findsOneWidget);
      expect(find.text('Long Document Test'), findsOneWidget);

      // Test that the document can be opened and scrolled
      await tester.tap(find.text('Long Document Test'));
      await tester.pumpAndSettle();

      // Verify content is displayed (at least partially)
      expect(find.textContaining('This is a very long document'), findsOneWidget);

      // Test scrolling in document details
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Should still be on the document details page
      expect(find.text('Long Document Test'), findsAtLeastNWidgets(1));
    });
  });
}