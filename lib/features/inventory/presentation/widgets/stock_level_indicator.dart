import 'package:flutter/material.dart';

class StockLevelIndicator extends StatelessWidget {
  final double quantity;

  const StockLevelIndicator({super.key, required this.quantity});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    if (quantity <= 0) {
      color = const Color(0xFFEF4444);
      text = 'Out of Stock';
    } else if (quantity < 10) {
      color = const Color(0xFFF59E0B);
      text = 'Low Stock';
    } else {
      color = const Color(0xFF10B981);
      text = 'In Stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
