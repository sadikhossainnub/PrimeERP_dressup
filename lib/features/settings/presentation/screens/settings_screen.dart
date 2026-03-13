import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ---------- HEADER ----------
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 52,
                bottom: 20,
              ),
              decoration: BoxDecoration(color: AppTheme.primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configure your preferences',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------- BODY ----------
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: 100,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle('App Preferences'),
                _buildCard(
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.language,
                        iconColor: const Color(0xFF2563EB),
                        title: 'Language',
                        subtitle: 'English (US)',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.dark_mode,
                        iconColor: const Color(0xFF4F46E5),
                        title: 'Dark Mode',
                        subtitle: 'System Default',
                        onTap: () {},
                        trailing: Switch(
                          value: false,
                          onChanged: (val) {},
                          activeThumbColor: AppTheme.primaryColor,
                        ),
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.notifications_active,
                        iconColor: const Color(0xFFEA580C),
                        title: 'Notifications',
                        subtitle: 'Enabled',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.dns_outlined,
                        iconColor: const Color(0xFF0EA5E9),
                        title: 'Server Configuration',
                        subtitle: 'View connected server details',
                        onTap: () => _showServerConfigDialog(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Security'),
                _buildCard(
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.lock_outline,
                        iconColor: const Color(0xFFDC2626),
                        title: 'Change Password',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.fingerprint,
                        iconColor: const Color(0xFF0D9488),
                        title: 'Biometric Authentication',
                        onTap: () {},
                        trailing: Switch(
                          value: true,
                          onChanged: (val) {},
                          activeThumbColor: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('About'),
                _buildCard(
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.info_outline,
                        iconColor: const Color(0xFF6B7280),
                        title: 'App Version',
                        trailing: const Text(
                          '1.0.0',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: const Color(0xFF16A34A),
                        title: 'Privacy Policy',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.description_outlined,
                        iconColor: const Color(0xFF475569),
                        title: 'Terms of Service',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Log Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEE2E2),
                      foregroundColor: const Color(0xFFDC2626),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 48), // extra padding for bottom nav
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showServerConfigDialog(BuildContext context) async {
    const storage = FlutterSecureStorage();
    final baseUrl = await storage.read(key: AppConstants.keyBaseUrl) ?? 'Not Set';
    final apiKey = await storage.read(key: AppConstants.keyApiKey) ?? 'Not Set';
    final apiSecret = await storage.read(key: AppConstants.keyApiSecret) ?? 'Not Set';

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.dns_rounded, color: Color(0xFF475569), size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Server Configuration',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildReadOnlyField('Base URL', baseUrl, Icons.link),
              const SizedBox(height: 16),
              _buildReadOnlyField('API Key', apiKey, Icons.vpn_key_outlined),
              const SizedBox(height: 16),
              _buildReadOnlyField('API Secret', _maskSecret(apiSecret), Icons.lock_outline),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _maskSecret(String secret) {
    if (secret == 'Not Set') return secret;
    if (secret.length <= 4) return '****';
    return '${secret.substring(0, 2)}••••••••${secret.substring(secret.length - 2)}';
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 56, // indent to align with text
      color: Color(0xFFF3F4F6),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0xFF9CA3AF),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
