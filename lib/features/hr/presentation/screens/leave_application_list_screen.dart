import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../../frappe_core/data/providers/frappe_provider.dart';
import '../../../../frappe_core/presentation/providers/permission_provider.dart';

class LeaveApplicationListScreen extends ConsumerStatefulWidget {
  const LeaveApplicationListScreen({super.key});

  @override
  ConsumerState<LeaveApplicationListScreen> createState() => _LeaveApplicationListScreenState();
}

class _LeaveApplicationListScreenState extends ConsumerState<LeaveApplicationListScreen> {
  static const _pageSize = 20;
  String? _statusFilter;
  final PagingController<int, Map<String, dynamic>> _pagingController = PagingController(firstPageKey: 0);

  static const _statusFilters = ['All', 'Open', 'Approved', 'Rejected'];

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
        'Leave Application',
        fields: ['name', 'employee_name', 'leave_type', 'from_date', 'to_date', 'total_leave_days', 'status', 'docstatus'],
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
        title: const Text('Leave Applications'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => context.push('/resource/Leave Application/new'))],
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
      floatingActionButton: ref.watch(userPermissionsProvider('Leave Application')).maybeWhen(
        data: (p) => p.canCreate == true ? FloatingActionButton(onPressed: () => context.push('/resource/Leave Application/new'), backgroundColor: const Color(0xFF10B981), child: const Icon(Icons.add, color: Colors.white)) : null,
        orElse: () => null,
      ),
      body: PagedListView<int, Map<String, dynamic>>(
        pagingController: _pagingController,
        padding: const EdgeInsets.all(16),
        builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
          itemBuilder: (context, item, index) => _buildCard(item),
          firstPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
          noItemsFoundIndicatorBuilder: (_) => const Center(child: Padding(padding: EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.event_note_outlined, size: 48, color: Color(0xFFD1D5DB)), SizedBox(height: 12), Text('No leave applications found', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)))]))),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final name = item['name']?.toString() ?? '';
    final empName = item['employee_name']?.toString() ?? 'Unknown Employee';
    final type = item['leave_type']?.toString() ?? '';
    final fromDate = item['from_date']?.toString() ?? '';
    final toDate = item['to_date']?.toString() ?? '';
    final days = ((item['total_leave_days'] ?? 0) as num).toDouble();
    final status = item['status']?.toString() ?? 'Open';
    
    Color badgeColor = status == 'Approved' ? const Color(0xFF10B981) : status == 'Rejected' ? const Color(0xFFEF4444) : const Color(0xFF3B82F6);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE5E7EB))),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/resource/Leave Application/$name'),
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
                    child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.category_outlined, size: 14, color: Color(0xFF6B7280)),
                  const SizedBox(width: 6),
                  Text(type, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
                  const Spacer(),
                  Text('$days ${days == 1 ? "Day" : "Days"}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38))),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Expanded(child: Text(fromDate.isNotEmpty ? DateFormat.yMMMd().format(DateTime.tryParse(fromDate) ?? DateTime.now()) : '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward_outlined, size: 14, color: Color(0xFF9CA3AF))),
                    Expanded(child: Text(toDate.isNotEmpty ? DateFormat.yMMMd().format(DateTime.tryParse(toDate) ?? DateTime.now()) : '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.right)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { _pagingController.dispose(); super.dispose(); }
}
