import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../frappe_core/presentation/providers/user_role_provider.dart';
import '../../../../core/constants/module_constants.dart';

/// Fetches the list of modules the current user has permission to access.
///
/// Uses Frappe v15 batch DocPerm fetch (Endpoint F) for efficient permission checks.
/// Permissions are additive across roles (OR logic).
/// System Manager → all modules visible.
final permittedModulesProvider = FutureProvider<List<ModuleItem>>((ref) async {
  // Step 1: Check if user is System Manager
  final isAdmin = await ref.watch(isSystemManagerProvider.future);
  if (isAdmin) {
    return appModules;
  }

  // Step 2: Fetch all doctype permissions in batch (one API call)
  final allPerms = await ref.watch(allDoctypePermissionsProvider.future);

  // Step 3: Filter modules based on read permission
  List<ModuleItem> filtered = [];

  for (final module in appModules) {
    if (module.subItems != null) {
      // Module with sub-items: show module if ANY sub-item is accessible
      final accessibleSubs = module.subItems!.where((item) {
        if (item.doctype == null) return true; // Dashboard items always show
        return allPerms[item.doctype]?.canRead ?? false;
      }).toList();

      if (accessibleSubs.isNotEmpty) {
        filtered.add(ModuleItem(
          label: module.label,
          icon: module.icon,
          route: module.route,
          doctype: module.doctype,
          subItems: accessibleSubs,
        ));
      }
    } else {
      // Standalone module: show if no doctype OR has read permission
      if (module.doctype == null || (allPerms[module.doctype]?.canRead ?? false)) {
        filtered.add(module);
      }
    }
  }

  debugPrint('Permitted modules: ${filtered.map((m) => m.label).toList()}');
  return filtered;
});
