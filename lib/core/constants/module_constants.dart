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
    subItems: [
      ModuleItem(label: 'Sales Order', icon: Icons.description_outlined, doctype: 'Sales Order'),
      ModuleItem(label: 'Sales Invoice', icon: Icons.receipt_long_outlined, doctype: 'Sales Invoice'),
      ModuleItem(label: 'Customer', icon: Icons.person_outline, doctype: 'Customer'),
      ModuleItem(label: 'Lead', icon: Icons.filter_list_alt, doctype: 'Lead'),
      ModuleItem(label: 'Quotation', icon: Icons.request_quote_outlined, doctype: 'Quotation'),
    ],
  ),
  ModuleItem(
    label: 'Purchase',
    icon: Icons.shopping_bag_outlined,
    subItems: [
      ModuleItem(label: 'Purchase Order', icon: Icons.description_outlined, doctype: 'Purchase Order'),
      ModuleItem(label: 'Purchase Invoice', icon: Icons.receipt_outlined, doctype: 'Purchase Invoice'),
      ModuleItem(label: 'Supplier', icon: Icons.local_shipping_outlined, doctype: 'Supplier'),
    ],
  ),
  ModuleItem(
    label: 'Inventory',
    icon: Icons.inventory_2_outlined,
    subItems: [
      ModuleItem(label: 'Item', icon: Icons.category_outlined, doctype: 'Item'),
      ModuleItem(label: 'Stock Entry', icon: Icons.move_to_inbox_outlined, doctype: 'Stock Entry'),
      ModuleItem(label: 'Warehouse', icon: Icons.warehouse_outlined, doctype: 'Warehouse'),
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
    subItems: [
      ModuleItem(label: 'Employee', icon: Icons.badge_outlined, doctype: 'Employee'),
      ModuleItem(label: 'Attendance', icon: Icons.how_to_reg_outlined, doctype: 'Attendance'),
      ModuleItem(label: 'Leave Application', icon: Icons.event_note_outlined, doctype: 'Leave Application'),
      ModuleItem(label: 'Salary Slip', icon: Icons.monetization_on_outlined, doctype: 'Salary Slip'),
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
