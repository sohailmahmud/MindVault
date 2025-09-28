import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindvault/core/error/failures.dart';
import 'package:mindvault/features/search/domain/entities/document.dart';
import 'package:mindvault/features/search/domain/repositories/search_repository.dart';
import 'package:mindvault/features/search/domain/usecases/add_document.dart';
import 'package:mindvault/features/search/domain/usecases/delete_document.dart';
import 'package:mindvault/features/search/domain/usecases/delete_multiple_documents.dart';
import 'package:mindvault/features/search/domain/usecases/get_all_documents.dart';
import 'package:mindvault/features/search/domain/usecases/get_document_by_id.dart';
import 'package:mindvault/features/search/domain/usecases/search_documents.dart';
import 'package:mindvault/features/search/domain/usecases/semantic_search.dart';
import 'package:mindvault/features/search/domain/usecases/update_document.dart';
import 'package:mindvault/features/search/presentation/bloc/search_bloc.dart';
import 'package:mindvault/features/search/presentation/bloc/search_event.dart';
import 'package:mindvault/features/search/presentation/bloc/search_state.dart';

// Mock repository with controlled behavior
class MockSearchRepository implements SearchRepository {
  List<Document> documentsToReturn = [];
  List<String> stringsToReturn = [];
  Document? documentToReturn;
  bool shouldReturnError = false;
  Failure? failureToReturn;

  void setSuccess(List<Document> documents) {
    documentsToReturn = documents;
    shouldReturnError = false;
    failureToReturn = null;
  }

  void setDocumentSuccess(Document document) {
    documentToReturn = document;
    shouldReturnError = false;
    failureToReturn = null;
  }

  void setStringSuccess(List<String> strings) {
    stringsToReturn = strings;
    shouldReturnError = false;
    failureToReturn = null;
  }

  void setError(Failure failure) {
    shouldReturnError = true;
    failureToReturn = failure;
  }

  void clearError() {
    shouldReturnError = false;
    failureToReturn = null;
  }

  @override
  Future<Either<Failure, List<Document>>> searchDocuments(String query) async {
    if (shouldReturnError) return Left(failureToReturn!);
    return Right(documentsToReturn);
  }

  @override
  Future<Either<Failure, List<Document>>> semanticSearch(String query) async {
    if (shouldReturnError) return Left(failureToReturn!);
    return Right(documentsToReturn);
  }

  @override
  Future<Either<Failure, List<Document>>> getAllDocuments() async {
    if (shouldReturnError) return Left(failureToReturn!);
    return Right(documentsToReturn);
  }

  @override
  Future<Either<Failure, Document>> addDocument(Document document) async {
    if (shouldReturnError) return Left(failureToReturn!);
    return Right(documentToReturn ?? document);
  }

  @override
  Future<Either<Failure, Document>> updateDocument(Document document) async {
    if (shouldReturnError) return Left(failureToReturn!);
    return Right(documentToReturn ?? document);
  }

