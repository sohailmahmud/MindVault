import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/document.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/ai_data_source.dart';
import '../datasources/search_local_data_source.dart';
import '../models/document_model.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchLocalDataSource localDataSource;
  final AIDataSource aiDataSource;

  SearchRepositoryImpl({
    required this.localDataSource,
    required this.aiDataSource,
  });

  @override
  Future<Either<Failure, List<Document>>> searchDocuments(String query) async {
    try {
      final documentModels = await localDataSource.searchDocuments(query);
      final documents = documentModels.map((model) => model.toEntity()).toList();
      return Right(documents);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Document>>> semanticSearch(String query) async {
    try {
      final allDocumentModels = await localDataSource.getAllDocuments();
      final semanticResults = await aiDataSource.performSemanticSearch(query, allDocumentModels);
      final documents = semanticResults.map((model) => model.toEntity()).toList();
      return Right(documents);
    } catch (e) {
      return Left(AIModelFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Document>> addDocument(Document document) async {
    try {
      final documentModel = DocumentModel.fromEntity(document);
      final addedModel = await localDataSource.addDocument(documentModel);
      return Right(addedModel.toEntity());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Document>> updateDocument(Document document) async {
    try {
      final documentModel = DocumentModel.fromEntity(document);
      final updatedModel = await localDataSource.updateDocument(documentModel);
      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteDocument(int documentId) async {
    try {
      await localDataSource.deleteDocument(documentId);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Document>>> getAllDocuments() async {
    try {
      final documentModels = await localDataSource.getAllDocuments();
      final documents = documentModels.map((model) => model.toEntity()).toList();
      return Right(documents);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Document?>> getDocumentById(int documentId) async {
    try {
      final documentModel = await localDataSource.getDocumentById(documentId);
      final document = documentModel?.toEntity();
      return Right(document);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Document>>> getDocumentsByCategory(String category) async {
    try {
      final documentModels = await localDataSource.getDocumentsByCategory(category);
      final documents = documentModels.map((model) => model.toEntity()).toList();
      return Right(documents);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Document>>> getDocumentsByTags(List<String> tags) async {
    try {
      final documentModels = await localDataSource.getDocumentsByTags(tags);
      final documents = documentModels.map((model) => model.toEntity()).toList();
      return Right(documents);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
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
    try {
      final documentModels = await localDataSource.searchWithFilters(
        query: query,
        category: category,
        tags: tags,
        startDate: startDate,
        endDate: endDate,
        sortBy: sortBy,
        ascending: ascending,
      );
      final documents = documentModels.map((model) => model.toEntity()).toList();
      return Right(documents);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllCategories() async {
    try {
      final categories = await localDataSource.getAllCategories();
      return Right(categories);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllTags() async {
    try {
      final tags = await localDataSource.getAllTags();
      return Right(tags);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> suggestCategories(String input) async {
    try {
      final suggestions = await localDataSource.suggestCategories(input);
      return Right(suggestions);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> suggestTags(String input) async {
    try {
      final suggestions = await localDataSource.suggestTags(input);
      return Right(suggestions);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMultipleDocuments(List<int> documentIds) async {
    try {
      await localDataSource.deleteMultipleDocuments(documentIds);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Document>>> updateMultipleDocuments(List<Document> documents) async {
    try {
      final documentModels = documents.map((doc) => DocumentModel.fromEntity(doc)).toList();
      final updatedModels = await localDataSource.updateMultipleDocuments(documentModels);
      final updatedDocuments = updatedModels.map((model) => model.toEntity()).toList();
      return Right(updatedDocuments);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}