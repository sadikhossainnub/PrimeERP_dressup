import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_permissions.freezed.dart';

@freezed
class UserPermissions with _$UserPermissions {
  const UserPermissions._();

  const factory UserPermissions({
    @Default(false) bool canRead,
    @Default(false) bool canWrite,
    @Default(false) bool canCreate,
    @Default(false) bool canDelete,
    @Default(false) bool canSubmit,
    @Default(false) bool canAmend,
    @Default(false) bool canCancel,
  }) = _UserPermissions;

  factory UserPermissions.fromJson(Map<String, dynamic> json) {
    // Determine the permissions map - handle both nested {'message': {...}}
    // and flat {read: 1, write: 1, ...} formats
    final Map<String, dynamic> p;
    if (json.containsKey('message') &&
        json['message'] is Map<String, dynamic>) {
      p = json['message'] as Map<String, dynamic>;
    } else {
      p = json;
    }

    return UserPermissions(
      canRead: (p['read'] == 1) || (p['read'] == true),
      canWrite: (p['write'] == 1) || (p['write'] == true),
      canCreate: (p['create'] == 1) || (p['create'] == true),
      canDelete: (p['delete'] == 1) || (p['delete'] == true),
      canSubmit: (p['submit'] == 1) || (p['submit'] == true),
      canAmend: (p['amend'] == 1) || (p['amend'] == true),
      canCancel: (p['cancel'] == 1) || (p['cancel'] == true),
    );
  }
}
