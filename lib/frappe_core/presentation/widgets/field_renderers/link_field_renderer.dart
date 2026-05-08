import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'field_renderer.dart';
import '../../../data/providers/frappe_provider.dart';

class LinkFieldRenderer extends ConsumerWidget {
  final FieldRenderer base;
  const LinkFieldRenderer({super.key, required this.base});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return base; // Temporary fallback until full searchable logic added
  }
}

// Actual implementation with search
class LinkFieldWidget extends ConsumerStatefulWidget {
  final String doctype;
  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final bool readOnly;
  final String label;
  final bool reqd;

  const LinkFieldWidget({
    super.key,
    required this.doctype,
    this.initialValue,
    required this.onChanged,
    this.readOnly = false,
    required this.label,
    this.reqd = false,
  });

  @override
  ConsumerState<LinkFieldWidget> createState() => _LinkFieldWidgetState();
}

class _LinkFieldWidgetState extends ConsumerState<LinkFieldWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true, // Navigate to search screen or show dialog
      onTap: widget.readOnly ? null : _showSearchDialog,
      decoration: InputDecoration(
        hintText: 'Search ${widget.label}',
        suffixIcon: const Icon(Icons.search, size: 20),
      ),
      validator: (val) {
        if (widget.reqd && (val == null || val.isEmpty)) {
          return 'Please select a ${widget.label}';
        }
        return null;
      },
    );
  }

  void _showSearchDialog() async {
    
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return _LinkSearchDialog(
          doctype: widget.doctype,
          onSelect: (val) => Navigator.of(context).pop(val),
        );
      },
    );

    if (selected != null) {
      setState(() => _controller.text = selected);
      widget.onChanged(selected);
    }
  }
}

class _LinkSearchDialog extends ConsumerStatefulWidget {
  final String doctype;
  final ValueChanged<String> onSelect;

  const _LinkSearchDialog({required this.doctype, required this.onSelect});

  @override
  ConsumerState<_LinkSearchDialog> createState() => _LinkSearchDialogState();
}

class _LinkSearchDialogState extends ConsumerState<_LinkSearchDialog> {
  String _searchQuery = '';
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final ds = ref.read(frappeRemoteDsProvider);
      final items = await ds.searchLink(widget.doctype, _searchQuery);
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _searchQuery = value);
        _fetchItems();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select ${widget.doctype}'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text('Error: $_error'))
                      : ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            final name = item['name'] as String? ?? item['value'] as String? ?? '';
                            final desc = item['description'] as String?;
                            return ListTile(
                              title: Text(name),
                              subtitle: desc != null && desc.isNotEmpty ? Text(desc) : null,
                              onTap: () => widget.onSelect(name),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
