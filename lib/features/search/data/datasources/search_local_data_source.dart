import '../models/document_model.dart';
import '../../../../objectbox.g.dart';

abstract class SearchLocalDataSource {
  Future<List<DocumentModel>> getAllDocuments();
  Future<DocumentModel?> getDocumentById(int id);
  Future<List<DocumentModel>> searchDocuments(String query);
  Future<DocumentModel> addDocument(DocumentModel document);
  Future<DocumentModel> updateDocument(DocumentModel document);
  Future<void> deleteDocument(int id);
  Future<List<DocumentModel>> getDocumentsByCategory(String category);
  Future<List<DocumentModel>> getDocumentsByTags(List<String> tags);

  // Advanced search features
  Future<List<DocumentModel>> searchWithFilters({
    String? query,
    String? category,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'updatedAt',
    bool ascending = false,
  });

  Future<List<String>> getAllCategories();
  Future<List<String>> getAllTags();
  Future<List<String>> suggestCategories(String input);
  Future<List<String>> suggestTags(String input);

  // Bulk operations
  Future<void> deleteMultipleDocuments(List<int> ids);
  Future<List<DocumentModel>> updateMultipleDocuments(
      List<DocumentModel> documents);
}

class SearchLocalDataSourceImpl implements SearchLocalDataSource {
  final Store store;
  late final Box<DocumentModel> _documentBox;

  SearchLocalDataSourceImpl({required this.store}) {
    _documentBox = store.box<DocumentModel>();
  }

  @override
  Future<List<DocumentModel>> getAllDocuments() async {
    return _documentBox.getAll();
  }

  @override
  Future<DocumentModel?> getDocumentById(int id) async {
    return _documentBox.get(id);
  }

  @override
  Future<List<DocumentModel>> searchDocuments(String query) async {
    final queryBuilder = _documentBox.query(
        DocumentModel_.title.contains(query, caseSensitive: false) |
            DocumentModel_.content.contains(query, caseSensitive: false) |
            DocumentModel_.category.contains(query, caseSensitive: false));

    final queryResult = queryBuilder.build();
    final results = queryResult.find();
    queryResult.close();

    return results;
  }

  @override
  Future<DocumentModel> addDocument(DocumentModel document) async {
    document.id = _documentBox.put(document);
    return document;
  }

  @override
  Future<DocumentModel> updateDocument(DocumentModel document) async {
    _documentBox.put(document);
    return document;
  }

  @override
  Future<void> deleteDocument(int id) async {
    final deleted = _documentBox.remove(id);
    if (!deleted) {
      throw Exception(
          'Failed to delete document with ID: $id. Document may not exist.');
    }
  }

  @override
  Future<List<DocumentModel>> getDocumentsByCategory(String category) async {
    final queryBuilder =
        _documentBox.query(DocumentModel_.category.equals(category));

    final queryResult = queryBuilder.build();
    final results = queryResult.find();
    queryResult.close();

    return results;
  }

  @override
  Future<List<DocumentModel>> getDocumentsByTags(List<String> tags) async {
    // For simplicity, we'll search for documents that contain any of the tags
    // In a more complex implementation, you might want to use ObjectBox relations
    final allDocuments = await getAllDocuments();
    return allDocuments
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
    // Build the base query with multiple conditions
    Condition<DocumentModel>? baseCondition;

    // Add text search condition
    if (query != null && query.isNotEmpty) {
      baseCondition =
          DocumentModel_.title.contains(query, caseSensitive: false) |
              DocumentModel_.content.contains(query, caseSensitive: false);
    }

    // Add category condition
    if (category != null && category.isNotEmpty) {
      final categoryCondition = DocumentModel_.category.equals(category);
      baseCondition = baseCondition != null
          ? baseCondition & categoryCondition
          : categoryCondition;
    }

    // Add date range conditions
    if (startDate != null) {
      final startCondition = DocumentModel_.updatedAt
          .greaterOrEqual(startDate.millisecondsSinceEpoch);
      baseCondition = baseCondition != null
          ? baseCondition & startCondition
          : startCondition;
    }

    if (endDate != null) {
      final endCondition =
          DocumentModel_.updatedAt.lessOrEqual(endDate.millisecondsSinceEpoch);
      baseCondition =
          baseCondition != null ? baseCondition & endCondition : endCondition;
    }

    // Create query builder with conditions
    final queryBuilder = baseCondition != null
        ? _documentBox.query(baseCondition)
        : _documentBox.query();

    // Add sorting
    switch (sortBy) {
      case 'title':
        queryBuilder.order(DocumentModel_.title,
            flags: ascending ? 0 : Order.descending);
        break;
      case 'createdAt':
        queryBuilder.order(DocumentModel_.createdAt,
            flags: ascending ? 0 : Order.descending);
        break;
      case 'updatedAt':
      default:
        queryBuilder.order(DocumentModel_.updatedAt,
            flags: ascending ? 0 : Order.descending);
        break;
    }

    final queryResult = queryBuilder.build();
    final results = queryResult.find();
    queryResult.close();

    // Apply tag filter if specified (post-query filtering)
    if (tags != null && tags.isNotEmpty) {
      return results
          .where((doc) => tags.any((tag) => doc.tags.contains(tag)))
          .toList();
    }

    return results;
  }

  @override
  Future<List<String>> getAllCategories() async {
    final documents = await getAllDocuments();
    final categories = documents
        .where((doc) => doc.category != null)
        .map((doc) => doc.category!)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  @override
  Future<List<String>> getAllTags() async {
    final documents = await getAllDocuments();
    final tags = <String>{};
    for (final doc in documents) {
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
      final deleted = _documentBox.remove(id);
      if (!deleted) {
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
      _documentBox.put(document);
      updatedDocs.add(document);
    }
    return updatedDocs;
  }
}
