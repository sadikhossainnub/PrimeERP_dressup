import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../frappe_core/data/providers/frappe_provider.dart';

// ─── Data Classes ───

class InventorySummary {
  final int totalItems;
  final int lowStockItems;
  final double totalValue;
  final int pendingStockEntries;
  const InventorySummary({this.totalItems = 0, this.lowStockItems = 0, this.totalValue = 0.0, this.pendingStockEntries = 0});
}

class WarehouseValue {
  final String warehouse;
  final double value;
  final int colorHex;
  const WarehouseValue(this.warehouse, this.value, this.colorHex);
}

class InventoryFilterParams {
  final String? itemGroup;
  final String? searchQuery;
  final int limitStart;
  final int limitPageLength;

  const InventoryFilterParams({this.itemGroup, this.searchQuery, this.limitStart = 0, this.limitPageLength = 20});

  List<List<dynamic>> toItemFilters() {
    final filters = <List<dynamic>>[];
    if (itemGroup != null && itemGroup!.isNotEmpty) filters.add(['item_group', '=', itemGroup]);
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      // Simplistic search, frappe allows 'like'
      filters.add(['item_name', 'like', '%$searchQuery%']);
    }
    return filters;
  }
}

// ─── Dashboard Summary ───

final inventorySummaryProvider = FutureProvider<InventorySummary>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    final totalItems = await repository.getCount('Item', filters: [['disabled', '=', 0]]);
    final pendingEntries = await repository.getCount('Stock Entry', filters: [['docstatus', '=', 0]]);
    
    // Total Value and Low Stock are slightly complex in Frappe standard APIs.
    // For the sake of the dashboard, we will fetch Bin data if available, or approximate.
    // Here we fetch total value from 'Bin' if accessible
    double totalValue = 0;
    int lowStockCount = 0;
    try {
      final bins = await repository.getList('Bin', fields: ['actual_qty', 'valuation_rate', 'projected_qty'], limitPageLength: 5000);
      for (var bin in bins) {
        final qty = ((bin['actual_qty'] ?? 0) as num).toDouble();
        final rate = ((bin['valuation_rate'] ?? 0) as num).toDouble();
        totalValue += (qty * rate);
        
        final projected = ((bin['projected_qty'] ?? 0) as num).toDouble();
        if (projected < 10) lowStockCount++; // Approximate logic for demo
      }
    } catch (_) {
      // Ignore if Bin is not accessible
    }

    return InventorySummary(totalItems: totalItems, lowStockItems: lowStockCount, totalValue: totalValue, pendingStockEntries: pendingEntries);
  } catch (e) { return const InventorySummary(); }
});

// ─── Stock Value by Warehouse ───

final warehouseValueProvider = FutureProvider<List<WarehouseValue>>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);
  const colors = [0xFF3B82F6, 0xFF10B981, 0xFFF59E0B, 0xFFEF4444, 0xFF8B5CF6, 0xFFEC4899];
  try {
    final list = await repository.getList('Bin', fields: ['warehouse', 'actual_qty', 'valuation_rate'], limitPageLength: 5000);
    final Map<String, double> whTotals = {};
    for (var doc in list) {
      final wh = doc['warehouse']?.toString() ?? 'Unknown';
      final qty = ((doc['actual_qty'] ?? 0) as num).toDouble();
      final rate = ((doc['valuation_rate'] ?? 0) as num).toDouble();
      whTotals[wh] = (whTotals[wh] ?? 0) + (qty * rate);
    }
    final sorted = whTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(6).toList().asMap().entries.map((e) => WarehouseValue(e.value.key, e.value.value, colors[e.key % colors.length])).toList();
  } catch (e) { return []; }
});

// ─── Items List ───

final itemListProvider = FutureProvider.family<List<Map<String, dynamic>>, InventoryFilterParams>((ref, params) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    return await repository.getList('Item', fields: ['name', 'item_name', 'item_code', 'item_group', 'image', 'standard_rate', 'stock_uom', 'disabled'], filters: params.toItemFilters().isNotEmpty ? params.toItemFilters() : null, limitStart: params.limitStart, limitPageLength: params.limitPageLength, orderBy: 'modified desc');
  } catch (e) { return []; }
});

// ─── Stock Entries List ───

final stockEntryListProvider = FutureProvider.family<List<Map<String, dynamic>>, InventoryFilterParams>((ref, params) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    return await repository.getList('Stock Entry', fields: ['name', 'stock_entry_type', 'purpose', 'posting_date', 'status', 'total_amount', 'from_warehouse', 'to_warehouse'], limitStart: params.limitStart, limitPageLength: params.limitPageLength, orderBy: 'creation desc');
  } catch (e) { return []; }
});

// ─── Warehouses List ───

final warehouseListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    return await repository.getList('Warehouse', fields: ['name', 'warehouse_name', 'company', 'parent_warehouse', 'is_group'], limitPageLength: 100);
  } catch (e) { return []; }
});

// ─── Item Detail ───

final itemDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, name) async {
  final ds = ref.watch(frappeRemoteDsProvider);
  return await ds.getDoc('Item', name);
});

// ─── Stock Entry Detail ───

final stockEntryDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, name) async {
  final ds = ref.watch(frappeRemoteDsProvider);
  return await ds.getDoc('Stock Entry', name, expandLinks: true);
});

// ─── Item Bin Stock ───

final itemStockProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, itemCode) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    return await repository.getList('Bin', fields: ['warehouse', 'actual_qty', 'projected_qty', 'reserved_qty'], filters: [['item_code', '=', itemCode]], limitPageLength: 50);
  } catch (e) { return []; }
});
