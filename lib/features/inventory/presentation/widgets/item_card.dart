import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'stock_level_indicator.dart';

class ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final name = item['name']?.toString() ?? '';
    final itemName = item['item_name']?.toString() ?? name;
    final code = item['item_code']?.toString() ?? name;
    final group = item['item_group']?.toString() ?? 'Default';
    final disabled = (item['disabled'] as num?)?.toInt() == 1;

    // Simulate stock for UI purposes since list doesn't include it directly without joining Bins
    final stockVal = name.length * 2.0; 

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE5E7EB))),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/inventory/items/$name'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(itemName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(code, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        const SizedBox(width: 8),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4)), child: Text(group, style: const TextStyle(fontSize: 10, color: Color(0xFF4B5563)))),
                        if (disabled) ...[
                          const SizedBox(width: 8),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: const Text('Disabled', style: TextStyle(fontSize: 10, color: Color(0xFFEF4444)))),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              StockLevelIndicator(quantity: disabled ? 0 : stockVal),
            ],
          ),
        ),
      ),
    );
  }
}
