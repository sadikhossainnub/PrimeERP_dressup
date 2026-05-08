import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA), // Softer background
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardTotalSalesProvider);
          ref.invalidate(dashboardPurchaseOrdersProvider);
          ref.invalidate(dashboardStockAlertsProvider);
          ref.invalidate(dashboardPendingPaymentsProvider);
          ref.invalidate(dashboardMonthlySalesProvider);
          ref.invalidate(dashboardInventoryStatusProvider);
          ref.invalidate(dashboardRecentTransactionsProvider);
          ref.invalidate(currentUserProfileProvider);
          ref.invalidate(dashboardPendingLeavesProvider);
          ref.invalidate(dashboardPendingStockEntriesProvider);
          ref.invalidate(dashboardOverdueInvoicesProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSliverHeader(context, ref),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildNeedsAttention(context, ref),
                  const SizedBox(height: 24),
                  _buildModuleHub(context),
                  const SizedBox(height: 24),
                  _buildSummaryGrid(context, ref),
                  const SizedBox(height: 24),
                  _buildMonthlySalesChart(context, ref),
                  const SizedBox(height: 24),
                  _buildInventoryStatusChart(context, ref),
                  const SizedBox(height: 24),
                  _buildRecentTransactions(context, ref),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return SliverAppBar(
      expandedHeight: 140.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E2A38), Color(0xFF2C3E50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        userAsync.when(
                          data: (user) {
                            final firstName = user['first_name'] ?? 'User';
                            return Text(
                              firstName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                          loading: () => const Text(
                            'Loading...',
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                          error: (_, _) => const Text(
                            'User',
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_none, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      userAsync.when(
                        data: (user) => UserAvatar(
                          userImage: user['user_image'] as String?,
                          baseUrl: user['_base_url'] as String?,
                          firstName: user['first_name'] as String?,
                          lastName: user['last_name'] as String?,
                          radius: 22,
                        ),
                        loading: () => const CircleAvatar(radius: 22, backgroundColor: Colors.grey),
                        error: (_, _) => const CircleAvatar(radius: 22, backgroundColor: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeedsAttention(BuildContext context, WidgetRef ref) {
    final leavesAsync = ref.watch(dashboardPendingLeavesProvider);
    final stockAsync = ref.watch(dashboardPendingStockEntriesProvider);
    final invoiceAsync = ref.watch(dashboardOverdueInvoicesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Needs Attention',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildAttentionCard(
                context,
                title: 'Pending Leaves',
                valueAsync: leavesAsync,
                icon: Icons.event_busy,
                color: const Color(0xFFF59E0B), // Amber
                onTap: () => context.push('/hr/leaves'), // Make sure this route matches if needed
              ),
              _buildAttentionCard(
                context,
                title: 'Draft Stock Entries',
                valueAsync: stockAsync,
                icon: Icons.inventory_2_outlined,
                color: const Color(0xFF3B82F6), // Blue
                onTap: () => context.push('/inventory/stock-entries'),
              ),
              _buildAttentionCard(
                context,
                title: 'Overdue Invoices',
                valueAsync: invoiceAsync,
                icon: Icons.receipt_long,
                color: const Color(0xFFEF4444), // Red
                onTap: () => context.push('/sales/invoices'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttentionCard(
    BuildContext context, {
    required String title,
    required AsyncValue<int> valueAsync,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return valueAsync.when(
      data: (val) {
        if (val == 0) return const SizedBox.shrink(); // Hide if nothing to attend to
        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        val.toString(),
                        style: TextStyle(color: color, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildModuleHub(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Modules',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38)),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildModuleIcon(context, 'Sales', Icons.point_of_sale, const Color(0xFF10B981), '/sales'),
            _buildModuleIcon(context, 'Purchase', Icons.shopping_basket, const Color(0xFF3B82F6), '/purchase'),
            _buildModuleIcon(context, 'Inventory', Icons.inventory, const Color(0xFF8B5CF6), '/inventory'),
            _buildModuleIcon(context, 'HR & Payroll', Icons.people, const Color(0xFFF59E0B), '/hr'),
          ],
        ),
      ],
    );
  }

  Widget _buildModuleIcon(BuildContext context, String title, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(dashboardTotalSalesProvider);
    final purchaseOrders = ref.watch(dashboardPurchaseOrdersProvider);
    final stockAlerts = ref.watch(dashboardStockAlertsProvider);
    final pendingPayments = ref.watch(dashboardPendingPaymentsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38)),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            _buildGlassStatCard(
              title: 'Sales Today',
              valueAsync: sales,
              format: (v) => 'TK. ${v is double ? v.toStringAsFixed(0) : v}',
              icon: Icons.trending_up,
              color: const Color(0xFF10B981),
            ),
            _buildGlassStatCard(
              title: 'Purchase Orders',
              valueAsync: purchaseOrders,
              format: (v) => 'TK. ${v is double ? v.toStringAsFixed(0) : v}',
              icon: Icons.shopping_cart,
              color: const Color(0xFF3B82F6),
            ),
            _buildGlassStatCard(
              title: 'Stock Alerts',
              valueAsync: stockAlerts,
              format: (v) => '$v Items',
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFEF4444),
            ),
            _buildGlassStatCard(
              title: 'Pending Payments',
              valueAsync: pendingPayments,
              format: (v) => 'TK. ${v is double ? v.toStringAsFixed(0) : v}',
              icon: Icons.account_balance_wallet,
              color: const Color(0xFFF59E0B),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassStatCard({
    required String title,
    required AsyncValue<dynamic> valueAsync,
    required String Function(dynamic) format,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              valueAsync.when(
                data: (data) => Text(
                  format(data),
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                loading: () => const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (err, stackTrace) => const Text('Error', style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySalesChart(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(dashboardMonthlySalesProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Sales',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E2A38)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: salesAsync.when(
              data: (data) {
                if (data.isEmpty) return const Center(child: Text('No data'));
                double maxVal = 0;
                for (var el in data) {
                  if (el.total > maxVal) maxVal = el.total;
                }
                if (maxVal == 0) maxVal = 1000;

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxVal * 1.2,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            'TK. ${rod.toY.toStringAsFixed(0)}',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= data.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                data[value.toInt()].month,
                                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const Text('0', style: TextStyle(color: Color(0xFF6B7280), fontSize: 10));
                            if (value >= 1000) return Text('${(value / 1000).toInt()}k', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10));
                            return Text(value.toInt().toString(), style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10));
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxVal > 0 ? maxVal / 2 : 1000,
                      getDrawingHorizontalLine: (value) => const FlLine(color: Color(0xFFF3F4F6), strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: data.asMap().entries.map((e) {
                      return BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value.total,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stackTrace) => const Center(child: Text('Error loading chart')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryStatusChart(BuildContext context, WidgetRef ref) {
    final invAsync = ref.watch(dashboardInventoryStatusProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory Status',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E2A38)),
          ),
          const SizedBox(height: 24),
          invAsync.when(
            data: (data) {
              return Row(
                children: [
                  SizedBox(
                    height: 140,
                    width: 140,
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 45,
                            sections: data.map((e) {
                              return PieChartSectionData(
                                color: Color(e.colorHex),
                                value: e.percentage,
                                title: '',
                                radius: 25,
                              );
                            }).toList(),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${data.isNotEmpty ? data[0].percentage.toInt() : 0}%',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF1E2A38)),
                              ),
                              const Text(
                                'In Stock',
                                style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: data.map((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(color: Color(e.colorHex), borderRadius: BorderRadius.circular(4)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        e.title,
                                        style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF4B5563), fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'TK. ${e.value.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E2A38), fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Center(child: Text('Error loading inventory status')),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(dashboardRecentTransactionsProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E2A38)),
              ),
              Text(
                'View All',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          txAsync.when(
            data: (data) {
              if (data.isEmpty) return const Text('No recent transactions');

              const mockColors = [0xFF10B981, 0xFF9CA3AF, 0xFF3B82F6, 0xFFF59E0B];
              const mockStatuses = ['Approved', 'Draft', 'Pending', 'Submitted'];
              const mockTitles = ['Office Supplies', 'Supplier Invoice', 'Customer Payment', 'Service Fee'];

              return Column(
                children: List.generate(data.length > 4 ? 4 : data.length, (index) {
                  final item = data[index];
                  final amount = (item['paid_amount'] as num?)?.toDouble() ?? 500.0;
                  final statusText = mockStatuses[index % mockStatuses.length];
                  final statusColor = Color(mockColors[index % mockColors.length]);
                  final title = mockTitles[index % mockTitles.length];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.receipt, color: statusColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1F2937), fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                statusText,
                                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'TK. ${amount.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E2A38), fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Center(child: Text('Error loading transactions')),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E2A38)),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionBtn('New Sale', Icons.point_of_sale, const Color(0xFF10B981), onPressed: () => context.push('/resource/Sales Invoice/new')),
            _buildActionBtn('Purchase', Icons.shopping_bag, const Color(0xFF3B82F6), onPressed: () => context.push('/resource/Purchase Order/new')),
            _buildActionBtn('Stock Entry', Icons.inventory_2, const Color(0xFF8B5CF6), onPressed: () => context.push('/resource/Stock Entry/new')),
            _buildActionBtn('Reports', Icons.analytics, const Color(0xFFF59E0B), onPressed: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildActionBtn(String title, IconData icon, Color color, {required VoidCallback onPressed}) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
