import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mindvault/core/error/failures.dart';
import 'package:mindvault/features/search/data/repositories/search_repository_impl.dart';
import 'package:mindvault/features/search/data/datasources/ai_data_source.dart';
import 'package:mindvault/features/search/data/datasources/search_local_data_source.dart';
import 'package:mindvault/features/search/data/models/document_model.dart';
import 'package:mindvault/features/search/domain/entities/document.dart';

// Manual Mock Classes
class MockSearchLocalDataSource implements SearchLocalDataSource {
  final List<DocumentModel> _documents = [];
  bool shouldThrowError = false;
  String errorMessage = 'Test error';

  @override
  Future<DocumentModel> addDocument(DocumentModel document) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    final newDocument = document.copyWith(id: _documents.length + 1);
    _documents.add(newDocument);
    return newDocument;
  }

  @override
  Future<void> deleteDocument(int documentId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    _documents.removeWhere((doc) => doc.id == documentId);
  }

  @override
  Future<void> deleteMultipleDocuments(List<int> documentIds) async {
    if (shouldThrowError) throw Exception(errorMessage);
    _documents.removeWhere((doc) => documentIds.contains(doc.id));
  }

  @override
  Future<List<DocumentModel>> getAllDocuments() async {
    if (shouldThrowError) throw Exception(errorMessage);
    return _documents;
  }

  @override
  Future<DocumentModel?> getDocumentById(int documentId) async {
    if (shouldThrowError) throw Exception(errorMessage);
    try {
      return _documents.firstWhere((doc) => doc.id == documentId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<DocumentModel>> searchDocuments(String query) async {
    if (shouldThrowError) throw Exception(errorMessage);
    return _documents
        .where((doc) =>
            doc.title.toLowerCase().contains(query.toLowerCase()) ||
            doc.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<DocumentModel> updateDocument(DocumentModel document) async {
    if (shouldThrowError) throw Exception(errorMessage);
    final index = _documents.indexWhere((doc) => doc.id == document.id);
    if (index >= 0) {
      _documents[index] = document;
      return document;
    }
    throw Exception('Document not found');
  }

  @override
  Future<List<DocumentModel>> getDocumentsByCategory(String category) async {
    if (shouldThrowError) throw Exception(errorMessage);
    return _documents.where((doc) => doc.category == category).toList();
  }

  @override
  Future<List<DocumentModel>> getDocumentsByTags(List<String> tags) async {
    if (shouldThrowError) throw Exception(errorMessage);
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
    if (shouldThrowError) throw Exception(errorMessage);
    var results = _documents.where((doc) {
      bool matches = true;
      if (query != null && query.isNotEmpty) {
        matches = matches &&
            (doc.title.toLowerCase().contains(query.toLowerCase()) ||
                doc.content.toLowerCase().contains(query.toLowerCase()));
      }
      if (category != null) {
        matches = matches && doc.category == category;
      }
      if (tags != null && tags.isNotEmpty) {
        matches = matches && tags.any((tag) => doc.tags.contains(tag));
      }
      return matches;
    }).toList();

    // Simple sorting by title for test
    results.sort((a, b) =>
        ascending ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
    return results;
  }

  @override
  Future<List<String>> getAllCategories() async {
    if (shouldThrowError) throw Exception(errorMessage);
    return _documents
        .map((doc) => doc.category ?? '')
        .where((cat) => cat.isNotEmpty)
        .toSet()
        .toList();
  }

  @override
  Future<List<String>> getAllTags() async {
    if (shouldThrowError) throw Exception(errorMessage);
    return _documents.expand((doc) => doc.tags).toSet().toList();
  }

  @override
  Future<List<String>> suggestCategories(String input) async {
    if (shouldThrowError) throw Exception(errorMessage);
    final allCategories = await getAllCategories();
    return allCategories
        .where((cat) => cat.toLowerCase().contains(input.toLowerCase()))
        .toList();
  }

  @override
  Future<List<String>> suggestTags(String input) async {
    if (shouldThrowError) throw Exception(errorMessage);
    final allTags = await getAllTags();
    return allTags
        .where((tag) => tag.toLowerCase().contains(input.toLowerCase()))
        .toList();
  }

  @override
  Future<List<DocumentModel>> updateMultipleDocuments(
      List<DocumentModel> documents) async {
    if (shouldThrowError) throw Exception(errorMessage);
    for (final doc in documents) {
      await updateDocument(doc);
    }
    return documents;
  }
}

class MockAIDataSource implements AIDataSource {
  bool shouldThrowError = false;
  String errorMessage = 'AI Test error';
  List<DocumentModel> mockResults = [];

  @override
  Future<List<DocumentModel>> performSemanticSearch(
      String query, List<DocumentModel> documents) async {
    if (shouldThrowError) throw Exception(errorMessage);
    return mockResults;
  }

  @override
  Future<List<double>> generateEmbedding(String text) async {
    if (shouldThrowError) throw Exception(errorMessage);
    return List.filled(100, 0.5);
  }

  @override
  Future<void> initializeModel() async {
    if (shouldThrowError) throw Exception(errorMessage);
  }

  @override
  Future<double> calculateSimilarity(
      List<double> embedding1, List<double> embedding2) async {
    if (shouldThrowError) throw Exception(errorMessage);
    return 0.8;
  }

  @override
  Future<List<String>> suggestCategories(String content) async {
    if (shouldThrowError) throw Exception(errorMessage);
    return ['Test Category'];
  }

  @override
  Future<List<String>> extractTags(String content) async {
    if (shouldThrowError) throw Exception(errorMessage);
    return ['test-tag'];
  }

  @override
  Future<String> generateSummary(String content) async {
    if (shouldThrowError) throw Exception(errorMessage);
    return 'Test summary';
  }

  @override
  Future<List<String>> findSimilarDocuments(
      DocumentModel document, List<DocumentModel> allDocuments) async {
    if (shouldThrowError) throw Exception(errorMessage);
    return ['Similar Document'];
  }
}

void main() {
  late SearchRepositoryImpl repository;
  late MockSearchLocalDataSource mockLocalDataSource;
  late MockAIDataSource mockAIDataSource;

  setUp(() {
    mockLocalDataSource = MockSearchLocalDataSource();
    mockAIDataSource = MockAIDataSource();
    repository = SearchRepositoryImpl(
      localDataSource: mockLocalDataSource,
      aiDataSource: mockAIDataSource,
    );
  });

  group('SearchRepositoryImpl', () {
    final testDocumentModel = DocumentModel(
      id: 1,
      title: 'Test Document',
      content: 'Test content',
      tags: ['test'],
      category: 'test-category',
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    final testDocument = Document(
      id: 1,
      title: 'Test Document',
      content: 'Test content',
      tags: const ['test'],
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    group('searchDocuments', () {
      test('should return documents when search is successful', () async {
        // Arrange
        mockLocalDataSource._documents.add(testDocumentModel);

        // Act
        final result = await repository.searchDocuments('test');

        // Assert
        expect(result, isA<Right<Failure, List<Document>>>());
        final documents = result.fold((l) => null, (r) => r);
        expect(documents, isNotNull);
        expect(documents!.length, 1);
        expect(documents.first.title, 'Test Document');
      });

      test(
          'should return DatabaseFailure when local data source throws exception',
          () async {
        // Arrange
        mockLocalDataSource.shouldThrowError = true;

        // Act
        final result = await repository.searchDocuments('test');

        // Assert
        expect(result, isA<Left<Failure, List<Document>>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
      });
    });

    group('semanticSearch', () {
      test('should return documents when semantic search is successful',
          () async {
        // Arrange
        mockAIDataSource.mockResults = [testDocumentModel];

        // Act
        final result = await repository.semanticSearch('semantic query');

        // Assert
        expect(result, isA<Right<Failure, List<Document>>>());
        final documents = result.fold((l) => null, (r) => r);
        expect(documents, isNotNull);
        expect(documents!.length, 1);
      });

      test('should return AIModelFailure when AI data source throws exception',
          () async {
        // Arrange
        mockAIDataSource.shouldThrowError = true;

        // Act
        final result = await repository.semanticSearch('query');

        // Assert
        expect(result, isA<Left<Failure, List<Document>>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<AIModelFailure>());
      });
    });

    group('addDocument', () {
      test('should return document when add is successful', () async {
        // Act
        final result = await repository.addDocument(testDocument);

        // Assert
        expect(result, isA<Right<Failure, Document>>());
        final document = result.fold((l) => null, (r) => r);
        expect(document, isNotNull);
        expect(document!.title, 'Test Document');
        expect(document.id, 1);
      });

      test(
          'should return DatabaseFailure when local data source throws exception',
          () async {
        // Arrange
        mockLocalDataSource.shouldThrowError = true;

        // Act
        final result = await repository.addDocument(testDocument);

        // Assert
        expect(result, isA<Left<Failure, Document>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
      });
    });

    group('updateDocument', () {
      test('should return updated document when update is successful',
          () async {
        // Arrange
        mockLocalDataSource._documents.add(testDocumentModel);

        // Act
        final result = await repository.updateDocument(testDocument);

        // Assert
        expect(result, isA<Right<Failure, Document>>());
        final document = result.fold((l) => null, (r) => r);
        expect(document, isNotNull);
      });

      test(
          'should return DatabaseFailure when local data source throws exception',
          () async {
        // Arrange
        mockLocalDataSource.shouldThrowError = true;

        // Act
        final result = await repository.updateDocument(testDocument);

        // Assert
        expect(result, isA<Left<Failure, Document>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
      });
    });

    group('deleteDocument', () {
      test('should return unit when delete is successful', () async {
        // Act
        final result = await repository.deleteDocument(1);

        // Assert
        expect(result, isA<Right<Failure, Unit>>());
        final unit = result.fold((l) => null, (r) => r);
        expect(unit, isNotNull);
      });

      test(
          'should return DatabaseFailure when local data source throws exception',
          () async {
        // Arrange
        mockLocalDataSource.shouldThrowError = true;

        // Act
        final result = await repository.deleteDocument(1);

        // Assert
        expect(result, isA<Left<Failure, Unit>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
      });
    });

    group('deleteMultipleDocuments', () {
      test('should return unit when delete multiple is successful', () async {
        // Act
        final result = await repository.deleteMultipleDocuments([1, 2, 3]);

        // Assert
        expect(result, isA<Right<Failure, Unit>>());
      });

      test(
          'should return DatabaseFailure when local data source throws exception',
          () async {
        // Arrange
        mockLocalDataSource.shouldThrowError = true;

        // Act
        final result = await repository.deleteMultipleDocuments([1, 2, 3]);

        // Assert
        expect(result, isA<Left<Failure, Unit>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
      });
    });

    group('getAllDocuments', () {
      test('should return all documents when successful', () async {
        // Arrange
        mockLocalDataSource._documents.add(testDocumentModel);

        // Act
        final result = await repository.getAllDocuments();

        // Assert
        expect(result, isA<Right<Failure, List<Document>>>());
        final documents = result.fold((l) => null, (r) => r);
        expect(documents, isNotNull);
        expect(documents!.length, 1);
      });

      test(
          'should return DatabaseFailure when local data source throws exception',
          () async {
        // Arrange
        mockLocalDataSource.shouldThrowError = true;

        // Act
        final result = await repository.getAllDocuments();

        // Assert
        expect(result, isA<Left<Failure, List<Document>>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
      });
    });

    group('getDocumentById', () {
      test('should return document when found', () async {
        // Arrange
        mockLocalDataSource._documents.add(testDocumentModel);

        // Act
        final result = await repository.getDocumentById(1);

        // Assert
        expect(result, isA<Right<Failure, Document?>>());
        final document = result.fold((l) => null, (r) => r);
        expect(document, isNotNull);
        expect(document!.id, 1);
      });

      test('should return null when document not found', () async {
        // Act
        final result = await repository.getDocumentById(999);

        // Assert
        expect(result, isA<Right<Failure, Document?>>());
        final document = result.fold((l) => null, (r) => r);
        expect(document, isNull);
      });

      test(
          'should return DatabaseFailure when local data source throws exception',
          () async {
        // Arrange
        mockLocalDataSource.shouldThrowError = true;

        // Act
        final result = await repository.getDocumentById(1);

        // Assert
        expect(result, isA<Left<Failure, Document?>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
      });
    });

    group('getDocumentsByCategory', () {
      test('should return documents by category', () async {
        // Arrange
        mockLocalDataSource._documents.add(testDocumentModel);

        // Act
        final result = await repository.getDocumentsByCategory('test-category');

        // Assert
        expect(result, isA<Right<Failure, List<Document>>>());
        final documents = result.fold((l) => null, (r) => r);
        expect(documents, isNotNull);
        expect(documents!.length, 1);
      });
    });

    group('getDocumentsByTags', () {
      test('should return documents by tags', () async {
        // Arrange
        mockLocalDataSource._documents.add(testDocumentModel);

        // Act
        final result = await repository.getDocumentsByTags(['test']);

        // Assert
        expect(result, isA<Right<Failure, List<Document>>>());
        final documents = result.fold((l) => null, (r) => r);
        expect(documents, isNotNull);
        expect(documents!.length, 1);
      });
    });

    group('searchWithFilters', () {
      test('should return filtered documents', () async {
        // Arrange
        mockLocalDataSource._documents.add(testDocumentModel);

        // Act
        final result = await repository.searchWithFilters(
          query: 'test',
          category: 'test-category',
        );

        // Assert
        expect(result, isA<Right<Failure, List<Document>>>());
        final documents = result.fold((l) => null, (r) => r);
        expect(documents, isNotNull);
        expect(documents!.length, 1);
      });
    });

    group('getAllCategories', () {
      test('should return all categories', () async {
        // Arrange
        mockLocalDataSource._documents.add(testDocumentModel);

        // Act
        final result = await repository.getAllCategories();

        // Assert
        expect(result, isA<Right<Failure, List<String>>>());
        final categories = result.fold((l) => null, (r) => r);
        expect(categories, isNotNull);
        expect(categories!.contains('test-category'), isTrue);
      });
    });

    group('getAllTags', () {
      test('should return all tags', () async {
        // Arrange
        mockLocalDataSource._documents.add(testDocumentModel);

        // Act
        final result = await repository.getAllTags();

        // Assert
        expect(result, isA<Right<Failure, List<String>>>());
        final tags = result.fold((l) => null, (r) => r);
        expect(tags, isNotNull);
        expect(tags!.contains('test'), isTrue);
      });
    });

    group('suggestCategories', () {
      test('should return category suggestions', () async {
        // Arrange
        mockLocalDataSource._documents.add(testDocumentModel);

        // Act
        final result = await repository.suggestCategories('test');

        // Assert
        expect(result, isA<Right<Failure, List<String>>>());
        final suggestions = result.fold((l) => null, (r) => r);
        expect(suggestions, isNotNull);
      });
    });

    group('suggestTags', () {
      test('should return tag suggestions', () async {
        // Arrange
        mockLocalDataSource._documents.add(testDocumentModel);

        // Act
        final result = await repository.suggestTags('test');

        // Assert
        expect(result, isA<Right<Failure, List<String>>>());
        final suggestions = result.fold((l) => null, (r) => r);
        expect(suggestions, isNotNull);
      });
    });

    group('updateMultipleDocuments', () {
      test('should return updated documents', () async {
        // Arrange - Add the document first
        mockLocalDataSource._documents.add(testDocumentModel);

        // Act
        final result = await repository.updateMultipleDocuments([testDocument]);

        // Assert
        expect(result, isA<Right<Failure, List<Document>>>());
        final documents = result.fold((l) => null, (r) => r);
        expect(documents, isNotNull);
        expect(documents!.length, 1);
      });

      test(
          'should return DatabaseFailure when local data source throws exception',
          () async {
        // Arrange
        mockLocalDataSource.shouldThrowError = true;

        // Act
        final result = await repository.updateMultipleDocuments([testDocument]);

        // Assert
        expect(result, isA<Left<Failure, List<Document>>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
      });
    });
  });
}
