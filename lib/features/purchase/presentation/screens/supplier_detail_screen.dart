import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../providers/purchase_provider.dart';
import '../widgets/purchase_status_badge.dart';

class SupplierDetailScreen extends ConsumerWidget {
  final String name;
  const SupplierDetailScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docAsync = ref.watch(supplierDetailProvider(name));

    return docAsync.when(
      data: (doc) => _buildView(context, ref, doc),
      loading: () => Scaffold(
        appBar: AppBar(title: Text(name), backgroundColor: const Color(0xFF1E2A38), foregroundColor: Colors.white),
        body: const LoadingWidget(),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: Text(name), backgroundColor: const Color(0xFF1E2A38), foregroundColor: Colors.white),
        body: ErrorStateWidget(message: err.toString()),
      ),
    );
  }

  Widget _buildView(BuildContext context, WidgetRef ref, Map<String, dynamic> doc) {
    final supplierName = doc['supplier_name']?.toString() ?? name;
    final group = doc['supplier_group']?.toString() ?? '';
    final type = doc['supplier_type']?.toString() ?? '';
    final country = doc['country']?.toString() ?? '';
    final disabled = (doc['disabled'] as num?)?.toInt() == 1;
    final initial = supplierName.isNotEmpty ? supplierName[0].toUpperCase() : '?';
    final phone = doc['mobile_no']?.toString() ?? doc['phone']?.toString() ?? '';
    final email = doc['email_id']?.toString() ?? '';
    final website = doc['website']?.toString() ?? '';
    final taxId = doc['tax_id']?.toString() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      body: DefaultTabController(
        length: 2,
        child: CustomScrollView(
          slivers: [
            // ─── App Bar ───
            SliverAppBar(
              backgroundColor: const Color(0xFF1E2A38),
              foregroundColor: Colors.white,
              pinned: true,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF1E2A38), Color(0xFF2D3B4E)]),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(56, 8, 16, 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [_getColor(initial), _getColor(initial).withValues(alpha: 0.7)]),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(child: Text(initial, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(supplierName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      if (group.isNotEmpty) _headerChip(group),
                                      if (type.isNotEmpty) ...[const SizedBox(width: 6), _headerChip(type)],
                                      if (disabled) ...[const SizedBox(width: 6), _headerChip('Disabled', isAlert: true)],
                                    ]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ─── Body ───
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Quick Actions
                  Row(children: [
                    _actionBtn(context, Icons.add_shopping_cart, 'New PO', const Color(0xFF3B82F6), () => context.push('/resource/Purchase Order/new')),
                    const SizedBox(width: 10),
                    _actionBtn(context, Icons.receipt_long_outlined, 'New Invoice', const Color(0xFF10B981), () => context.push('/resource/Purchase Invoice/new')),
                    if (phone.isNotEmpty) ...[const SizedBox(width: 10), _actionBtn(context, Icons.phone, 'Call', const Color(0xFF8B5CF6), () {})],
                    if (email.isNotEmpty) ...[const SizedBox(width: 10), _actionBtn(context, Icons.email_outlined, 'Email', const Color(0xFFF59E0B), () {})],
                  ]),
                  const SizedBox(height: 16),

                  // Contact Info
                  _card(title: 'Contact Information', children: [
                    if (phone.isNotEmpty) _infoRow(Icons.phone_outlined, 'Phone', phone),
                    if (email.isNotEmpty) _infoRow(Icons.email_outlined, 'Email', email),
                    if (website.isNotEmpty) _infoRow(Icons.language, 'Website', website),
                    if (country.isNotEmpty) _infoRow(Icons.public, 'Country', country),
                    if (taxId.isNotEmpty) _infoRow(Icons.assignment_ind_outlined, 'Tax ID', taxId),
                    if (phone.isEmpty && email.isEmpty && website.isEmpty && country.isEmpty && taxId.isEmpty)
                      const Padding(padding: EdgeInsets.all(8), child: Text('No contact information available', style: TextStyle(color: Color(0xFF9CA3AF)))),
                  ]),
                  const SizedBox(height: 16),

                  // Purchase Orders
                  _buildTransactionSection(context, ref, 'Recent Purchase Orders', supplierPurchaseOrdersProvider(name), isPO: true),
                  const SizedBox(height: 16),

                  // Purchase Invoices
                  _buildTransactionSection(context, ref, 'Recent Purchase Invoices', supplierPurchaseInvoicesProvider(name), isPO: false),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionSection(
    BuildContext context,
    WidgetRef ref,
    String title,
    FutureProvider<List<Map<String, dynamic>>> provider, {
    required bool isPO,
  }) {
    final dataAsync = ref.watch(provider);
    final formatter = NumberFormat('#,##0.00');

    return _card(title: title, children: [
      dataAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Padding(padding: EdgeInsets.all(12), child: Text('No records found', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)));
          }
          return Column(
            children: items.take(5).map((item) {
              final n = item['name']?.toString() ?? '';
              final total = ((item['grand_total'] ?? 0) as num).toDouble();
              final status = item['status']?.toString() ?? '';
              final date = isPO ? (item['transaction_date']?.toString() ?? '') : (item['posting_date']?.toString() ?? '');
              return InkWell(
                onTap: () {
                  if (isPO) {
                    context.push('/purchase/orders/$n');
                  } else {
                    context.push('/purchase/invoices/$n');
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(n, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
                      if (date.isNotEmpty) Text(DateFormat.yMMMd().format(DateTime.tryParse(date) ?? DateTime.now()), style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('TK. ${formatter.format(total)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38))),
                      if (status.isNotEmpty) ...[const SizedBox(height: 4), PurchaseStatusBadge(status: status, fontSize: 9)],
                    ]),
                  ]),
                ),
              );
            }).toList(),
          );
        },
        loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
        error: (e, _) => Padding(padding: const EdgeInsets.all(8), child: Text('Error: $e', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12))),
      ),
    ]);
  }

  Widget _card({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 10),
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1F2937)))),
      ]),
    );
  }

  Widget _headerChip(String text, {bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAlert ? const Color(0xFFEF4444).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isAlert ? const Color(0xFFEF4444) : Colors.white.withValues(alpha: 0.9))),
    );
  }

  Widget _actionBtn(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))]),
          child: Column(children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF374151)), textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }

  Color _getColor(String letter) {
    const colors = [Color(0xFF3B82F6), Color(0xFF10B981), Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFF06B6D4)];
    return colors[letter.codeUnitAt(0) % colors.length];
  }
}
