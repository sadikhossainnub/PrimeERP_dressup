import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../frappe_core/data/providers/frappe_provider.dart';

// ─── Data Classes ───

class PurchaseSummary {
  final int totalPurchaseOrders;
  final int pendingApproval;
  final double totalPurchaseValue;
  final int overdueInvoices;

  const PurchaseSummary({
    this.totalPurchaseOrders = 0,
    this.pendingApproval = 0,
    this.totalPurchaseValue = 0.0,
    this.overdueInvoices = 0,
  });
}

class PurchaseMonthlyData {
  final String month;
  final double total;
  const PurchaseMonthlyData(this.month, this.total);
}

class SupplierPurchaseData {
  final String supplier;
  final double total;
  final int colorHex;
  const SupplierPurchaseData(this.supplier, this.total, this.colorHex);
}

class PurchaseFilterParams {
  final String? status;
  final String? supplier;
  final String? fromDate;
  final String? toDate;
  final int limitStart;
  final int limitPageLength;
  final String orderBy;

  const PurchaseFilterParams({
    this.status,
    this.supplier,
    this.fromDate,
    this.toDate,
    this.limitStart = 0,
    this.limitPageLength = 20,
    this.orderBy = 'creation desc',
  });

  /// Creates a copy with optional overrides.
  PurchaseFilterParams copyWith({
    String? status,
    String? supplier,
    String? fromDate,
    String? toDate,
    int? limitStart,
    int? limitPageLength,
    String? orderBy,
  }) {
    return PurchaseFilterParams(
      status: status ?? this.status,
      supplier: supplier ?? this.supplier,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      limitStart: limitStart ?? this.limitStart,
      limitPageLength: limitPageLength ?? this.limitPageLength,
      orderBy: orderBy ?? this.orderBy,
    );
  }

  /// Builds Frappe REST API filter array from current params.
  List<List<dynamic>> toFilters() {
    final filters = <List<dynamic>>[];
    if (status != null && status!.isNotEmpty) {
      filters.add(['status', '=', status]);
    }
    if (supplier != null && supplier!.isNotEmpty) {
      filters.add(['supplier', 'like', '%$supplier%']);
    }
    if (fromDate != null && fromDate!.isNotEmpty) {
      filters.add(['transaction_date', '>=', fromDate]);
    }
    if (toDate != null && toDate!.isNotEmpty) {
      filters.add(['transaction_date', '<=', toDate]);
    }
    return filters;
  }

  /// Builds Frappe REST API filter array for Purchase Invoices (uses posting_date).
  List<List<dynamic>> toInvoiceFilters() {
    final filters = <List<dynamic>>[];
    if (status != null && status!.isNotEmpty) {
      filters.add(['status', '=', status]);
    }
    if (supplier != null && supplier!.isNotEmpty) {
      filters.add(['supplier', 'like', '%$supplier%']);
    }
    if (fromDate != null && fromDate!.isNotEmpty) {
      filters.add(['posting_date', '>=', fromDate]);
    }
    if (toDate != null && toDate!.isNotEmpty) {
      filters.add(['posting_date', '<=', toDate]);
    }
    return filters;
  }
}

// ─── Dashboard Summary Provider ───

