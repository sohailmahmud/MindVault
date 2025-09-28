import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mindvault/main.dart' as app;
import 'package:mindvault/features/search/presentation/widgets/search_bar_widget.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MindVault Integration Tests', () {
    testWidgets('App startup and basic navigation',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify app starts with MindVault title
      expect(find.text('MindVault'), findsOneWidget);

      // Verify search bar is present
      expect(find.text('Search documents...'), findsOneWidget);

      // Verify main UI elements are present
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Document creation workflow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Tap the add button to navigate to add document page
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify we're on the add document page
      expect(find.text('Add Document'), findsOneWidget);
      expect(find.text('Title *'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);

      // Fill in document details
      await tester.enterText(
          find.byType(TextFormField).first, 'Integration Test Document');
      await tester.enterText(find.byType(TextFormField).at(1),
          'This is a test document created during integration testing.');

      // Scroll down to find category dropdown if needed
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      // Select a category
      await tester.tap(find.text('Category'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Work').last);
      await tester.pumpAndSettle();

      // Save the document
      await tester.tap(find.text('Save Document'));
      await tester.pumpAndSettle();

      // Verify we're back on the main page and document was created
      expect(find.text('MindVault'), findsOneWidget);
      expect(find.text('Document added successfully!'), findsOneWidget);

      // Wait for the snackbar to disappear
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify the document appears in the list
      expect(find.text('Integration Test Document'), findsOneWidget);
    });

    testWidgets('Document search workflow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // First, ensure we have some documents by adding one
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).first, 'Searchable Document');
      await tester.enterText(find.byType(TextFormField).at(1),
          'This document contains searchable content about flutter development.');

      await tester.tap(find.text('Save Document'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Now test search functionality
      final searchField =
          find.widgetWithText(TextField, 'Search documents...').first;
      await tester.enterText(searchField, 'searchable');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify search results
      expect(find.text('Searchable Document'), findsOneWidget);
      expect(find.textContaining('results found'), findsOneWidget);

      // Test clearing search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Verify search is cleared and all documents are shown
      final searchTextField = tester.widget<TextField>(searchField);
      expect(searchTextField.controller?.text, isEmpty);
    });

    testWidgets('AI search mode toggle', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify default search mode is Text Search
      expect(find.text('Text Search'), findsOneWidget);
      expect(find.text('AI Search'), findsOneWidget);

      // Switch to AI Search
      await tester.tap(find.text('AI Search'));
      await tester.pumpAndSettle();

      // Verify AI search chip is selected
      final aiSearchChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'AI Search'),
      );
      expect(aiSearchChip.selected, isTrue);

      // Switch back to Text Search
      await tester.tap(find.text('Text Search'));
      await tester.pumpAndSettle();

      final textSearchChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Text Search'),
      );
      expect(textSearchChip.selected, isTrue);
    });

    testWidgets('Document details navigation', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Add a document first
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).first, 'Detail Test Document');
      await tester.enterText(find.byType(TextFormField).at(1),
          'This document will be used to test the details view navigation.');

      await tester.tap(find.text('Save Document'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap on the document to view details
      await tester.tap(find.text('Detail Test Document'));
      await tester.pumpAndSettle();

      // Verify we're on the document details page
      expect(find.text('Detail Test Document'), findsAtLeastNWidgets(1));
      expect(
          find.text(
              'This document will be used to test the details view navigation.'),
          findsOneWidget);

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back on the main page
      expect(find.text('MindVault'), findsOneWidget);
    });

    testWidgets('Selection mode and bulk operations',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Add a couple of documents for testing
      for (int i = 1; i <= 2; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.enterText(
            find.byType(TextFormField).first, 'Test Document $i');
        await tester.enterText(find.byType(TextFormField).at(1),
            'Content for test document number $i.');

        await tester.tap(find.text('Save Document'));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Enter selection mode by tapping the checklist icon
      await tester.tap(find.byIcon(Icons.checklist));
      await tester.pumpAndSettle();

      // Verify we're in selection mode
      expect(find.text('0 selected'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Select a document by tapping its checkbox
      final checkboxes = find.byType(Checkbox);
      if (checkboxes.evaluate().isNotEmpty) {
        await tester.tap(checkboxes.first);
        await tester.pumpAndSettle();

        // Verify selection count updates
        expect(find.text('1 selected'), findsOneWidget);
        expect(find.byIcon(Icons.delete), findsOneWidget);
      }

      // Exit selection mode
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verify we're out of selection mode
      expect(find.text('MindVault'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Error handling and recovery', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test form validation by trying to save empty document
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Try to save without filling required fields
      await tester.tap(find.text('Save Document'));
      await tester.pumpAndSettle();

      // Verify validation error appears
      expect(find.text('Please enter a title'), findsOneWidget);

      // Fill in title only and try again
      await tester.enterText(find.byType(TextFormField).first, 'Test Title');
      await tester.tap(find.text('Save Document'));
      await tester.pumpAndSettle();

      // Should still show content validation error
      expect(find.text('Please enter some content'), findsOneWidget);

      // Navigate back without saving
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back on main page
      expect(find.text('MindVault'), findsOneWidget);
    });

    testWidgets('App theme and visual consistency',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify main theme elements
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, isNotNull);

      // Check for consistent Material Design 3 elements
      expect(find.byType(FloatingActionButton),
          findsNothing); // App uses IconButton instead
      expect(find.byType(SearchBarWidget), findsOneWidget);
      expect(find.byType(ChoiceChip),
          findsNWidgets(2)); // Text Search and AI Search chips

      // Navigate to add document page to check consistency
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify form styling consistency
      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
