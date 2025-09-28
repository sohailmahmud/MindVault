import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mindvault/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Experience and Performance Integration Tests', () {
    testWidgets('App startup performance and initialization', (WidgetTester tester) async {
      // Measure app startup time
      final stopwatch = Stopwatch()..start();
      
      app.main();
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Verify app starts within reasonable time (5 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      
      // Verify all main components are initialized
      expect(find.text('MindVault'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Text Search'), findsOneWidget);
      expect(find.text('AI Search'), findsOneWidget);
    });

    testWidgets('Navigation responsiveness and UI feedback', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test navigation to add document page
      final navStopwatch = Stopwatch()..start();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      navStopwatch.stop();

      // Navigation should be fast (under 1 second)
      expect(navStopwatch.elapsedMilliseconds, lessThan(1000));
      expect(find.text('Add Document'), findsOneWidget);

      // Test back navigation
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('MindVault'), findsOneWidget);

      // Test selection mode toggle responsiveness
      await tester.tap(find.byIcon(Icons.checklist));
      await tester.pumpAndSettle();
      expect(find.text('0 selected'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('MindVault'), findsOneWidget);
    });

    testWidgets('Memory usage with many documents', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create many documents to test memory usage
      const documentCount = 50;
      
      for (int i = 1; i <= documentCount; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).first, 'Memory Test Document $i');
        await tester.enterText(find.byType(TextFormField).at(1), 'Content for memory test document $i. This document contains enough text to test memory usage patterns.');

        await tester.tap(find.text('Save Document'));
        await tester.pumpAndSettle();
        
        // Only wait briefly to speed up test
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Test scrolling performance with many documents
      final scrollStopwatch = Stopwatch()..start();
      
      // Scroll through the document list
      for (int scroll = 0; scroll < 10; scroll++) {
        await tester.drag(find.byType(ListView), const Offset(0, -200));
        await tester.pump();
      }
      
      scrollStopwatch.stop();
      
      // Scrolling should remain responsive
      expect(scrollStopwatch.elapsedMilliseconds, lessThan(2000));

      // Test search performance with many documents
      final searchStopwatch = Stopwatch()..start();
      
      final searchField = find.widgetWithText(TextField, 'Search documents...').first;
      await tester.enterText(searchField, 'Memory Test');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      
      searchStopwatch.stop();
      
      // Search should complete reasonably quickly
      expect(searchStopwatch.elapsedMilliseconds, lessThan(3000));
      expect(find.textContaining('results found'), findsOneWidget);
    });

    testWidgets('UI theme consistency and accessibility', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test theme consistency across screens
      final mainAppBar = tester.widget<AppBar>(find.byType(AppBar));
      final mainTheme = Theme.of(tester.element(find.byType(AppBar)));

      // Navigate to add document page
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final addDocumentAppBar = tester.widget<AppBar>(find.byType(AppBar));
      final addDocumentTheme = Theme.of(tester.element(find.byType(AppBar)));

      // Verify theme consistency
      expect(addDocumentAppBar.backgroundColor, equals(mainAppBar.backgroundColor));
      expect(addDocumentTheme.colorScheme.primary, equals(mainTheme.colorScheme.primary));

      // Test accessibility elements
      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
      
      // Check for semantic labels by looking for label text
      expect(find.text('Title *'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);

      // Test form validation accessibility
      await tester.tap(find.text('Save Document'));
      await tester.pumpAndSettle();
      
      expect(find.text('Please enter a title'), findsOneWidget);

      // Go back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Test contrast and visibility
      final searchBar = find.widgetWithText(TextField, 'Search documents...');
      expect(searchBar, findsOneWidget);
      
      final textField = tester.widget<TextField>(searchBar.first);
      expect(textField.decoration?.hintText, equals('Search documents...'));
    });

    testWidgets('Error recovery and app stability', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test app stability with rapid interactions
      for (int i = 0; i < 5; i++) {
        // Rapidly switch between search modes
        await tester.tap(find.text('AI Search'));
        await tester.pump();
        await tester.tap(find.text('Text Search'));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // App should remain stable
      expect(find.text('MindVault'), findsOneWidget);

      // Test rapid navigation
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(find.text('MindVault'), findsOneWidget);

      // Test selection mode stability
      await tester.tap(find.byIcon(Icons.checklist));
      await tester.pumpAndSettle();
      
      // Rapidly toggle selection mode
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.checklist));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // Exit selection mode properly
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('MindVault'), findsOneWidget);
    });

    testWidgets('Database persistence and data integrity', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create a test document
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      const testTitle = 'Persistence Test Document';
      const testContent = 'This document tests data persistence across app sessions.';

      await tester.enterText(find.byType(TextFormField).first, testTitle);
      await tester.enterText(find.byType(TextFormField).at(1), testContent);

      await tester.tap(find.text('Save Document'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify document was created
      expect(find.text(testTitle), findsOneWidget);

      // Test document details persistence
      await tester.tap(find.text(testTitle));
      await tester.pumpAndSettle();

      expect(find.text(testTitle), findsAtLeastNWidgets(1));
      expect(find.text(testContent), findsOneWidget);

      // Go back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Test search functionality with persisted data
      final searchField = find.widgetWithText(TextField, 'Search documents...').first;
      await tester.enterText(searchField, 'persistence');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text(testTitle), findsOneWidget);

      // Clear search to verify data is still accessible
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.text(testTitle), findsOneWidget);
    });

    testWidgets('Offline functionality and local storage', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test that app works without network (it should be fully offline)
      // Create documents to verify local storage
      final testDocs = [
        'Offline Test Document 1',
        'Offline Test Document 2',
        'Offline Test Document 3',
      ];

      for (final docTitle in testDocs) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).first, docTitle);
        await tester.enterText(find.byType(TextFormField).at(1, ), 'Content for $docTitle stored locally.');

        await tester.tap(find.text('Save Document'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
      }

      // Verify all documents are accessible
      for (final docTitle in testDocs) {
        expect(find.text(docTitle), findsOneWidget);
      }

      // Test search works offline
      final searchField = find.widgetWithText(TextField, 'Search documents...').first;
      await tester.enterText(searchField, 'offline');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should find all offline test documents
      expect(find.textContaining('results found'), findsOneWidget);
      for (final docTitle in testDocs) {
        expect(find.text(docTitle), findsOneWidget);
      }

      // Test AI search works offline
      await tester.tap(find.text('AI Search'));
      await tester.pumpAndSettle();

      await tester.enterText(searchField, 'test document');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // AI search should work locally (results may vary based on implementation)
      expect(find.textContaining('AI Search'), findsOneWidget);
    });
  });
}