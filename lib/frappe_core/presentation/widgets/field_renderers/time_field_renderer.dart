import 'package:flutter/material.dart';
import 'field_renderer.dart';

class TimeFieldRenderer extends FieldRenderer {
  const TimeFieldRenderer({
    super.key,
    required super.field,
    required super.value,
    required super.onChanged,
    super.readOnly,
  });

  @override
  Widget buildWidget(BuildContext context) {
    final controller = TextEditingController(text: value?.toString() ?? '');

    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: !readOnly && field.readOnly == 0,
      decoration: InputDecoration(
        hintText: 'HH:mm:ss',
        suffixIcon: const Icon(Icons.access_time_outlined, size: 20),
        prefixIcon: const Icon(Icons.schedule, size: 20),
      ),
      onTap: () async {
        if (readOnly || field.readOnly == 1) return;

        TimeOfDay? initialTime;
        if (value != null) {
          final parts = value.toString().split(':');
          if (parts.length >= 2) {
            initialTime = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? TimeOfDay.now().hour,
              minute: int.tryParse(parts[1]) ?? TimeOfDay.now().minute,
            );
          }
        }

        final picked = await showTimePicker(
          context: context,
          initialTime: initialTime ?? TimeOfDay.now(),
        );

        if (picked != null) {
          final formatted =
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
          controller.text = formatted;
          onChanged(formatted);
        }
      },
    );
  }
}
