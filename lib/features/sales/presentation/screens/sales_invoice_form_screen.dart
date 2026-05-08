import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../providers/sales_provider.dart';
import '../widgets/sales_status_badge.dart';
import '../../../purchase/presentation/widgets/purchase_item_table.dart';
import '../../../purchase/presentation/widgets/purchase_totals_card.dart';
import '../../../../frappe_core/presentation/widgets/workflow_actions_bar.dart';

class SalesInvoiceFormScreen extends ConsumerStatefulWidget {
  final String? name;
  const SalesInvoiceFormScreen({super.key, this.name});

  @override
  ConsumerState<SalesInvoiceFormScreen> createState() => _SalesInvoiceFormScreenState();
}

class _SalesInvoiceFormScreenState extends ConsumerState<SalesInvoiceFormScreen> {
  final bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    if (widget.name == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('New Sales Invoice'), backgroundColor: const Color(0xFF1E2A38), foregroundColor: Colors.white),
        body: const Center(child: Text('Use the generic form to create a new Sales Invoice.')),
      );
    }
    final docAsync = ref.watch(salesInvoiceDetailProvider(widget.name!));
    return docAsync.when(
      data: (doc) => _buildView(doc),
      loading: () => Scaffold(appBar: AppBar(title: Text(widget.name ?? ''), backgroundColor: const Color(0xFF1E2A38), foregroundColor: Colors.white), body: const LoadingWidget()),
      error: (err, _) => Scaffold(appBar: AppBar(title: Text(widget.name ?? ''), backgroundColor: const Color(0xFF1E2A38), foregroundColor: Colors.white), body: ErrorStateWidget(message: err.toString())),
    );
  }

  Widget _buildView(Map<String, dynamic> doc) {
    final name = doc['name']?.toString() ?? '';
    final status = doc['status']?.toString() ?? 'Draft';
    final cust = doc['customer_name']?.toString() ?? doc['customer']?.toString() ?? '';
    final postDate = doc['posting_date']?.toString() ?? '';
    final dueDate = doc['due_date']?.toString() ?? '';
    final company = doc['company']?.toString() ?? '';
    final currency = doc['currency']?.toString() ?? 'TK.';
    final items = (doc['items'] as List<dynamic>?) ?? [];
    final isReturn = (doc['is_return'] as num?)?.toInt() == 1;
    final outstanding = ((doc['outstanding_amount'] ?? 0) as num).toDouble();
    final formatter = NumberFormat('#,##0.00');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1E2A38), Color(0xFF2D3B4E)])),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(56, 8, 16, 16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                      Row(children: [
                        Expanded(child: Row(children: [
                          Flexible(child: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
                          if (isReturn) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)), child: const Text('RETURN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))))],
                        ])),
                        SalesStatusBadge(status: status),
                      ]),
                      const SizedBox(height: 4),
                      Text(cust, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
                      if (outstanding > 0) ...[
                        const SizedBox(height: 4),
                        Text('Outstanding: $currency ${formatter.format(outstanding)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                      ],
                    ]),
                  ),
                ),
              ),
            ),
          ),
          if (widget.name != null)
            SliverToBoxAdapter(
              child: WorkflowActionsBar(
                doctype: 'Sales Invoice',
                docname: widget.name!,
                currentDoc: doc,
                onWorkflowApplied: () {
                  ref.invalidate(salesInvoiceDetailProvider(widget.name!));
                },
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(delegate: SliverChildListDelegate([
              _card(children: [
                _row('Customer', cust),
                _row('Posting Date', _fmtDate(postDate)),
                _row('Due Date', _fmtDate(dueDate)),
                _row('Company', company),
                _row('Currency', currency),
                if (isReturn) _row('Is Return', 'Yes'),
              ]),
              const SizedBox(height: 16),
              PurchaseItemTable(items: items, currency: currency),
              PurchaseTotalsCard(doc: doc),
              const SizedBox(height: 80),
            ])),
          ),
        ],
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)))),
      ]),
    );
  }

  String _fmtDate(String d) {
    if (d.isEmpty) return '-';
    final dt = DateTime.tryParse(d);
    return dt != null ? DateFormat.yMMMd().format(dt) : d;
  }

}
