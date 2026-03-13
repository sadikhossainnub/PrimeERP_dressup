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
          if (widget.name != null) _buildWorkflowActions(),
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


  Widget _buildWorkflowActions() {
    final transitionsAsync = ref.watch(workflowTransitionsProvider('${widget.doctype}|${widget.name!}'));

    return transitionsAsync.when(
      data: (transitions) {
        if (transitions.isEmpty) return const SizedBox.shrink();
        
        return PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: _applyWorkflowAction,
          itemBuilder: (context) => transitions.map((t) {
            final action = (t as Map<String, dynamic>)['action'] as String;
            return PopupMenuItem(
              value: action,
              child: Text(action),
            );
          }).toList(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _buildBottomBar(DocTypeMetaModel meta, AppLocalizations l10n) {
    // Determine if we should show Cancel, Save, or Submit
    // For submittable docs (docstatus: 0 = Draft, 1 = Submitted, 2 = Cancelled)
    final docStatus = _formData['docstatus'] ?? 0;
    
    if (docStatus > 0) return const SizedBox.shrink(); // Submitted or Cancelled docs are read-only

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
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveDoc,
              child: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.save),
            ),
          ),
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
        Navigator.pop(context, savedDoc);
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

  Future<void> _applyWorkflowAction(String action) async {
    setState(() => _isSaving = true);
    try {
      await ref.read(frappeRemoteDsProvider).applyWorkflowAction(
        widget.doctype,
        widget.name!,
        action,
      );
      if (mounted) {
        ref.invalidate(frappeDocProvider('${widget.doctype}|${widget.name!}'));
        ref.invalidate(workflowTransitionsProvider('${widget.doctype}|${widget.name!}'));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Workflow error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
