import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/document.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<Document>>> searchDocuments(String query);
  Future<Either<Failure, List<Document>>> semanticSearch(String query);
  Future<Either<Failure, Document>> addDocument(Document document);
  Future<Either<Failure, Document>> updateDocument(Document document);
  Future<Either<Failure, Unit>> deleteDocument(int documentId);
  Future<Either<Failure, List<Document>>> getAllDocuments();
  Future<Either<Failure, Document?>> getDocumentById(int documentId);
  Future<Either<Failure, List<Document>>> getDocumentsByCategory(String category);
  Future<Either<Failure, List<Document>>> getDocumentsByTags(List<String> tags);
  
  // Advanced search features
  Future<Either<Failure, List<Document>>> searchWithFilters({
    String? query,
    String? category,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'updatedAt',
    bool ascending = false,
  });
  
  Future<Either<Failure, List<String>>> getAllCategories();
  Future<Either<Failure, List<String>>> getAllTags();
  Future<Either<Failure, List<String>>> suggestCategories(String input);
  Future<Either<Failure, List<String>>> suggestTags(String input);
  
  // Bulk operations
  Future<Either<Failure, Unit>> deleteMultipleDocuments(List<int> documentIds);
  Future<Either<Failure, List<Document>>> updateMultipleDocuments(List<Document> documents);
}