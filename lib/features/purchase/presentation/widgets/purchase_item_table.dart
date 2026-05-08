import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PurchaseItemTable extends StatelessWidget {
  final List<dynamic> items;
  final String currency;
  final bool readOnly;

  const PurchaseItemTable({
    super.key,
    required this.items,
    this.currency = 'TK.',
    this.readOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Center(
          child: Text(
            'No items added yet',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Items',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
            Text(
              '${items.length} item${items.length != 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value as Map<String, dynamic>;
          return _buildItemCard(idx, item);
        }),
      ],
    );
  }

  Widget _buildItemCard(int index, Map<String, dynamic> item) {
    final formatter = NumberFormat('#,##0.00');
    final itemCode = item['item_code']?.toString() ?? '';
    final itemName = item['item_name']?.toString() ?? itemCode;
    final qty = _toDouble(item['qty']);
    final rate = _toDouble(item['rate']);
    final amount = _toDouble(item['amount']);
    final uom = item['uom']?.toString() ?? '';
    final warehouse = item['warehouse']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Index + Item Name + Amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (itemCode.isNotEmpty && itemCode != itemName)
                      Text(
                        itemCode,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$currency ${formatter.format(amount)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2A38),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Row 2: Qty × Rate + Warehouse
          Row(
            children: [
              const SizedBox(width: 34), // Align with item name
              _buildDetailChip(
                Icons.inventory_2_outlined,
                '${qty.toStringAsFixed(qty == qty.roundToDouble() ? 0 : 2)} $uom × $currency ${formatter.format(rate)}',
              ),
              if (warehouse.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDetailChip(
                    Icons.warehouse_outlined,
                    warehouse,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }
}
