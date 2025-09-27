import 'package:equatable/equatable.dart';
import '../../domain/entities/document.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Document> documents;
  final String? searchQuery;
  final bool isSemanticSearch;
  final Set<int> selectedDocumentIds;
  final List<String> availableCategories;
  final List<String> availableTags;

  const SearchLoaded({
    required this.documents,
    this.searchQuery,
    this.isSemanticSearch = false,
    this.selectedDocumentIds = const {},
    this.availableCategories = const [],
    this.availableTags = const [],
  });

  @override
  List<Object?> get props => [
    documents, 
    searchQuery, 
    isSemanticSearch, 
    selectedDocumentIds,
    availableCategories,
    availableTags,
  ];

  SearchLoaded copyWith({
    List<Document>? documents,
    String? searchQuery,
    bool? isSemanticSearch,
    Set<int>? selectedDocumentIds,
    List<String>? availableCategories,
    List<String>? availableTags,
  }) {
    return SearchLoaded(
      documents: documents ?? this.documents,
      searchQuery: searchQuery ?? this.searchQuery,
      isSemanticSearch: isSemanticSearch ?? this.isSemanticSearch,
      selectedDocumentIds: selectedDocumentIds ?? this.selectedDocumentIds,
      availableCategories: availableCategories ?? this.availableCategories,
      availableTags: availableTags ?? this.availableTags,
    );
  }
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}

class DocumentAdded extends SearchState {
  final Document document;

  const DocumentAdded(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentUpdated extends SearchState {
  final Document document;

  const DocumentUpdated(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentDeleted extends SearchState {
  final int documentId;

  const DocumentDeleted(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

class MultipleDocumentsDeleted extends SearchState {
  final List<int> documentIds;

  const MultipleDocumentsDeleted(this.documentIds);

  @override
  List<Object?> get props => [documentIds];
}

class CategoriesLoaded extends SearchState {
  final List<String> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class TagsLoaded extends SearchState {
  final List<String> tags;

  const TagsLoaded(this.tags);

  @override
  List<Object?> get props => [tags];
}