class DocFieldModel {
  final String fieldname;
  final String label;
  final String fieldtype;
  final String? options;
  final int reqd;
  final int readOnly;
  final int hidden;
  final int inListView;
  final int inStandardFilter;
  final int bold;
  final int collapsible;
  final String? description;
  final String defaultValue;
  final int permlevel;

  const DocFieldModel({
    required this.fieldname,
    required this.label,
    required this.fieldtype,
    this.options,
    this.reqd = 0,
    this.readOnly = 0,
    this.hidden = 0,
    this.inListView = 0,
    this.inStandardFilter = 0,
    this.bold = 0,
    this.collapsible = 0,
    this.description,
    this.defaultValue = '',
    this.permlevel = 0,
  });

  factory DocFieldModel.fromJson(Map<String, dynamic> json) {
    return DocFieldModel(
      fieldname: json['fieldname'] as String,
      label: json['label'] as String? ?? json['fieldname'] as String,
      fieldtype: json['fieldtype'] as String,
      options: json['options'] as String?,
      reqd: json['reqd'] as int? ?? 0,
      readOnly: json['read_only'] as int? ?? 0,
      hidden: json['hidden'] as int? ?? 0,
      inListView: json['in_list_view'] as int? ?? 0,
      inStandardFilter: json['in_standard_filter'] as int? ?? 0,
      bold: json['bold'] as int? ?? 0,
      collapsible: json['collapsible'] as int? ?? 0,
      description: json['description'] as String?,
      defaultValue: json['default']?.toString() ?? '',
      permlevel: json['permlevel'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldname': fieldname,
      'label': label,
      'fieldtype': fieldtype,
      'options': options,
      'reqd': reqd,
      'read_only': readOnly,
      'hidden': hidden,
      'in_list_view': inListView,
      'in_standard_filter': inStandardFilter,
      'bold': bold,
      'collapsible': collapsible,
      'description': description,
      'default': defaultValue,
      'permlevel': permlevel,
    };
  }
}
