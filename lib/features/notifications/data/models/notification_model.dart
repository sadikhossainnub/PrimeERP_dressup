class NotificationItem {
  final String name;
  final String subject;
  final String? emailContent;
  final String? documentType;
  final String? documentName;
  final String? fromUser;
  final bool isRead;
  final DateTime? creation;

  NotificationItem({
    required this.name,
    required this.subject,
    this.emailContent,
    this.documentType,
    this.documentName,
    this.fromUser,
    required this.isRead,
    this.creation,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      name: json['name'] as String? ?? '',
      subject: json['subject'] as String? ?? 'No Subject',
      emailContent: json['email_content'] as String?,
      documentType: json['document_type'] as String?,
      documentName: json['document_name'] as String?,
      fromUser: json['from_user'] as String?,
      isRead: (json['read'] == 1 || json['read'] == true),
      creation: json['creation'] != null ? DateTime.tryParse(json['creation']) : null,
    );
  }
}
