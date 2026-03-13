import 'doc_field_model.dart';

class DocTypeMetaModel {
  final String name;
  final String module;
  final int istable;
  final int issingle;
  final int isSubmittable;
  final List<DocFieldModel> fields;
  final List<Map<String, dynamic>> permissions;
  final String? imageField;
  final String? titleField;
  final int trackChanges;
  final int trackViews;
  final int allowImport;
  final int quickEntry;

  const DocTypeMetaModel({
    required this.name,
    required this.module,
    this.istable = 0,
    this.issingle = 0,
    this.isSubmittable = 0,
    required this.fields,
    this.permissions = const [],
    this.imageField,
    this.titleField,
    this.trackChanges = 0,
    this.trackViews = 0,
    this.allowImport = 0,
    this.quickEntry = 0,
  });

  factory DocTypeMetaModel.fromJson(Map<String, dynamic> json) {
    return DocTypeMetaModel(
      name: json['name'] as String,
      module: json['module'] as String,
      istable: json['istable'] as int? ?? 0,
      issingle: json['issingle'] as int? ?? 0,
      isSubmittable: json['is_submittable'] as int? ?? 0,
      fields: (json['fields'] as List<dynamic>)
          .map((e) => DocFieldModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      imageField: json['image_field'] as String?,
      titleField: json['title_field'] as String?,
      trackChanges: json['track_changes'] as int? ?? 0,
      trackViews: json['track_views'] as int? ?? 0,
      allowImport: json['allow_import'] as int? ?? 0,
      quickEntry: json['quick_entry'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'module': module,
      'istable': istable,
      'issingle': issingle,
      'is_submittable': isSubmittable,
      'fields': fields.map((e) => e.toJson()).toList(),
      'permissions': permissions,
      'image_field': imageField,
      'title_field': titleField,
      'track_changes': trackChanges,
      'track_views': trackViews,
      'allow_import': allowImport,
      'quick_entry': quickEntry,
    };
  }
}
