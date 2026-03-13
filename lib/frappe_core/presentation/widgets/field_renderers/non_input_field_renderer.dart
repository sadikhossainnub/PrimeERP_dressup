import 'package:flutter/material.dart';
import '../../../data/models/doc_field_model.dart';
import '../../../../core/theme/app_theme.dart';

class NonInputFieldRenderer extends StatelessWidget {
  final DocFieldModel field;

  const NonInputFieldRenderer({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    if (field.hidden == 1) return const SizedBox.shrink();

    final String type = field.fieldtype;
    final String label = field.label;

    switch (type) {
      case 'Section Break':
        return Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    label.toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      letterSpacing: 1.2,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Divider(thickness: 1.5),
            ],
          ),
        );
      case 'Heading':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        );
      case 'Column Break':
        // On mobile, Column Break is usually ignore or just a small space
        return const SizedBox(height: 8);
      default:
        return const SizedBox.shrink();
    }
  }
}
