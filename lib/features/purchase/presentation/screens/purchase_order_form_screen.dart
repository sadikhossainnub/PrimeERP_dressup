import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../providers/purchase_provider.dart';
import '../widgets/purchase_status_badge.dart';
import '../widgets/purchase_item_table.dart';
import '../widgets/purchase_totals_card.dart';
import '../../../../frappe_core/presentation/widgets/workflow_actions_bar.dart';

class PurchaseOrderFormScreen extends ConsumerStatefulWidget {
  final String? name;
  const PurchaseOrderFormScreen({super.key, this.name});

  @override
  ConsumerState<PurchaseOrderFormScreen> createState() => _PurchaseOrderFormScreenState();
}

class _PurchaseOrderFormScreenState extends ConsumerState<PurchaseOrderFormScreen> {
  final bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    if (widget.name == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('New Purchase Order'), backgroundColor: const Color(0xFF1E2A38), foregroundColor: Colors.white),
        body: const Center(child: Text('Use the generic form to create a new Purchase Order.')),
      );
    }
    final docAsync = ref.watch(purchaseOrderDetailProvider(widget.name!));
    return docAsync.when(
      data: (doc) => _buildView(doc),
      loading: () => Scaffold(appBar: AppBar(title: Text(widget.name ?? ''), backgroundColor: const Color(0xFF1E2A38), foregroundColor: Colors.white), body: const LoadingWidget()),
      error: (err, _) => Scaffold(appBar: AppBar(title: Text(widget.name ?? ''), backgroundColor: const Color(0xFF1E2A38), foregroundColor: Colors.white), body: ErrorStateWidget(message: err.toString())),
    );
  }

  Widget _buildView(Map<String, dynamic> doc) {
    final name = doc['name']?.toString() ?? '';
    final status = doc['status']?.toString() ?? 'Draft';
    final supplier = doc['supplier_name']?.toString() ?? doc['supplier']?.toString() ?? '';
    final txDate = doc['transaction_date']?.toString() ?? '';
    final reqDate = doc['schedule_date']?.toString() ?? '';
    final company = doc['company']?.toString() ?? '';
    final currency = doc['currency']?.toString() ?? 'TK.';
    final items = (doc['items'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF1E2A38),
            foregroundColor: Colors.white,
            pinned: true,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1E2A38), Color(0xFF2D3B4E)])),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(56, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(children: [
                          Expanded(child: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
                          PurchaseStatusBadge(status: status),
                        ]),
                        const SizedBox(height: 4),
                        Text(supplier, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.name != null)
            SliverToBoxAdapter(
              child: WorkflowActionsBar(
                doctype: 'Purchase Order',
                docname: widget.name!,
                currentDoc: doc,
                onWorkflowApplied: () {
                  ref.invalidate(purchaseOrderDetailProvider(widget.name!));
                },
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(delegate: SliverChildListDelegate([
              _card(children: [
                _row('Supplier', supplier),
                _row('Transaction Date', _fmtDate(txDate)),
                _row('Required By', _fmtDate(reqDate)),
                _row('Company', company),
                _row('Currency', currency),
              ]),
              const SizedBox(height: 16),
              PurchaseItemTable(items: items, currency: currency),
              PurchaseTotalsCard(doc: doc),
              if (doc['terms'] != null && doc['terms'].toString().isNotEmpty) ...[
                const SizedBox(height: 16),
                _card(children: [
                  const Text('Terms & Conditions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
                  const SizedBox(height: 8),
                  Text(doc['terms'].toString(), style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5)),
                ]),
              ],
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
