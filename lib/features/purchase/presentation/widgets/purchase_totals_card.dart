import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PurchaseTotalsCard extends StatelessWidget {
  final Map<String, dynamic> doc;

  const PurchaseTotalsCard({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final currency = doc['currency']?.toString() ?? 'TK.';
    final formatter = NumberFormat('#,##0.00');

    final netTotal = _toDouble(doc['net_total']);
    final totalTaxes = _toDouble(doc['total_taxes_and_charges']);
    final discount = _toDouble(doc['discount_amount']);
    final grandTotal = _toDouble(doc['grand_total']);
    final roundedTotal = _toDouble(doc['rounded_total']);
    final outstanding = _toDouble(doc['outstanding_amount']);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Totals',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          _buildRow('Net Total', '$currency ${formatter.format(netTotal)}'),
          if (totalTaxes > 0)
            _buildRow(
              'Taxes & Charges',
              '$currency ${formatter.format(totalTaxes)}',
            ),
          if (discount > 0)
            _buildRow(
              'Discount',
              '- $currency ${formatter.format(discount)}',
              valueColor: const Color(0xFF10B981),
            ),
          const Divider(height: 20),
          _buildRow(
            'Grand Total',
            '$currency ${formatter.format(grandTotal)}',
            isBold: true,
            valueColor: const Color(0xFF1E2A38),
          ),
          if (roundedTotal > 0 && roundedTotal != grandTotal)
            _buildRow(
              'Rounded Total',
              '$currency ${formatter.format(roundedTotal)}',
            ),
          if (outstanding > 0)
            _buildRow(
              'Outstanding',
              '$currency ${formatter.format(outstanding)}',
              valueColor: const Color(0xFFEF4444),
              isBold: true,
            ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }
}
