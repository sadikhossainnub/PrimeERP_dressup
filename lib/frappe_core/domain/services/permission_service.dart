import '../../data/models/doctype_meta_model.dart';
import '../../data/models/doc_field_model.dart';

class PermissionService {
  PermissionService._();

  // Role-based permission check against DocType meta permissions
  static bool hasPermission(DocTypeMetaModel meta, String ptype) {
    // If no permissions defined in meta, deny by default for safety
    if (meta.permissions.isEmpty) return false;

    // Check if any permission entry allows the requested ptype
    for (final perm in meta.permissions) {
      final value = perm[ptype];
      if (value == 1 || value == true) return true;
    }
    return false;
  }

  static bool isFieldVisible(DocFieldModel field, int userPermLevel) {
    if (field.hidden == 1) return false;
    return field.permlevel <= userPermLevel;
  }

  static bool isFieldReadOnly(
    DocFieldModel field,
    int userPermLevel,
    bool isSubmitted,
  ) {
    if (isSubmitted) {
      return true; // Standard Frappe behavior: submitted docs are read-only
    }
    if (field.readOnly == 1) {
      return true;
    }

    // If user doesn't have write permission for this permlevel
    // return true;

    return false;
  }
}
