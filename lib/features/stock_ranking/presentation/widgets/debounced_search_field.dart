import 'dart:async';

import 'package:flutter/material.dart';

class DebouncedSearchField extends StatefulWidget {
  const DebouncedSearchField({
    super.key,
    required this.onSearch,
    this.hintText = 'Search...', // default hint text
    this.debounceTime =
        const Duration(milliseconds: 500), // default debounce time
  });
  final Function(String) onSearch;
  final String hintText;
  final Duration debounceTime;

  @override
  State<DebouncedSearchField> createState() => _DebouncedSearchFieldState();
}

class _DebouncedSearchFieldState extends State<DebouncedSearchField> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(widget.debounceTime, () {
      widget.onSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      // Borders, fill and radius come from inputDecorationTheme.
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
      ),
      onChanged: _onSearchChanged,
    );
  }
}
