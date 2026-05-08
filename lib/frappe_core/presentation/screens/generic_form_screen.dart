import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../data/models/doctype_meta_model.dart';
import '../../data/providers/frappe_provider.dart';
import '../providers/meta_provider.dart';
import '../providers/frappe_doc_provider.dart';
import '../widgets/doc_form_body.dart';
import '../widgets/comments_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../widgets/workflow_actions_bar.dart';

class GenericFormScreen extends ConsumerStatefulWidget {
  final String doctype;
  final String? name;

  const GenericFormScreen({
    super.key,
    required this.doctype,
    this.name,
  });

  @override
  ConsumerState<GenericFormScreen> createState() => _GenericFormScreenState();
}

class _GenericFormScreenState extends ConsumerState<GenericFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {};
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final metaAsync = ref.watch(docTypeMetaProvider(widget.doctype));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name ?? 'New ${widget.doctype}'),
        actions: [
          if (widget.name != null)
            PopupMenuButton<String>(
              onSelected: (val) => _handleMenuAction(val, l10n),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'amend', child: Text('Amend')),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
        ],
      ),
      body: metaAsync.when(
        data: (meta) => _buildForm(meta, l10n),
        loading: () => const LoadingWidget(),
        error: (err, _) => ErrorStateWidget(message: err.toString()),
      ),
      bottomNavigationBar: metaAsync.maybeWhen(
        data: (meta) => _buildBottomBar(meta, l10n),
        orElse: () => null,
      ),
    );
  }

  Widget _buildForm(DocTypeMetaModel meta, AppLocalizations l10n) {
    final docAsync = widget.name != null 
      ? ref.watch(frappeDocProvider('${widget.doctype}|${widget.name!}'))
      : const AsyncValue.data(<String, dynamic>{});

    return docAsync.when(
      data: (doc) {
        if (_formData.isEmpty && doc.isNotEmpty) {
          _formData = Map<String, dynamic>.from(doc);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (widget.name != null)
                WorkflowActionsBar(
                  doctype: widget.doctype,
                  docname: widget.name!,
                  currentDoc: _formData,
                  onWorkflowApplied: () {
                    // Force rebuild / refetch
                    setState(() {});
                  },
                ),
              if (widget.name != null) const SizedBox(height: 16),
              Form(
                key: _formKey,
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
              if (widget.name != null) ...[
                const Divider(height: 32),
                CommentsWidget(doctype: widget.doctype, name: widget.name!),
              ],
            ],
          ),
        );
      },
      loading: () => const LoadingWidget(),
      error: (err, _) => ErrorStateWidget(message: err.toString()),
    );
  }


  Widget _buildBottomBar(DocTypeMetaModel meta, AppLocalizations l10n) {
    final docStatus = _formData['docstatus'] ?? 0;
    final isNew = widget.name == null;
    final isSubmittable = meta.isSubmittable == 1;

    // If submitted (1) or cancelled (2), usually read-only, but show Cancel button if status is 1
    if (docStatus == 2) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          if (docStatus == 1) ...[
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: _isSaving ? null : _cancelDoc,
                child: _isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Cancel'),
              ),
            ),
          ] else ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
            ),
            const SizedBox(width: 16),
            if (!isNew && isSubmittable)
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: _isSaving ? null : _submitDoc,
                  child: _isSaving 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit'),
                ),
              )
            else
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveDoc,
                  child: _isSaving 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.save),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _saveDoc() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      _formData['doctype'] = widget.doctype;
      if (widget.name != null) _formData['name'] = widget.name;

      final savedDoc = await ref.read(frappeRemoteDsProvider).saveDoc(_formData);
      if (mounted) {
        ref.invalidate(frappeDocProvider('${widget.doctype}|${widget.name!}'));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document saved')));
        if (widget.name == null) {
          // If new, maybe pop with result or navigate to detail
          Navigator.pop(context, savedDoc);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _submitDoc() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(frappeRemoteDsProvider).submitDoc(widget.doctype, widget.name!, _formData);
      if (mounted) {
        ref.invalidate(frappeDocProvider('${widget.doctype}|${widget.name!}'));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document submitted')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _cancelDoc() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Document'),
        content: const Text('Are you sure you want to cancel this document?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(frappeRemoteDsProvider).cancelDoc(widget.doctype, widget.name!);
      if (mounted) {
        ref.invalidate(frappeDocProvider('${widget.doctype}|${widget.name!}'));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document cancelled')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cancelling: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _handleMenuAction(String action, AppLocalizations l10n) async {
    if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Document'),
          content: const Text('Are you sure you want to delete this document?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
          ],
        ),
      );
      if (confirm == true) {
        try {
          await ref.read(frappeRemoteDsProvider).deleteDoc(widget.doctype, widget.name!);
          if (mounted) Navigator.pop(context);
        } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
        }
      }
    } else if (action == 'amend') {
       // Implementation for amend: open same form with amended_from set
       final newDoc = Map<String, dynamic>.from(_formData);
       newDoc.remove('name');
       newDoc.remove('docstatus');
       newDoc['amended_from'] = widget.name;
       
       // Navigate to new form with this data (requires logic to pass initial data to GenericFormScreen)
       // For now, just show message or implement passing initial data
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Amendment feature coming soon')));
    }
  }

}
