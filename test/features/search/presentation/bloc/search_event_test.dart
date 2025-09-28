import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault/features/search/domain/entities/document.dart';
import 'package:mindvault/features/search/presentation/bloc/search_event.dart';

void main() {
  group('SearchEvent Tests', () {
    final testDocument = Document(
      id: 1,
      title: 'Test Document',
      content: 'Test content',
      category: 'Test Category',
      tags: ['tag1', 'tag2'],
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 2),
    );

    group('SearchDocumentsEvent', () {
      test('should create SearchDocumentsEvent with query', () {
        const query = 'test query';
        const event = SearchDocumentsEvent(query);

        expect(event, isA<SearchEvent>());
        expect(event.query, equals(query));
        expect(event.props, equals([query]));
      });

      test('should support equality comparison', () {
        const event1 = SearchDocumentsEvent('query');
        const event2 = SearchDocumentsEvent('query');
        const event3 = SearchDocumentsEvent('different');

        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('SemanticSearchEvent', () {
      test('should create SemanticSearchEvent with query', () {
        const query = 'semantic query';
        const event = SemanticSearchEvent(query);

        expect(event, isA<SearchEvent>());
        expect(event.query, equals(query));
        expect(event.props, equals([query]));
      });

      test('should support equality comparison', () {
        const event1 = SemanticSearchEvent('query');
        const event2 = SemanticSearchEvent('query');
        const event3 = SemanticSearchEvent('different');

        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('LoadAllDocumentsEvent', () {
      test('should create LoadAllDocumentsEvent', () {
        const event = LoadAllDocumentsEvent();

        expect(event, isA<SearchEvent>());
        expect(event.props, equals([]));
      });

      test('should support equality comparison', () {
        const event1 = LoadAllDocumentsEvent();
        const event2 = LoadAllDocumentsEvent();

        expect(event1, equals(event2));
      });
    });

    group('AddDocumentEvent', () {
      test('should create AddDocumentEvent with document', () {
        final event = AddDocumentEvent(testDocument);

        expect(event, isA<SearchEvent>());
        expect(event.document, equals(testDocument));
        expect(event.props, equals([testDocument]));
      });

      test('should support equality comparison', () {
        final event1 = AddDocumentEvent(testDocument);
        final event2 = AddDocumentEvent(testDocument);
        final differentDocument = Document(
          id: 2,
          title: 'Different Document',
          content: 'Different content',
          category: 'Different Category',
          tags: ['different'],
          createdAt: DateTime(2023, 2, 1),
          updatedAt: DateTime(2023, 2, 2),
        );
        final event3 = AddDocumentEvent(differentDocument);

        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('ClearSearchEvent', () {
      test('should create ClearSearchEvent', () {
        const event = ClearSearchEvent();

        expect(event, isA<SearchEvent>());
        expect(event.props, equals([]));
      });

      test('should support equality comparison', () {
        const event1 = ClearSearchEvent();
        const event2 = ClearSearchEvent();

        expect(event1, equals(event2));
      });
    });

    group('UpdateDocumentEvent', () {
      test('should create UpdateDocumentEvent with document', () {
        final event = UpdateDocumentEvent(testDocument);

        expect(event, isA<SearchEvent>());
        expect(event.document, equals(testDocument));
        expect(event.props, equals([testDocument]));
      });

      test('should support equality comparison', () {
        final event1 = UpdateDocumentEvent(testDocument);
        final event2 = UpdateDocumentEvent(testDocument);
        final differentDocument = Document(
          id: 2,
          title: 'Different Document',
          content: 'Different content',
          category: 'Different Category',
          tags: ['different'],
          createdAt: DateTime(2023, 2, 1),
          updatedAt: DateTime(2023, 2, 2),
        );
        final event3 = UpdateDocumentEvent(differentDocument);

        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('DeleteDocumentEvent', () {
      test('should create DeleteDocumentEvent with document ID', () {
        const documentId = 123;
        const event = DeleteDocumentEvent(documentId);

        expect(event, isA<SearchEvent>());
        expect(event.documentId, equals(documentId));
        expect(event.props, equals([documentId]));
      });

      test('should support equality comparison', () {
        const event1 = DeleteDocumentEvent(123);
        const event2 = DeleteDocumentEvent(123);
        const event3 = DeleteDocumentEvent(456);

        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('DeleteMultipleDocumentsEvent', () {
      test('should create DeleteMultipleDocumentsEvent with document IDs', () {
        const documentIds = [1, 2, 3];
        const event = DeleteMultipleDocumentsEvent(documentIds);

        expect(event, isA<SearchEvent>());
        expect(event.documentIds, equals(documentIds));
        expect(event.props, equals([documentIds]));
      });

      test('should support equality comparison', () {
        const event1 = DeleteMultipleDocumentsEvent([1, 2, 3]);
        const event2 = DeleteMultipleDocumentsEvent([1, 2, 3]);
        const event3 = DeleteMultipleDocumentsEvent([4, 5, 6]);

        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('SearchWithFiltersEvent', () {
      test('should create SearchWithFiltersEvent with default values', () {
        const event = SearchWithFiltersEvent();

        expect(event, isA<SearchEvent>());
        expect(event.query, isNull);
        expect(event.category, isNull);
        expect(event.tags, isNull);
        expect(event.startDate, isNull);
        expect(event.endDate, isNull);
        expect(event.sortBy, equals('updatedAt'));
        expect(event.ascending, isFalse);
        expect(event.props,
            equals([null, null, null, null, null, 'updatedAt', false]));
      });

      test('should create SearchWithFiltersEvent with custom values', () {
        final startDate = DateTime(2023, 1, 1);
        final endDate = DateTime(2023, 12, 31);
        final event = SearchWithFiltersEvent(
          query: 'test query',
          category: 'Work',
          tags: const ['important', 'urgent'],
          startDate: startDate,
          endDate: endDate,
          sortBy: 'createdAt',
          ascending: true,
        );

        expect(event.query, equals('test query'));
        expect(event.category, equals('Work'));
        expect(event.tags, equals(['important', 'urgent']));
        expect(event.startDate, equals(startDate));
        expect(event.endDate, equals(endDate));
        expect(event.sortBy, equals('createdAt'));
        expect(event.ascending, isTrue);
        expect(
            event.props,
            equals([
              'test query',
              'Work',
              ['important', 'urgent'],
              startDate,
              endDate,
              'createdAt',
              true
            ]));
      });

      test('should support equality comparison', () {
        const event1 = SearchWithFiltersEvent(query: 'test');
        const event2 = SearchWithFiltersEvent(query: 'test');
        const event3 = SearchWithFiltersEvent(query: 'different');

        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('GetCategoriesEvent', () {
      test('should create GetCategoriesEvent', () {
        const event = GetCategoriesEvent();

        expect(event, isA<SearchEvent>());
        expect(event.props, equals([]));
      });

      test('should support equality comparison', () {
        const event1 = GetCategoriesEvent();
        const event2 = GetCategoriesEvent();

        expect(event1, equals(event2));
      });
    });

    group('GetTagsEvent', () {
      test('should create GetTagsEvent', () {
        const event = GetTagsEvent();

        expect(event, isA<SearchEvent>());
        expect(event.props, equals([]));
      });

      test('should support equality comparison', () {
        const event1 = GetTagsEvent();
        const event2 = GetTagsEvent();

        expect(event1, equals(event2));
      });
    });

    group('ToggleDocumentSelectionEvent', () {
      test('should create ToggleDocumentSelectionEvent with document ID', () {
        const documentId = 42;
        const event = ToggleDocumentSelectionEvent(documentId);

        expect(event, isA<SearchEvent>());
        expect(event.documentId, equals(documentId));
        expect(event.props, equals([documentId]));
      });

      test('should support equality comparison', () {
        const event1 = ToggleDocumentSelectionEvent(42);
        const event2 = ToggleDocumentSelectionEvent(42);
        const event3 = ToggleDocumentSelectionEvent(84);

        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('ClearSelectionEvent', () {
      test('should create ClearSelectionEvent', () {
        const event = ClearSelectionEvent();

        expect(event, isA<SearchEvent>());
        expect(event.props, equals([]));
      });

      test('should support equality comparison', () {
        const event1 = ClearSelectionEvent();
        const event2 = ClearSelectionEvent();

        expect(event1, equals(event2));
      });
    });

    group('SearchEvent base class', () {
      test('should have empty props by default', () {
        // Create a concrete subclass to test the base class
        const event = LoadAllDocumentsEvent();
        expect(event.props, equals([]));
      });
    });
  });
}
