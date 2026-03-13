import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'field_renderer.dart';
import '../../../../core/theme/app_theme.dart';

class SignatureFieldRenderer extends FieldRenderer {
  const SignatureFieldRenderer({
    super.key,
    required super.field,
    required super.value,
    required super.onChanged,
    super.readOnly,
  });

  @override
  Widget buildWidget(BuildContext context) {
    // If we have a value, it's usually a URL to the SVG/PNG in Frappe.
    // For simplicity, if we have value, we show "View Signature" or just the image.
    // If not, we show a pad to draw.

    if (value != null && value.toString().isNotEmpty) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Image.network(
          value.toString(),
          errorBuilder: (context, error, stackTrace) =>
              const Center(child: Text('Signature Loaded')),
        ),
      );
    }

    if (readOnly) return const Text('No signature provided');

    final SignatureController controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.transparent,
    );

    return Column(
      children: [
        Signature(
          controller: controller,
          height: 150,
          backgroundColor: Colors.grey[100]!,
        ),
        Container(
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => controller.clear(),
              ),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () async {
                  final data = await controller.toPngBytes();
                  if (data != null) {
                    // In a real app, we would upload this byte array to Frappe
                    // and get a file_url back, then call onChanged(file_url).
                    // For now, we'll just base64 format it as a placeholder.
                    onChanged('data:image/png;base64,${base64Encode(data)}');
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
