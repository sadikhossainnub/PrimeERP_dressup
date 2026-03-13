import 'package:flutter/material.dart';
import '../../../data/models/doc_field_model.dart';
import 'data_field_renderer.dart';
import 'select_field_renderer.dart';
import 'check_field_renderer.dart';
import 'link_field_renderer.dart';
import 'date_field_renderer.dart';
import 'table_field_renderer.dart';
import 'attach_field_renderer.dart';
import 'time_field_renderer.dart';
import 'non_input_field_renderer.dart';
import 'rating_field_renderer.dart';
import 'signature_field_renderer.dart';

class FieldRendererFactory {
  static Widget getRenderer({
    required DocFieldModel field,
    required dynamic value,
    required ValueChanged<dynamic> onChanged,
    bool readOnly = false,
  }) {
    final String type = field.fieldtype;

    switch (type) {
      case 'Read Only':
        return DataFieldRenderer(
          field: field,
          value: value,
          onChanged: onChanged,
          readOnly: true,
        );
      case 'Rating':
        return RatingFieldRenderer(
          field: field,
          value: value,
          onChanged: onChanged,
          readOnly: readOnly,
        );
      case 'Signature':
        return SignatureFieldRenderer(
          field: field,
          value: value,
          onChanged: onChanged,
          readOnly: readOnly,
        );
      case 'Data':
      case 'Int':
      case 'Float':
      case 'Currency':
      case 'Phone':
      case 'Email':
      case 'Password':
      case 'Small Text':
      case 'Long Text':
      case 'Text Editor':
        return DataFieldRenderer(
          field: field,
          value: value,
          onChanged: onChanged,
          readOnly: readOnly,
        );
      case 'Select':
        return SelectFieldRenderer(
          field: field,
          value: value,
          onChanged: onChanged,
          readOnly: readOnly,
        );
      case 'Check':
        return CheckFieldRenderer(
          field: field,
          value: value,
          onChanged: onChanged,
          readOnly: readOnly,
        );
      case 'Attach':
      case 'Attach Image':
        return AttachFieldRenderer(
          field: field,
          value: value,
          onChanged: onChanged,
          readOnly: readOnly,
        );
      case 'Link':
        return LinkFieldWidget(
          doctype: field.options ?? '',
          initialValue: value?.toString(),
          onChanged: onChanged,
          readOnly: readOnly,
          label: field.label,
          reqd: field.reqd == 1,
        );
      case 'Time':
        return TimeFieldRenderer(
          field: field,
          value: value,
          onChanged: onChanged,
          readOnly: readOnly,
        );
      case 'Date':
      case 'Datetime':
        return DateFieldRenderer(
          field: field,
          value: value,
          onChanged: onChanged,
          readOnly: readOnly,
        );
      case 'Table':
        return TableFieldRenderer(
          field: field,
          value: value as List<dynamic>?,
          onChanged: (val) => onChanged(val),
        );
      case 'Section Break':
      case 'Column Break':
      case 'Heading':
        return NonInputFieldRenderer(field: field);
      default:
        // Fallback to Data if unknown
        return DataFieldRenderer(
          field: field,
          value: value,
          onChanged: onChanged,
          readOnly: readOnly,
        );
    }
  }
}
