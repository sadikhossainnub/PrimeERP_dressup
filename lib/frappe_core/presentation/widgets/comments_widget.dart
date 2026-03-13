import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../data/models/comment_model.dart';
import '../../data/providers/frappe_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_widget.dart';
import 'package:intl/intl.dart';

class CommentsWidget extends ConsumerStatefulWidget {
  final String doctype;
  final String name;

  const CommentsWidget({
    super.key,
    required this.doctype,
    required this.name,
  });

  @override
  ConsumerState<CommentsWidget> createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends ConsumerState<CommentsWidget> {
  final _commentController = TextEditingController();
  bool _isPosting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.comments,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        _buildCommentInput(l10n),
        const SizedBox(height: 16),
        _buildCommentsList(l10n),
      ],
    );
  }

  Widget _buildCommentInput(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: l10n.addComment,
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _isPosting ? null : _postComment,
          icon: _isPosting 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.send, color: AppTheme.primaryColor),
        ),
      ],
    );
  }

  Widget _buildCommentsList(AppLocalizations l10n) {
    return FutureBuilder<List<CommentModel>>(
      future: ref.read(frappeRemoteDsProvider).getComments(widget.doctype, widget.name).then(
            (list) => list.map((e) => CommentModel.fromJson(e)).toList(),
          ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const LoadingWidget();
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        
        final comments = snapshot.data ?? [];
        if (comments.isEmpty) return Text(l10n.noActivity);

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final comment = comments[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    comment.commentBy.isNotEmpty ? comment.commentBy[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment.commentBy,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(comment.creation),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(comment.content),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat.yMMMd().add_jm().format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _postComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isPosting = true);
    try {
      await ref.read(frappeRemoteDsProvider).addComment(
        widget.doctype,
        widget.name,
        content,
      );
      _commentController.clear();
      setState(() {}); // Refresh list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post comment: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
