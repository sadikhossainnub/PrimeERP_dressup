import 'package:flutter/material.dart';
import 'field_renderer.dart';

class SelectFieldRenderer extends FieldRenderer {
  const SelectFieldRenderer({
    super.key,
    required super.field,
    required super.value,
    required super.onChanged,
    super.readOnly,
  });

  @override
  Widget buildWidget(BuildContext context) {
    final List<String> options = (field.options ?? '').split('\n');
    final String? currentValue = value?.toString();

    // Ensure current value is in options, otherwise default to first if required
    final String? effectiveValue = options.contains(currentValue)
        ? currentValue
        : (field.reqd == 1 && options.isNotEmpty ? options[0] : null);

    return DropdownButtonFormField<String>(
      initialValue: effectiveValue,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: 'Select ${field.label}',
      ),
      validator: (val) {
        if (field.reqd == 1 && (val == null || val.isEmpty)) {
          return 'Please select an option';
        }
        return null;
      },
      items: options.map((opt) {
        return DropdownMenuItem<String>(
          value: opt,
          child: Text(opt.isEmpty ? 'Select ${field.label}' : opt),
        );
      }).toList(),
      onChanged: readOnly || field.readOnly == 1 ? null : (val) => onChanged(val),
    );
  }
}
