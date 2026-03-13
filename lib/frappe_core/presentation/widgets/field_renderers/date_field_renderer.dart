import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'field_renderer.dart';

class DateFieldRenderer extends FieldRenderer {
  const DateFieldRenderer({
    super.key,
    required super.field,
    required super.value,
    required super.onChanged,
    super.readOnly,
  });

  @override
  Widget buildWidget(BuildContext context) {
    final DateTime? initialDate = value != null ? DateTime.tryParse(value.toString()) : null;
    final String displayValue = initialDate != null ? DateFormat('yyyy-MM-dd').format(initialDate) : '';

    return TextFormField(
      initialValue: displayValue,
      readOnly: true,
      onTap: readOnly || field.readOnly == 1 ? null : () => _selectDate(context, initialDate),
      decoration: const InputDecoration(
        suffixIcon: Icon(Icons.calendar_today_outlined, size: 20),
      ),
    );
  }

  void _selectDate(BuildContext context, DateTime? initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      onChanged(DateFormat('yyyy-MM-dd').format(picked));
    }
  }
}
