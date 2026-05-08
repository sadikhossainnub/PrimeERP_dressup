import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../frappe_core/data/providers/frappe_provider.dart';

// ─── Data Classes ───

class HRSummary {
  final int totalEmployees;
  final int presentToday;
  final int leaveApplications;
  const HRSummary({this.totalEmployees = 0, this.presentToday = 0, this.leaveApplications = 0});
}

class DepartmentStats {
  final String department;
  final int count;
  final int colorHex;
  const DepartmentStats(this.department, this.count, this.colorHex);
}

class HRFilterParams {
  final String? department;
  final String? designation;
  final String? searchQuery;
  final int limitStart;
  final int limitPageLength;

  const HRFilterParams({this.department, this.designation, this.searchQuery, this.limitStart = 0, this.limitPageLength = 20});

  List<List<dynamic>> toEmployeeFilters() {
    final filters = <List<dynamic>>[];
    if (department != null && department!.isNotEmpty) filters.add(['department', '=', department]);
    if (designation != null && designation!.isNotEmpty) filters.add(['designation', '=', designation]);
    if (searchQuery != null && searchQuery!.isNotEmpty) filters.add(['employee_name', 'like', '%$searchQuery%']);
    return filters;
  }
}

// ─── Dashboard Summary ───

final hrSummaryProvider = FutureProvider<HRSummary>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);
  final today = DateTime.now().toIso8601String().split('T')[0];

  try {
    final totalEmployees = await repository.getCount('Employee', filters: [['status', '=', 'Active']]);
    final presentToday = await repository.getCount('Attendance', filters: [['attendance_date', '=', today], ['status', 'in', ['Present', 'Half Day', 'Work From Home']]]);
    final leaves = await repository.getCount('Leave Application', filters: [['status', '=', 'Open']]);

    return HRSummary(totalEmployees: totalEmployees, presentToday: presentToday, leaveApplications: leaves);
  } catch (e) { return const HRSummary(); }
});

// ─── Department Statistics ───

final hrDepartmentStatsProvider = FutureProvider<List<DepartmentStats>>((ref) async {
  final repository = ref.watch(frappeRepositoryProvider);
  const colors = [0xFF3B82F6, 0xFF10B981, 0xFFF59E0B, 0xFFEF4444, 0xFF8B5CF6, 0xFFEC4899];
  try {
    final list = await repository.getList('Employee', fields: ['department'], filters: [['status', '=', 'Active']], limitPageLength: 5000);
    final Map<String, int> deptTotals = {};
    for (var doc in list) {
      final dept = doc['department']?.toString() ?? 'Unassigned';
      deptTotals[dept] = (deptTotals[dept] ?? 0) + 1;
    }
    final sorted = deptTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(6).toList().asMap().entries.map((e) => DepartmentStats(e.value.key, e.value.value, colors[e.key % colors.length])).toList();
  } catch (e) { return []; }
});

// ─── Employee List ───

final employeeListProvider = FutureProvider.family<List<Map<String, dynamic>>, HRFilterParams>((ref, params) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    return await repository.getList('Employee', fields: ['name', 'employee_name', 'department', 'designation', 'status', 'image'], filters: params.toEmployeeFilters().isNotEmpty ? params.toEmployeeFilters() : null, limitStart: params.limitStart, limitPageLength: params.limitPageLength, orderBy: 'employee_name asc');
  } catch (e) { return []; }
});

// ─── Leave Applications List ───

final leaveApplicationListProvider = FutureProvider.family<List<Map<String, dynamic>>, HRFilterParams>((ref, params) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    return await repository.getList('Leave Application', fields: ['name', 'employee_name', 'leave_type', 'from_date', 'to_date', 'total_leave_days', 'status'], limitStart: params.limitStart, limitPageLength: params.limitPageLength, orderBy: 'creation desc');
  } catch (e) { return []; }
});

// ─── Salary Slips List ───

final salarySlipListProvider = FutureProvider.family<List<Map<String, dynamic>>, HRFilterParams>((ref, params) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    return await repository.getList('Salary Slip', fields: ['name', 'employee_name', 'start_date', 'end_date', 'gross_pay', 'net_pay', 'status'], limitStart: params.limitStart, limitPageLength: params.limitPageLength, orderBy: 'creation desc');
  } catch (e) { return []; }
});

// ─── Attendance List ───

final attendanceListProvider = FutureProvider.family<List<Map<String, dynamic>>, HRFilterParams>((ref, params) async {
  final repository = ref.watch(frappeRepositoryProvider);
  try {
    return await repository.getList('Attendance', fields: ['name', 'employee_name', 'attendance_date', 'status', 'shift'], limitStart: params.limitStart, limitPageLength: params.limitPageLength, orderBy: 'attendance_date desc');
  } catch (e) { return []; }
});

// ─── Detail Providers ───

final employeeDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, name) async {
  final ds = ref.watch(frappeRemoteDsProvider);
  return await ds.getDoc('Employee', name);
});
