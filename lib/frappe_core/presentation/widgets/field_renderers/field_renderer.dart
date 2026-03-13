import 'package:flutter/material.dart';
import '../../../data/models/doc_field_model.dart';

abstract class FieldRenderer extends StatelessWidget {
  final DocFieldModel field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final bool readOnly;

  const FieldRenderer({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (field.hidden == 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                field.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              if (field.reqd == 1)
                const Text(
                  ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 4),
          buildWidget(context),
          if (field.description != null && field.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                field.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildWidget(BuildContext context);
}
