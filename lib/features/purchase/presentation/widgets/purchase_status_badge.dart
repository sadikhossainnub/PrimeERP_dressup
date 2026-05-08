import 'package:flutter/material.dart';

class PurchaseStatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const PurchaseStatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
  });

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
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      // Green statuses
      case 'completed':
      case 'paid':
      case 'submitted':
      case 'received':
      case 'closed':
        return const Color(0xFF10B981);

      // Blue statuses
      case 'to receive and bill':
      case 'to receive':
      case 'to bill':
        return const Color(0xFF3B82F6);

      // Orange/Yellow statuses
      case 'draft':
      case 'pending':
      case 'partly received':
      case 'partly paid':
      case 'unpaid':
        return const Color(0xFFF59E0B);

      // Red statuses
      case 'cancelled':
      case 'overdue':
      case 'return':
      case 'debit note issued':
        return const Color(0xFFEF4444);

      // Purple statuses
      case 'on hold':
        return const Color(0xFF8B5CF6);

      default:
        return const Color(0xFF6B7280);
    }
  }
}
