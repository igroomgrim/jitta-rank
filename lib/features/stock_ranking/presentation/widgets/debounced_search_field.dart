import 'package:flutter/material.dart';
import 'dart:async';

class DebouncedSearchField extends StatefulWidget {
  final Function(String) onSearch;
  final String hintText;
  final Duration debounceTime;

  const DebouncedSearchField({
    Key? key,
    required this.onSearch,
    this.hintText = 'Search...', // default hint text
    this.debounceTime =
        const Duration(milliseconds: 500), // default debounce time
  }) : super(key: key);

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
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:BorderSide(color: Colors.blue.shade200, width: 1),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      onChanged: _onSearchChanged,
    );
  }
}
