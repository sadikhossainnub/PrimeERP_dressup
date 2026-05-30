import 'package:freezed_annotation/freezed_annotation.dart';

part 'frappe_user_model.freezed.dart';
part 'frappe_user_model.g.dart';

@freezed
class FrappeUserModel with _$FrappeUserModel {
  const FrappeUserModel._();

  const factory FrappeUserModel({
    required String name,
    required String fullName,
    required String userType,
    String? userImage,
    @Default([]) List<String> roles,
  }) = _FrappeUserModel;

  factory FrappeUserModel.fromJson(Map<String, dynamic> json) {
    // Handle Frappe response: json['message'] contains the actual data
    final data = json['message'] is Map ? json['message'] as Map<String, dynamic> : json;

    // Parse roles from: [{"role": "Sales User"}, {"role": "System Manager"}]
    final rawRoles = data['roles'] as List? ?? [];
    final roles = rawRoles
        .whereType<Map>()
        .map((r) => r['role']?.toString() ?? '')
        .where((r) => r.isNotEmpty)
        .toList();

    return FrappeUserModel(
      name: data['name']?.toString() ?? '',
      fullName: data['full_name']?.toString() ?? '',
      userType: data['user_type']?.toString() ?? 'System User',
      userImage: data['user_image']?.toString(),
      roles: roles,
    );
  }

  @override
  Map<String, dynamic> toJson() => _$FrappeUserModelToJson(this);
}
