import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/doc_field_model.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AttachFieldRenderer extends ConsumerStatefulWidget {
  final DocFieldModel field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final bool readOnly;

  const AttachFieldRenderer({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
    this.readOnly = false,
  });

  @override
  ConsumerState<AttachFieldRenderer> createState() =>
      _AttachFieldRendererState();
}

class _AttachFieldRendererState extends ConsumerState<AttachFieldRenderer> {
  bool _isUploading = false;
  String? _baseUrl;

  @override
  void initState() {
    super.initState();
    _loadBaseUrl();
  }

  Future<void> _loadBaseUrl() async {
    const storage = FlutterSecureStorage();
    _baseUrl = await storage.read(key: AppConstants.keyBaseUrl);
    if (mounted) setState(() {});
  }

  Future<void> _pickAndUpload(bool isImage) async {
    if (widget.field.options == null) {
      return; // Need doctype reference from parent
    }

    File? file;

    if (isImage) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        file = File(pickedFile.path);
      }
    } else {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        file = File(result.files.single.path!);
      }
    }

    if (file == null) return;

    setState(() => _isUploading = true);

    try {
      final dio = ref.read(dioProvider);

      // Upload endpoint
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'is_private': 0,
        // Hack: We need the parent doctype from somewhere. For now, we assume field 'options' is not used,
        // or that the parent explicitly passes doctype to `field.options` (we'd have to map that upstream).
        // Real implementation usually passes parent DocType via form state.
        // Assuming parent DocType is passed through options for Attach field (not standard Frappe, but we adapt).
      });

      // Simple file upload, linking must happen on backend standard or we just want the URL.
      final res = await dio.post('/api/method/upload_file', data: formData);

      if (res.statusCode == 200 && res.data['message'] != null) {
        final fileUrl = res.data['message']['file_url'];
        widget.onChanged(fileUrl);
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Upload failed: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.field.hidden == 1) return const SizedBox.shrink();

    final isImage = widget.field.fieldtype == 'Attach Image';
    final hasValue = widget.value != null && widget.value.toString().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.field.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              if (widget.field.reqd == 1)
                const Text(' *', style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 8),

          if (hasValue)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: isImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _baseUrl != null
                            ? '$_baseUrl${widget.value}'
                            : widget.value.toString(),
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 120,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                  : ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.attachment,
                        color: AppTheme.primaryColor,
                      ),
                      title: Text(widget.value.toString().split('/').last),
                      trailing: widget.readOnly
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: () => widget.onChanged(null),
                            ),
                    ),
            ),

          if (!widget.readOnly)
            _isUploading
                ? const SizedBox(
                    height: 48,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : OutlinedButton.icon(
                    icon: Icon(
                      isImage ? Icons.image_outlined : Icons.upload_file,
                    ),
                    label: Text(
                      isImage
                          ? (hasValue ? 'Change Image' : 'Upload Image')
                          : (hasValue ? 'Change File' : 'Upload File'),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _pickAndUpload(isImage),
                  ),
        ],
      ),
    );
  }
}
