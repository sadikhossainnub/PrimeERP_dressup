import 'package:flutter/material.dart';
import 'field_renderer.dart';

class CheckFieldRenderer extends FieldRenderer {
  const CheckFieldRenderer({
    super.key,
    required super.field,
    required super.value,
    required super.onChanged,
    super.readOnly,
  });

  @override
  Widget buildWidget(BuildContext context) {
    final bool isChecked = value == 1 || value == true;

    return CheckboxListTile(
      value: isChecked,
      title: Text(field.label),
      contentPadding: EdgeInsets.zero,
      dense: true,
      enabled: !(readOnly || field.readOnly == 1),
      onChanged: (val) {
        onChanged(val == true ? 1 : 0);
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
