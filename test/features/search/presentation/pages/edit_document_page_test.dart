import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindvault/features/search/domain/entities/document.dart';
import 'package:mindvault/features/search/presentation/bloc/search_bloc.dart';
import 'package:mindvault/features/search/presentation/bloc/search_event.dart';
import 'package:mindvault/features/search/presentation/bloc/search_state.dart';
import 'package:mindvault/features/search/presentation/pages/edit_document_page.dart';

class MockSearchBloc extends MockBloc<SearchEvent, SearchState> implements SearchBloc {}

void main() {
  group('EditDocumentPage Tests', () {
    late MockSearchBloc mockSearchBloc;
    late Document testDocument;

    setUp(() {
      mockSearchBloc = MockSearchBloc();
      testDocument = Document(
        id: 1,
        title: 'Test Document',
        content: 'Test content for editing',
        tags: const ['test', 'edit'],
        category: 'Work',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      when(() => mockSearchBloc.state).thenReturn(SearchInitial());
    });

    Widget createEditDocumentPage() {
      return MaterialApp(
        home: BlocProvider<SearchBloc>.value(
          value: mockSearchBloc,
          child: EditDocumentView(document: testDocument),
        ),
      );
    }

    testWidgets('displays edit document page with document data', (WidgetTester tester) async {
      await tester.pumpWidget(createEditDocumentPage());
      await tester.pumpAndSettle();

      expect(find.text('Edit Document'), findsOneWidget);
      expect(find.text(testDocument.title), findsOneWidget);
      expect(find.text(testDocument.content), findsOneWidget);
    });

    testWidgets('has form fields for document editing', (WidgetTester tester) async {
      await tester.pumpWidget(createEditDocumentPage());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
      expect(find.text('Title *'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('shows update button', (WidgetTester tester) async {
      await tester.pumpWidget(createEditDocumentPage());
      await tester.pumpAndSettle();

      expect(find.text('Update Document'), findsOneWidget);
    });

    testWidgets('can modify document title', (WidgetTester tester) async {
      await tester.pumpWidget(createEditDocumentPage());
      await tester.pumpAndSettle();

      final titleField = find.byType(TextFormField).first;
      await tester.tap(titleField);
      await tester.enterText(titleField, 'Updated Title');
      
      expect(find.text('Updated Title'), findsOneWidget);
    });

    testWidgets('has back navigation', (WidgetTester tester) async {
      await tester.pumpWidget(createEditDocumentPage());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('displays document category if present', (WidgetTester tester) async {
      await tester.pumpWidget(createEditDocumentPage());
      await tester.pumpAndSettle();

      expect(find.text('Category'), findsOneWidget);
    });
  });
}