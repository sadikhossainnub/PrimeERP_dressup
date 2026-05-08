import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../../frappe_core/data/providers/frappe_provider.dart';
import '../../../../frappe_core/presentation/providers/permission_provider.dart';

class SalarySlipListScreen extends ConsumerStatefulWidget {
  const SalarySlipListScreen({super.key});

  @override
  ConsumerState<SalarySlipListScreen> createState() => _SalarySlipListScreenState();
}

class _SalarySlipListScreenState extends ConsumerState<SalarySlipListScreen> {
  static const _pageSize = 20;
  String? _statusFilter;
  final PagingController<int, Map<String, dynamic>> _pagingController = PagingController(firstPageKey: 0);
  final formatter = NumberFormat('#,##0.00');

  static const _statusFilters = ['All', 'Draft', 'Submitted', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final ds = ref.read(frappeRemoteDsProvider);
      final filters = <List<dynamic>>[];
      if (_statusFilter != null && _statusFilter != 'All') filters.add(['status', '=', _statusFilter]);

      final items = await ds.getList(
        'Salary Slip',
        fields: ['name', 'employee_name', 'start_date', 'end_date', 'gross_pay', 'net_pay', 'status', 'docstatus'],
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
        title: const Text('Salary Slips'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => context.push('/resource/Salary Slip/new'))],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SizedBox(
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
        ),
      ),
      floatingActionButton: ref.watch(userPermissionsProvider('Salary Slip')).maybeWhen(
        data: (p) => p.canCreate == true ? FloatingActionButton(onPressed: () => context.push('/resource/Salary Slip/new'), backgroundColor: const Color(0xFF10B981), child: const Icon(Icons.add, color: Colors.white)) : null,
        orElse: () => null,
      ),
      body: PagedListView<int, Map<String, dynamic>>(
        pagingController: _pagingController,
        padding: const EdgeInsets.all(16),
        builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
          itemBuilder: (context, item, index) => _buildCard(item),
          firstPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
          noItemsFoundIndicatorBuilder: (_) => const Center(child: Padding(padding: EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.monetization_on_outlined, size: 48, color: Color(0xFFD1D5DB)), SizedBox(height: 12), Text('No salary slips found', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)))]))),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final name = item['name']?.toString() ?? '';
    final empName = item['employee_name']?.toString() ?? 'Unknown Employee';
    final start = item['start_date']?.toString() ?? '';
    final end = item['end_date']?.toString() ?? '';
    final netPay = ((item['net_pay'] ?? 0) as num).toDouble();
    final docstatus = (item['docstatus'] as num?)?.toInt() ?? 0;
    
    Color badgeColor = docstatus == 1 ? const Color(0xFF10B981) : docstatus == 2 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
    String statusStr = docstatus == 1 ? 'Submitted' : docstatus == 2 ? 'Cancelled' : 'Draft';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE5E7EB))),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/resource/Salary Slip/$name'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(empName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(statusStr, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_fmtMonth(start)} - ${_fmtMonth(end)}', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  Text('TK ${formatter.format(netPay)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtMonth(String d) {
    if (d.isEmpty) return '';
    final dt = DateTime.tryParse(d);
    return dt != null ? DateFormat.MMMd().format(dt) : d;
  }

  @override
  void dispose() { _pagingController.dispose(); super.dispose(); }
}
