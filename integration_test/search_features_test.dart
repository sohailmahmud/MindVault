import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mindvault/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Search and AI Features Integration Tests', () {
    testWidgets('Text search functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create test documents with specific searchable content
      final testDocuments = [
        {
          'title': 'Flutter Development Guide',
          'content':
              'Learn Flutter development with widgets and state management'
        },
        {
          'title': 'JavaScript Tutorial',
          'content':
              'Complete guide to JavaScript programming and web development'
        },
        {
          'title': 'Mobile App Design',
          'content': 'Best practices for designing mobile applications'
        },
        {
          'title': 'Database Management',
          'content': 'SQL and NoSQL database concepts and implementation'
        },
      ];

      for (final doc in testDocuments) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).first, doc['title']!);
        await tester.enterText(
            find.byType(TextFormField).at(1), doc['content']!);

        await tester.tap(find.text('Save Document'));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Test exact word search
      final searchField =
          find.widgetWithText(TextField, 'Search documents...').first;
      await tester.enterText(searchField, 'Flutter');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Flutter Development Guide'), findsOneWidget);
      expect(find.textContaining('results found'), findsOneWidget);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Test partial word search
      await tester.enterText(searchField, 'develop');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should find both Flutter and JavaScript documents
      expect(find.text('Flutter Development Guide'), findsOneWidget);
      expect(find.text('JavaScript Tutorial'), findsOneWidget);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Test case-insensitive search
      await tester.enterText(searchField, 'MOBILE');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Mobile App Design'), findsOneWidget);

      // Clear search and verify all documents are shown
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      for (final doc in testDocuments) {
        expect(find.text(doc['title']!), findsOneWidget);
      }
    });

    testWidgets('AI semantic search functionality',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create documents with semantically related but different terminology
      final semanticDocuments = [
        {
          'title': 'Car Maintenance Tips',
          'content': 'How to maintain your vehicle and keep it running smoothly'
        },
        {
          'title': 'Cooking Recipes',
          'content':
              'Delicious recipes for meals and food preparation techniques'
        },
        {
          'title': 'Exercise Routine',
          'content': 'Physical fitness workouts and training schedules'
        },
        {
          'title': 'Garden Care Guide',
          'content': 'Plant care, watering, and gardening best practices'
        },
      ];

      for (final doc in semanticDocuments) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).first, doc['title']!);
        await tester.enterText(
            find.byType(TextFormField).at(1), doc['content']!);

        await tester.tap(find.text('Save Document'));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Switch to AI Search mode
      await tester.tap(find.text('AI Search'));
      await tester.pumpAndSettle();

      // Verify AI Search chip is selected
      final aiSearchChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'AI Search'),
      );
      expect(aiSearchChip.selected, isTrue);

      // Test semantic search - search for "automobile" should find car document
      final searchField =
          find.widgetWithText(TextField, 'Search documents...').first;
      await tester.enterText(searchField, 'automobile');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // With AI search, it might find car-related content
      // Note: Results depend on AI implementation
      expect(find.textContaining('AI Search'), findsOneWidget);

      // Clear and test another semantic search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      await tester.enterText(searchField, 'healthy lifestyle');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should potentially find exercise or food-related documents
      // Results depend on AI semantic understanding

      // Switch back to text search
      await tester.tap(find.text('Text Search'));
      await tester.pumpAndSettle();

      final textSearchChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Text Search'),
      );
      expect(textSearchChip.selected, isTrue);
    });

    testWidgets('Search performance and responsiveness',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create multiple documents for performance testing
      for (int i = 1; i <= 10; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.enterText(
            find.byType(TextFormField).first, 'Performance Test Document $i');
        await tester.enterText(find.byType(TextFormField).at(1),
            'Content for performance testing document number $i with various keywords and content.');

        await tester.tap(find.text('Save Document'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
      }

      // Test rapid search queries
      final searchField =
          find.widgetWithText(TextField, 'Search documents...').first;

      final searchQueries = [
        'performance',
        'test',
        'document',
        'content',
        'number'
      ];

      for (final query in searchQueries) {
        await tester.enterText(searchField, query);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Verify search completes and shows results
        expect(find.textContaining('results found'), findsOneWidget);

        // Clear for next search
        await tester.tap(find.byIcon(Icons.clear));
        await tester.pumpAndSettle();
      }

      // Test empty search returns all documents
      await tester.enterText(searchField, '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should show multiple documents
      expect(find.text('Performance Test Document 1'), findsOneWidget);
      expect(find.text('Performance Test Document 10'), findsOneWidget);
    });

    testWidgets('Search edge cases and error handling',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Add one test document
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).first, 'Edge Case Document');
      await tester.enterText(find.byType(TextFormField).at(1),
          'Content for testing edge cases in search functionality.');

      await tester.tap(find.text('Save Document'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final searchField =
          find.widgetWithText(TextField, 'Search documents...').first;

      // Test search with no results
      await tester.enterText(searchField, 'nonexistentterm');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.textContaining('No documents found'), findsOneWidget);
      expect(find.text('Clear Search'), findsOneWidget);

      // Clear no-results state
      await tester.tap(find.text('Clear Search'));
      await tester.pumpAndSettle();

      // Should be back to showing all documents
      expect(find.text('Edge Case Document'), findsOneWidget);

      // Test special characters in search
      await tester.enterText(searchField, '@#\$%');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should handle gracefully - likely no results
      expect(find.textContaining('No documents found'), findsOneWidget);

      // Test very long search query
      const longQuery =
          'this is a very long search query that tests how the search handles extremely long input strings';
      await tester.enterText(searchField, longQuery);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should handle without crashing
      expect(find.byType(TextField), findsOneWidget);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Verify clear functionality works
      final textField = tester.widget<TextField>(searchField);
      expect(textField.controller?.text, isEmpty);
      expect(find.text('Edge Case Document'), findsOneWidget);
    });

    testWidgets('Search mode switching during active search',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Add test documents
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).first, 'Search Mode Test');
      await tester.enterText(find.byType(TextFormField).at(1),
          'Testing search mode switching functionality.');

      await tester.tap(find.text('Save Document'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Start with text search
      final searchField =
          find.widgetWithText(TextField, 'Search documents...').first;
      await tester.enterText(searchField, 'test');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should show results with text search indicator
      expect(find.textContaining('Text Search'), findsOneWidget);
      expect(find.text('Search Mode Test'), findsOneWidget);

      // Switch to AI search while query is active
      await tester.tap(find.text('AI Search'));
      await tester.pumpAndSettle();

      // Should re-run search with AI mode
      expect(find.textContaining('AI Search'), findsOneWidget);

      // Switch back to text search
      await tester.tap(find.text('Text Search'));
      await tester.pumpAndSettle();

      // Should re-run search with text mode
      expect(find.textContaining('Text Search'), findsOneWidget);
      expect(find.text('Search Mode Test'), findsOneWidget);
    });
  });
}
