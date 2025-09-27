import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_document.dart';
import '../../domain/usecases/delete_document.dart';
import '../../domain/usecases/get_all_documents.dart';
import '../../domain/usecases/get_document_by_id.dart';
import '../../domain/usecases/search_documents.dart';
import '../../domain/usecases/semantic_search.dart';
import '../../domain/usecases/update_document.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchDocuments searchDocuments;
  final SemanticSearch semanticSearch;
  final GetAllDocuments getAllDocuments;
  final AddDocument addDocument;
  final UpdateDocument updateDocument;
  final DeleteDocument deleteDocument;
  final GetDocumentById getDocumentById;

  SearchBloc({
    required this.searchDocuments,
    required this.semanticSearch,
    required this.getAllDocuments,
    required this.addDocument,
    required this.updateDocument,
    required this.deleteDocument,
    required this.getDocumentById,
  }) : super(SearchInitial()) {
    on<SearchDocumentsEvent>(_onSearchDocuments);
    on<SemanticSearchEvent>(_onSemanticSearch);
    on<LoadAllDocumentsEvent>(_onLoadAllDocuments);
    on<AddDocumentEvent>(_onAddDocument);
    on<UpdateDocumentEvent>(_onUpdateDocument);
    on<DeleteDocumentEvent>(_onDeleteDocument);
    on<ClearSearchEvent>(_onClearSearch);
    on<ToggleDocumentSelectionEvent>(_onToggleDocumentSelection);
    on<ClearSelectionEvent>(_onClearSelection);
    on<DeleteMultipleDocumentsEvent>(_onDeleteMultipleDocuments);
  }

  void _onSearchDocuments(SearchDocumentsEvent event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    
    final result = await searchDocuments(SearchParams(query: event.query));
    
    result.fold(
      (failure) => emit(SearchError(_mapFailureToMessage(failure))),
      (documents) => emit(SearchLoaded(
        documents: documents,
        searchQuery: event.query,
        isSemanticSearch: false,
      )),
    );
  }

  void _onSemanticSearch(SemanticSearchEvent event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    
    final result = await semanticSearch(SemanticSearchParams(query: event.query));
    
    result.fold(
      (failure) => emit(SearchError(_mapFailureToMessage(failure))),
      (documents) => emit(SearchLoaded(
        documents: documents,
        searchQuery: event.query,
        isSemanticSearch: true,
      )),
    );
  }

  void _onLoadAllDocuments(LoadAllDocumentsEvent event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    
    final result = await getAllDocuments(NoParams());
    
    result.fold(
      (failure) => emit(SearchError(_mapFailureToMessage(failure))),
      (documents) => emit(SearchLoaded(
        documents: documents,
        searchQuery: null,
        isSemanticSearch: false,
      )),
    );
  }

  void _onAddDocument(AddDocumentEvent event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    
    final result = await addDocument(AddDocumentParams(document: event.document));
    
    result.fold(
      (failure) => emit(SearchError(_mapFailureToMessage(failure))),
      (document) {
        emit(DocumentAdded(document));
        // Reload all documents after adding
        add(const LoadAllDocumentsEvent());
      },
    );
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<SearchState> emit) async {
    add(const LoadAllDocumentsEvent());
  }

  void _onUpdateDocument(UpdateDocumentEvent event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    
    final result = await updateDocument(UpdateDocumentParams(document: event.document));
    
    result.fold(
      (failure) => emit(SearchError(_mapFailureToMessage(failure))),
      (document) {
        emit(DocumentUpdated(document));
        // Reload all documents after updating
        add(const LoadAllDocumentsEvent());
      },
    );
  }

  void _onDeleteDocument(DeleteDocumentEvent event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    
    final result = await deleteDocument(DeleteDocumentParams(documentId: event.documentId));
    
    result.fold(
      (failure) => emit(SearchError(_mapFailureToMessage(failure))),
      (_) {
        emit(DocumentDeleted(event.documentId));
        // Reload all documents after deleting
        add(const LoadAllDocumentsEvent());
      },
    );
  }

  void _onToggleDocumentSelection(ToggleDocumentSelectionEvent event, Emitter<SearchState> emit) {
    if (state is SearchLoaded) {
      final currentState = state as SearchLoaded;
      final selectedIds = Set<int>.from(currentState.selectedDocumentIds);
      
      if (selectedIds.contains(event.documentId)) {
        selectedIds.remove(event.documentId);
      } else {
        selectedIds.add(event.documentId);
      }
      
      emit(currentState.copyWith(selectedDocumentIds: selectedIds));
    }
  }

  void _onClearSelection(ClearSelectionEvent event, Emitter<SearchState> emit) {
    if (state is SearchLoaded) {
      final currentState = state as SearchLoaded;
      emit(currentState.copyWith(selectedDocumentIds: const <int>{}));
    }
  }

  void _onDeleteMultipleDocuments(DeleteMultipleDocumentsEvent event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    
    // Delete documents one by one for now (could be optimized with bulk operation)
    for (final documentId in event.documentIds) {
      final result = await deleteDocument(DeleteDocumentParams(documentId: documentId));
      if (result.isLeft()) {
        emit(SearchError('Failed to delete some documents'));
        return;
      }
    }
    
    emit(MultipleDocumentsDeleted(event.documentIds));
    // Reload all documents after deleting
    add(const LoadAllDocumentsEvent());
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case DatabaseFailure:
        return 'Database Error: ${(failure as DatabaseFailure).message}';
      case SearchFailure:
        return 'Search Error: ${(failure as SearchFailure).message}';
      case AIModelFailure:
        return 'AI Model Error: ${(failure as AIModelFailure).message}';
      default:
        return 'Unexpected Error';
    }
  }
}