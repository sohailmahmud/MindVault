import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault/features/search/domain/entities/document.dart';
import 'package:mindvault/features/search/presentation/bloc/search_state.dart';

void main() {
  group('SearchState Tests', () {
    final testDocument = Document(
      id: 1,
      title: 'Test Document',
      content: 'Test content',
      category: 'Test Category',
      tags: const ['tag1', 'tag2'],
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 2),
    );

    final testDocument2 = Document(
      id: 2,
      title: 'Test Document 2',
      content: 'Test content 2',
      category: 'Test Category 2',
      tags: const ['tag3', 'tag4'],
      createdAt: DateTime(2023, 2, 1),
      updatedAt: DateTime(2023, 2, 2),
    );

    group('SearchInitial', () {
      test('should extend SearchState', () {
        final state = SearchInitial();
        expect(state, isA<SearchState>());
        expect(state.props, equals([]));
      });

      test('should support equality comparison', () {
        final state1 = SearchInitial();
        final state2 = SearchInitial();
        expect(state1, equals(state2));
      });
    });

    group('SearchLoading', () {
      test('should extend SearchState', () {
        final state = SearchLoading();
        expect(state, isA<SearchState>());
        expect(state.props, equals([]));
      });

      test('should support equality comparison', () {
        final state1 = SearchLoading();
        final state2 = SearchLoading();
        expect(state1, equals(state2));
      });
    });

    group('SearchLoaded', () {
      test('should create SearchLoaded with required documents', () {
        final documents = [testDocument, testDocument2];
        final state = SearchLoaded(documents: documents);

        expect(state, isA<SearchState>());
        expect(state.documents, equals(documents));
        expect(state.searchQuery, isNull);
        expect(state.isSemanticSearch, isFalse);
        expect(state.selectedDocumentIds, equals(const <int>{}));
        expect(state.availableCategories, equals(const <String>[]));
        expect(state.availableTags, equals(const <String>[]));
      });

      test('should create SearchLoaded with all parameters', () {
        final documents = [testDocument];
        const searchQuery = 'test query';
        const isSemanticSearch = true;
        const selectedIds = {1, 2, 3};
        const categories = ['Work', 'Personal'];
        const tags = ['important', 'urgent'];

        final state = SearchLoaded(
          documents: documents,
          searchQuery: searchQuery,
          isSemanticSearch: isSemanticSearch,
          selectedDocumentIds: selectedIds,
          availableCategories: categories,
          availableTags: tags,
        );

        expect(state.documents, equals(documents));
        expect(state.searchQuery, equals(searchQuery));
        expect(state.isSemanticSearch, equals(isSemanticSearch));
        expect(state.selectedDocumentIds, equals(selectedIds));
        expect(state.availableCategories, equals(categories));
        expect(state.availableTags, equals(tags));
      });

      test('should return correct props for equality', () {
        final documents = [testDocument];
        const searchQuery = 'test query';
        const isSemanticSearch = true;
        const selectedIds = {1, 2};
        const categories = ['Work'];
        const tags = ['important'];

        final state = SearchLoaded(
          documents: documents,
          searchQuery: searchQuery,
          isSemanticSearch: isSemanticSearch,
          selectedDocumentIds: selectedIds,
          availableCategories: categories,
          availableTags: tags,
        );

        expect(
            state.props,
            equals([
              documents,
              searchQuery,
              isSemanticSearch,
              selectedIds,
              categories,
              tags,
            ]));
      });

      test('should support equality comparison', () {
        final documents = [testDocument];
        final state1 = SearchLoaded(documents: documents, searchQuery: 'test');
        final state2 = SearchLoaded(documents: documents, searchQuery: 'test');
        final state3 =
            SearchLoaded(documents: documents, searchQuery: 'different');

        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });

      test('copyWith should return new instance with updated fields', () {
        final originalDocuments = [testDocument];
        final newDocuments = [testDocument2];
        final originalState = SearchLoaded(
          documents: originalDocuments,
          searchQuery: 'original',
          isSemanticSearch: false,
          selectedDocumentIds: const {1},
          availableCategories: const ['Work'],
          availableTags: const ['tag1'],
        );

        final copiedState = originalState.copyWith(
          documents: newDocuments,
          searchQuery: 'updated',
          isSemanticSearch: true,
          selectedDocumentIds: const {2, 3},
          availableCategories: const ['Personal'],
          availableTags: const ['tag2'],
        );

        expect(copiedState.documents, equals(newDocuments));
        expect(copiedState.searchQuery, equals('updated'));
        expect(copiedState.isSemanticSearch, isTrue);
        expect(copiedState.selectedDocumentIds, equals(const {2, 3}));
        expect(copiedState.availableCategories, equals(const ['Personal']));
        expect(copiedState.availableTags, equals(const ['tag2']));

        // Original should remain unchanged
        expect(originalState.documents, equals(originalDocuments));
        expect(originalState.searchQuery, equals('original'));
        expect(originalState.isSemanticSearch, isFalse);
      });

      test(
          'copyWith should preserve original values when no parameters provided',
          () {
        final documents = [testDocument];
        final originalState = SearchLoaded(
          documents: documents,
          searchQuery: 'test',
          isSemanticSearch: true,
          selectedDocumentIds: const {1, 2},
          availableCategories: const ['Work'],
          availableTags: const ['important'],
        );

        final copiedState = originalState.copyWith();

        expect(copiedState.documents, equals(documents));
        expect(copiedState.searchQuery, equals('test'));
        expect(copiedState.isSemanticSearch, isTrue);
        expect(copiedState.selectedDocumentIds, equals(const {1, 2}));
        expect(copiedState.availableCategories, equals(const ['Work']));
        expect(copiedState.availableTags, equals(const ['important']));
      });

      test('copyWith should partially update fields', () {
        final documents = [testDocument];
        final originalState = SearchLoaded(
          documents: documents,
          searchQuery: 'original',
          isSemanticSearch: false,
        );

        final copiedState = originalState.copyWith(searchQuery: 'updated');

        expect(copiedState.documents, equals(documents));
        expect(copiedState.searchQuery, equals('updated'));
        expect(
            copiedState.isSemanticSearch, isFalse); // Should remain unchanged
      });
    });

    group('SearchError', () {
      test('should create SearchError with message', () {
        const message = 'Something went wrong';
        const state = SearchError(message);

        expect(state, isA<SearchState>());
        expect(state.message, equals(message));
        expect(state.props, equals([message]));
      });

      test('should support equality comparison', () {
        const state1 = SearchError('error');
        const state2 = SearchError('error');
        const state3 = SearchError('different error');

        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });
    });

    group('DocumentAdded', () {
      test('should create DocumentAdded with document', () {
        final state = DocumentAdded(testDocument);

        expect(state, isA<SearchState>());
        expect(state.document, equals(testDocument));
        expect(state.props, equals([testDocument]));
      });

      test('should support equality comparison', () {
        final state1 = DocumentAdded(testDocument);
        final state2 = DocumentAdded(testDocument);
        final state3 = DocumentAdded(testDocument2);

        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });
    });

    group('DocumentUpdated', () {
      test('should create DocumentUpdated with document', () {
        final state = DocumentUpdated(testDocument);

        expect(state, isA<SearchState>());
        expect(state.document, equals(testDocument));
        expect(state.props, equals([testDocument]));
      });

      test('should support equality comparison', () {
        final state1 = DocumentUpdated(testDocument);
        final state2 = DocumentUpdated(testDocument);
        final state3 = DocumentUpdated(testDocument2);

        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });
    });

    group('DocumentDeleted', () {
      test('should create DocumentDeleted with document ID', () {
        const documentId = 123;
        const state = DocumentDeleted(documentId);

        expect(state, isA<SearchState>());
        expect(state.documentId, equals(documentId));
        expect(state.props, equals([documentId]));
      });

      test('should support equality comparison', () {
        const state1 = DocumentDeleted(123);
        const state2 = DocumentDeleted(123);
        const state3 = DocumentDeleted(456);

        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });
    });

    group('MultipleDocumentsDeleted', () {
      test('should create MultipleDocumentsDeleted with document IDs', () {
        const documentIds = [1, 2, 3];
        const state = MultipleDocumentsDeleted(documentIds);

        expect(state, isA<SearchState>());
        expect(state.documentIds, equals(documentIds));
        expect(state.props, equals([documentIds]));
      });

      test('should support equality comparison', () {
        const state1 = MultipleDocumentsDeleted([1, 2, 3]);
        const state2 = MultipleDocumentsDeleted([1, 2, 3]);
        const state3 = MultipleDocumentsDeleted([4, 5, 6]);

        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });
    });

    group('CategoriesLoaded', () {
      test('should create CategoriesLoaded with categories list', () {
        const categories = ['Work', 'Personal', 'Study'];
        const state = CategoriesLoaded(categories);

        expect(state, isA<SearchState>());
        expect(state.categories, equals(categories));
        expect(state.props, equals([categories]));
      });

      test('should support equality comparison', () {
        const state1 = CategoriesLoaded(['Work', 'Personal']);
        const state2 = CategoriesLoaded(['Work', 'Personal']);
        const state3 = CategoriesLoaded(['Study', 'Projects']);

        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });
    });

    group('TagsLoaded', () {
      test('should create TagsLoaded with tags list', () {
        const tags = ['important', 'urgent', 'meeting'];
        const state = TagsLoaded(tags);

        expect(state, isA<SearchState>());
        expect(state.tags, equals(tags));
        expect(state.props, equals([tags]));
      });

      test('should support equality comparison', () {
        const state1 = TagsLoaded(['important', 'urgent']);
        const state2 = TagsLoaded(['important', 'urgent']);
        const state3 = TagsLoaded(['meeting', 'deadline']);

        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });
    });

    group('SearchState base class', () {
      test('should have empty props by default', () {
        // Test using a concrete implementation
        final state = SearchInitial();
        expect(state.props, equals([]));
      });
    });
  });
}
