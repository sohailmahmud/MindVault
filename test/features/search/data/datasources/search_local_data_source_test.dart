import 'package:flutter_test/flutter_test.dart';

import 'package:mindvault/features/search/data/datasources/search_local_data_source.dart';
import 'package:mindvault/features/search/data/models/document_model.dart';

// Simple test implementation for interface testing
class TestSearchLocalDataSource implements SearchLocalDataSource {
  final List<DocumentModel> _documents = [];
  int _nextId = 1;

  @override
  Future<List<DocumentModel>> getAllDocuments() async {
    return List.from(_documents);
  }

  @override
  Future<DocumentModel?> getDocumentById(int id) async {
    try {
      return _documents.firstWhere((doc) => doc.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<DocumentModel>> searchDocuments(String query) async {
    return _documents
        .where((doc) =>
            doc.title.toLowerCase().contains(query.toLowerCase()) ||
            doc.content.toLowerCase().contains(query.toLowerCase()) ||
            (doc.category?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .toList();
  }

  @override
  Future<DocumentModel> addDocument(DocumentModel document) async {
    final newDoc = document.copyWith(id: _nextId++);
    _documents.add(newDoc);
    return newDoc;
  }

  @override
  Future<DocumentModel> updateDocument(DocumentModel document) async {
    final index = _documents.indexWhere((doc) => doc.id == document.id);
    if (index != -1) {
      _documents[index] = document;
      return document;
    }
    throw Exception('Document with ID ${document.id} not found');
  }

  @override
  Future<void> deleteDocument(int id) async {
    final initialLength = _documents.length;
    _documents.removeWhere((doc) => doc.id == id);
    if (_documents.length == initialLength) {
      throw Exception(
          'Failed to delete document with ID: $id. Document may not exist.');
    }
  }

  @override
  Future<List<DocumentModel>> getDocumentsByCategory(String category) async {
    return _documents.where((doc) => doc.category == category).toList();
  }

  @override
  Future<List<DocumentModel>> getDocumentsByTags(List<String> tags) async {
    return _documents
        .where((doc) => tags.any((tag) => doc.tags.contains(tag)))
        .toList();
  }

  @override
  Future<List<DocumentModel>> searchWithFilters({
    String? query,
    String? category,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'updatedAt',
    bool ascending = false,
  }) async {
    var results = List.from(_documents);

    // Apply filters
    if (query != null && query.isNotEmpty) {
      results = results
          .where((doc) =>
              doc.title.toLowerCase().contains(query.toLowerCase()) ||
              doc.content.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    if (category != null && category.isNotEmpty) {
      results = results.where((doc) => doc.category == category).toList();
    }

    if (tags != null && tags.isNotEmpty) {
      results = results
          .where((doc) => tags.any((tag) => doc.tags.contains(tag)))
          .toList();
    }

    if (startDate != null) {
      results = results
          .where((doc) =>
              doc.updatedAt.isAfter(startDate) ||
              doc.updatedAt.isAtSameMomentAs(startDate))
          .toList();
    }

    if (endDate != null) {
      results = results
          .where((doc) =>
              doc.updatedAt.isBefore(endDate) ||
              doc.updatedAt.isAtSameMomentAs(endDate))
          .toList();
    }

    // Apply sorting
    results.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'createdAt':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'updatedAt':
        default:
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
      }
      return ascending ? comparison : -comparison;
    });

    return results.cast<DocumentModel>();
  }

  @override
  Future<List<String>> getAllCategories() async {
    final categories = _documents
        .where((doc) => doc.category != null)
        .map((doc) => doc.category!)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  @override
  Future<List<String>> getAllTags() async {
    final tags = <String>{};
    for (final doc in _documents) {
      tags.addAll(doc.tags);
    }
    final sortedTags = tags.toList()..sort();
    return sortedTags;
  }

  @override
  Future<List<String>> suggestCategories(String input) async {
    final categories = await getAllCategories();
    return categories
        .where(
            (category) => category.toLowerCase().contains(input.toLowerCase()))
        .take(5)
        .toList();
  }

  @override
  Future<List<String>> suggestTags(String input) async {
    final tags = await getAllTags();
    return tags
        .where((tag) => tag.toLowerCase().contains(input.toLowerCase()))
        .take(10)
        .toList();
  }

  @override
  Future<void> deleteMultipleDocuments(List<int> ids) async {
    final failedDeletes = <int>[];
    for (final id in ids) {
      final initialLength = _documents.length;
      _documents.removeWhere((doc) => doc.id == id);
      if (_documents.length == initialLength) {
        failedDeletes.add(id);
      }
    }
    if (failedDeletes.isNotEmpty) {
      throw Exception(
          'Failed to delete documents with IDs: $failedDeletes. Documents may not exist.');
    }
  }

  @override
  Future<List<DocumentModel>> updateMultipleDocuments(
      List<DocumentModel> documents) async {
    final updatedDocs = <DocumentModel>[];
    for (final document in documents) {
      final updated = await updateDocument(document);
      updatedDocs.add(updated);
    }
    return updatedDocs;
  }
}

void main() {
  late TestSearchLocalDataSource dataSource;
  late List<DocumentModel> testDocuments;

  setUp(() {
    dataSource = TestSearchLocalDataSource();
    testDocuments = [
      DocumentModel(
        id: 1,
        title: 'Test Document 1',
        content: 'Content 1',
        category: 'Category 1',
        tags: ['tag1', 'tag2'],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      ),
      DocumentModel(
        id: 2,
        title: 'Test Document 2',
        content: 'Content 2',
        category: 'Category 2',
        tags: ['tag2', 'tag3'],
        createdAt: DateTime(2024, 1, 3),
        updatedAt: DateTime(2024, 1, 4),
      ),
    ];
  });

  group('SearchLocalDataSource', () {
    group('getAllDocuments', () {
      test('should return all documents', () async {
        // arrange
        for (final doc in testDocuments) {
          await dataSource.addDocument(doc);
        }

        // act
        final result = await dataSource.getAllDocuments();

        // assert
        expect(result.length, equals(2));
        expect(result.any((doc) => doc.title == 'Test Document 1'), isTrue);
        expect(result.any((doc) => doc.title == 'Test Document 2'), isTrue);
      });

      test('should return empty list when no documents exist', () async {
        // act
        final result = await dataSource.getAllDocuments();

        // assert
        expect(result, isEmpty);
      });
    });

    group('getDocumentById', () {
      test('should return document when found', () async {
        // arrange
        final addedDoc = await dataSource.addDocument(testDocuments[0]);

        // act
        final result = await dataSource.getDocumentById(addedDoc.id);

        // assert
        expect(result, isNotNull);
        expect(result!.title, equals('Test Document 1'));
      });

      test('should return null when document not found', () async {
        // act
        final result = await dataSource.getDocumentById(999);

        // assert
        expect(result, isNull);
      });
    });

    group('addDocument', () {
      test('should add document and return it with ID', () async {
        // arrange
        final newDocument = DocumentModel(
          title: 'New Document',
          content: 'New Content',
          category: 'New Category',
          tags: ['new-tag'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act
        final result = await dataSource.addDocument(newDocument);

        // assert
        expect(result.id, isNotNull);
        expect(result.title, equals('New Document'));

        // Verify it's stored
        final stored = await dataSource.getDocumentById(result.id);
        expect(stored, isNotNull);
      });
    });

    group('updateDocument', () {
      test('should update document and return it', () async {
        // arrange
        final addedDoc = await dataSource.addDocument(testDocuments[0]);
        final updatedDocument = addedDoc.copyWith(title: 'Updated Title');

        // act
        final result = await dataSource.updateDocument(updatedDocument);

        // assert
        expect(result.title, equals('Updated Title'));

        // Verify it's updated in storage
        final stored = await dataSource.getDocumentById(addedDoc.id);
        expect(stored!.title, equals('Updated Title'));
      });

      test('should throw exception when document not found', () async {
        // arrange
        final nonExistentDoc = testDocuments[0].copyWith(id: 999);

        // act & assert
        await expectLater(
          () => dataSource.updateDocument(nonExistentDoc),
          throwsException,
        );
      });
    });

    group('deleteDocument', () {
      test('should delete document successfully', () async {
        // arrange
        final addedDoc = await dataSource.addDocument(testDocuments[0]);

        // act
        await dataSource.deleteDocument(addedDoc.id);

        // assert
        final result = await dataSource.getDocumentById(addedDoc.id);
        expect(result, isNull);
      });

      test('should throw exception when document not found', () async {
        // act & assert
        await expectLater(
          () => dataSource.deleteDocument(999),
          throwsException,
        );
      });
    });

    group('searchDocuments', () {
      test('should return documents matching query in title', () async {
        // arrange
        for (final doc in testDocuments) {
          await dataSource.addDocument(doc);
        }

        // act
        final result = await dataSource.searchDocuments('Document 1');

        // assert
        expect(result.length, equals(1));
        expect(result[0].title, contains('Document 1'));
      });

      test('should return documents matching query in content', () async {
        // arrange
        for (final doc in testDocuments) {
          await dataSource.addDocument(doc);
        }

        // act
        final result = await dataSource.searchDocuments('Content 2');

        // assert
        expect(result.length, equals(1));
        expect(result[0].content, contains('Content 2'));
      });

      test('should return empty list when no matches found', () async {
        // arrange
        for (final doc in testDocuments) {
          await dataSource.addDocument(doc);
        }

        // act
        final result = await dataSource.searchDocuments('NonExistent');

        // assert
        expect(result, isEmpty);
      });
    });

    group('getDocumentsByCategory', () {
      test('should return documents in specified category', () async {
        // arrange
        for (final doc in testDocuments) {
          await dataSource.addDocument(doc);
        }

        // act
        final result = await dataSource.getDocumentsByCategory('Category 1');

        // assert
        expect(result.length, equals(1));
        expect(result[0].category, equals('Category 1'));
      });
    });

    group('getAllCategories', () {
      test('should return sorted list of unique categories', () async {
        // arrange
        for (final doc in testDocuments) {
          await dataSource.addDocument(doc);
        }

        // act
        final result = await dataSource.getAllCategories();

        // assert
        expect(result, equals(['Category 1', 'Category 2']));
      });

      test('should handle documents with null categories', () async {
        // arrange
        final docWithoutCategory = testDocuments[0].copyWith(category: null);
        await dataSource.addDocument(testDocuments[0]);
        await dataSource.addDocument(docWithoutCategory);

        // act
        final result = await dataSource.getAllCategories();

        // assert
        expect(result, equals(['Category 1']));
      });
    });

    group('getAllTags', () {
      test('should return sorted list of unique tags', () async {
        // arrange
        for (final doc in testDocuments) {
          await dataSource.addDocument(doc);
        }

        // act
        final result = await dataSource.getAllTags();

        // assert
        expect(result, equals(['tag1', 'tag2', 'tag3']));
      });
    });

    group('getDocumentsByTags', () {
      test('should return documents that contain any of the specified tags',
          () async {
        // arrange
        for (final doc in testDocuments) {
          await dataSource.addDocument(doc);
        }

        // act
        final result = await dataSource.getDocumentsByTags(['tag1']);

        // assert
        expect(result.length, equals(1));
        expect(result[0].tags, contains('tag1'));
      });

      test('should return documents that contain multiple tags', () async {
        // arrange
        for (final doc in testDocuments) {
          await dataSource.addDocument(doc);
        }

        // act
        final result = await dataSource.getDocumentsByTags(['tag2']);

        // assert
        expect(result.length, equals(2)); // Both documents have tag2
      });
    });

    group('deleteMultipleDocuments', () {
      test('should delete all documents successfully', () async {
        // arrange
        final doc1 = await dataSource.addDocument(testDocuments[0]);
        final doc2 = await dataSource.addDocument(testDocuments[1]);

        // act
        await dataSource.deleteMultipleDocuments([doc1.id, doc2.id]);

        // assert
        final result1 = await dataSource.getDocumentById(doc1.id);
        final result2 = await dataSource.getDocumentById(doc2.id);
        expect(result1, isNull);
        expect(result2, isNull);
      });

      test('should throw exception when some documents cannot be deleted',
          () async {
        // arrange
        final doc1 = await dataSource.addDocument(testDocuments[0]);

        // act & assert
        await expectLater(
          () => dataSource.deleteMultipleDocuments([doc1.id, 999]),
          throwsException,
        );
      });
    });

    group('updateMultipleDocuments', () {
      test('should update all documents successfully', () async {
        // arrange
        final doc1 = await dataSource.addDocument(testDocuments[0]);
        final doc2 = await dataSource.addDocument(testDocuments[1]);

        final updatedDocs = [
          doc1.copyWith(title: 'Updated Title 1'),
          doc2.copyWith(title: 'Updated Title 2'),
        ];

        // act
        final result = await dataSource.updateMultipleDocuments(updatedDocs);

        // assert
        expect(result.length, equals(2));
        expect(result[0].title, equals('Updated Title 1'));
        expect(result[1].title, equals('Updated Title 2'));
      });
    });

    group('searchWithFilters', () {
      test('should filter by query', () async {
        // arrange
        for (final doc in testDocuments) {
          await dataSource.addDocument(doc);
        }

        // act
        final result = await dataSource.searchWithFilters(query: 'Document 1');

        // assert
        expect(result.length, equals(1));
        expect(result[0].title, contains('Document 1'));
      });

      test('should filter by category', () async {
        // arrange
        for (final doc in testDocuments) {
          await dataSource.addDocument(doc);
        }

        // act
        final result =
            await dataSource.searchWithFilters(category: 'Category 2');

        // assert
        expect(result.length, equals(1));
        expect(result[0].category, equals('Category 2'));
      });

      test('should sort results', () async {
        // arrange
        for (final doc in testDocuments) {
          await dataSource.addDocument(doc);
        }

        // act
        final result = await dataSource.searchWithFilters(
          sortBy: 'title',
          ascending: true,
        );

        // assert
        expect(result.length, equals(2));
        expect(result[0].title.compareTo(result[1].title), lessThan(0));
      });
    });
  });
}
