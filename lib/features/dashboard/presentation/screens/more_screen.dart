import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/module_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/module_permission_provider.dart';
import '../providers/dashboard_provider.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final modulesAsync = ref.watch(permittedModulesProvider);
    final userAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(permittedModulesProvider);
          ref.invalidate(currentUserProfileProvider);
        },
        child: CustomScrollView(
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
                      'More',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Additional tools and settings',
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
                  // ===== MODULE SECTIONS =====
                  modulesAsync.when(
                    data: (modules) {
                      if (modules.isEmpty) {
                        return _buildCard(
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'No modules available for your role.',
                                style: TextStyle(color: Color(0xFF6B7280)),
                              ),
                            ),
                          ),
                        );
                      }
                      // Group modules into sections (each module is a section)
                      return Column(
                        children: modules.map((module) {
                          return _buildModuleSection(context, module, l10n);
                        }).toList(),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, stack) => _buildCard(
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Failed to load modules. Pull to retry.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== QUICK STATS =====
                  _buildQuickStats(ref),

                  const SizedBox(height: 16),

                  // ===== ACCOUNT CARD =====
                  _buildAccountCard(context, ref, userAsync, l10n),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- MODULE SECTION CARD ----------
  Widget _buildModuleSection(
    BuildContext context,
    ModuleItem module,
    AppLocalizations l10n,
  ) {
    final label = _getLocalizedModuleLabel(module, l10n);
    final items = module.subItems ?? [module];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            ...items.map((item) {
              return InkWell(
                onTap: () => _navigate(context, item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(item.icon, size: 20, color: const Color(0xFF6B7280)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  // ---------- QUICK STATS ----------
  Widget _buildQuickStats(WidgetRef ref) {
    final sales = ref.watch(dashboardTotalSalesProvider);
    final stockAlerts = ref.watch(dashboardStockAlertsProvider);
    final pendingPayments = ref.watch(dashboardPendingPaymentsProvider);
    final purchaseOrders = ref.watch(dashboardPurchaseOrdersProvider);

    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                  'Sales Today',
                  sales,
                  (v) => '৳${v is double ? v.toStringAsFixed(0) : v}',
                  const Color(0xFF2563EB),
                ),
                _buildStatItem(
                  'Purchases',
                  purchaseOrders,
                  (v) => '৳${v is double ? v.toStringAsFixed(0) : v}',
                  const Color(0xFF16A34A),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                  'Stock Alerts',
                  stockAlerts,
                  (v) => '$v',
                  const Color(0xFFEA580C),
                ),
                _buildStatItem(
                  'Pending Pay',
                  pendingPayments,
                  (v) => '৳${v is double ? v.toStringAsFixed(0) : v}',
                  const Color(0xFF9333EA),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    AsyncValue<dynamic> valueAsync,
    String Function(dynamic) format,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          valueAsync.when(
            data: (data) => Text(
              format(data),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            loading: () => const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (err, stack) =>
                const Text('--', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  // ---------- ACCOUNT CARD ----------
  Widget _buildAccountCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Map<String, dynamic>> userAsync,
    AppLocalizations l10n,
  ) {
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            userAsync.when(
              data: (user) {
                final firstName = user['first_name'] ?? 'User';
                final lastName = user['last_name'] ?? '';
                final fullName = '$firstName $lastName'.trim();
                final email = user['email'] ?? user['name'] ?? '';
                final userImage = user['user_image'] as String?;
                final baseUrl = user['_base_url'] as String?;

                return Row(
                  children: [
                    UserAvatar(
                      userImage: userImage,
                      baseUrl: baseUrl,
                      radius: 24,
                      firstName: firstName,
                      lastName: lastName,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email.toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Row(
                children: [
                  CircleAvatar(radius: 24, backgroundColor: Color(0xFFE5E7EB)),
                  SizedBox(width: 12),
                  Text(
                    'Loading...',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              error: (err, stack) => const Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFE5E7EB),
                    child: Icon(Icons.person),
                  ),
                  SizedBox(width: 12),
                  Text('User', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                },
                icon: const Icon(Icons.logout, size: 18),
                label: Text(l10n.logout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- HELPERS ----------
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
      child: ClipRRect(borderRadius: BorderRadius.circular(16), child: child),
    );
  }

  String _getLocalizedModuleLabel(ModuleItem module, AppLocalizations l10n) {
    switch (module.label) {
      case 'Sales':
        return l10n.sales;
      case 'Purchase':
        return l10n.purchase;
      case 'Inventory':
        return l10n.inventory;
      case 'Accounts':
        return l10n.accounts;
      case 'HR & Payroll':
        return l10n.hr;
      default:
        return module.label;
    }
  }

  void _navigate(BuildContext context, ModuleItem item) {
    if (item.doctype != null) {
      context.push('/resource/${item.doctype}');
    } else if (item.route != null) {
      context.push(item.route!);
    }
  }
}
