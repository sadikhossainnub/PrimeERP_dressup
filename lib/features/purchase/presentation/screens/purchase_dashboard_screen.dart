import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/purchase_provider.dart';
import '../widgets/purchase_status_badge.dart';

class PurchaseDashboardScreen extends ConsumerWidget {
  const PurchaseDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(purchaseDashboardSummaryProvider);
            ref.invalidate(purchaseMonthlyTrendProvider);
            ref.invalidate(purchaseBySupplierProvider);
            ref.invalidate(recentPurchaseOrdersProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ─── Header ───
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E2A38), Color(0xFF2D3B4E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Purchase',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          _buildHeaderAction(
                            Icons.filter_list_rounded,
                            'Filter',
                            () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Overview & Analytics',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Body ───
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildKpiGrid(ref),
                    const SizedBox(height: 20),
                    _buildMonthlyTrendChart(ref),
                    const SizedBox(height: 20),
                    _buildTopSuppliersChart(ref),
                    const SizedBox(height: 20),
                    _buildRecentPurchaseOrders(context, ref),
                    const SizedBox(height: 20),
                    _buildQuickActions(context),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── KPI Summary Grid ───

  Widget _buildKpiGrid(WidgetRef ref) {
    final summaryAsync = ref.watch(purchaseDashboardSummaryProvider);

    return summaryAsync.when(
      data: (summary) => GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.6,
        children: [
          _buildKpiCard(
            title: 'Purchase Orders',
            value: '${summary.totalPurchaseOrders}',
            subtitle: 'This month',
            icon: Icons.description_outlined,
            color: const Color(0xFF3B82F6),
          ),
          _buildKpiCard(
            title: 'Pending Approval',
            value: '${summary.pendingApproval}',
            subtitle: 'Drafts',
            icon: Icons.pending_actions,
            color: const Color(0xFFF59E0B),
          ),
          _buildKpiCard(
            title: 'Total Value',
            value:
                'TK. ${NumberFormat.compact().format(summary.totalPurchaseValue)}',
            subtitle: 'This month',
            icon: Icons.account_balance_wallet_outlined,
            color: const Color(0xFF10B981),
          ),
          _buildKpiCard(
            title: 'Overdue Invoices',
            value: '${summary.overdueInvoices}',
            subtitle: 'Unpaid',
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFEF4444),
          ),
        ],
      ),
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const SizedBox(
        height: 200,
        child: Center(child: Text('Failed to load summary')),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Monthly Trend Chart ───

  Widget _buildMonthlyTrendChart(WidgetRef ref) {
    final trendAsync = ref.watch(purchaseMonthlyTrendProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Purchase Trend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: trendAsync.when(
              data: (data) {
                if (data.isEmpty) {
                  return const Center(child: Text('No data available'));
                }
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
                            'TK. ${NumberFormat.compact().format(rod.toY)}',
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
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
                            if (value.toInt() >= data.length) {
                              return const SizedBox();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
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
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const SizedBox();
                            return Text(
                              NumberFormat.compact().format(value),
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 11,
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
                      horizontalInterval: maxVal > 0 ? maxVal / 3 : 1000,
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
                            gradient: const LinearGradient(
                              colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            width: 20,
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
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  const Center(child: Text('Error loading chart')),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Top Suppliers Chart ───

  Widget _buildTopSuppliersChart(WidgetRef ref) {
    final suppliersAsync = ref.watch(purchaseBySupplierProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Suppliers',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 16),
          suppliersAsync.when(
            data: (data) {
              if (data.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('No supplier data')),
                );
              }

              final total = data.fold(0.0, (sum, e) => sum + e.total);

              return Row(
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 36,
                        sections: data.map((e) {
                          final pct = total > 0 ? (e.total / total) * 100 : 0;
                          return PieChartSectionData(
                            color: Color(e.colorHex),
                            value: pct.toDouble(),
                            title: '',
                            radius: 22,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: data.map((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
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
                                  e.supplier,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF374151),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'TK. ${NumberFormat.compact().format(e.total)}',
                                style: const TextStyle(
                                  fontSize: 13,
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
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                const Center(child: Text('Error loading suppliers')),
          ),
        ],
      ),
    );
  }

  // ─── Recent Purchase Orders ───

  Widget _buildRecentPurchaseOrders(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(recentPurchaseOrdersProvider);
    final formatter = NumberFormat('#,##0.00');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                'Recent Purchase Orders',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/purchase/orders'),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ordersAsync.when(
            data: (orders) {
              if (orders.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('No recent purchase orders')),
                );
              }

              return Column(
                children: orders.take(5).map((po) {
                  final name = po['name']?.toString() ?? '';
                  final supplier =
                      po['supplier_name']?.toString() ?? po['supplier']?.toString() ?? '';
                  final total =
                      ((po['grand_total'] ?? 0) as num).toDouble();
                  final status = po['status']?.toString() ?? 'Draft';
                  final date = po['transaction_date']?.toString() ?? '';

                  return InkWell(
                    onTap: () => context.push('/purchase/orders/$name'),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  supplier,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (date.isNotEmpty)
                                  Text(
                                    DateFormat.yMMMd().format(
                                        DateTime.tryParse(date) ??
                                            DateTime.now()),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'TK. ${formatter.format(total)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E2A38),
                                ),
                              ),
                              const SizedBox(height: 4),
                              PurchaseStatusBadge(
                                status: status,
                                fontSize: 10,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                const Center(child: Text('Error loading orders')),
          ),
        ],
      ),
    );
  }

  // ─── Quick Actions ───

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildActionButton(
              context,
              icon: Icons.add_shopping_cart,
              label: 'New PO',
              color: const Color(0xFF3B82F6),
              onTap: () => context.push('/resource/Purchase Order/new'),
            ),
            const SizedBox(width: 10),
            _buildActionButton(
              context,
              icon: Icons.receipt_long_outlined,
              label: 'New Invoice',
              color: const Color(0xFF10B981),
              onTap: () => context.push('/resource/Purchase Invoice/new'),
            ),
            const SizedBox(width: 10),
            _buildActionButton(
              context,
              icon: Icons.people_outline,
              label: 'Suppliers',
              color: const Color(0xFF8B5CF6),
              onTap: () => context.push('/purchase/suppliers'),
            ),
            const SizedBox(width: 10),
            _buildActionButton(
              context,
              icon: Icons.list_alt_outlined,
              label: 'Invoices',
              color: const Color(0xFFF59E0B),
              onTap: () => context.push('/purchase/invoices'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
