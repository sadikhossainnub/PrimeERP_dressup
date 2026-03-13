class CommentModel {
  final String name;
  final String content;
  final String commentType;
  final String commentEmail;
  final String commentBy;
  final String creation;
  final String? referenceDoctype;
  final String? referenceName;

  const CommentModel({
    required this.name,
    required this.content,
    required this.commentType,
    required this.commentEmail,
    required this.commentBy,
    required this.creation,
    this.referenceDoctype,
    this.referenceName,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      name: json['name'] as String,
      content: json['content'] as String? ?? '',
      commentType: json['comment_type'] as String? ?? 'Comment',
      commentEmail: json['comment_email'] as String? ?? '',
      commentBy: json['comment_by'] as String? ?? json['owner'] as String? ?? 'Unknown',
      creation: json['creation'] as String,
      referenceDoctype: json['reference_doctype'] as String?,
      referenceName: json['reference_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'content': content,
      'comment_type': commentType,
      'comment_email': commentEmail,
      'comment_by': commentBy,
      'creation': creation,
      'reference_doctype': referenceDoctype,
      'reference_name': referenceName,
    };
  }
}
