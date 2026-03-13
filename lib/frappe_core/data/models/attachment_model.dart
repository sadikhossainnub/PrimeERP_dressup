class AttachmentModel {
  final String name;
  final String fileName;
  final String fileUrl;
  final String? attachedToDoctype;
  final String? attachedToName;
  final int isPrivate;
  final int? fileSize;

  const AttachmentModel({
    required this.name,
    required this.fileName,
    required this.fileUrl,
    this.attachedToDoctype,
    this.attachedToName,
    this.isPrivate = 0,
    this.fileSize,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      name: json['name'] as String,
      fileName: json['file_name'] as String? ?? '',
      fileUrl: json['file_url'] as String? ?? '',
      attachedToDoctype: json['attached_to_doctype'] as String?,
      attachedToName: json['attached_to_name'] as String?,
      isPrivate: json['is_private'] as int? ?? 0,
      fileSize: json['file_size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'file_name': fileName,
      'file_url': fileUrl,
      'attached_to_doctype': attachedToDoctype,
      'attached_to_name': attachedToName,
      'is_private': isPrivate,
      'file_size': fileSize,
    };
  }
}
