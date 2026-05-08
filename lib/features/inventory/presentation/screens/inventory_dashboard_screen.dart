import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_provider.dart';

class InventoryDashboardScreen extends ConsumerStatefulWidget {
  const InventoryDashboardScreen({super.key});

  @override
  ConsumerState<InventoryDashboardScreen> createState() => _InventoryDashboardScreenState();
}

class _InventoryDashboardScreenState extends ConsumerState<InventoryDashboardScreen> {
  final formatter = NumberFormat('#,##0.00');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        title: const Text('Inventory Dashboard'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(inventorySummaryProvider);
          ref.invalidate(warehouseValueProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildKPIs(context, ref),
              const SizedBox(height: 20),
              _buildWarehouseChart(context, ref),
              const SizedBox(height: 20),
              _buildQuickActions(context),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPIs(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(inventorySummaryProvider);
    return summaryAsync.when(
      data: (summary) => Column(
        children: [
          Row(
            children: [
              Expanded(child: _kpiCard('Total Items', summary.totalItems.toString(), Icons.inventory_2_outlined, const Color(0xFF3B82F6))),
              const SizedBox(width: 12),
              Expanded(child: _kpiCard('Low Stock', summary.lowStockItems.toString(), Icons.warning_amber_outlined, const Color(0xFFEF4444))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _kpiCard('Total Value', 'TK ${formatter.format(summary.totalValue)}', Icons.monetization_on_outlined, const Color(0xFF10B981))),
              const SizedBox(width: 12),
              Expanded(child: _kpiCard('Pending Entries', summary.pendingStockEntries.toString(), Icons.sync_alt_outlined, const Color(0xFFF59E0B))),
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

  Widget _buildWarehouseChart(BuildContext context, WidgetRef ref) {
    final whAsync = ref.watch(warehouseValueProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Stock Value by Warehouse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38))),
          const SizedBox(height: 20),
          whAsync.when(
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
                          value: e.value,
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
                            Expanded(child: Text(e.warehouse, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)), maxLines: 1, overflow: TextOverflow.ellipsis)),
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
              _actionBtn('Items', Icons.category_outlined, () => context.push('/inventory/items')),
              _actionBtn('Stock Entry', Icons.sync_alt_outlined, () => context.push('/inventory/stock-entries')),
              _actionBtn('Warehouses', Icons.warehouse_outlined, () => context.push('/inventory/warehouses')),
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
}
