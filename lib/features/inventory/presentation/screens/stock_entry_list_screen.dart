import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../../frappe_core/data/providers/frappe_provider.dart';
import '../../../../frappe_core/presentation/providers/permission_provider.dart';

class StockEntryListScreen extends ConsumerStatefulWidget {
  const StockEntryListScreen({super.key});

  @override
  ConsumerState<StockEntryListScreen> createState() => _StockEntryListScreenState();
}

class _StockEntryListScreenState extends ConsumerState<StockEntryListScreen> {
  static const _pageSize = 20;
  String? _purposeFilter;
  final PagingController<int, Map<String, dynamic>> _pagingController = PagingController(firstPageKey: 0);

  static const _purposes = ['All', 'Material Issue', 'Material Receipt', 'Material Transfer', 'Manufacture'];

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final ds = ref.read(frappeRemoteDsProvider);
      final filters = <List<dynamic>>[];
      if (_purposeFilter != null && _purposeFilter != 'All') filters.add(['purpose', '=', _purposeFilter]);

      final items = await ds.getList(
        'Stock Entry',
        fields: ['name', 'stock_entry_type', 'purpose', 'posting_date', 'status', 'total_amount', 'from_warehouse', 'to_warehouse', 'docstatus'],
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
        title: const Text('Stock Entries'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => context.push('/resource/Stock Entry/new'))],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              itemCount: _purposes.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final f = _purposes[index];
                final sel = (f == 'All' && _purposeFilter == null) || f == _purposeFilter;
                return GestureDetector(
                  onTap: () { setState(() { _purposeFilter = f == 'All' ? null : f; }); _pagingController.refresh(); },
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
        ),
      ),
      floatingActionButton: ref.watch(userPermissionsProvider('Stock Entry')).maybeWhen(
        data: (p) => p.canCreate == true ? FloatingActionButton(onPressed: () => context.push('/resource/Stock Entry/new'), backgroundColor: const Color(0xFF10B981), child: const Icon(Icons.add, color: Colors.white)) : null,
        orElse: () => null,
      ),
      body: PagedListView<int, Map<String, dynamic>>(
        pagingController: _pagingController,
        padding: const EdgeInsets.all(16),
        builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
          itemBuilder: (context, item, index) => _buildCard(item),
          firstPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
          noItemsFoundIndicatorBuilder: (_) => const Center(child: Padding(padding: EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.sync_alt_outlined, size: 48, color: Color(0xFFD1D5DB)), SizedBox(height: 12), Text('No stock entries found', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)))]))),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final name = item['name']?.toString() ?? '';
    final purpose = item['purpose']?.toString() ?? 'Stock Entry';
    final date = item['posting_date']?.toString() ?? '';
    final fromWh = item['from_warehouse']?.toString() ?? '';
    final toWh = item['to_warehouse']?.toString() ?? '';
    final docstatus = (item['docstatus'] as num?)?.toInt() ?? 0;
    
    Color badgeColor = docstatus == 1 ? const Color(0xFF10B981) : docstatus == 2 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
    String statusStr = docstatus == 1 ? 'Submitted' : docstatus == 2 ? 'Cancelled' : 'Draft';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE5E7EB))),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/inventory/stock-entries/$name'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(statusStr, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.category_outlined, size: 14, color: Color(0xFF6B7280)),
                  const SizedBox(width: 6),
                  Text(purpose, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
                ],
              ),
              const SizedBox(height: 8),
              if (fromWh.isNotEmpty || toWh.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      if (fromWh.isNotEmpty) Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('From', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))), Text(fromWh, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)])),
                      if (fromWh.isNotEmpty && toWh.isNotEmpty) const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward_outlined, size: 14, color: Color(0xFF9CA3AF))),
                      if (toWh.isNotEmpty) Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('To', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))), Text(toWh, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)])),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(date.isNotEmpty ? DateFormat.yMMMd().format(DateTime.tryParse(date) ?? DateTime.now()) : '', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { _pagingController.dispose(); super.dispose(); }
}
