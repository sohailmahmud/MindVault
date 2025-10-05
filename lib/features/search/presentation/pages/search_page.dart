import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../widgets/document_card.dart';
import '../widgets/search_bar_widget.dart';
import 'add_document_page.dart';
import '../../../ai_demo/ai_features_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          serviceLocator<SearchBloc>()..add(const LoadAllDocumentsEvent()),
      child: const SearchView(),
    );
  }
}

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSemanticSearch = false;
  bool _isSelectionMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      context.read<SearchBloc>().add(const LoadAllDocumentsEvent());
      return;
    }

    if (_isSemanticSearch) {
      context.read<SearchBloc>().add(SemanticSearchEvent(query));
    } else {
      context.read<SearchBloc>().add(SearchDocumentsEvent(query));
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
    });
    if (!_isSelectionMode) {
      context.read<SearchBloc>().add(const ClearSelectionEvent());
    }
  }

  void _deleteSelectedDocuments(BuildContext context, Set<int> selectedIds) {
    if (selectedIds.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Documents'),
        content: Text(
          'Are you sure you want to delete ${selectedIds.length} document(s)? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<SearchBloc>()
                  .add(DeleteMultipleDocumentsEvent(selectedIds.toList()));
              _toggleSelectionMode();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        final selectedCount =
            state is SearchLoaded ? state.selectedDocumentIds.length : 0;

        return Scaffold(
          appBar: AppBar(
            title: _isSelectionMode
                ? Text('$selectedCount selected')
                : const Text('MindVault'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            leading: _isSelectionMode
                ? IconButton(
                    onPressed: _toggleSelectionMode,
                    icon: const Icon(Icons.close),
                  )
                : null,
            actions: _isSelectionMode
                ? [
                    if (selectedCount > 0)
                      IconButton(
                        onPressed: () => _deleteSelectedDocuments(
                          context,
                          (state as SearchLoaded).selectedDocumentIds,
                        ),
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete Selected',
                      ),
                    IconButton(
                      onPressed: () => context
                          .read<SearchBloc>()
                          .add(const ClearSelectionEvent()),
                      icon: const Icon(Icons.deselect),
                      tooltip: 'Clear Selection',
                    ),
                  ]
                : [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AIFeaturesPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.psychology),
                      tooltip: 'AI Features',
                    ),
                    IconButton(
                      onPressed: _toggleSelectionMode,
                      icon: const Icon(Icons.checklist),
                      tooltip: 'Select Multiple',
                    ),
                    IconButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        final bloc = context.read<SearchBloc>();

                        await navigator.push(
                          MaterialPageRoute(
                              builder: (context) => const AddDocumentPage()),
                        );
                        // Refresh the documents list
                        if (mounted) {
                          bloc.add(const LoadAllDocumentsEvent());
                        }
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SearchBarWidget(
                      controller: _searchController,
                      onSearch: _performSearch,
                      onClear: () {
                        _searchController.clear();
                        context
                            .read<SearchBloc>()
                            .add(const LoadAllDocumentsEvent());
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Search Mode: '),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Text Search'),
                          selected: !_isSemanticSearch,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _isSemanticSearch = false);
                              if (_searchController.text.isNotEmpty) {
                                _performSearch(_searchController.text);
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('AI Search'),
                          selected: _isSemanticSearch,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _isSemanticSearch = true);
                              if (_searchController.text.isNotEmpty) {
                                _performSearch(_searchController.text);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocListener<SearchBloc, SearchState>(
                  listener: (context, state) {
                    if (state is DocumentDeleted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Document deleted successfully!'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    } else if (state is MultipleDocumentsDeleted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${state.documentIds.length} documents deleted successfully!'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    } else if (state is SearchError &&
                        state.message.contains('delete')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Delete Error: ${state.message}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: BlocBuilder<SearchBloc, SearchState>(
                    builder: (context, state) {
                      if (state is SearchLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is SearchError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error,
                                  size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                'Error: ${state.message}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<SearchBloc>()
                                      .add(const LoadAllDocumentsEvent());
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      } else if (state is SearchLoaded) {
                        if (state.documents.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off,
                                    size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  state.searchQuery != null
                                      ? 'No documents found for "${state.searchQuery}"'
                                      : 'No documents available',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                if (state.searchQuery != null) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      context
                                          .read<SearchBloc>()
                                          .add(const LoadAllDocumentsEvent());
                                    },
                                    child: const Text('Clear Search'),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: [
                            if (state.searchQuery != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: Text(
                                  '${state.documents.length} results found for "${state.searchQuery}"'
                                  '${state.isSemanticSearch ? " (AI Search)" : " (Text Search)"}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: state.documents.length,
                                itemBuilder: (context, index) {
                                  final document = state.documents[index];
                                  final isSelected = state.selectedDocumentIds
                                      .contains(document.id);

                                  return DocumentCard(
                                    document: document,
                                    searchQuery: state.searchQuery,
                                    isSelectable: _isSelectionMode,
                                    isSelected: isSelected,
                                    onSelectionToggle: () {
                                      context.read<SearchBloc>().add(
                                          ToggleDocumentSelectionEvent(
                                              document.id));
                                    },
                                    onDelete: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Document'),
                                          content: Text(
                                              'Are you sure you want to delete "${document.title}"?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                context.read<SearchBloc>().add(
                                                    DeleteDocumentEvent(
                                                        document.id));
                                              },
                                              style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }

                      return const Center(child: Text('Welcome to MindVault'));
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
