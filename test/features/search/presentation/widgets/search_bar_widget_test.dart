import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault/features/search/presentation/widgets/search_bar_widget.dart';

void main() {
  group('SearchBarWidget Tests', () {
    late TextEditingController controller;
    late List<String> searchQueries;
    late int clearCallCount;

    setUp(() {
      controller = TextEditingController();
      searchQueries = [];
      clearCallCount = 0;
    });

    tearDown(() {
      controller.dispose();
    });

    Widget createSearchBarWidget() {
      return MaterialApp(
        home: Scaffold(
          body: SearchBarWidget(
            controller: controller,
            onSearch: (query) => searchQueries.add(query),
            onClear: () => clearCallCount++,
          ),
        ),
      );
    }

    testWidgets('displays search icon and hint text', (WidgetTester tester) async {
      await tester.pumpWidget(createSearchBarWidget());

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Search documents...'), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('calls onSearch when text is submitted', (WidgetTester tester) async {
      await tester.pumpWidget(createSearchBarWidget());

      const testQuery = 'flutter test';
      await tester.enterText(find.byType(TextField), testQuery);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(); // Handle pending timers

      expect(searchQueries, contains(testQuery));
    });

    testWidgets('calls onClear when clear button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(createSearchBarWidget());

      await tester.tap(find.byIcon(Icons.clear));
      
      expect(clearCallCount, equals(1));
    });

    testWidgets('calls onClear when text is cleared', (WidgetTester tester) async {
      await tester.pumpWidget(createSearchBarWidget());

      // Enter some text first
      await tester.enterText(find.byType(TextField), 'some text');
      await tester.pump();

      // Clear the text
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle(); // Handle pending timers

      expect(clearCallCount, equals(1));
    });

    testWidgets('performs delayed search on text change', (WidgetTester tester) async {
      await tester.pumpWidget(createSearchBarWidget());

      const testQuery = 'delayed search';
      await tester.enterText(find.byType(TextField), testQuery);
      await tester.pump();

      // Initially no search should be called
      expect(searchQueries, isEmpty);

      // Wait for the delay
      await tester.pump(const Duration(milliseconds: 600));

      expect(searchQueries, contains(testQuery));
    });

    testWidgets('controller updates text field', (WidgetTester tester) async {
      await tester.pumpWidget(createSearchBarWidget());

      const testText = 'programmatic text';
      controller.text = testText;
      await tester.pump();

      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('has proper styling', (WidgetTester tester) async {
      await tester.pumpWidget(createSearchBarWidget());

      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration!;

      expect(decoration.hintText, equals('Search documents...'));
      expect(decoration.prefixIcon, isA<Icon>());
      expect(decoration.suffixIcon, isA<IconButton>());
      expect(decoration.border, isA<OutlineInputBorder>());
      expect(decoration.filled, isTrue);
    });

    testWidgets('handles rapid text changes correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createSearchBarWidget());

      // Type multiple characters quickly
      await tester.enterText(find.byType(TextField), 'f');
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'fl');
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'flu');
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pump();

      // Only the final text should be searched after delay
      await tester.pump(const Duration(milliseconds: 600));

      expect(searchQueries.length, equals(1));
      expect(searchQueries.first, equals('flutter'));
    });
  });
}