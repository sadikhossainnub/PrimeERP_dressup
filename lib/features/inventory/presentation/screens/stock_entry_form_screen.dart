import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../frappe_core/presentation/widgets/workflow_actions_bar.dart';
import '../providers/inventory_provider.dart';

class StockEntryFormScreen extends ConsumerStatefulWidget {
  final String? name;
  const StockEntryFormScreen({super.key, this.name});

  @override
  ConsumerState<StockEntryFormScreen> createState() => _StockEntryFormScreenState();
}

class _StockEntryFormScreenState extends ConsumerState<StockEntryFormScreen> {
  final bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    if (widget.name == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('New Stock Entry'), backgroundColor: const Color(0xFF1E2A38), foregroundColor: Colors.white),
        body: const Center(child: Text('Use the generic form to create a new Stock Entry.')),
      );
    }
    final docAsync = ref.watch(stockEntryDetailProvider(widget.name!));
    return docAsync.when(
      data: (doc) => _buildView(doc),
      loading: () => Scaffold(appBar: AppBar(title: Text(widget.name ?? ''), backgroundColor: const Color(0xFF1E2A38), foregroundColor: Colors.white), body: const LoadingWidget()),
      error: (err, _) => Scaffold(appBar: AppBar(title: Text(widget.name ?? ''), backgroundColor: const Color(0xFF1E2A38), foregroundColor: Colors.white), body: ErrorStateWidget(message: err.toString())),
    );
  }

  Widget _buildView(Map<String, dynamic> doc) {
    final name = doc['name']?.toString() ?? '';
    final purpose = doc['purpose']?.toString() ?? '';
    final docstatus = (doc['docstatus'] as num?)?.toInt() ?? 0;
    final date = doc['posting_date']?.toString() ?? '';
    final fromWh = doc['from_warehouse']?.toString() ?? '';
    final toWh = doc['to_warehouse']?.toString() ?? '';
    final items = (doc['items'] as List<dynamic>?) ?? [];

    Color badgeColor = docstatus == 1 ? const Color(0xFF10B981) : docstatus == 2 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
    String statusStr = docstatus == 1 ? 'Submitted' : docstatus == 2 ? 'Cancelled' : 'Draft';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF1E2A38), foregroundColor: Colors.white, pinned: true, expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1E2A38), Color(0xFF2D3B4E)])),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(56, 8, 16, 16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                      Row(children: [
                        Expanded(child: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Text(statusStr, style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold))),
                      ]),
                      const SizedBox(height: 4),
                      Text(purpose, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
                    ]),
                  ),
                ),
              ),
            ),
          ),
          if (widget.name != null)
            SliverToBoxAdapter(
              child: WorkflowActionsBar(
                doctype: 'Stock Entry',
                docname: widget.name!,
                currentDoc: doc,
                onWorkflowApplied: () {
                  ref.invalidate(stockEntryDetailProvider(widget.name!));
                },
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(delegate: SliverChildListDelegate([
              _card(children: [
                _row('Purpose', purpose),
                _row('Posting Date', _fmtDate(date)),
                if (fromWh.isNotEmpty) _row('Default Source', fromWh),
                if (toWh.isNotEmpty) _row('Default Target', toWh),
              ]),
              const SizedBox(height: 16),
              const Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38))),
              const SizedBox(height: 8),
              ...items.map((i) => _itemCard(i as Map<String, dynamic>)),
              const SizedBox(height: 80),
            ])),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(Map<String, dynamic> item) {
    final itemCode = item['item_code']?.toString() ?? '';
    final itemName = item['item_name']?.toString() ?? itemCode;
    final qty = ((item['qty'] ?? 0) as num).toDouble();
    final uom = item['uom']?.toString() ?? '';
    final sWh = item['s_warehouse']?.toString() ?? '';
    final tWh = item['t_warehouse']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFE5E7EB))),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(itemName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6)),
                  child: Text('$qty $uom', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            if (sWh.isNotEmpty || tWh.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (sWh.isNotEmpty) Expanded(child: _whPill('From', sWh, const Color(0xFFEF4444))),
                  if (sWh.isNotEmpty && tWh.isNotEmpty) const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, size: 14, color: Color(0xFF9CA3AF))),
                  if (tWh.isNotEmpty) Expanded(child: _whPill('To', tWh, const Color(0xFF10B981))),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _whPill(String label, String wh, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
        Text(wh, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
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
