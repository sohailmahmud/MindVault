import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/document.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';

class AddDocumentPage extends StatelessWidget {
  const AddDocumentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<SearchBloc>(),
      child: const AddDocumentView(),
    );
  }
}

class AddDocumentView extends StatefulWidget {
  const AddDocumentView({super.key});

  @override
  State<AddDocumentView> createState() => _AddDocumentViewState();
}

class _AddDocumentViewState extends State<AddDocumentView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();
  final _tagsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _addDocument() {
    if (_formKey.currentState!.validate()) {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final document = Document(
        id: 0, // Will be assigned by ObjectBox
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        tags: tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<SearchBloc>().add(AddDocumentEvent(document));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Document'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _addDocument,
            child: const Text('Save'),
          ),
        ],
      ),
      body: BlocListener<SearchBloc, SearchState>(
        listener: (context, state) {
          if (state is DocumentAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Document added successfully!'),
                backgroundColor: Colors.green,
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
                        ElevatedButton(
                          onPressed:
                              state is SearchLoading ? null : _addDocument,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: state is SearchLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Add Document'),
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
}
