import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/meta_provider.dart';
import 'doc_form_body.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../l10n/app_localizations.dart';

class ChildRowFormDialog extends ConsumerStatefulWidget {
  final String doctype;
  final Map<String, dynamic> initialData;

  const ChildRowFormDialog({
    super.key,
    required this.doctype,
    required this.initialData,
  });

  @override
  ConsumerState<ChildRowFormDialog> createState() => _ChildRowFormDialogState();
}

class _ChildRowFormDialogState extends ConsumerState<ChildRowFormDialog> {
  late Map<String, dynamic> _formData;

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.initialData);
  }

  @override
  Widget build(BuildContext context) {
    final metaAsync = ref.watch(docTypeMetaProvider(widget.doctype));
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.newDoc(widget.doctype)),
      content: SizedBox(
        width: double.maxFinite,
        child: metaAsync.when(
          data: (meta) => SingleChildScrollView(
            child: DocFormBody(
              meta: meta,
              formData: _formData,
              onChanged: (newMap) {
                setState(() {
                  _formData = newMap;
                });
              },
            ),
          ),
          loading: () => const LoadingWidget(),
          error: (err, _) => ErrorStateWidget(message: err.toString()),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _formData),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
