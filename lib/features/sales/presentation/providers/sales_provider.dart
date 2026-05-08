import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../frappe_core/data/providers/frappe_provider.dart';

// ─── Data Classes ───

class SalesSummary {
  final int totalSalesOrders;
  final int pendingDelivery;
  final double totalRevenue;
  final int overdueReceivables;
  const SalesSummary({this.totalSalesOrders = 0, this.pendingDelivery = 0, this.totalRevenue = 0.0, this.overdueReceivables = 0});
}

class SalesMonthlyData {
  final String month;
  final double total;
  const SalesMonthlyData(this.month, this.total);
}

class CustomerSalesData {
  final String customer;
  final double total;
  final int colorHex;
  const CustomerSalesData(this.customer, this.total, this.colorHex);
}

class SalesFilterParams {
  final String? status;
  final String? customer;
  final String? fromDate;
  final String? toDate;
  final int limitStart;
  final int limitPageLength;
  final String orderBy;

  const SalesFilterParams({this.status, this.customer, this.fromDate, this.toDate, this.limitStart = 0, this.limitPageLength = 20, this.orderBy = 'creation desc'});

  SalesFilterParams copyWith({String? status, String? customer, String? fromDate, String? toDate, int? limitStart, int? limitPageLength, String? orderBy}) {
    return SalesFilterParams(status: status ?? this.status, customer: customer ?? this.customer, fromDate: fromDate ?? this.fromDate, toDate: toDate ?? this.toDate, limitStart: limitStart ?? this.limitStart, limitPageLength: limitPageLength ?? this.limitPageLength, orderBy: orderBy ?? this.orderBy);
  }

  List<List<dynamic>> toFilters() {
    final filters = <List<dynamic>>[];
    if (status != null && status!.isNotEmpty) filters.add(['status', '=', status]);
    if (customer != null && customer!.isNotEmpty) filters.add(['customer_name', 'like', '%$customer%']);
    if (fromDate != null && fromDate!.isNotEmpty) filters.add(['transaction_date', '>=', fromDate]);
    if (toDate != null && toDate!.isNotEmpty) filters.add(['transaction_date', '<=', toDate]);
    return filters;
  }

  List<List<dynamic>> toInvoiceFilters() {
    final filters = <List<dynamic>>[];
    if (status != null && status!.isNotEmpty) filters.add(['status', '=', status]);
    if (customer != null && customer!.isNotEmpty) filters.add(['customer_name', 'like', '%$customer%']);
    if (fromDate != null && fromDate!.isNotEmpty) filters.add(['posting_date', '>=', fromDate]);
    if (toDate != null && toDate!.isNotEmpty) filters.add(['posting_date', '<=', toDate]);
    return filters;
  }
}

// ─── Dashboard Summary ───

final salesDashboardSummaryProvider = FutureProvider<SalesSummary>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);
  final now = DateTime.now();
  final monthStart = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
  final today = now.toIso8601String().split('T')[0];

  try {
    final soCount = await repository.getCount('Sales Order', filters: [['docstatus', '=', 1], ['transaction_date', '>=', monthStart], ['transaction_date', '<=', today]]);
    final pendingCount = await repository.getCount('Sales Order', filters: [['docstatus', '=', 1], ['per_delivered', '<', 100]]);

    final siList = await repository.getList('Sales Invoice', fields: ['grand_total'], filters: [['docstatus', '=', 1], ['posting_date', '>=', monthStart], ['posting_date', '<=', today]], limitPageLength: 5000);
    double totalRevenue = 0;
    for (var doc in siList) { totalRevenue += ((doc['grand_total'] ?? 0) as num).toDouble(); }

    final overdueCount = await repository.getCount('Sales Invoice', filters: [['docstatus', '=', 1], ['outstanding_amount', '>', 0], ['due_date', '<', today]]);

    return SalesSummary(totalSalesOrders: soCount, pendingDelivery: pendingCount, totalRevenue: totalRevenue, overdueReceivables: overdueCount);
  } catch (e) { return const SalesSummary(); }
});

// ─── Monthly Sales Trend ───

final salesMonthlyTrendProvider = FutureProvider<List<SalesMonthlyData>>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    final year = DateTime.now().year;
    final list = await repository.getList('Sales Invoice', fields: ['posting_date', 'grand_total'], filters: [['docstatus', '=', 1], ['posting_date', '>=', '$year-01-01'], ['posting_date', '<=', '$year-12-31']], limitPageLength: 5000);

    List<double> monthlyTotals = List.filled(12, 0.0);
    for (var doc in list) {
      final dateStr = doc['posting_date'] as String?;
      final total = ((doc['grand_total'] ?? 0) as num).toDouble();
      if (dateStr != null && dateStr.isNotEmpty) { final date = DateTime.tryParse(dateStr); if (date != null) monthlyTotals[date.month - 1] += total; }
    }

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    int maxMonth = DateTime.now().month;
    List<SalesMonthlyData> res = [];
    for (int i = 0; i < maxMonth; i++) { res.add(SalesMonthlyData(months[i], monthlyTotals[i])); }
    if (res.length > 6) return res.sublist(res.length - 6);
    return res;
  } catch (e) { return []; }
});