final purchaseDashboardSummaryProvider =
    FutureProvider<PurchaseSummary>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);
  final now = DateTime.now();
  final monthStart = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
  final today = now.toIso8601String().split('T')[0];

  try {
    // Total POs this month
    final poCount = await repository.getCount(
      'Purchase Order',
      filters: [
        ['docstatus', '=', 1],
        ['transaction_date', '>=', monthStart],
        ['transaction_date', '<=', today],
      ],
    );

    // Pending Approval (Draft POs)
    final pendingCount = await repository.getCount(
      'Purchase Order',
      filters: [
        ['docstatus', '=', 0],
      ],
    );

    // Total Purchase Value this month
    final poList = await repository.getList(
      'Purchase Order',
      fields: ['grand_total'],
      filters: [
        ['docstatus', '=', 1],
        ['transaction_date', '>=', monthStart],
        ['transaction_date', '<=', today],
      ],
      limitPageLength: 5000,
    );
    double totalValue = 0;
    for (var doc in poList) {
      totalValue += ((doc['grand_total'] ?? 0) as num).toDouble();
    }

    // Overdue Invoices
    final overdueCount = await repository.getCount(
      'Purchase Invoice',
      filters: [
        ['docstatus', '=', 1],
        ['outstanding_amount', '>', 0],
        ['due_date', '<', today],
      ],
    );

    return PurchaseSummary(
      totalPurchaseOrders: poCount,
      pendingApproval: pendingCount,
      totalPurchaseValue: totalValue,
      overdueInvoices: overdueCount,
    );
  } catch (e) {
    return const PurchaseSummary();
  }
});

// ─── Monthly Trend Provider ───

final purchaseMonthlyTrendProvider =
    FutureProvider<List<PurchaseMonthlyData>>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    final year = DateTime.now().year;
    final list = await repository.getList(
      'Purchase Order',
      fields: ['transaction_date', 'grand_total'],
      filters: [
        ['docstatus', '=', 1],
        ['transaction_date', '>=', '$year-01-01'],
        ['transaction_date', '<=', '$year-12-31'],
      ],
      limitPageLength: 5000,
    );

    List<double> monthlyTotals = List.filled(12, 0.0);
    for (var doc in list) {
      final dateStr = doc['transaction_date'] as String?;
      final total = ((doc['grand_total'] ?? 0) as num).toDouble();
      if (dateStr != null && dateStr.isNotEmpty) {
        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          monthlyTotals[date.month - 1] += total;
        }
      }
    }

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    int maxMonth = DateTime.now().month;
    List<PurchaseMonthlyData> res = [];
    for (int i = 0; i < maxMonth; i++) {
      res.add(PurchaseMonthlyData(months[i], monthlyTotals[i]));
    }
    if (res.length > 6) {
      return res.sublist(res.length - 6);
    }
    return res;
  } catch (e) {
    return [];
  }
});

// ─── Top Suppliers Provider ───

final purchaseBySupplierProvider =
    FutureProvider<List<SupplierPurchaseData>>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);
  const colors = [0xFF3B82F6, 0xFF10B981, 0xFFF59E0B, 0xFFEF4444, 0xFF8B5CF6];

  try {
    final list = await repository.getList(
      'Purchase Order',
      fields: ['supplier', 'grand_total'],
      filters: [
        ['docstatus', '=', 1],
      ],
      limitPageLength: 5000,
    );

    // Aggregate by supplier
    final Map<String, double> supplierTotals = {};
    for (var doc in list) {
      final supplier = doc['supplier']?.toString() ?? 'Unknown';
      final total = ((doc['grand_total'] ?? 0) as num).toDouble();
      supplierTotals[supplier] = (supplierTotals[supplier] ?? 0) + total;
    }

    // Sort and take top 5
    final sorted = supplierTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();

    return top.asMap().entries.map((e) {
      return SupplierPurchaseData(
        e.value.key,
        e.value.value,
        colors[e.key % colors.length],
      );
    }).toList();
  } catch (e) {
    return [];
  }
});

// ─── Recent Purchase Orders Provider ───

final recentPurchaseOrdersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    return await repository.getList(
      'Purchase Order',
      fields: [
        'name', 'supplier', 'supplier_name', 'grand_total',
        'status', 'transaction_date', 'currency',
      ],
      limitPageLength: 10,
      orderBy: 'creation desc',
    );
  } catch (e) {
    return [];
  }
});

// ─── Recent Purchase Invoices Provider ───

final recentPurchaseInvoicesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    return await repository.getList(
      'Purchase Invoice',
      fields: [
        'name', 'supplier', 'supplier_name', 'grand_total',
        'outstanding_amount', 'status', 'posting_date', 'due_date', 'currency',
      ],
      limitPageLength: 10,
      orderBy: 'creation desc',
    );
  } catch (e) {
    return [];
  }
});

