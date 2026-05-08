import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../../frappe_core/data/providers/frappe_provider.dart';
import '../../../../frappe_core/presentation/providers/permission_provider.dart';
import '../widgets/purchase_status_badge.dart';

class PurchaseInvoiceListScreen extends ConsumerStatefulWidget {
  const PurchaseInvoiceListScreen({super.key});

  @override
  ConsumerState<PurchaseInvoiceListScreen> createState() => _PurchaseInvoiceListScreenState();
}

class _PurchaseInvoiceListScreenState extends ConsumerState<PurchaseInvoiceListScreen> {
  static const _pageSize = 20;
  String _searchQuery = '';
  String? _statusFilter;
  final PagingController<int, Map<String, dynamic>> _pagingController = PagingController(firstPageKey: 0);
  final formatter = NumberFormat('#,##0.00');

  static const _statusFilters = ['All', 'Draft', 'Unpaid', 'Partly Paid', 'Paid', 'Overdue', 'Return', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final ds = ref.read(frappeRemoteDsProvider);
      final filters = <List<dynamic>>[];
      if (_searchQuery.isNotEmpty) filters.add(['supplier_name', 'like', '%$_searchQuery%']);
      if (_statusFilter != null && _statusFilter!.isNotEmpty) filters.add(['status', '=', _statusFilter]);

      final items = await ds.getList(
        'Purchase Invoice',
        fields: ['name', 'supplier', 'supplier_name', 'grand_total', 'outstanding_amount', 'status', 'posting_date', 'due_date', 'currency', 'is_return'],
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
        title: const Text('Purchase Invoices'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => context.push('/resource/Purchase Invoice/new'))],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by supplier...', hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
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
      floatingActionButton: ref.watch(userPermissionsProvider('Purchase Invoice')).maybeWhen(
        data: (p) => p.canCreate == true ? FloatingActionButton(onPressed: () => context.push('/resource/Purchase Invoice/new'), backgroundColor: const Color(0xFF10B981), child: const Icon(Icons.add, color: Colors.white)) : null,
        orElse: () => null,
      ),
      body: PagedListView<int, Map<String, dynamic>>(
        pagingController: _pagingController,
        padding: const EdgeInsets.all(16),
        builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
          itemBuilder: (context, item, index) => _buildCard(item),
          firstPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
          noItemsFoundIndicatorBuilder: (_) => const Center(child: Padding(padding: EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.receipt_outlined, size: 48, color: Color(0xFFD1D5DB)), SizedBox(height: 12), Text('No purchase invoices found', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)))]))),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final name = item['name']?.toString() ?? '';
    final supplier = item['supplier_name']?.toString() ?? item['supplier']?.toString() ?? '';
    final total = ((item['grand_total'] ?? 0) as num).toDouble();
    final outstanding = ((item['outstanding_amount'] ?? 0) as num).toDouble();
    final status = item['status']?.toString() ?? 'Draft';
    final date = item['posting_date']?.toString() ?? '';
    final dueDate = item['due_date']?.toString() ?? '';
    final isReturn = (item['is_return'] as num?)?.toInt() == 1;
    final isOverdue = outstanding > 0 && dueDate.isNotEmpty && DateTime.tryParse(dueDate)?.isBefore(DateTime.now()) == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isOverdue ? const Color(0xFFEF4444).withValues(alpha: 0.4) : const Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/purchase/invoices/$name'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Row(children: [
                Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                if (isReturn) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: const Text('Return', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))))],
              ])),
              PurchaseStatusBadge(status: status, fontSize: 10),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Row(children: [const Icon(Icons.local_shipping_outlined, size: 14, color: Color(0xFF9CA3AF)), const SizedBox(width: 6), Expanded(child: Text(supplier, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)), overflow: TextOverflow.ellipsis))])),
              Text('TK. ${formatter.format(total)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38))),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              if (date.isNotEmpty) Text(DateFormat.yMMMd().format(DateTime.tryParse(date) ?? DateTime.now()), style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
              if (outstanding > 0) Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text('Due: TK. ${formatter.format(outstanding)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() { _pagingController.dispose(); super.dispose(); }
}
