import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../frappe_core/data/models/doc_field_model.dart';
import '../../../../frappe_core/data/models/doctype_meta_model.dart';
import '../../providers/meta_provider.dart';
import '../child_row_form_dialog.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class TableFieldRenderer extends ConsumerWidget {
  final DocFieldModel field;
  final List<dynamic>? value;
  final ValueChanged<List<dynamic>> onChanged;

  const TableFieldRenderer({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childDoctype = field.options;
    if (childDoctype == null) return const Text('Error: No child doctype defined');

    final metaAsync = ref.watch(docTypeMetaProvider(childDoctype));
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              field.label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.primaryColor),
            ),
            TextButton.icon(
              onPressed: () => _addRow(context, childDoctype),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.newDoc('')), // Simplified for now
            ),
          ],
        ),
        const SizedBox(height: 8),
        metaAsync.when(
          data: (meta) => _buildTable(context, meta),
          loading: () => const LoadingWidget(),
          error: (err, _) => Text('Error loading table meta: $err'),
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context, DocTypeMetaModel meta) {
    final rows = value ?? [];
    if (rows.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: const Text('No items added', textAlign: TextAlign.center),
      );
    }

    final listViewFields = meta.fields.where((f) => f.inListView == 1).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
        columns: listViewFields.map((f) => DataColumn(label: Text(f.label))).toList()
          ..add(const DataColumn(label: Text(''))),
        rows: rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value as Map<String, dynamic>;
          return DataRow(
            onLongPress: () => _editRow(context, meta.name, row, index),
            cells: listViewFields
                .map((f) => DataCell(
                  Text(row[f.fieldname]?.toString() ?? ''),
                  onTap: () => _editRow(context, meta.name, row, index),
                ))
                .toList()
              ..add(DataCell(
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _removeRow(index),
                ),
              )),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _addRow(BuildContext context, String doctype) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ChildRowFormDialog(
        doctype: doctype,
        initialData: {'doctype': doctype},
      ),
    );

    if (result != null) {
      final newList = List<dynamic>.from(value ?? []);
      newList.add(result);
      onChanged(newList);
    }
  }

  Future<void> _editRow(BuildContext context, String doctype, Map<String, dynamic> row, int index) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ChildRowFormDialog(
        doctype: doctype,
        initialData: row,
      ),
    );

    if (result != null) {
      final newList = List<dynamic>.from(value ?? []);
      newList[index] = result;
      onChanged(newList);
    }
  }

  void _removeRow(int index) {
    final newList = List<dynamic>.from(value ?? []);
    newList.removeAt(index);
    onChanged(newList);
  }
}
