import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../providers/sales_provider.dart';
import '../widgets/sales_status_badge.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  final String customer;
  const CustomerDetailScreen({super.key, required this.customer});

  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> with SingleTickerProviderStateMixin {
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
    final docAsync = ref.watch(customerDetailProvider(widget.customer));
    return docAsync.when(
      data: (doc) => _buildView(doc),
      loading: () => Scaffold(appBar: AppBar(title: Text(widget.customer), backgroundColor: const Color(0xFF1E2A38), foregroundColor: Colors.white), body: const LoadingWidget()),
      error: (err, _) => Scaffold(appBar: AppBar(title: Text(widget.customer), backgroundColor: const Color(0xFF1E2A38), foregroundColor: Colors.white), body: ErrorStateWidget(message: err.toString())),
    );
  }

  Widget _buildView(Map<String, dynamic> doc) {
    final name = doc['name']?.toString() ?? '';
    final custName = doc['customer_name']?.toString() ?? name;
    final group = doc['customer_group']?.toString() ?? '';
    final territory = doc['territory']?.toString() ?? '';
    final initial = custName.isNotEmpty ? custName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        title: const Text('Customer Profile'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () => context.push('/resource/Customer/$name/edit')),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF1E2A38),
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: Colors.white.withValues(alpha: 0.1), radius: 36, child: Text(initial, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white))),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(custName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('$group • $territory', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
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
              tabs: const [Tab(text: 'Sales Orders'), Tab(text: 'Invoices')],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSalesOrdersTab(name),
                _buildInvoicesTab(name),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesOrdersTab(String customer) {
    final asyncData = ref.watch(customerSalesOrdersProvider(customer));
    return asyncData.when(
      data: (orders) {
        if (orders.isEmpty) return const Center(child: Text('No Sales Orders found'));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doc = orders[index];
            final name = doc['name']?.toString() ?? '';
            final total = ((doc['grand_total'] ?? 0) as num).toDouble();
            final status = doc['status']?.toString() ?? 'Draft';
            final dateStr = doc['transaction_date']?.toString() ?? '';
            return _buildTransactionCard(name, dateStr, total, status, () => context.push('/sales/orders/$name'));
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(child: Text('Error loading data')),
    );
  }

  Widget _buildInvoicesTab(String customer) {
    final asyncData = ref.watch(customerSalesInvoicesProvider(customer));
    return asyncData.when(
      data: (invoices) {
        if (invoices.isEmpty) return const Center(child: Text('No Invoices found'));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: invoices.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doc = invoices[index];
            final name = doc['name']?.toString() ?? '';
            final total = ((doc['grand_total'] ?? 0) as num).toDouble();
            final outstanding = ((doc['outstanding_amount'] ?? 0) as num).toDouble();
            final status = doc['status']?.toString() ?? 'Draft';
            final dateStr = doc['posting_date']?.toString() ?? '';
            return _buildTransactionCard(name, dateStr, total, status, () => context.push('/sales/invoices/$name'), outstanding: outstanding);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(child: Text('Error loading data')),
    );
  }

  Widget _buildTransactionCard(String name, String dateStr, double total, String status, VoidCallback onTap, {double? outstanding}) {
    String displayDate = dateStr;
    if (dateStr.isNotEmpty) {
      final dt = DateTime.tryParse(dateStr);
      if (dt != null) displayDate = DateFormat.yMMMd().format(dt);
    }
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE5E7EB))),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  SalesStatusBadge(status: status, fontSize: 10),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(displayDate, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  Text('TK ${formatter.format(total)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              if (outstanding != null && outstanding > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Due: TK ${formatter.format(outstanding)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
