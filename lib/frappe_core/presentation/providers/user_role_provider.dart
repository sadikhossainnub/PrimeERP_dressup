import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/app_constants.dart';
import '../../domain/models/frappe_user_model.dart';
import '../../domain/models/user_permissions.dart';
import '../../data/providers/frappe_provider.dart';

part 'user_role_provider.g.dart';

/// Fetch current logged-in user's profile and roles
/// GET /api/method/frappe.client.get?doctype=User&name={username}&fields=[...]
/// Caches in Hive with 10 min TTL
@riverpod
Future<FrappeUserModel> currentFrappeUser(CurrentFrappeUserRef ref) async {
  final storage = const FlutterSecureStorage();
  final username = await storage.read(key: AppConstants.keyUsername);

  if (username == null || username.isEmpty) {
    throw Exception('Username not found in secure storage');
  }

  final box = await Hive.openBox(AppConstants.hiveSettingsBox);
  final cacheKey = 'frappe_user_$username';

  // Check cache with 10-min TTL
  final cached = box.get(cacheKey);
  if (cached != null && cached is Map) {
    final timestamp = cached['timestamp'] as int?;
    if (timestamp != null) {
      final elapsed = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (elapsed < 10 * 60 * 1000) {
        // Cache still valid
        try {
          return FrappeUserModel.fromJson(cached['data'] as Map<String, dynamic>);
        } catch (_) {
          // Corrupt cache, refetch
        }
      }
    }
  }

  // Fetch from Frappe API
  final ds = ref.watch(frappeRemoteDsProvider);
  final response = await ds.callMethod(
    'frappe.client.get',
    queryParameters: {
      'doctype': 'User',
      'name': username,
      'fields': '["name","full_name","user_type","roles","user_image"]',
    },
  );

  if (response is Map<String, dynamic>) {
    final user = FrappeUserModel.fromJson(response);

    // Cache it
    await box.put(cacheKey, {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': response,
    });

    return user;
  }

  throw Exception('Failed to fetch user data');
}

/// Get user's roles list
@riverpod
Future<List<String>> userRoles(UserRolesRef ref) async {
  final user = await ref.watch(currentFrappeUserProvider.future);
  return user.roles;
}

/// Check if user is System Manager or Administrator
@riverpod
Future<bool> isSystemManager(IsSystemManagerRef ref) async {
  final roles = await ref.watch(userRolesProvider.future);
  return roles.contains('System Manager') || roles.contains('Administrator');
}

/// Batch fetch all DocType permissions for user's roles (Frappe v15 Endpoint F)
/// GET /api/method/frappe.client.get_list
///   ?doctype=DocPerm
///   &filters=[["role","in",{roles}],["permlevel","=",0]]
///   &fields=[...]
/// Returns: Map<String, UserPermissions> where key = doctype name
/// Permissions are additive across roles (OR logic)
@riverpod
Future<Map<String, UserPermissions>> allDoctypePermissions(
  AllDoctypePermissionsRef ref,
) async {
  final isAdmin = await ref.watch(isSystemManagerProvider.future);

  // System Manager/Administrator → all permissions granted
  if (isAdmin) {
    return _buildAllGrantedPermissions();
  }

  final roles = await ref.watch(userRolesProvider.future);
  if (roles.isEmpty) return {};

  final ds = ref.watch(frappeRemoteDsProvider);

  // Batch fetch all DocPerm for user's roles in ONE API call (Endpoint F)
  try {
    final response = await ds.callMethod(
      'frappe.client.get_list',
      queryParameters: {
        'doctype': 'DocPerm',
        'filters': '[["role","in",${_encodeList(roles)}],["permlevel","=",0]]',
        'fields': '["parent","role","read","write","create","delete","submit","cancel","amend","report","print","export","email","share"]',
        'limit_page_length': '500',
      },
    );

    if (response is List) {
      // Group by doctype (parent) and merge permissions with OR logic
      final Map<String, UserPermissions> permissions = {};

      for (final item in response) {
        if (item is! Map<String, dynamic>) continue;

        final doctype = item['parent']?.toString();
        if (doctype == null || doctype.isEmpty) continue;

        final canRead = (item['read'] == 1 || item['read'] == true);
        final canWrite = (item['write'] == 1 || item['write'] == true);
        final canCreate = (item['create'] == 1 || item['create'] == true);
        final canDelete = (item['delete'] == 1 || item['delete'] == true);
        final canSubmit = (item['submit'] == 1 || item['submit'] == true);
        final canAmend = (item['amend'] == 1 || item['amend'] == true);
        final canCancel = (item['cancel'] == 1 || item['cancel'] == true);

        final existing = permissions[doctype];
        if (existing != null) {
          // Merge with OR logic (additive across roles)
          permissions[doctype] = UserPermissions(
            canRead: existing.canRead || canRead,
            canWrite: existing.canWrite || canWrite,
            canCreate: existing.canCreate || canCreate,
            canDelete: existing.canDelete || canDelete,
            canSubmit: existing.canSubmit || canSubmit,
            canAmend: existing.canAmend || canAmend,
            canCancel: existing.canCancel || canCancel,
          );
        } else {
          permissions[doctype] = UserPermissions(
            canRead: canRead,
            canWrite: canWrite,
            canCreate: canCreate,
            canDelete: canDelete,
            canSubmit: canSubmit,
            canAmend: canAmend,
            canCancel: canCancel,
          );
        }
      }

      return permissions;
    }
  } catch (e) {
    // Fallback: return empty map (deny all)
    return {};
  }

  return {};
}

