import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../../frappe_core/data/providers/frappe_provider.dart';
import '../../../../frappe_core/presentation/widgets/permission_gate.dart';
import '../widgets/sales_status_badge.dart';

class SalesOrderListScreen extends ConsumerStatefulWidget {
  const SalesOrderListScreen({super.key});

  @override
  ConsumerState<SalesOrderListScreen> createState() => _SalesOrderListScreenState();
}

class _SalesOrderListScreenState extends ConsumerState<SalesOrderListScreen> {
  static const _pageSize = 20;
  String _searchQuery = '';
  String? _statusFilter;
  final PagingController<int, Map<String, dynamic>> _pagingController = PagingController(firstPageKey: 0);
  final formatter = NumberFormat('#,##0.00');

  static const _statusFilters = ['All', 'Draft', 'To Deliver and Bill', 'To Bill', 'To Deliver', 'Completed', 'Cancelled', 'On Hold'];

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final ds = ref.read(frappeRemoteDsProvider);
      final filters = <List<dynamic>>[];
      if (_searchQuery.isNotEmpty) filters.add(['customer_name', 'like', '%$_searchQuery%']);
      if (_statusFilter != null && _statusFilter!.isNotEmpty) filters.add(['status', '=', _statusFilter]);

      final items = await ds.getList(
        'Sales Order',
        fields: ['name', 'customer', 'customer_name', 'grand_total', 'status', 'transaction_date', 'currency', 'per_delivered', 'per_billed'],
        filters: filters.isNotEmpty ? filters : null,
        limitStart: pageKey,
        limitPageLength: _pageSize,
        orderBy: 'creation desc',
      );
      final isLastPage = items.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(items);
      } else {
        _pagingController.appendPage(items, pageKey + items.length);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        title: const Text('Sales Orders'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => context.push('/resource/Sales Order/new'))],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by customer...', hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                  filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: (val) { _searchQuery = val; _pagingController.refresh(); },
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                itemCount: _statusFilters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final f = _statusFilters[index];
                  final sel = (f == 'All' && _statusFilter == null) || f == _statusFilter;
                  return GestureDetector(
                    onTap: () { setState(() { _statusFilter = f == 'All' ? null : f; }); _pagingController.refresh(); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? Colors.white : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: sel ? Border.all(color: Colors.white, width: 1.5) : null,
                      ),
                      child: Center(child: Text(f, style: TextStyle(color: sel ? const Color(0xFF1E2A38) : Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
      floatingActionButton: PermissionGate(
        doctype: 'Sales Order',
        action: 'create',
        child: FloatingActionButton(
          onPressed: () => context.push('/resource/Sales Order/new'),
          backgroundColor: const Color(0xFF10B981),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: PagedListView<int, Map<String, dynamic>>(
        pagingController: _pagingController,
        padding: const EdgeInsets.all(16),
        builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
          itemBuilder: (context, item, index) => _buildCard(item),
          firstPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
          noItemsFoundIndicatorBuilder: (_) => const Center(child: Padding(padding: EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.description_outlined, size: 48, color: Color(0xFFD1D5DB)), SizedBox(height: 12), Text('No sales orders found', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)))]))),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final name = item['name']?.toString() ?? '';
    final cust = item['customer_name']?.toString() ?? item['customer']?.toString() ?? '';
    final total = ((item['grand_total'] ?? 0) as num).toDouble();
    final status = item['status']?.toString() ?? 'Draft';
    final date = item['transaction_date']?.toString() ?? '';
    final perDelivered = ((item['per_delivered'] ?? 0) as num).toDouble();
    final perBilled = ((item['per_billed'] ?? 0) as num).toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE5E7EB))),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/sales/orders/$name'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)))),
              SalesStatusBadge(status: status, fontSize: 10),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Row(children: [const Icon(Icons.person_outline, size: 14, color: Color(0xFF9CA3AF)), const SizedBox(width: 6), Expanded(child: Text(cust, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)), overflow: TextOverflow.ellipsis))])),
              Text('TK. ${formatter.format(total)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38))),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              if (date.isNotEmpty) Text(DateFormat.yMMMd().format(DateTime.tryParse(date) ?? DateTime.now()), style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
              Row(children: [
                _buildProgress('Delivered', perDelivered),
                const SizedBox(width: 8),
                _buildProgress('Billed', perBilled),
              ]),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildProgress(String label, double percentage) {
    if (percentage == 0) return const SizedBox.shrink();
    final isComplete = percentage >= 100;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: isComplete ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFF3B82F6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Row(children: [
        Icon(isComplete ? Icons.check_circle : Icons.timelapse, size: 10, color: isComplete ? const Color(0xFF10B981) : const Color(0xFF3B82F6)),
        const SizedBox(width: 4),
        Text('$label ${percentage.toInt()}%', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: isComplete ? const Color(0xFF10B981) : const Color(0xFF3B82F6))),
      ]),
    );
  }

  @override
  void dispose() { _pagingController.dispose(); super.dispose(); }
}
