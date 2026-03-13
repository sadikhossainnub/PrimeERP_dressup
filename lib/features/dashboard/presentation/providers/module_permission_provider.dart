import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../frappe_core/data/providers/frappe_provider.dart';
import '../../../../core/constants/module_constants.dart';

/// Fetches the list of DocTypes the current user has read permission for,
/// then filters the static appModules list to only show accessible ones.
final permittedModulesProvider = FutureProvider<List<ModuleItem>>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);

  Set<String> allowedDoctypes = {};

  try {
    // Step 1: Get all DocTypes the user has access to in one call
    // Using callMethod with frappe.client.get_list as it's sometimes more permissive than /api/resource/DocType
    final dynamic response = await repository.callMethod(
      'frappe.client.get_list',
      queryParameters: {
        'doctype': 'DocType',
        'fields': '["name"]',
        'filters': '[["istable", "=", 0]]',
        'limit_page_length': '1000',
      },
    );
    
    if (response is List) {
      allowedDoctypes = response.map((e) => (e as Map)['name'] as String).toSet();
    }
    
    debugPrint('Permitted DocTypes count: ${allowedDoctypes.length}');
  } catch (e) {
    debugPrint('Error fetching permitted DocTypes: $e');
    // If it fails, we'll proceed with empty set, but for debugging 
    // we might want to see if they can access these doctypes if we show them
  }

  // DEBUG FALLBACK: If we couldn't get the list (e.g. 403 on DocType), 
  // but the user is logged in, they likely have some permissions.
  // If allowedDoctypes is empty, it means either they really have no permissions
  // OR the check itself was blocked.
  bool bypassFilter = allowedDoctypes.isEmpty;
  if (bypassFilter) {
    debugPrint('DEBUG: allowedDoctypes is empty, showing all modules as fallback for testing');
  }

  debugPrint('Allowed DocTypes Sample: ${allowedDoctypes.take(5).toList()}');

  // Step 3: Filter module list based on allowed doctypes
  List<ModuleItem> filteredModules = [];
  debugPrint('Filtering appModules against ${allowedDoctypes.length} allowed doctypes');
  
  for (var module in appModules) {
    if (module.subItems != null) {
      // Filter sub-items to only those the user has access to
      final filteredSubs = module.subItems!
          .where((s) {
            final has = bypassFilter || s.doctype == null || allowedDoctypes.contains(s.doctype);
            return has;
          })
          .toList();

      // Only show the parent module if at least one sub-item is accessible
      if (filteredSubs.isNotEmpty) {
        filteredModules.add(
          ModuleItem(
            label: module.label,
            icon: module.icon,
            doctype: module.doctype,
            route: module.route,
            subItems: filteredSubs,
          ),
        );
      }
    } else {
      // Standalone module item - check directly
      if (bypassFilter || module.doctype == null || allowedDoctypes.contains(module.doctype)) {
        filteredModules.add(module);
      }
    }
  }

  debugPrint('Filtered modules count: ${filteredModules.length}');
  return filteredModules;
});
