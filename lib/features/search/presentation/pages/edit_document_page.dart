import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/document.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';

class EditDocumentPage extends StatelessWidget {
  final Document document;

  const EditDocumentPage({
    super.key,
    required this.document,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<SearchBloc>(),
      child: EditDocumentView(document: document),
    );
  }
}

class EditDocumentView extends StatefulWidget {
  final Document document;

  const EditDocumentView({
    super.key,
    required this.document,
  });

  @override
  State<EditDocumentView> createState() => _EditDocumentViewState();
}

class _EditDocumentViewState extends State<EditDocumentView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _categoryController;
  late final TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.document.title);
    _contentController = TextEditingController(text: widget.document.content);
    _categoryController =
        TextEditingController(text: widget.document.category ?? '');
    _tagsController =
        TextEditingController(text: widget.document.tags.join(', '));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _updateDocument() {
    if (_formKey.currentState!.validate()) {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final updatedDocument = widget.document.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        tags: tags,
        updatedAt: DateTime.now(),
      );

      context.read<SearchBloc>().add(UpdateDocumentEvent(updatedDocument));
    }
  }

  void _deleteDocument() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text(
            'Are you sure you want to delete "${widget.document.title}"? This action cannot be undone.'),
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
                  .add(DeleteDocumentEvent(widget.document.id));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Document'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _deleteDocument,
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Document',
          ),
          TextButton(
            onPressed: _updateDocument,
            child: const Text('Save'),
          ),
        ],
      ),
      body: BlocListener<SearchBloc, SearchState>(
        listener: (context, state) {
          if (state is DocumentUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Document updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is DocumentDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Document deleted successfully!'),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.pop(context);
          } else if (state is SearchError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Document Info',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    'Created: ${_formatDate(widget.document.createdAt)}'),
                                Text(
                                    'Last Updated: ${_formatDate(widget.document.updatedAt)}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title *',
                            hintText: 'Enter document title',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Title is required';
                            }
                            return null;
                          },
                          maxLength: 200,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _contentController,
                          decoration: const InputDecoration(
                            labelText: 'Content *',
                            hintText: 'Enter document content',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Content is required';
                            }
                            return null;
                          },
                          maxLines: 10,
                          minLines: 5,
                          maxLength: 10000,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _categoryController,
                          decoration: const InputDecoration(
                            labelText: 'Category (Optional)',
                            hintText: 'e.g., Work, Personal, Ideas',
                            border: OutlineInputBorder(),
                          ),
                          maxLength: 50,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _tagsController,
                          decoration: const InputDecoration(
                            labelText: 'Tags (Optional)',
                            hintText: 'Enter tags separated by commas',
                            border: OutlineInputBorder(),
                            helperText:
                                'Separate tags with commas (e.g., important, work, project)',
                          ),
                          maxLength: 200,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: state is SearchLoading
                                    ? null
                                    : _deleteDocument,
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  foregroundColor: Colors.red,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.delete_outline),
                                    SizedBox(width: 8),
                                    Text('Delete Document'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: state is SearchLoading
                                    ? null
                                    : _updateDocument,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: state is SearchLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Text('Save Changes'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (state is SearchLoading)
                  Container(
                    color: Colors.black.withAlpha(76),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
