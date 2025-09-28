import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault/features/search/domain/entities/document.dart';
import 'package:mindvault/features/search/domain/usecases/add_document.dart';
import 'package:mindvault/features/search/domain/usecases/delete_document.dart';
import 'package:mindvault/features/search/domain/usecases/delete_multiple_documents.dart';
import 'package:mindvault/features/search/domain/usecases/get_document_by_id.dart';
import 'package:mindvault/features/search/domain/usecases/search_documents.dart';
import 'package:mindvault/features/search/domain/usecases/semantic_search.dart';
import 'package:mindvault/features/search/domain/usecases/update_document.dart';
import 'package:mindvault/core/usecases/usecase.dart';

void main() {
  group('UseCase Parameter Tests', () {
    test('AddDocumentParams should have correct properties', () {
      final document = Document(
        id: 1,
        title: 'Test Document',
        content: 'Test content',
        tags: ['test'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final params = AddDocumentParams(document: document);

      expect(params.document, equals(document));
      expect(params.props, equals([document]));
    });

    test('DeleteDocumentParams should have correct properties', () {
      const documentId = 123;
      const params = DeleteDocumentParams(documentId: documentId);

      expect(params.documentId, equals(documentId));
      expect(params.props, equals([documentId]));
    });

    test('DeleteMultipleDocumentsParams should have correct properties', () {
      const documentIds = [1, 2, 3, 4, 5];
      const params = DeleteMultipleDocumentsParams(documentIds: documentIds);

      expect(params.documentIds, equals(documentIds));
      expect(params.props, equals([documentIds]));
    });

    test('UpdateDocumentParams should have correct properties', () {
      final document = Document(
        id: 1,
        title: 'Updated Document',
        content: 'Updated content',
        tags: ['updated'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final params = UpdateDocumentParams(document: document);

      expect(params.document, equals(document));
      expect(params.props, equals([document]));
    });

    test('GetDocumentByIdParams should have correct properties', () {
      const documentId = 42;
      const params = GetDocumentByIdParams(documentId: documentId);

      expect(params.documentId, equals(documentId));
      expect(params.props, equals([documentId]));
    });

    test('SearchParams should have correct properties', () {
      const query = 'test search query';
      const params = SearchParams(query: query);

      expect(params.query, equals(query));
      expect(params.props, equals([query]));
    });

    test('SemanticSearchParams should have correct properties', () {
      const query = 'semantic search query';
      const params = SemanticSearchParams(query: query);

      expect(params.query, equals(query));
      expect(params.props, equals([query]));
    });

    test('NoParams should have empty props', () {
      final params = NoParams();

      expect(params.props, isEmpty);
    });

    test('Different AddDocumentParams with same document should be equal', () {
      final document = Document(
        id: 1,
        title: 'Test Document',
        content: 'Test content',
        tags: ['test'],
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      final params1 = AddDocumentParams(document: document);
      final params2 = AddDocumentParams(document: document);

      expect(params1, equals(params2));
    });

    test('Different DeleteDocumentParams with same id should be equal', () {
      const params1 = DeleteDocumentParams(documentId: 123);
      const params2 = DeleteDocumentParams(documentId: 123);

      expect(params1, equals(params2));
    });

    test('Different SearchParams with same query should be equal', () {
      const params1 = SearchParams(query: 'test');
      const params2 = SearchParams(query: 'test');

      expect(params1, equals(params2));
    });

    test('DeleteMultipleDocumentsParams with empty list', () {
      const params = DeleteMultipleDocumentsParams(documentIds: []);

      expect(params.documentIds, isEmpty);
      expect(params.props, equals([<int>[]]));
    });

    test('DeleteMultipleDocumentsParams with single item', () {
      const params = DeleteMultipleDocumentsParams(documentIds: [1]);

      expect(params.documentIds.length, equals(1));
      expect(params.documentIds.first, equals(1));
    });
  });
}