/// Get permission for a specific doctype
@riverpod
Future<UserPermissions> doctypePermission(
  DoctypePermissionRef ref,
  String doctype,
) async {
  final all = await ref.watch(allDoctypePermissionsProvider.future);
  return all[doctype] ?? const UserPermissions();
}

/// Get user's record-level permissions (User Permissions DocType)
/// Frappe v15 Endpoint E
/// Returns: Map<String, List<String>> where key = field name, value = allowed values
@riverpod
Future<Map<String, List<String>>> userRecordPermissions(
  UserRecordPermissionsRef ref,
) async {
  final isAdmin = await ref.watch(isSystemManagerProvider.future);
  if (isAdmin) return {};

  final ds = ref.watch(frappeRemoteDsProvider);

  try {
    final response = await ds.callMethod(
      'frappe.core.doctype.user_permission.user_permission.get_user_permissions',
    );

    if (response is Map<String, dynamic>) {
      final result = <String, List<String>>{};

      // Response format: { "Company": [{"doc": "Dress Up", "applicable_for": null}], ... }
      response.forEach((doctype, perms) {
        if (perms is List) {
          final docs = <String>[];
          for (final perm in perms) {
            if (perm is Map<String, dynamic>) {
              final doc = perm['doc']?.toString();
              if (doc != null && doc.isNotEmpty) {
                docs.add(doc);
              }
            }
          }
          if (docs.isNotEmpty) {
            result[doctype] = docs;
          }
        }
      });

      return result;
    }
  } catch (_) {
    // Silently fail, return empty map
  }

  return {};
}

/// Build auto-filters for list views based on user permissions
/// Maps record permission doctypes to filter field names
@riverpod
List<List<dynamic>> autoFiltersForList(
  AutoFiltersForListRef ref,
  String doctype,
) {
  // Watch record permissions
  final permsAsync = ref.watch(userRecordPermissionsProvider);

  return permsAsync.maybeWhen(
    data: (perms) {
      final filters = <List<dynamic>>[];

      // Standard Frappe field mappings
      const fieldMapping = {
        'Company': 'company',
        'Territory': 'territory',
        'Cost Center': 'cost_center',
        'Warehouse': 'warehouse',
        'Branch': 'branch',
      };

      // For each user permission type
      fieldMapping.forEach((permType, fieldName) {
        final allowedValues = perms[permType];
        if (allowedValues != null && allowedValues.isNotEmpty) {
          // Special case for Warehouse in Stock Entry
          if (fieldName == 'warehouse' && doctype == 'Stock Entry') {
            fieldName = 'set_warehouse';
          }

          // Build filter: [field, "=", value] (if single value)
          // or [field, "in", values] (if multiple)
          if (allowedValues.length == 1) {
            filters.add([fieldName, '=', allowedValues.first]);
          } else {
            filters.add([fieldName, 'in', allowedValues]);
          }
        }
      });

      return filters;
    },
    orElse: () => [],
  );
}

// ─── Helpers ───

/// Build permission map with all permissions granted (for System Manager)
Map<String, UserPermissions> _buildAllGrantedPermissions() {
  final grantAll = const UserPermissions(
    canRead: true,
    canWrite: true,
    canCreate: true,
    canDelete: true,
    canSubmit: true,
    canAmend: true,
    canCancel: true,
  );

  // Return empty map; System Manager bypass is handled at widget level
  // But we include common doctypes for safety
  return {
    'Sales Invoice': grantAll,
    'Sales Order': grantAll,
    'Purchase Invoice': grantAll,
    'Purchase Order': grantAll,
    'Customer': grantAll,
    'Supplier': grantAll,
    'Item': grantAll,
    'Stock Entry': grantAll,
    'Warehouse': grantAll,
    'Employee': grantAll,
    'Attendance': grantAll,
    'Leave Application': grantAll,
    'Salary Slip': grantAll,
    'Quotation': grantAll,
    'Lead': grantAll,
  };
}

/// Encode list as JSON string for query parameters
String _encodeList(List<String> items) {
  final escaped = items.map((s) => '"$s"').join(',');
  return '[$escaped]';
}
