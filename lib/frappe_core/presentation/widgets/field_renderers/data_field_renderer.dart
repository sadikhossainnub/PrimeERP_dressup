import 'package:flutter/material.dart';
import 'field_renderer.dart';

class DataFieldRenderer extends FieldRenderer {
  const DataFieldRenderer({
    super.key,
    required super.field,
    required super.value,
    required super.onChanged,
    super.readOnly,
  });

  @override
  Widget buildWidget(BuildContext context) {
    final bool isNumeric = field.fieldtype == 'Int' ||
        field.fieldtype == 'Float' ||
        field.fieldtype == 'Currency';

    final bool isPassword = field.fieldtype == 'Password';

    final int maxLines = field.fieldtype == 'Long Text' ? 5 : (field.fieldtype == 'Small Text' ? 2 : 1);

    return TextFormField(
      initialValue: value?.toString() ?? '',
      readOnly: readOnly || field.readOnly == 1,
      obscureText: isPassword,
      maxLines: isPassword ? 1 : maxLines,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: field.label,
        prefixIcon: _getPrefixIcon(),
      ),
      validator: (val) {
        if (field.reqd == 1 && (val == null || val.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
      onChanged: (val) {
        if (isNumeric) {
          onChanged(num.tryParse(val) ?? 0);
        } else {
          onChanged(val);
        }
      },
    );
  }

  Widget? _getPrefixIcon() {
    switch (field.fieldtype) {
      case 'Phone':
        return const Icon(Icons.phone_outlined, size: 20);
      case 'Email':
        return const Icon(Icons.email_outlined, size: 20);
      case 'Currency':
        return const Icon(Icons.account_balance_wallet_outlined, size: 20);
      default:
        return null;
    }
  }
}
