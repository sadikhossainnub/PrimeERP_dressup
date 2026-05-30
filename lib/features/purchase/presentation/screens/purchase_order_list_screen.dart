import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../../frappe_core/data/providers/frappe_provider.dart';
import '../../../../frappe_core/presentation/widgets/permission_gate.dart';
import '../widgets/purchase_status_badge.dart';

class PurchaseOrderListScreen extends ConsumerStatefulWidget {
  const PurchaseOrderListScreen({super.key});

  @override
  ConsumerState<PurchaseOrderListScreen> createState() =>
      _PurchaseOrderListScreenState();
}

class _PurchaseOrderListScreenState
    extends ConsumerState<PurchaseOrderListScreen> {
  static const _pageSize = 20;
  String _searchQuery = '';
  String? _statusFilter;

  final PagingController<int, Map<String, dynamic>> _pagingController =
      PagingController(firstPageKey: 0);

  final formatter = NumberFormat('#,##0.00');

  static const _statusFilters = [
    'All',
    'Draft',
    'To Receive and Bill',
    'To Bill',
    'To Receive',
    'Completed',
    'Cancelled',
    'Closed',
  ];

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final ds = ref.read(frappeRemoteDsProvider);

      final filters = <List<dynamic>>[];
      if (_searchQuery.isNotEmpty) {
        filters.add(['supplier_name', 'like', '%$_searchQuery%']);
      }
      if (_statusFilter != null && _statusFilter!.isNotEmpty) {
        filters.add(['status', '=', _statusFilter]);
      }

      final items = await ds.getList(
        'Purchase Order',
        fields: [
          'name', 'supplier', 'supplier_name', 'grand_total',
          'status', 'transaction_date', 'currency', 'per_received',
          'per_billed',
        ],
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
        title: const Text('Purchase Orders'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/resource/Purchase Order/new'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by supplier...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    _searchQuery = val;
                    _pagingController.refresh();
                  },
                ),
              ),
              // Filter chips
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  itemCount: _statusFilters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _statusFilters[index];
                    final isSelected = (filter == 'All' && _statusFilter == null) ||
                        filter == _statusFilter;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _statusFilter = filter == 'All' ? null : filter;
                        });
                        _pagingController.refresh();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 1.5)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            filter,
                            style: TextStyle(
                              color:
                                  isSelected ? const Color(0xFF1E2A38) : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: PermissionGate(
        doctype: 'Purchase Order',
        action: 'create',
        child: FloatingActionButton(
          onPressed: () => context.push('/resource/Purchase Order/new'),
          backgroundColor: const Color(0xFF3B82F6),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: PagedListView<int, Map<String, dynamic>>(
        pagingController: _pagingController,
        padding: const EdgeInsets.all(16),
        builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
          itemBuilder: (context, item, index) => _buildPOCard(item),
          firstPageProgressIndicatorBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          newPageProgressIndicatorBuilder: (_) => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          noItemsFoundIndicatorBuilder: (_) => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.description_outlined,
                      size: 48, color: Color(0xFFD1D5DB)),
                  SizedBox(height: 12),
                  Text(
                    'No purchase orders found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPOCard(Map<String, dynamic> item) {
    final name = item['name']?.toString() ?? '';
    final supplier =
        item['supplier_name']?.toString() ?? item['supplier']?.toString() ?? '';
    final total = ((item['grand_total'] ?? 0) as num).toDouble();
    final status = item['status']?.toString() ?? 'Draft';
    final date = item['transaction_date']?.toString() ?? '';
    final perReceived = ((item['per_received'] ?? 0) as num).toDouble();
    final perBilled = ((item['per_billed'] ?? 0) as num).toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/purchase/orders/$name'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: PO Name + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PurchaseStatusBadge(status: status, fontSize: 10),
                ],
              ),
              const SizedBox(height: 8),

              // Row 2: Supplier + Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined,
                            size: 14, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            supplier,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'TK. ${formatter.format(total)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2A38),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Row 3: Date + Progress indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (date.isNotEmpty)
                    Text(
                      DateFormat.yMMMd()
                          .format(DateTime.tryParse(date) ?? DateTime.now()),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  Row(
                    children: [
                      _buildProgressChip(
                        'Rcvd ${perReceived.toStringAsFixed(0)}%',
                        perReceived,
                      ),
                      const SizedBox(width: 6),
                      _buildProgressChip(
                        'Billed ${perBilled.toStringAsFixed(0)}%',
                        perBilled,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressChip(String label, double percent) {
    final color = percent >= 100
        ? const Color(0xFF10B981)
        : percent > 0
            ? const Color(0xFF3B82F6)
            : const Color(0xFF9CA3AF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
