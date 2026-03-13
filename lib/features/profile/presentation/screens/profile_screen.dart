import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0.5,
      ),
      body: userAsync.when(
        data: (user) {
          final firstName = user['first_name'] ?? 'User';
          final lastName = user['last_name'] ?? '';
          final email = user['email'] ?? user['name'] ?? '';
          final phone = user['mobile_no'] ?? user['phone'] ?? 'N/A';
          final bio = user['bio'] ?? 'No bio provided.';
          final gender = user['gender'] ?? 'Not Specified';
          final userImage = user['user_image'] as String?;
          final baseUrl = user['_base_url'] as String?;

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh the provider to re-fetch data from ERPNext
              ref.invalidate(currentUserProfileProvider);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 24.0,
                bottom: 100.0,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  UserAvatar(
                    userImage: userImage,
                    baseUrl: baseUrl,
                    radius: 50,
                    firstName: firstName,
                    lastName: lastName,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$firstName $lastName'.trim(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E2A38),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildInfoCard(
                    context,
                    title: 'Personal Information',
                    items: [
                      _InfoItem(
                        Icons.phone_outlined,
                        'Phone',
                        phone.toString(),
                      ),
                      _InfoItem(
                        Icons.email_outlined,
                        'Email',
                        email.toString(),
                      ),
                      _InfoItem(
                        Icons.person_outline,
                        'Gender',
                        gender.toString(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    title: 'About',
                    items: [
                      _InfoItem(
                        Icons.info_outline,
                        'Bio',
                        bio.toString(),
                        isMultline: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            const Center(child: Text('Failed to load profile details')),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<_InfoItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 8,
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
          ),
          const Divider(height: 1),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: item.isMultline
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Icon(item.icon, size: 20, color: const Color(0xFF9CA3AF)),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 80,
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1F2937),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final bool isMultline;

  _InfoItem(this.icon, this.label, this.value, {this.isMultline = false});
}