  @override
  Future<Either<Failure, Unit>> deleteDocument(int documentId) async {
    if (shouldReturnError) return Left(failureToReturn!);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> deleteMultipleDocuments(
      List<int> documentIds) async {
    if (shouldReturnError) return Left(failureToReturn!);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Document?>> getDocumentById(int id) async {
    if (shouldReturnError) return Left(failureToReturn!);
    return Right(documentToReturn);
  }

  @override
  Future<Either<Failure, List<Document>>> getDocumentsByCategory(
      String category) async {
    if (shouldReturnError) return Left(failureToReturn!);
    return Right(documentsToReturn);
  }

  @override
  Future<Either<Failure, List<Document>>> getDocumentsByTags(
      List<String> tags) async {
    if (shouldReturnError) return Left(failureToReturn!);
    return Right(documentsToReturn);
  }

  @override
  Future<Either<Failure, List<Document>>> searchWithFilters({
    String? query,
    String? category,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'updatedAt',
    bool ascending = false,
  }) async {
    if (shouldReturnError) return Left(failureToReturn!);
    return Right(documentsToReturn);
  }

  @override
  Future<Either<Failure, List<String>>> getAllCategories() async {
    if (shouldReturnError) return Left(failureToReturn!);
    return Right(stringsToReturn);
  }

  @override
  Future<Either<Failure, List<String>>> getAllTags() async {
    if (shouldReturnError) return Left(failureToReturn!);
    return Right(stringsToReturn);
  }

  @override
  Future<Either<Failure, List<String>>> suggestCategories(String input) async {
    if (shouldReturnError) return Left(failureToReturn!);
    return Right(stringsToReturn);
  }

  @override
  Future<Either<Failure, List<String>>> suggestTags(String input) async {
    if (shouldReturnError) return Left(failureToReturn!);
    return Right(stringsToReturn);
  }

  @override
  Future<Either<Failure, List<Document>>> updateMultipleDocuments(
      List<Document> documents) async {
    if (shouldReturnError) return Left(failureToReturn!);
    return Right(documentsToReturn);
  }
}

void main() {
  late SearchBloc searchBloc;
  late MockSearchRepository mockRepository;

  // Test use cases
  late SearchDocuments searchDocuments;
  late SemanticSearch semanticSearch;
  late GetAllDocuments getAllDocuments;
  late AddDocument addDocument;
  late UpdateDocument updateDocument;
  late DeleteDocument deleteDocument;
  late DeleteMultipleDocuments deleteMultipleDocuments;
  late GetDocumentById getDocumentById;

  // Test data
  final testDocument1 = Document(
    id: 1,
    title: 'Test Document 1',
    content: 'This is test content 1',
    category: 'Test',
    tags: const ['flutter', 'test'],
    createdAt: DateTime(2023, 1, 1),
    updatedAt: DateTime(2023, 1, 1),
  );

  final testDocument2 = Document(
    id: 2,
    title: 'Test Document 2',
    content: 'This is test content 2',
    category: 'Test',
    tags: const ['dart', 'test'],
    createdAt: DateTime(2023, 1, 2),
    updatedAt: DateTime(2023, 1, 2),
  );

  final testDocuments = [testDocument1, testDocument2];

  setUp(() {
    mockRepository = MockSearchRepository();

    // Initialize use cases with mock repository
    searchDocuments = SearchDocuments(mockRepository);
    semanticSearch = SemanticSearch(mockRepository);
    getAllDocuments = GetAllDocuments(mockRepository);
    addDocument = AddDocument(mockRepository);
    updateDocument = UpdateDocument(mockRepository);
    deleteDocument = DeleteDocument(mockRepository);
    deleteMultipleDocuments = DeleteMultipleDocuments(mockRepository);
    getDocumentById = GetDocumentById(mockRepository);

    // Initialize SearchBloc with use cases
    searchBloc = SearchBloc(
      searchDocuments: searchDocuments,
      semanticSearch: semanticSearch,
      getAllDocuments: getAllDocuments,
      addDocument: addDocument,
      updateDocument: updateDocument,
      deleteDocument: deleteDocument,
      deleteMultipleDocuments: deleteMultipleDocuments,
      getDocumentById: getDocumentById,
    );
  });

  tearDown(() {
    searchBloc.close();
  });

  group('SearchBloc', () {
    test('initial state is SearchInitial', () {
      expect(searchBloc.state, equals(SearchInitial()));
    });

    group('SearchDocumentsEvent', () {
      const testQuery = 'flutter';

      blocTest<SearchBloc, SearchState>(
        'emits [SearchLoading, SearchLoaded] when search documents succeeds',
        build: () {
          mockRepository.setSuccess(testDocuments);
          return searchBloc;
        },
        act: (bloc) => bloc.add(const SearchDocumentsEvent(testQuery)),
        expect: () => [
          SearchLoading(),
          SearchLoaded(
            documents: testDocuments,
            searchQuery: testQuery,
            isSemanticSearch: false,
          ),
        ],
      );

      blocTest<SearchBloc, SearchState>(
        'emits [SearchLoading, SearchError] when search documents fails',
        build: () {
          mockRepository.setError(ServerFailure());
          return searchBloc;
        },
        act: (bloc) => bloc.add(const SearchDocumentsEvent(testQuery)),
        expect: () => [
          SearchLoading(),
          const SearchError('Unexpected Error'),
        ],
      );
    });

    group('AddDocumentEvent', () {
      blocTest<SearchBloc, SearchState>(
        'emits [SearchLoading, DocumentAdded, SearchLoading, SearchLoaded] when adding document succeeds',
        build: () {
          mockRepository.setDocumentSuccess(testDocument1);
          return searchBloc;
        },
        act: (bloc) {
          // Set up for the reload that happens after add
          mockRepository.setSuccess(testDocuments);
          bloc.add(AddDocumentEvent(testDocument1));
        },
        expect: () => [
          SearchLoading(),
          DocumentAdded(testDocument1),
          SearchLoading(),
          SearchLoaded(
            documents: testDocuments,
            searchQuery: null,
            isSemanticSearch: false,
          ),
        ],
      );
    });

    group('LoadAllDocumentsEvent', () {
      blocTest<SearchBloc, SearchState>(
        'emits [SearchLoading, SearchLoaded] when loading all documents succeeds',
        build: () {
          mockRepository.setSuccess(testDocuments);
          return searchBloc;
        },
        act: (bloc) => bloc.add(const LoadAllDocumentsEvent()),
        expect: () => [
          SearchLoading(),
          SearchLoaded(
            documents: testDocuments,
            searchQuery: null,
            isSemanticSearch: false,
          ),
        ],
      );
    });
  });
}
