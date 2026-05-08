import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/sales_provider.dart';
import '../widgets/sales_status_badge.dart';

class SalesDashboardScreen extends ConsumerStatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  ConsumerState<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends ConsumerState<SalesDashboardScreen> {
  final formatter = NumberFormat('#,##0.00');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        title: const Text('Sales Dashboard'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(salesDashboardSummaryProvider);
          ref.invalidate(salesMonthlyTrendProvider);
          ref.invalidate(salesByCustomerProvider);
          ref.invalidate(recentSalesOrdersProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildKPIs(context, ref),
              const SizedBox(height: 20),
              _buildMonthlyTrend(context, ref),
              const SizedBox(height: 20),
              _buildTopCustomers(context, ref),
              const SizedBox(height: 20),
              _buildQuickActions(context),
              const SizedBox(height: 20),
              _buildRecentOrders(context, ref),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPIs(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(salesDashboardSummaryProvider);
    return summaryAsync.when(
      data: (summary) => Column(
        children: [
          Row(
            children: [
              Expanded(child: _kpiCard('Sales Orders', summary.totalSalesOrders.toString(), Icons.assignment_outlined, const Color(0xFF3B82F6))),
              const SizedBox(width: 12),
              Expanded(child: _kpiCard('Pending Delivery', summary.pendingDelivery.toString(), Icons.local_shipping_outlined, const Color(0xFFF59E0B))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _kpiCard('Total Revenue', 'TK ${formatter.format(summary.totalRevenue)}', Icons.monetization_on_outlined, const Color(0xFF10B981))),
              const SizedBox(width: 12),
              Expanded(child: _kpiCard('Overdue', summary.overdueReceivables.toString(), Icons.warning_amber_outlined, const Color(0xFFEF4444))),
            ],
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const SizedBox(),
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38)), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrend(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(salesMonthlyTrendProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Revenue Trend (6 Months)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38))),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: trendAsync.when(
              data: (data) {
                if (data.isEmpty) return const Center(child: Text('No data'));
                double maxY = data.fold(0.0, (m, e) => e.total > m ? e.total : m);
                if (maxY == 0) maxY = 100;
                
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY * 1.2,
                    barTouchData: BarTouchData(enabled: true, touchTooltipData: BarTouchTooltipData(getTooltipColor: (_) => const Color(0xFF1E2A38), getTooltipItem: (group, _, rod, _) => BarTooltipItem(formatter.format(rod.toY), const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Padding(padding: const EdgeInsets.only(top: 8), child: Text(data[v.toInt()].month, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10))))),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY / 4, getDrawingHorizontalLine: (v) => FlLine(color: const Color(0xFFF3F4F6), strokeWidth: 1)),
                    barGroups: data.asMap().entries.map((e) => BarChartGroupData(
                      x: e.key,
                      barRods: [BarChartRodData(toY: e.value.total, color: const Color(0xFF3B82F6), width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))],
                    )).toList(),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCustomers(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(salesByCustomerProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Customers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38))),
          const SizedBox(height: 20),
          customersAsync.when(
            data: (data) {
              if (data.isEmpty) return const Center(child: Text('No data'));
              return Row(
                children: [
                  SizedBox(
                    height: 140,
                    width: 140,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: data.map((e) => PieChartSectionData(
                          color: Color(e.colorHex),
                          value: e.total,
                          title: '',
                          radius: 20,
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: data.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(width: 10, height: 10, decoration: BoxDecoration(color: Color(e.colorHex), shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(e.customer, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Links', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _actionBtn('Orders', Icons.description_outlined, () => context.push('/sales/orders')),
              _actionBtn('Invoices', Icons.receipt_long_outlined, () => context.push('/sales/invoices')),
              _actionBtn('Customers', Icons.people_outline, () => context.push('/sales/customers')),
              _actionBtn('Quotation', Icons.request_quote_outlined, () => context.push('/resource/Quotation')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF4B5563)),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF4B5563))),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentSalesOrdersProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38))),
              TextButton(onPressed: () => context.push('/sales/orders'), style: TextButton.styleFrom(visualDensity: VisualDensity.compact), child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 8),
          recentAsync.when(
            data: (orders) {
              if (orders.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Center(child: Text('No recent orders')));
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFE5E7EB)),
                itemBuilder: (context, index) {
                  final doc = orders[index];
                  final name = doc['name']?.toString() ?? '';
                  final cust = doc['customer_name']?.toString() ?? doc['customer']?.toString() ?? '';
                  final total = ((doc['grand_total'] ?? 0) as num).toDouble();
                  final status = doc['status']?.toString() ?? 'Draft';
                  final dateStr = doc['transaction_date']?.toString() ?? '';
                  String displayDate = dateStr;
                  if (dateStr.isNotEmpty) {
                    final dt = DateTime.tryParse(dateStr);
                    if (dt != null) displayDate = DateFormat.yMMMd().format(dt);
                  }

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () => context.push('/sales/orders/$name'),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                        SalesStatusBadge(status: status, fontSize: 10),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('$displayDate • $cust', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          Text('TK ${formatter.format(total)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E2A38))),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const SizedBox(),
          ),
        ],
      ),
    );
  }
}
