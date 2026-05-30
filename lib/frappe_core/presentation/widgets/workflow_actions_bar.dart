import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/frappe_provider.dart';
import '../providers/frappe_doc_provider.dart';
import '../providers/permission_provider.dart';

class WorkflowActionsBar extends ConsumerStatefulWidget {
  final String doctype;
  final String docname;
  final Map<String, dynamic> currentDoc;
  final VoidCallback onWorkflowApplied;

  const WorkflowActionsBar({
    super.key,
    required this.doctype,
    required this.docname,
    required this.currentDoc,
    required this.onWorkflowApplied,
  });

  @override
  ConsumerState<WorkflowActionsBar> createState() => _WorkflowActionsBarState();
}

class _WorkflowActionsBarState extends ConsumerState<WorkflowActionsBar> {
  bool _isApplying = false;

  @override
  Widget build(BuildContext context) {
    final transitionsAsync = ref.watch(workflowTransitionsProvider('${widget.doctype}|${widget.docname}'));

    return transitionsAsync.when(
      data: (transitions) {
        if (transitions.isEmpty) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: transitions.map((t) {
                  final action = (t as Map<String, dynamic>)['action'] as String;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildActionButton(action),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _buildActionButton(String action) {
    // Determine the permission action based on workflow action
    String? permAction;
    final lowerAction = action.toLowerCase();
    if (lowerAction.contains('submit')) {
      permAction = 'submit';
    } else if (lowerAction.contains('cancel')) {
      permAction = 'cancel';
    } else if (lowerAction.contains('amend')) {
      permAction = 'amend';
    } else if (lowerAction.contains('approve') || lowerAction.contains('accept')) {
      permAction = 'write'; // General write permission for approve actions
    }

    // Check if user has permission for this action
    if (permAction != null) {
      final permission = ref.watch(userPermissionsProvider(widget.doctype));
      
      final hasPermission = permission.maybeWhen(
        data: (perms) {
          switch (permAction) {
            case 'submit':
              return perms.canSubmit;
            case 'cancel':
              return perms.canCancel;
            case 'amend':
              return perms.canAmend;
            case 'write':
              return perms.canWrite;
            default:
              return false;
          }
        },
        orElse: () => false,
      );
      
      if (!hasPermission) {
        return const SizedBox.shrink();
      }
    }

    Color btnColor;
    
    // Assign colors based on typical workflow keywords
    if (lowerAction.contains('approve') || lowerAction.contains('submit') || lowerAction.contains('accept')) {
      btnColor = const Color(0xFF10B981); // Green
    } else if (lowerAction.contains('reject') || lowerAction.contains('cancel') || lowerAction.contains('deny')) {
      btnColor = const Color(0xFFEF4444); // Red
    } else if (lowerAction.contains('review') || lowerAction.contains('hold') || lowerAction.contains('revise')) {
      btnColor = const Color(0xFFF59E0B); // Amber
    } else {
      btnColor = const Color(0xFF3B82F6); // Blue
    }

    return ElevatedButton.icon(
      onPressed: _isApplying ? null : () => _applyAction(action),
      style: ElevatedButton.styleFrom(
        backgroundColor: btnColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: _isApplying 
        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : const Icon(Icons.check_circle_outline, size: 18),
      label: Text(action, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _applyAction(String action) async {
    setState(() => _isApplying = true);
    try {
      await ref.read(frappeRemoteDsProvider).applyWorkflowAction(
        widget.doctype,
        widget.docname,
        action,
        widget.currentDoc, // The all-important full doc
      );
      if (mounted) {
        ref.invalidate(workflowTransitionsProvider('${widget.doctype}|${widget.docname}'));
        widget.onWorkflowApplied(); // Trigger a refresh of the parent document
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Workflow Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }
}