// ─── Purchase Order List Provider (with filters) ───

final purchaseOrderListProvider = FutureProvider.family<
    List<Map<String, dynamic>>, PurchaseFilterParams>((ref, params) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    final filters = params.toFilters();
    return await repository.getList(
      'Purchase Order',
      fields: [
        'name', 'supplier', 'supplier_name', 'grand_total',
        'status', 'transaction_date', 'currency', 'per_received',
        'per_billed',
      ],
      filters: filters.isNotEmpty ? filters : null,
      limitStart: params.limitStart,
      limitPageLength: params.limitPageLength,
      orderBy: params.orderBy,
    );
  } catch (e) {
    return [];
  }
});

// ─── Purchase Invoice List Provider (with filters) ───

final purchaseInvoiceListProvider = FutureProvider.family<
    List<Map<String, dynamic>>, PurchaseFilterParams>((ref, params) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    final filters = params.toInvoiceFilters();
    return await repository.getList(
      'Purchase Invoice',
      fields: [
        'name', 'supplier', 'supplier_name', 'grand_total',
        'outstanding_amount', 'status', 'posting_date', 'due_date',
        'currency', 'is_return',
      ],
      filters: filters.isNotEmpty ? filters : null,
      limitStart: params.limitStart,
      limitPageLength: params.limitPageLength,
      orderBy: params.orderBy,
    );
  } catch (e) {
    return [];
  }
});

// ─── Supplier List Provider ───

final supplierListProvider = FutureProvider.family<
    List<Map<String, dynamic>>, PurchaseFilterParams>((ref, params) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    final filters = <List<dynamic>>[];
    if (params.supplier != null && params.supplier!.isNotEmpty) {
      filters.add(['supplier_name', 'like', '%${params.supplier}%']);
    }
    return await repository.getList(
      'Supplier',
      fields: [
        'name', 'supplier_name', 'supplier_group', 'supplier_type',
        'country', 'image', 'disabled',
      ],
      filters: filters.isNotEmpty ? filters : null,
      limitStart: params.limitStart,
      limitPageLength: params.limitPageLength,
      orderBy: 'supplier_name asc',
    );
  } catch (e) {
    return [];
  }
});

// ─── Purchase Order Detail Provider ───

final purchaseOrderDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, name) async {
  final ds = ref.watch(frappeRemoteDsProvider);
  return await ds.getDoc('Purchase Order', name, expandLinks: true);
});

// ─── Purchase Invoice Detail Provider ───

final purchaseInvoiceDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, name) async {
  final ds = ref.watch(frappeRemoteDsProvider);
  return await ds.getDoc('Purchase Invoice', name, expandLinks: true);
});

// ─── Supplier Detail Provider ───

final supplierDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, name) async {
  final ds = ref.watch(frappeRemoteDsProvider);
  return await ds.getDoc('Supplier', name, expandLinks: true);
});

// ─── Supplier Transaction History ───

final supplierPurchaseOrdersProvider = FutureProvider.family<
    List<Map<String, dynamic>>, String>((ref, supplier) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    return await repository.getList(
      'Purchase Order',
      fields: [
        'name', 'grand_total', 'status', 'transaction_date', 'currency',
      ],
      filters: [
        ['supplier', '=', supplier],
      ],
      limitPageLength: 20,
      orderBy: 'creation desc',
    );
  } catch (e) {
    return [];
  }
});

final supplierPurchaseInvoicesProvider = FutureProvider.family<
    List<Map<String, dynamic>>, String>((ref, supplier) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    return await repository.getList(
      'Purchase Invoice',
      fields: [
        'name', 'grand_total', 'outstanding_amount', 'status',
        'posting_date', 'currency',
      ],
      filters: [
        ['supplier', '=', supplier],
      ],
      limitPageLength: 20,
      orderBy: 'creation desc',
    );
  } catch (e) {
    return [];
  }
});
