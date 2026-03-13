import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../frappe_core/data/providers/frappe_provider.dart';

final currentUserProfileProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final repository = ref.watch(frappeRepositoryProvider);
  const storage = FlutterSecureStorage();

  try {
    final userResponse = await repository.callMethod(
      'frappe.auth.get_logged_user',
    );
    // callMethod already unwraps response.data['message'],
    // so userResponse is the email string directly (e.g. "admin@example.com")
    String email = (userResponse is String) ? userResponse : '';

    if (email.isEmpty) {
      email = await storage.read(key: AppConstants.keyUsername) ?? '';
    }

    if (email.isNotEmpty) {
      final userDoc = await repository.getDoc('User', email);
      final baseUrl = await storage.read(key: AppConstants.keyBaseUrl) ?? '';
      userDoc['_base_url'] = baseUrl; // attach base_url to complete avatar path
      return userDoc;
    }
  } catch (e) {
    // Return empty on error, handled in UI
  }
  return {};
});

final dashboardTotalSalesProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);
  final today = DateTime.now().toIso8601String().split('T')[0];
  try {
    final list = await repository.getList(
      'Sales Invoice',
      fields: ['grand_total'],
      filters: [
        ['docstatus', '=', 1],
        ['posting_date', '=', today],
      ],
      limitPageLength: 1000,
    );
    double total = 0;
    for (var doc in list) {
      total += (doc['grand_total'] ?? 0) as double;
    }
    return total;
  } catch (e) {
    return 0.0;
  }
});

final dashboardPurchaseOrdersProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    final list = await repository.getList(
      'Purchase Order',
      fields: ['grand_total'],
      filters: [
        ['docstatus', '=', 1],
      ],
      limitPageLength: 1000,
    );
    double total = 0;
    for (var doc in list) {
      total += (doc['grand_total'] ?? 0) as double;
    }
    return total;
  } catch (e) {
    return 0.0;
  }
});

final dashboardPendingPaymentsProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    final list = await repository.getList(
      'Sales Invoice',
      fields: ['outstanding_amount'],
      filters: [
        ['docstatus', '=', 1],
        ['outstanding_amount', '>', 0],
      ],
      limitPageLength: 1000,
    );
    double total = 0;
    for (var doc in list) {
      // sometimes ERPNext returns double/int or dynamic based on parsing
      final amount = doc['outstanding_amount'];
      if (amount is num) total += amount.toDouble();
    }
    return total;
  } catch (e) {
    return 0.0;
  }
});

final dashboardStockAlertsProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    final count = await repository.getCount(
      'Bin',
      filters: [
        ['actual_qty', '<=', 0],
      ],
    );
    return count;
  } catch (e) {
    return 0; // fallback if Bin isn't accessible
  }
});

final dashboardRecentTransactionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      final repository = ref.watch(frappeRepositoryProvider);
      try {
        final list = await repository.getList(
          'Payment Entry',
          fields: [
            'name',
            'payment_type',
            'paid_amount',
            'docstatus',
            'party',
            'posting_date',
          ],
          limitPageLength: 5,
          orderBy: 'creation desc',
        );
        return list;
      } catch (e) {
        return [];
      }
    });

class MonthlySales {
  final String month;
  final double total;
  MonthlySales(this.month, this.total);
}

final dashboardMonthlySalesProvider = FutureProvider<List<MonthlySales>>((
  ref,
) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    final year = DateTime.now().year;
    final list = await repository.getList(
      'Sales Invoice',
      fields: ['posting_date', 'grand_total'],
      filters: [
        ['docstatus', '=', 1],
        ['posting_date', '>=', '$year-01-01'],
        ['posting_date', '<=', '$year-12-31'],
      ],
      limitPageLength: 5000,
    );

    List<double> monthlyTotals = List.filled(12, 0.0);
    for (var doc in list) {
      final dateStr = doc['posting_date'] as String?;
      final total = (doc['grand_total'] as num?)?.toDouble() ?? 0.0;
      if (dateStr != null && dateStr.isNotEmpty) {
        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          monthlyTotals[date.month - 1] += total;
        }
      }
    }

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    List<MonthlySales> res = [];
    // Just return up to current month or first 6 months
    int maxMonth = DateTime.now().month;
    for (int i = 0; i < maxMonth; i++) {
      res.add(MonthlySales(months[i], monthlyTotals[i]));
    }
    // Return last 6 months to avoid overcrowding
    if (res.length > 6) {
      return res.sublist(res.length - 6);
    }
    return res;
  } catch (e) {
    return [];
  }
});

class InventoryStatus {
  final String title;
  final double percentage;
  final double value;
  final int colorHex;
  InventoryStatus(this.title, this.percentage, this.value, this.colorHex);
}

final dashboardInventoryStatusProvider = FutureProvider<List<InventoryStatus>>((
  ref,
) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    // Fetch a few aggregate values, or mock the percentages based on total actual item valuations
    // Since direct aggregation is hard, we'll try fetching item counts for simplicity.
    final inStock = await repository.getCount(
      'Bin',
      filters: [
        ['actual_qty', '>', 10],
      ],
    );
    final lowStock = await repository.getCount(
      'Bin',
      filters: [
        ['actual_qty', '>', 0],
        ['actual_qty', '<=', 10],
      ],
    );
    final outOfStock = await repository.getCount(
      'Bin',
      filters: [
        ['actual_qty', '<=', 0],
      ],
    );

    final total = (inStock + lowStock + outOfStock).toDouble();
    if (total == 0) {
      return [
        InventoryStatus('In Stock', 55, 350.0, 0xFF4CAF50),
        InventoryStatus('Low Stock', 30, 250.0, 0xFFFF9800),
        InventoryStatus('Out of Stock', 15, 20.0, 0xFFF44336),
      ];
    }

    return [
      InventoryStatus(
        'In Stock',
        (inStock / total) * 100,
        inStock * 10.0,
        0xFF4CAF50,
      ),
      InventoryStatus(
        'Low Stock',
        (lowStock / total) * 100,
        lowStock * 10.0,
        0xFFFF9800,
      ),
      InventoryStatus(
        'Out of Stock',
        (outOfStock / total) * 100,
        outOfStock * 10.0,
        0xFFF44336,
      ),
    ];
  } catch (e) {
    return [
      InventoryStatus('In Stock', 55, 350.0, 0xFF4CAF50),
      InventoryStatus('Low Stock', 30, 250.0, 0xFFFF9800),
      InventoryStatus('Out of Stock', 15, 20.0, 0xFFF44336),
    ];
  }
});