// ─── Top Customers ───

final salesByCustomerProvider = FutureProvider<List<CustomerSalesData>>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);
  const colors = [0xFF3B82F6, 0xFF10B981, 0xFFF59E0B, 0xFFEF4444, 0xFF8B5CF6];
  try {
    final list = await repository.getList('Sales Invoice', fields: ['customer_name', 'grand_total'], filters: [['docstatus', '=', 1]], limitPageLength: 5000);
    final Map<String, double> customerTotals = {};
    for (var doc in list) {
      final cust = doc['customer_name']?.toString() ?? 'Unknown';
      final total = ((doc['grand_total'] ?? 0) as num).toDouble();
      customerTotals[cust] = (customerTotals[cust] ?? 0) + total;
    }
    final sorted = customerTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList().asMap().entries.map((e) => CustomerSalesData(e.value.key, e.value.value, colors[e.key % colors.length])).toList();
  } catch (e) { return []; }
});

// ─── Recent Sales Orders ───

final recentSalesOrdersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    return await repository.getList('Sales Order', fields: ['name', 'customer', 'customer_name', 'grand_total', 'status', 'transaction_date', 'currency'], limitPageLength: 10, orderBy: 'creation desc');
  } catch (e) { return []; }
});

// ─── Recent Sales Invoices ───

final recentSalesInvoicesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    return await repository.getList('Sales Invoice', fields: ['name', 'customer', 'customer_name', 'grand_total', 'outstanding_amount', 'status', 'posting_date', 'due_date', 'currency'], limitPageLength: 10, orderBy: 'creation desc');
  } catch (e) { return []; }
});

// ─── Sales Order List (with filters) ───

final salesOrderListProvider = FutureProvider.family<List<Map<String, dynamic>>, SalesFilterParams>((ref, params) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    final filters = params.toFilters();
    return await repository.getList('Sales Order', fields: ['name', 'customer', 'customer_name', 'grand_total', 'status', 'transaction_date', 'currency', 'per_delivered', 'per_billed'], filters: filters.isNotEmpty ? filters : null, limitStart: params.limitStart, limitPageLength: params.limitPageLength, orderBy: params.orderBy);
  } catch (e) { return []; }
});

// ─── Sales Invoice List (with filters) ───

final salesInvoiceListProvider = FutureProvider.family<List<Map<String, dynamic>>, SalesFilterParams>((ref, params) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    final filters = params.toInvoiceFilters();
    return await repository.getList('Sales Invoice', fields: ['name', 'customer', 'customer_name', 'grand_total', 'outstanding_amount', 'status', 'posting_date', 'due_date', 'currency', 'is_return'], filters: filters.isNotEmpty ? filters : null, limitStart: params.limitStart, limitPageLength: params.limitPageLength, orderBy: params.orderBy);
  } catch (e) { return []; }
});

// ─── Customer List ───

final customerListProvider = FutureProvider.family<List<Map<String, dynamic>>, SalesFilterParams>((ref, params) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    final filters = <List<dynamic>>[];
    if (params.customer != null && params.customer!.isNotEmpty) filters.add(['customer_name', 'like', '%${params.customer}%']);
    return await repository.getList('Customer', fields: ['name', 'customer_name', 'customer_group', 'customer_type', 'territory', 'image', 'disabled'], filters: filters.isNotEmpty ? filters : null, limitStart: params.limitStart, limitPageLength: params.limitPageLength, orderBy: 'customer_name asc');
  } catch (e) { return []; }
});

// ─── Detail Providers ───

final salesOrderDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, name) async {
  final ds = ref.watch(frappeRemoteDsProvider);
  return await ds.getDoc('Sales Order', name, expandLinks: true);
});

final salesInvoiceDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, name) async {
  final ds = ref.watch(frappeRemoteDsProvider);
  return await ds.getDoc('Sales Invoice', name, expandLinks: true);
});

final customerDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, name) async {
  final ds = ref.watch(frappeRemoteDsProvider);
  return await ds.getDoc('Customer', name, expandLinks: true);
});

// ─── Customer Transaction History ───

final customerSalesOrdersProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, customer) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    return await repository.getList('Sales Order', fields: ['name', 'grand_total', 'status', 'transaction_date', 'currency'], filters: [['customer', '=', customer]], limitPageLength: 20, orderBy: 'creation desc');
  } catch (e) { return []; }
});

final customerSalesInvoicesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, customer) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    return await repository.getList('Sales Invoice', fields: ['name', 'grand_total', 'outstanding_amount', 'status', 'posting_date', 'currency'], filters: [['customer', '=', customer]], limitPageLength: 20, orderBy: 'creation desc');
  } catch (e) { return []; }
});
