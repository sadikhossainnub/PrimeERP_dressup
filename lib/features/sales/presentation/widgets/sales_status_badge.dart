import 'package:flutter/material.dart';

class SalesStatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const SalesStatusBadge({super.key, required this.status, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
    );
  }

  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': case 'paid': case 'submitted': case 'delivered': case 'closed':
        return const Color(0xFF10B981);
      case 'to deliver and bill': case 'to deliver': case 'to bill':
        return const Color(0xFF3B82F6);
      case 'draft': case 'pending': case 'partly delivered': case 'partly paid': case 'unpaid':
        return const Color(0xFFF59E0B);
      case 'cancelled': case 'overdue': case 'return': case 'credit note issued':
        return const Color(0xFFEF4444);
      case 'on hold':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
