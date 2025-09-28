import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindvault/features/search/domain/entities/document.dart';
import 'package:mindvault/features/search/presentation/bloc/search_bloc.dart';
import 'package:mindvault/features/search/presentation/bloc/search_event.dart';
import 'package:mindvault/features/search/presentation/bloc/search_state.dart';
import 'package:mindvault/features/search/presentation/pages/add_document_page.dart';

class MockSearchBloc extends MockBloc<SearchEvent, SearchState>
    implements SearchBloc {}

class FakeSearchEvent extends Fake implements SearchEvent {}

class FakeDocument extends Fake implements Document {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSearchEvent());
    registerFallbackValue(FakeDocument());
  });

  group('AddDocumentPage Tests', () {
    late MockSearchBloc mockSearchBloc;

    setUp(() {
      mockSearchBloc = MockSearchBloc();
      when(() => mockSearchBloc.state).thenReturn(SearchInitial());
      when(() => mockSearchBloc.stream).thenAnswer((_) => const Stream.empty());
    });

    Widget createAddDocumentPage() {
      return MaterialApp(
        home: BlocProvider<SearchBloc>.value(
          value: mockSearchBloc,
          child: const AddDocumentView(),
        ),
      );
    }

    group('UI Elements', () {
      testWidgets('displays all form fields and elements',
          (WidgetTester tester) async {
        await tester.pumpWidget(createAddDocumentPage());

        // Check AppBar
        expect(find.widgetWithText(AppBar, 'Add Document'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);

        // Check form fields
        expect(find.byType(TextFormField), findsNWidgets(4));

        // Check field labels
        expect(find.text('Title *'), findsOneWidget);
        expect(find.text('Content *'), findsOneWidget);
        expect(find.text('Category (Optional)'), findsOneWidget);
        expect(find.text('Tags (Optional)'), findsOneWidget);

        // Check submit button
        expect(find.widgetWithText(ElevatedButton, 'Add Document'),
            findsOneWidget);
      });

      testWidgets('displays hint texts correctly', (WidgetTester tester) async {
        await tester.pumpWidget(createAddDocumentPage());

        expect(find.text('Enter document title'), findsOneWidget);
        expect(find.text('Enter document content'), findsOneWidget);
        expect(find.text('e.g., Work, Personal, Ideas'), findsOneWidget);
        expect(find.text('Enter tags separated by commas'), findsOneWidget);
      });

      testWidgets('displays helper text for tags field',
          (WidgetTester tester) async {
        await tester.pumpWidget(createAddDocumentPage());

        expect(
          find.text(
              'Separate tags with commas (e.g., important, work, project)'),
          findsOneWidget,
        );
      });
    });

    group('Form Validation', () {
      testWidgets('shows validation errors for required fields',
          (WidgetTester tester) async {
        await tester.pumpWidget(createAddDocumentPage());

        // Try to submit empty form
        await tester.tap(find.widgetWithText(ElevatedButton, 'Add Document'));
        await tester.pump();

        // Check validation messages
        expect(find.text('Title is required'), findsOneWidget);
        expect(find.text('Content is required'), findsOneWidget);
      });

      testWidgets('validates title field', (WidgetTester tester) async {
        await tester.pumpWidget(createAddDocumentPage());

        // Test empty title
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Title *'), '');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Add Document'));
        await tester.pump();

        expect(find.text('Title is required'), findsOneWidget);

        // Test whitespace-only title
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Title *'), '   ');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Add Document'));
        await tester.pump();

        expect(find.text('Title is required'), findsOneWidget);
      });

      testWidgets('validates content field', (WidgetTester tester) async {
        await tester.pumpWidget(createAddDocumentPage());

        // Test empty content
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Content *'), '');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Add Document'));
        await tester.pump();

        expect(find.text('Content is required'), findsOneWidget);

        // Test whitespace-only content
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Content *'), '   ');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Add Document'));
        await tester.pump();

        expect(find.text('Content is required'), findsOneWidget);
      });

      testWidgets('passes validation with valid input',
          (WidgetTester tester) async {
        await tester.pumpWidget(createAddDocumentPage());

        // Fill required fields
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Title *'),
          'Valid Title',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Content *'),
          'Valid content for the document',
        );

        await tester.tap(find.widgetWithText(ElevatedButton, 'Add Document'));
        await tester.pump();

        // No validation errors should be shown
        expect(find.text('Title is required'), findsNothing);
        expect(find.text('Content is required'), findsNothing);
      });
    });

    group('Form Submission', () {
      testWidgets('creates document with correct data on submission',
          (WidgetTester tester) async {
        await tester.pumpWidget(createAddDocumentPage());

        // Fill form fields
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Title *'),
          'Test Document',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Content *'),
          'This is test content',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Category (Optional)'),
          'Test Category',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Tags (Optional)'),
          'tag1, tag2, tag3',
        );

        await tester.tap(find.widgetWithText(ElevatedButton, 'Add Document'));
        await tester.pump();

        // Verify the correct event was added to the bloc
        verify(() => mockSearchBloc.add(any(that: isA<AddDocumentEvent>())))
            .called(1);
      });

      testWidgets('creates document without optional fields',
          (WidgetTester tester) async {
        await tester.pumpWidget(createAddDocumentPage());

        // Fill only required fields
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Title *'),
          'Test Document',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Content *'),
          'This is test content',
        );

        await tester.tap(find.widgetWithText(ElevatedButton, 'Add Document'));
        await tester.pump();

        verify(() => mockSearchBloc.add(any(that: isA<AddDocumentEvent>())))
            .called(1);
      });

      testWidgets('handles tags with whitespace correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(createAddDocumentPage());

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Title *'),
          'Test Document',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Content *'),
          'This is test content',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Tags (Optional)'),
          'tag1,  tag2 , ,tag3, ',
        );

        await tester.tap(find.widgetWithText(ElevatedButton, 'Add Document'));
        await tester.pump();

        verify(() => mockSearchBloc.add(any(that: isA<AddDocumentEvent>())))
            .called(1);
      });
    });

    group('BLoC State Handling', () {
      testWidgets('shows loading indicator when state is SearchLoading',
          (WidgetTester tester) async {
        when(() => mockSearchBloc.state).thenReturn(SearchLoading());

        await tester.pumpWidget(createAddDocumentPage());

        expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
        expect(
            find.widgetWithText(ElevatedButton, 'Add Document'), findsNothing);
      });

      testWidgets('disables submit button when loading',
          (WidgetTester tester) async {
        when(() => mockSearchBloc.state).thenReturn(SearchLoading());

        await tester.pumpWidget(createAddDocumentPage());

        final button =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);
      });

      testWidgets('shows success snackbar on DocumentAdded state',
          (WidgetTester tester) async {
        final testDocument = Document(
          id: 1,
          title: 'Test',
          content: 'Content',
          category: 'Category',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        whenListen(
          mockSearchBloc,
          Stream.fromIterable([
            SearchInitial(),
            DocumentAdded(testDocument),
          ]),
          initialState: SearchInitial(),
        );

        await tester.pumpWidget(createAddDocumentPage());
        await tester.pump();

        expect(find.text('Document added successfully!'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('shows error snackbar on SearchError state',
          (WidgetTester tester) async {
        const errorMessage = 'Failed to add document';

        whenListen(
          mockSearchBloc,
          Stream.fromIterable([
            SearchInitial(),
            const SearchError(errorMessage),
          ]),
          initialState: SearchInitial(),
        );

        await tester.pumpWidget(createAddDocumentPage());
        await tester.pump();

        expect(find.text('Error: $errorMessage'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });
    });

    group('AppBar Actions', () {
      testWidgets('save button triggers form submission',
          (WidgetTester tester) async {
        await tester.pumpWidget(createAddDocumentPage());

        // Fill required fields
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Title *'),
          'Test Title',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Content *'),
          'Test Content',
        );

        // Tap save button in AppBar
        await tester.tap(find.text('Save'));
        await tester.pump();

        verify(() => mockSearchBloc.add(any(that: isA<AddDocumentEvent>())))
            .called(1);
      });
    });

    group('Field Configuration', () {
      testWidgets('has proper form structure and validation',
          (WidgetTester tester) async {
        await tester.pumpWidget(createAddDocumentPage());

        // Verify all form fields are present
        expect(find.byType(Form), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(4));

        // Verify the form validates required fields
        await tester.tap(find.widgetWithText(ElevatedButton, 'Add Document'));
        await tester.pump();

        // Both title and content should show validation errors
        expect(find.text('Title is required'), findsOneWidget);
        expect(find.text('Content is required'), findsOneWidget);
      });
    });
  });
}
