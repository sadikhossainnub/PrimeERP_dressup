import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../providers/hr_provider.dart';

class EmployeeDetailScreen extends ConsumerWidget {
  final String employee;
  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docAsync = ref.watch(employeeDetailProvider(employee));
    return docAsync.when(
      data: (doc) => _buildView(context, doc),
      loading: () => Scaffold(appBar: AppBar(title: Text(employee), backgroundColor: const Color(0xFF1E2A38), foregroundColor: Colors.white), body: const LoadingWidget()),
      error: (err, _) => Scaffold(appBar: AppBar(title: Text(employee), backgroundColor: const Color(0xFF1E2A38), foregroundColor: Colors.white), body: ErrorStateWidget(message: err.toString())),
    );
  }

  Widget _buildView(BuildContext context, Map<String, dynamic> doc) {
    final name = doc['name']?.toString() ?? '';
    final empName = doc['employee_name']?.toString() ?? name;
    final dept = doc['department']?.toString() ?? '';
    final desig = doc['designation']?.toString() ?? '';
    final status = doc['status']?.toString() ?? 'Active';
    final imageUrl = doc['image']?.toString();
    
    final email = doc['company_email']?.toString() ?? doc['personal_email']?.toString() ?? '';
    final phone = doc['cell_number']?.toString() ?? '';
    final branch = doc['branch']?.toString() ?? '';
    final doj = doc['date_of_joining']?.toString() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        title: const Text('Employee Profile'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () => context.push('/resource/Employee/$name/edit')),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF1E2A38),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Row(
                children: [
                  UserAvatar(userImage: imageUrl, firstName: empName, radius: 40),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(empName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(desig, style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.9))),
                        const SizedBox(height: 2),
                        Text(dept, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
                        const SizedBox(height: 8),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: status == 'Active' ? const Color(0xFF10B981) : const Color(0xFFEF4444), borderRadius: BorderRadius.circular(4)), child: Text(status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _card([
                    const Text('Contact Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38))),
                    const SizedBox(height: 16),
                    _row(Icons.email_outlined, 'Email', email.isNotEmpty ? email : '-'),
                    _row(Icons.phone_outlined, 'Phone', phone.isNotEmpty ? phone : '-'),
                  ]),
                  const SizedBox(height: 16),
                  _card([
                    const Text('Employment Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38))),
                    const SizedBox(height: 16),
                    _row(Icons.badge_outlined, 'Employee ID', name),
                    _row(Icons.business_outlined, 'Branch', branch.isNotEmpty ? branch : '-'),
                    _row(Icons.calendar_today_outlined, 'Date of Joining', _fmtDate(doj)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F2937))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(String d) {
    if (d.isEmpty) return '-';
    final dt = DateTime.tryParse(d);
    return dt != null ? DateFormat.yMMMd().format(dt) : d;
  }
}
