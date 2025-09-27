import 'package:equatable/equatable.dart';
import '../../domain/entities/document.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchDocumentsEvent extends SearchEvent {
  final String query;

  const SearchDocumentsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SemanticSearchEvent extends SearchEvent {
  final String query;

  const SemanticSearchEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadAllDocumentsEvent extends SearchEvent {
  const LoadAllDocumentsEvent();
}

class AddDocumentEvent extends SearchEvent {
  final Document document;

  const AddDocumentEvent(this.document);

  @override
  List<Object?> get props => [document];
}

class ClearSearchEvent extends SearchEvent {
  const ClearSearchEvent();
}

class UpdateDocumentEvent extends SearchEvent {
  final Document document;

  const UpdateDocumentEvent(this.document);

  @override
  List<Object?> get props => [document];
}

class DeleteDocumentEvent extends SearchEvent {
  final int documentId;

  const DeleteDocumentEvent(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

class DeleteMultipleDocumentsEvent extends SearchEvent {
  final List<int> documentIds;

  const DeleteMultipleDocumentsEvent(this.documentIds);

  @override
  List<Object?> get props => [documentIds];
}

class SearchWithFiltersEvent extends SearchEvent {
  final String? query;
  final String? category;
  final List<String>? tags;
  final DateTime? startDate;
  final DateTime? endDate;
  final String sortBy;
  final bool ascending;

  const SearchWithFiltersEvent({
    this.query,
    this.category,
    this.tags,
    this.startDate,
    this.endDate,
    this.sortBy = 'updatedAt',
    this.ascending = false,
  });

  @override
  List<Object?> get props => [query, category, tags, startDate, endDate, sortBy, ascending];
}

class GetCategoriesEvent extends SearchEvent {
  const GetCategoriesEvent();
}

class GetTagsEvent extends SearchEvent {
  const GetTagsEvent();
}

class ToggleDocumentSelectionEvent extends SearchEvent {
  final int documentId;

  const ToggleDocumentSelectionEvent(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

class ClearSelectionEvent extends SearchEvent {
  const ClearSelectionEvent();
}