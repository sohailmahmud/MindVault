import 'dart:async';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onClear,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onSubmitted: widget.onSearch,
      decoration: InputDecoration(
        hintText: 'Search documents...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: widget.onClear,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      onChanged: (value) {
        if (value.isEmpty) {
          _debounceTimer?.cancel();
          widget.onClear();
        } else {
          // Cancel previous timer
          _debounceTimer?.cancel();

          // Start new timer for delayed search
          _debounceTimer = Timer(const Duration(milliseconds: 500), () {
            if (widget.controller.text == value && mounted) {
              widget.onSearch(value);
            }
          });
        }
      },
    );
  }
}
