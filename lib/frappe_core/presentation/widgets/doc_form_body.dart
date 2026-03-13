import 'package:flutter/material.dart';
import '../../data/models/doc_field_model.dart';
import '../../data/models/doctype_meta_model.dart';
import '../widgets/field_renderers/field_renderer_factory.dart';

class DocFormBody extends StatefulWidget {
  final DocTypeMetaModel meta;
  final Map<String, dynamic> formData;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const DocFormBody({
    super.key,
    required this.meta,
    required this.formData,
    required this.onChanged,
  });

  @override
  State<DocFormBody> createState() => _DocFormBodyState();
}

class _DocFormBodyState extends State<DocFormBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.meta.fields
          .where((f) => f.hidden == 0)
          .map((f) => _buildField(f))
          .toList(),
    );
  }

  Widget _buildField(DocFieldModel field) {
    final bool isReadOnly = widget.formData['docstatus'] != null && widget.formData['docstatus'] > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FieldRendererFactory.getRenderer(
        field: field,
        value: widget.formData[field.fieldname],
        readOnly: isReadOnly || field.readOnly == 1,
        onChanged: (val) {
          final newMap = Map<String, dynamic>.from(widget.formData);
          newMap[field.fieldname] = val;
          widget.onChanged(newMap);
        },
      ),
    );
  }
}
