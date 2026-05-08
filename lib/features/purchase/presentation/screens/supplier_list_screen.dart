import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../../frappe_core/data/providers/frappe_provider.dart';

class SupplierListScreen extends ConsumerStatefulWidget {
  const SupplierListScreen({super.key});

  @override
  ConsumerState<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends ConsumerState<SupplierListScreen> {
  static const _pageSize = 20;
  String _searchQuery = '';
  final PagingController<int, Map<String, dynamic>> _pagingController = PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final ds = ref.read(frappeRemoteDsProvider);
      final filters = <List<dynamic>>[];
      if (_searchQuery.isNotEmpty) {
        filters.add(['supplier_name', 'like', '%$_searchQuery%']);
      }
      final items = await ds.getList(
        'Supplier',
        fields: ['name', 'supplier_name', 'supplier_group', 'supplier_type', 'country', 'image', 'disabled'],
        filters: filters.isNotEmpty ? filters : null,
        limitStart: pageKey,
        limitPageLength: _pageSize,
        orderBy: 'supplier_name asc',
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
        title: const Text('Suppliers'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => context.push('/resource/Supplier/new')),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search suppliers...',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                filled: true, fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (val) { _searchQuery = val; _pagingController.refresh(); },
            ),
          ),
        ),
      ),
      body: PagedListView<int, Map<String, dynamic>>(
        pagingController: _pagingController,
        padding: const EdgeInsets.all(16),
        builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
          itemBuilder: (context, item, index) => _buildSupplierCard(item),
          firstPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
          noItemsFoundIndicatorBuilder: (_) => const Center(
            child: Padding(padding: EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.people_outline, size: 48, color: Color(0xFFD1D5DB)),
              SizedBox(height: 12),
              Text('No suppliers found', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
            ])),
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierCard(Map<String, dynamic> item) {
    final name = item['name']?.toString() ?? '';
    final supplierName = item['supplier_name']?.toString() ?? name;
    final group = item['supplier_group']?.toString() ?? '';

    final country = item['country']?.toString() ?? '';
    final disabled = (item['disabled'] as num?)?.toInt() == 1;
    final initial = supplierName.isNotEmpty ? supplierName[0].toUpperCase() : '?';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/purchase/suppliers/$name'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_getAvatarColor(initial), _getAvatarColor(initial).withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(initial, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
              ),
              const SizedBox(width: 14),
              // Details
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(supplierName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)), overflow: TextOverflow.ellipsis)),
                    if (disabled) Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: const Text('Disabled', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    if (group.isNotEmpty) ...[
                      const Icon(Icons.category_outlined, size: 12, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Text(group, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      const SizedBox(width: 12),
                    ],
                    if (country.isNotEmpty) ...[
                      const Icon(Icons.public, size: 12, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Text(country, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    ],
                  ]),
                ]),
              ),
              const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String letter) {
    const colors = [Color(0xFF3B82F6), Color(0xFF10B981), Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFF06B6D4)];
    return colors[letter.codeUnitAt(0) % colors.length];
  }

  @override
  void dispose() { _pagingController.dispose(); super.dispose(); }
}
