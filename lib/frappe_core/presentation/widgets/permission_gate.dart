import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/permission_provider.dart';
import '../providers/user_role_provider.dart';

/// A widget that conditionally shows/hides its child based on permission checks.
///
/// Supports:
/// 1. **Doctype + Action checks**: Checks frappe doctype permissions
///    ```dart
///    PermissionGate(
///      doctype: 'Sales Invoice',
///      action: 'create',
///      child: FloatingActionButton(...),
///    )
///    ```
///
/// 2. **Role-based checks**: Checks if user has any of the specified roles
///    ```dart
///    PermissionGate(
///      roles: ['Sales Manager', 'System Manager'],
///      child: DiscountField(),
///    )
///    ```
///
/// 3. **Combined checks**: Both conditions with OR logic
///
/// **Permission hierarchy (Frappe v15 source-verified):**
/// 1. Administrator/System Manager → bypass all checks, show child
/// 2. Role-based permissions → check userRolesProvider
/// 3. Doctype permissions → check doctypePermissionProvider
///
/// While loading or on error: hides child by default (fail-safe deny)
class PermissionGate extends ConsumerWidget {
  /// The doctype to check permission for (optional)
  final String? doctype;

  /// The permission action to check.
  /// Valid values: 'read', 'write', 'create', 'delete', 'submit', 'cancel',
  /// 'amend', 'print', 'export', 'email', 'report', 'share'
  final String? action;

  /// List of roles to check if user has any of them (optional)
  final List<String>? roles;

  /// The widget to show if permission is granted
  final Widget child;

  /// The widget to show if permission is denied (default: SizedBox.shrink())
  final Widget? fallback;

  /// Show loading indicator while checking permissions (default: false)
  /// If false, hides content silently while loading
  final bool showLoading;

  const PermissionGate({
    super.key,
    this.doctype,
    this.action,
    this.roles,
    required this.child,
    this.fallback,
    this.showLoading = false,
  }) : assert(
    doctype != null || roles != null,
    'Either doctype or roles must be provided',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Step 1: Check System Manager status first (Frappe v15 priority)
    final isAdminAsync = ref.watch(isSystemManagerProvider);

    return isAdminAsync.when(
      data: (isAdmin) {
        if (isAdmin) {
          // System Manager/Administrator → show child immediately
          return child;
        }

        // Step 2: Check role-based permissions if roles provided
        if (roles != null && roles!.isNotEmpty) {
          final userRolesAsync = ref.watch(userRolesProvider);

          return userRolesAsync.when(
            data: (userRoles) {
              if (userRoles.any((role) => roles!.contains(role))) {
                return child;
              }

              // No role match, check doctype permission if available
              if (doctype != null && action != null) {
                return _checkDoctypePermission(ref, context);
              }

              // No permissions granted
              return fallback ?? const SizedBox.shrink();
            },
            loading: () => showLoading
                ? const Center(child: CircularProgressIndicator())
                : (fallback ?? const SizedBox.shrink()),
            error: (e, st) {
              // On error, deny access (fail-safe)
              return fallback ?? const SizedBox.shrink();
            },
          );
        }

        // Step 3: Check doctype-based permissions
        if (doctype != null && action != null) {
          return _checkDoctypePermission(ref, context);
        }

        // No checks provided
        return fallback ?? const SizedBox.shrink();
      },
      loading: () => showLoading
          ? const Center(child: CircularProgressIndicator())
          : (fallback ?? const SizedBox.shrink()),
      error: (e, st) {
        // On error, deny access (fail-safe)
        return fallback ?? const SizedBox.shrink();
      },
    );
  }

  /// Check doctype permission for the specified action
  Widget _checkDoctypePermission(WidgetRef ref, BuildContext context) {
    final permAsync = ref.watch(doctypePermissionProvider(doctype!));

    return permAsync.when(
      data: (perm) {
        bool hasPermission = false;

        switch (action) {
          case 'read':
            hasPermission = perm.canRead;
            break;
          case 'write':
            hasPermission = perm.canWrite;
            break;
          case 'create':
            hasPermission = perm.canCreate;
            break;
          case 'delete':
            hasPermission = perm.canDelete;
            break;
          case 'submit':
            hasPermission = perm.canSubmit;
            break;
          case 'cancel':
            hasPermission = perm.canCancel;
            break;
          case 'amend':
            hasPermission = perm.canAmend;
            break;
          default:
            // Unknown action, deny by default
            hasPermission = false;
        }

        return hasPermission ? child : (fallback ?? const SizedBox.shrink());
      },
      loading: () => showLoading
          ? const Center(child: CircularProgressIndicator())
          : (fallback ?? const SizedBox.shrink()),
      error: (e, st) {
        // On error, deny access (fail-safe)
        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}
