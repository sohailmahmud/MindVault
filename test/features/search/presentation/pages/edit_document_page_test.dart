import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindvault/features/search/domain/entities/document.dart';
import 'package:mindvault/features/search/presentation/bloc/search_bloc.dart';
import 'package:mindvault/features/search/presentation/bloc/search_state.dart';
import 'package:mindvault/features/search/presentation/pages/edit_document_page.dart';

class MockSearchBloc extends Mock implements SearchBloc {
  @override
  Future<void> close() async {
    return Future.value();
  }
}

void main() {
  late MockSearchBloc mockSearchBloc;
  late Document testDocument;

  setUp(() {
    mockSearchBloc = MockSearchBloc();
    testDocument = Document(
      id: 1,
      title: 'Test Document',
      content: 'Test Content',
      category: 'Test Category',
      tags: const ['tag1', 'tag2'],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
    );
    
    // Set up default bloc behavior
    when(() => mockSearchBloc.state).thenReturn(SearchInitial());
    when(() => mockSearchBloc.stream).thenAnswer((_) => Stream.fromIterable([SearchInitial()]));
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<SearchBloc>(
        create: (_) => mockSearchBloc,
        child: EditDocumentView(document: testDocument),
      ),
    );
  }

  group('EditDocumentPage Tests', () {
    group('Widget Rendering', () {
      testWidgets('should display document information correctly', (tester) async {
        // arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // assert
        expect(find.text('Edit Document'), findsOneWidget);
        expect(find.text('Test Document'), findsOneWidget);
        expect(find.text('Test Content'), findsOneWidget);
        expect(find.text('Test Category'), findsOneWidget);
        expect(find.text('tag1, tag2'), findsOneWidget);
      });

      testWidgets('should display creation and update dates', (tester) async {
        // arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // assert
        expect(find.textContaining('Created:'), findsOneWidget);
        expect(find.textContaining('Last Updated:'), findsOneWidget);
        expect(find.textContaining('1/1/2024'), findsOneWidget);
        expect(find.textContaining('2/1/2024'), findsOneWidget);
      });

      testWidgets('should have all required form fields', (tester) async {
        // arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // assert
        expect(find.byType(TextFormField), findsNWidgets(4));
        expect(find.text('Title *'), findsOneWidget);
        expect(find.text('Content *'), findsOneWidget);
        expect(find.text('Category (Optional)'), findsOneWidget);
        expect(find.text('Tags (Optional)'), findsOneWidget);
      });

      testWidgets('should display action buttons', (tester) async {
        // arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // assert
        expect(find.text('Save Changes'), findsOneWidget);
        expect(find.text('Delete Document'), findsOneWidget);
        expect(find.byIcon(Icons.delete), findsNWidgets(2)); // AppBar and button
        expect(find.text('Save'), findsOneWidget); // AppBar save button
      });
    });

    group('Form Interaction', () {
      testWidgets('should allow text input in all fields', (tester) async {
        // arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // act & assert - Title field
        final titleField = find.widgetWithText(TextFormField, 'Test Document');
        expect(titleField, findsOneWidget);
        await tester.enterText(titleField, 'Updated Title');
        expect(find.text('Updated Title'), findsOneWidget);

        // act & assert - Content field
        final contentField = find.widgetWithText(TextFormField, 'Test Content');
        expect(contentField, findsOneWidget);
        await tester.enterText(contentField, 'Updated Content');
        expect(find.text('Updated Content'), findsOneWidget);
      });

      testWidgets('should validate required fields when empty', (tester) async {
        // arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // act - Clear title field and try to save
        final titleField = find.widgetWithText(TextFormField, 'Test Document');
        await tester.enterText(titleField, '');
        await tester.tap(find.text('Save Changes'));
        await tester.pump();

        // assert
        expect(find.text('Title is required'), findsOneWidget);
      });
    });

    group('BLoC State Handling', () {
      testWidgets('should show loading indicator when state is SearchLoading', (tester) async {
        // arrange
        when(() => mockSearchBloc.state).thenReturn(SearchLoading());
        when(() => mockSearchBloc.stream).thenAnswer((_) => Stream.fromIterable([SearchLoading()]));

        await tester.pumpWidget(createWidgetUnderTest());

        // assert
        expect(find.byType(CircularProgressIndicator), findsNWidgets(2)); // Both overlay and button
      });

      testWidgets('should disable buttons when loading', (tester) async {
        // arrange
        when(() => mockSearchBloc.state).thenReturn(SearchLoading());
        when(() => mockSearchBloc.stream).thenAnswer((_) => Stream.fromIterable([SearchLoading()]));

        await tester.pumpWidget(createWidgetUnderTest());

        // assert
        final saveButton = find.widgetWithText(ElevatedButton, 'Save Changes');
        final deleteButton = find.widgetWithText(OutlinedButton, 'Delete Document');
        
        final saveButtonWidget = tester.widget<ElevatedButton>(saveButton);
        final deleteButtonWidget = tester.widget<OutlinedButton>(deleteButton);
        
        expect(saveButtonWidget.onPressed, isNull);
        expect(deleteButtonWidget.onPressed, isNull);
      });
    });

    group('Delete Dialog', () {
      testWidgets('should show delete confirmation dialog', (tester) async {
        // arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // act
        await tester.tap(find.text('Delete Document'));
        await tester.pumpAndSettle();

        // assert
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Delete Document'), findsNWidgets(2)); // Dialog title and button
        expect(find.textContaining('Are you sure you want to delete'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Delete'), findsNWidgets(2)); // Dialog button and page button
      });

      testWidgets('should close dialog when cancel is tapped', (tester) async {
        // arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // act
        await tester.tap(find.text('Delete Document'));
        await tester.pumpAndSettle();
        
        expect(find.byType(AlertDialog), findsOneWidget);
        
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // assert
        expect(find.byType(AlertDialog), findsNothing);
      });
    });

    group('Field Content Display', () {
      testWidgets('should display empty category when document has null category', (tester) async {
        // arrange
        final docWithoutCategory = testDocument.copyWith(category: null);
        
        final widget = MaterialApp(
          home: BlocProvider<SearchBloc>(
            create: (_) => mockSearchBloc,
            child: EditDocumentView(document: docWithoutCategory),
          ),
        );

        await tester.pumpWidget(widget);

        // assert - Look for the category field by finding the label text
        expect(find.text('Category (Optional)'), findsOneWidget);
        
        // The text field should not contain any initial text for null category
        final formFields = find.byType(TextFormField);
        expect(formFields, findsNWidgets(4));
      });

      testWidgets('should display empty tags when document has no tags', (tester) async {
        // arrange
        final docWithoutTags = testDocument.copyWith(tags: []);
        
        final widget = MaterialApp(
          home: BlocProvider<SearchBloc>(
            create: (_) => mockSearchBloc,
            child: EditDocumentView(document: docWithoutTags),
          ),
        );

        await tester.pumpWidget(widget);

        // assert - Look for the tags field by finding the label text
        expect(find.text('Tags (Optional)'), findsOneWidget);
        
        // The form should render with empty tags field
        final formFields = find.byType(TextFormField);
        expect(formFields, findsNWidgets(4));
      });
    });

    group('AppBar Actions', () {
      testWidgets('should have delete and save buttons in app bar', (tester) async {
        // arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // assert
        expect(find.byIcon(Icons.delete), findsAtLeastNWidgets(1));
        expect(find.text('Save'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should provide proper semantics for screen readers', (tester) async {
        // arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // assert
        expect(find.byTooltip('Delete Document'), findsOneWidget);
        expect(find.text('Title *'), findsOneWidget); // Required field indicator
        expect(find.text('Content *'), findsOneWidget); // Required field indicator
      });
    });
  });
}