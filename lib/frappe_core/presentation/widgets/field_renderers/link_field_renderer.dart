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

class _LinkSearchDialog extends ConsumerWidget {
  final String doctype;
  final ValueChanged<String> onSelect;

  const _LinkSearchDialog({required this.doctype, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ds = ref.watch(frappeRemoteDsProvider);
    
    return AlertDialog(
      title: Text('Select $doctype'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: ds.getList(doctype, limitPageLength: 50),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final items = snapshot.data ?? [];
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final name = item['name'] as String;
                return ListTile(
                  title: Text(name),
                  onTap: () => onSelect(name),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
