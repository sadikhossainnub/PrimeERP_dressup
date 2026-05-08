import 'package:flutter/material.dart';
import '../../data/models/doc_field_model.dart';
import '../../data/models/doctype_meta_model.dart';
import '../../utils/frappe_evaluator.dart';
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
          .where((f) {
            if (f.dependsOn != null && f.dependsOn!.isNotEmpty) {
              return FrappeEvaluator.evaluate(f.dependsOn!, widget.formData);
            }
            return true;
          })
          .map((f) => _buildField(f))
          .toList(),
    );
  }

  Widget _buildField(DocFieldModel field) {
    final bool isReadOnly = widget.formData['docstatus'] != null && widget.formData['docstatus'] > 0;
    
    // Evaluate mandatory_depends_on dynamically
    bool isMandatory = field.reqd == 1;
    if (field.mandatoryDependsOn != null && field.mandatoryDependsOn!.isNotEmpty) {
      isMandatory = FrappeEvaluator.evaluate(field.mandatoryDependsOn!, widget.formData);
    }
    
    // Create a localized copy of the field with the evaluated mandatory status
    final evaluatedField = DocFieldModel(
      fieldname: field.fieldname,
      label: field.label,
      fieldtype: field.fieldtype,
      options: field.options,
      reqd: isMandatory ? 1 : 0,
      readOnly: field.readOnly,
      hidden: field.hidden,
      inListView: field.inListView,
      inStandardFilter: field.inStandardFilter,
      bold: field.bold,
      collapsible: field.collapsible,
      description: field.description,
      defaultValue: field.defaultValue,
      permlevel: field.permlevel,
      dependsOn: field.dependsOn,
      mandatoryDependsOn: field.mandatoryDependsOn,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FieldRendererFactory.getRenderer(
        field: evaluatedField,
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
