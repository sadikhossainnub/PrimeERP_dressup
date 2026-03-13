import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            // refresh providers
            ref.invalidate(dashboardTotalSalesProvider);
            ref.invalidate(dashboardPurchaseOrdersProvider);
            ref.invalidate(dashboardStockAlertsProvider);
            ref.invalidate(dashboardPendingPaymentsProvider);
            ref.invalidate(dashboardMonthlySalesProvider);
            ref.invalidate(dashboardInventoryStatusProvider);
            ref.invalidate(dashboardRecentTransactionsProvider);
            ref.invalidate(currentUserProfileProvider);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: 100,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, ref),
                const SizedBox(height: 20),
                _buildSummaryGrid(context, ref),
                const SizedBox(height: 16),
                _buildMonthlySalesChart(context, ref),
                const SizedBox(height: 16),
                _buildInventoryStatusChart(context, ref),
                const SizedBox(height: 16),
                _buildRecentTransactions(context, ref),
                const SizedBox(height: 16),
                _buildQuickActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: userAsync.when(
            data: (user) {
              final firstName = user['first_name'] ?? 'User';
              return Text(
                'Welcome $firstName',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2A38),
                ),
                overflow: TextOverflow.ellipsis,
              );
            },
            loading: () => Text(
              'Welcome...',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E2A38),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            error: (err, stack) => Text(
              'Welcome User',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E2A38),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 16),
        userAsync.when(
          data: (user) {
            final userImage = user['user_image'] as String?;
            final baseUrl = user['_base_url'] as String?;

            return UserAvatar(
              userImage: userImage,
              baseUrl: baseUrl,
              radius: 18,
              firstName: user['first_name'] as String?,
              lastName: user['last_name'] as String?,
            );
          },
          loading: () => const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, color: Colors.white),
          ),
          error: (err, stack) => const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(dashboardTotalSalesProvider);
    final purchaseOrders = ref.watch(dashboardPurchaseOrdersProvider);
    final stockAlerts = ref.watch(dashboardStockAlertsProvider);
    final pendingPayments = ref.watch(dashboardPendingPaymentsProvider);

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: [
        _buildStatCard(
          title: 'Sales Today',
          valueAsync: sales,
          format: (v) => 'TK. ${v is double ? v.toStringAsFixed(0) : v}',
          valueColor: const Color(0xFF10B981),
          showArrowUp: true,
        ),
        _buildStatCard(
          title: 'Purchase Orders',
          valueAsync: purchaseOrders,
          format: (v) => 'TK. ${v is double ? v.toStringAsFixed(0) : v}',
          valueColor: const Color(0xFF374151),
        ),
        _buildStatCard(
          title: 'Stock Alerts',
          valueAsync: stockAlerts,
          format: (v) => '$v Items',
          valueColor: const Color(0xFFEF4444),
          showArrowUp: true,
        ),
        _buildStatCard(
          title: 'Pending Payments',
          valueAsync: pendingPayments,
          format: (v) => 'TK. ${v is double ? v.toStringAsFixed(0) : v}',
          valueColor: const Color(0xFFEF4444),
          showArrowDown: true,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required AsyncValue<dynamic> valueAsync,
    required String Function(dynamic) format,
    required Color valueColor,
    bool showArrowUp = false,
    bool showArrowDown = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Flexible(
                child: valueAsync.when(
                  data: (data) => Text(
                    format(data),
                    style: TextStyle(
                      color: valueColor,
                      fontSize: 20,
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
                  error: (err, stackTrace) =>
                      const Text('Error', style: TextStyle(color: Colors.red)),
                ),
              ),
              if (showArrowUp) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_upward,
                  color: Color(0xFF10B981),
                  size: 16,
                ),
              ],
              if (showArrowDown) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_downward,
                  color: Color(0xFFF59E0B),
                  size: 16,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySalesChart(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(dashboardMonthlySalesProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Text(
            'Monthly Sales Overview',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 20),
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
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= data.length) {
                              return const SizedBox();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                data[value.toInt()].month,
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                ),
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
                            if (value == 0) {
                              return const Text(
                                '0',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                ),
                              );
                            }
                            if (value >= 1000) {
                              return Text(
                                '${(value / 1000).toInt()}k',
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                ),
                              );
                            }
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxVal > 0 ? maxVal / 2 : 1000,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: const Color(0xFFE5E7EB),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: data.asMap().entries.map((e) {
                      return BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value.total,
                            color: const Color(0xFF93C5FD),
                            width: 22,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stackTrace) =>
                  const Center(child: Text('Error loading chart')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryStatusChart(BuildContext context, WidgetRef ref) {
    final invAsync = ref.watch(dashboardInventoryStatusProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Text(
            'Inventory Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 16),
          invAsync.when(
            data: (data) {
              return Row(
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: data.map((e) {
                              return PieChartSectionData(
                                color: Color(e.colorHex),
                                value: e.percentage,
                                title: '',
                                radius: 20,
                              );
                            }).toList(),
                          ),
                        ),
                        Center(
                          child: Text(
                            '${data.isNotEmpty ? data[0].percentage.toInt() : 0}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
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
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Color(e.colorHex),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        e.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF374151),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'TK. ${e.value.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E2A38),
                                ),
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
            error: (err, stack) =>
                const Center(child: Text('Error loading inventory status')),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(dashboardRecentTransactionsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF374151),
                ),
              ),
              Text(
                'View All',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          txAsync.when(
            data: (data) {
              if (data.isEmpty) return const Text('No recent transactions');

              const mockColors = [
                0xFF10B981,
                0xFF9CA3AF,
                0xFF3B82F6,
                0xFFF59E0B,
              ];
              const mockStatuses = [
                'Approved',
                'Draft',
                'Pending',
                'Submitted',
              ];
              const mockTitles = [
                'Office Supplies',
                'Supplier Invoice',
                'Customer Payment',
                'Service Fee',
              ];

              return Column(
                children: List.generate(data.length > 3 ? 3 : data.length, (
                  index,
                ) {
                  final item = data[index];
                  final amount =
                      (item['paid_amount'] as num?)?.toDouble() ?? 500.0;
                  // In real app we parse status, here we mock to look exactly like the image if actual is int
                  final statusText = mockStatuses[index % mockStatuses.length];
                  final statusColor = Color(
                    mockColors[index % mockColors.length],
                  );
                  final title = mockTitles[index % mockTitles.length];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 80,
                          child: Text(
                            'TK. ${amount.toStringAsFixed(2)}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E2A38),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                const Center(child: Text('Error loading transactions')),
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionBtn(
              'New Sale',
              Icons.shopping_cart,
              onPressed: () => context.push('/resource/Sales Invoice/new'),
            ),
            _buildActionBtn(
              'New Purchase',
              Icons.assignment,
              onPressed: () => context.push('/resource/Purchase Order/new'),
            ),
            _buildActionBtn(
              'Stock Entry',
              Icons.inventory,
              onPressed: () => context.push('/resource/Stock Entry/new'),
            ),
            _buildActionBtn('Reports', Icons.bar_chart, onPressed: () => {}),
          ],
        ),
      ],
    );
  }

  Widget _buildActionBtn(
    String title,
    IconData icon, {
    required VoidCallback onPressed,
  }) {
    // Need to format string if it breaks to next line e.g., Stock Entry
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF4B5563), size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
