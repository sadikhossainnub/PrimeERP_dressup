import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../providers/inventory_provider.dart';
import '../widgets/stock_level_indicator.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final String name;
  const ItemDetailScreen({super.key, required this.name});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final formatter = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docAsync = ref.watch(itemDetailProvider(widget.name));
    return docAsync.when(
      data: (doc) => _buildView(doc),
      loading: () => Scaffold(appBar: AppBar(title: Text(widget.name), backgroundColor: const Color(0xFF1E2A38), foregroundColor: Colors.white), body: const LoadingWidget()),
      error: (err, _) => Scaffold(appBar: AppBar(title: Text(widget.name), backgroundColor: const Color(0xFF1E2A38), foregroundColor: Colors.white), body: ErrorStateWidget(message: err.toString())),
    );
  }

  Widget _buildView(Map<String, dynamic> doc) {
    final itemName = doc['item_name']?.toString() ?? widget.name;
    final itemCode = doc['item_code']?.toString() ?? widget.name;
    final group = doc['item_group']?.toString() ?? 'Default';
    final uom = doc['stock_uom']?.toString() ?? 'Nos';
    final rate = ((doc['standard_rate'] ?? 0) as num).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        title: const Text('Item Detail'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () => context.push('/resource/Item/${widget.name}/edit')),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF1E2A38),
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 36),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(itemName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('$itemCode • $group', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF3B82F6),
              unselectedLabelColor: const Color(0xFF6B7280),
              indicatorColor: const Color(0xFF3B82F6),
              tabs: const [Tab(text: 'Details'), Tab(text: 'Warehouse Stock')],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(uom, rate, doc),
                _buildWarehouseStockTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(String uom, double rate, Map<String, dynamic> doc) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card([
          _row('Item Code', doc['item_code']?.toString() ?? ''),
          _row('Item Name', doc['item_name']?.toString() ?? ''),
          _row('Item Group', doc['item_group']?.toString() ?? ''),
          _row('Stock UOM', uom),
          _row('Standard Rate', 'TK ${formatter.format(rate)}'),
          _row('Valuation Method', doc['valuation_method']?.toString() ?? 'FIFO'),
        ]),
        const SizedBox(height: 16),
        _card([
          _row('Is Stock Item', ((doc['is_stock_item'] as num?)?.toInt() == 1) ? 'Yes' : 'No'),
          _row('Has Variants', ((doc['has_variants'] as num?)?.toInt() == 1) ? 'Yes' : 'No'),
          _row('Disabled', ((doc['disabled'] as num?)?.toInt() == 1) ? 'Yes' : 'No'),
        ]),
      ],
    );
  }

  Widget _buildWarehouseStockTab() {
    final stockAsync = ref.watch(itemStockProvider(widget.name));
    return stockAsync.when(
      data: (stockList) {
        if (stockList.isEmpty) return const Center(child: Text('No stock data available in any warehouse.'));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: stockList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final bin = stockList[index];
            final wh = bin['warehouse']?.toString() ?? '';
            final qty = ((bin['actual_qty'] ?? 0) as num).toDouble();
            final res = ((bin['reserved_qty'] ?? 0) as num).toDouble();
            final proj = ((bin['projected_qty'] ?? 0) as num).toDouble();
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE5E7EB))),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(wh, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E2A38)))),
                        StockLevelIndicator(quantity: qty),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stockVal('Actual', qty),
                        _stockVal('Reserved', res, color: const Color(0xFFF59E0B)),
                        _stockVal('Projected', proj, color: const Color(0xFF3B82F6)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(child: Text('Error loading stock data.')),
    );
  }

  Widget _stockVal(String label, double val, {Color color = const Color(0xFF10B981)}) {
    return Column(
      children: [
        Text(val.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
      ],
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)))),
      ]),
    );
  }
}
