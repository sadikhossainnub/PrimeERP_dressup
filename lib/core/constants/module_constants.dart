import 'package:flutter/material.dart';

class ModuleItem {
  final String label;
  final IconData icon;
  final String? doctype;
  final String? route;
  final List<ModuleItem>? subItems;

  const ModuleItem({
    required this.label,
    required this.icon,
    this.doctype,
    this.route,
    this.subItems,
  });
}

const List<ModuleItem> appModules = [
  ModuleItem(
    label: 'Sales',
    icon: Icons.shopping_cart_outlined,
    route: '/sales',
    subItems: [
      ModuleItem(label: 'Sales Dashboard', icon: Icons.dashboard_outlined, route: '/sales'),
      ModuleItem(label: 'Sales Order', icon: Icons.description_outlined, doctype: 'Sales Order', route: '/sales/orders'),
      ModuleItem(label: 'Sales Invoice', icon: Icons.receipt_long_outlined, doctype: 'Sales Invoice', route: '/sales/invoices'),
      ModuleItem(label: 'Customer', icon: Icons.person_outline, doctype: 'Customer', route: '/sales/customers'),
      ModuleItem(label: 'Lead', icon: Icons.filter_list_alt, doctype: 'Lead'),
      ModuleItem(label: 'Quotation', icon: Icons.request_quote_outlined, doctype: 'Quotation'),
    ],
  ),
  ModuleItem(
    label: 'Purchase',
    icon: Icons.shopping_bag_outlined,
    route: '/purchase',
    subItems: [
      ModuleItem(label: 'Purchase Dashboard', icon: Icons.dashboard_outlined, route: '/purchase'),
      ModuleItem(label: 'Purchase Order', icon: Icons.description_outlined, doctype: 'Purchase Order', route: '/purchase/orders'),
      ModuleItem(label: 'Purchase Invoice', icon: Icons.receipt_outlined, doctype: 'Purchase Invoice', route: '/purchase/invoices'),
      ModuleItem(label: 'Supplier', icon: Icons.local_shipping_outlined, doctype: 'Supplier', route: '/purchase/suppliers'),
      ModuleItem(label: 'Purchase Receipt', icon: Icons.move_to_inbox_outlined, doctype: 'Purchase Receipt'),
      ModuleItem(label: 'Material Request', icon: Icons.assignment_outlined, doctype: 'Material Request'),
    ],
  ),
  ModuleItem(
    label: 'Inventory',
    icon: Icons.inventory_2_outlined,
    route: '/inventory',
    subItems: [
      ModuleItem(label: 'Inventory Dashboard', icon: Icons.dashboard_outlined, route: '/inventory'),
      ModuleItem(label: 'Item', icon: Icons.category_outlined, doctype: 'Item', route: '/inventory/items'),
      ModuleItem(label: 'Stock Entry', icon: Icons.sync_alt_outlined, doctype: 'Stock Entry', route: '/inventory/stock-entries'),
      ModuleItem(label: 'Warehouse', icon: Icons.warehouse_outlined, doctype: 'Warehouse', route: '/inventory/warehouses'),
    ],
  ),
  ModuleItem(
    label: 'Accounts',
    icon: Icons.account_balance_outlined,
    subItems: [
      ModuleItem(label: 'Payment Entry', icon: Icons.payments_outlined, doctype: 'Payment Entry'),
      ModuleItem(label: 'Journal Entry', icon: Icons.book_outlined, doctype: 'Journal Entry'),
      ModuleItem(label: 'Chart of Accounts', icon: Icons.account_tree_outlined, doctype: 'Account'),
    ],
  ),
  ModuleItem(
    label: 'HR & Payroll',
    icon: Icons.people_alt_outlined,
    route: '/hr',
    subItems: [
      ModuleItem(label: 'HR Dashboard', icon: Icons.dashboard_outlined, route: '/hr'),
      ModuleItem(label: 'Employee', icon: Icons.badge_outlined, doctype: 'Employee', route: '/hr/employees'),
      ModuleItem(label: 'Attendance', icon: Icons.how_to_reg_outlined, doctype: 'Attendance', route: '/hr/attendance'),
      ModuleItem(label: 'Leave Application', icon: Icons.event_note_outlined, doctype: 'Leave Application', route: '/hr/leaves'),
      ModuleItem(label: 'Salary Slip', icon: Icons.monetization_on_outlined, doctype: 'Salary Slip', route: '/hr/salary-slips'),
    ],
  ),
  ModuleItem(
    label: 'Manufacturing',
    icon: Icons.factory_outlined,
    subItems: [
      ModuleItem(label: 'BOM', icon: Icons.list_alt_outlined, doctype: 'BOM'),
      ModuleItem(label: 'Work Order', icon: Icons.build_outlined, doctype: 'Work Order'),
      ModuleItem(label: 'Job Card', icon: Icons.assignment_outlined, doctype: 'Job Card'),
    ],
  ),
  ModuleItem(
    label: 'Projects',
    icon: Icons.assignment_outlined,
    subItems: [
      ModuleItem(label: 'Project', icon: Icons.work_outline, doctype: 'Project'),
      ModuleItem(label: 'Task', icon: Icons.task_alt, doctype: 'Task'),
    ],
  ),
  ModuleItem(
    label: 'Assets',
    icon: Icons.web_asset_outlined,
    subItems: [
      ModuleItem(label: 'Asset', icon: Icons.apartment_outlined, doctype: 'Asset'),
      ModuleItem(label: 'Asset Maintenance', icon: Icons.settings_suggest_outlined, doctype: 'Asset Maintenance'),
    ],
  ),
  ModuleItem(
    label: 'CRM',
    icon: Icons.hail_outlined,
    subItems: [
      ModuleItem(label: 'Opportunity', icon: Icons.lightbulb_outline, doctype: 'Opportunity'),
      ModuleItem(label: 'Campaign', icon: Icons.campaign_outlined, doctype: 'Campaign'),
    ],
  ),
];
