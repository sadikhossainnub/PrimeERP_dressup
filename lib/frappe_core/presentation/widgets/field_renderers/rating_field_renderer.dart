import 'package:flutter/material.dart';
import 'field_renderer.dart';

class RatingFieldRenderer extends FieldRenderer {
  const RatingFieldRenderer({
    super.key,
    required super.field,
    required super.value,
    required super.onChanged,
    super.readOnly,
  });

  @override
  Widget buildWidget(BuildContext context) {
    final int rating = (value is num) ? (value as num).toInt() : 0;
    final int maxRating = 5;

    return Row(
      children: List.generate(maxRating, (index) {
        return IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: index < rating ? Colors.amber : Colors.grey,
            size: 32,
          ),
          onPressed: (readOnly || field.readOnly == 1)
              ? null
              : () => onChanged(index + 1),
        );
      }),
    );
  }
}
