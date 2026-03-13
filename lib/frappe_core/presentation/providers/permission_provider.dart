import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_permissions.dart';
import '../../data/providers/frappe_provider.dart';

// Provider that fetches permissions and caches them based on doctype name
final userPermissionsProvider = FutureProvider.family<UserPermissions, String>((
  ref,
  doctype,
) async {
  final frappeRepository = ref.watch(frappeRepositoryProvider);

  // Call frappe client to get doc permissions
  // callMethod already unwraps 'message', so res is the permissions map directly
  final res = await frappeRepository.callMethod(
    'frappe.client.get_doc_permissions',
    queryParameters: {'doctype': doctype},
  );

  // res is already the unwrapped permissions map (e.g., {read: 1, write: 1, ...})
  if (res is Map<String, dynamic>) {
    return UserPermissions.fromJson(res);
  }
  // Fallback: return no permissions if response is unexpected
  return const UserPermissions();
});
