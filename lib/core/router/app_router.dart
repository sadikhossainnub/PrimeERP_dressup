import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/more_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../frappe_core/presentation/screens/generic_list_screen.dart';
import '../../frappe_core/presentation/screens/generic_form_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../frappe_core/presentation/providers/permission_provider.dart';
import '../../frappe_core/presentation/providers/user_role_provider.dart';

import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../core/screens/unauthorized_screen.dart';

// Purchase Module screens
import '../../features/purchase/presentation/screens/purchase_dashboard_screen.dart';
import '../../features/purchase/presentation/screens/purchase_order_list_screen.dart';
import '../../features/purchase/presentation/screens/purchase_order_form_screen.dart';
import '../../features/purchase/presentation/screens/purchase_invoice_list_screen.dart';
import '../../features/purchase/presentation/screens/purchase_invoice_form_screen.dart';
import '../../features/purchase/presentation/screens/supplier_list_screen.dart';
import '../../features/purchase/presentation/screens/supplier_detail_screen.dart';

// Sales Module screens
import '../../features/sales/presentation/screens/sales_dashboard_screen.dart';
import '../../features/sales/presentation/screens/sales_order_list_screen.dart';
import '../../features/sales/presentation/screens/sales_order_form_screen.dart';
import '../../features/sales/presentation/screens/sales_invoice_list_screen.dart';
import '../../features/sales/presentation/screens/sales_invoice_form_screen.dart';
import '../../features/sales/presentation/screens/customer_list_screen.dart';
import '../../features/sales/presentation/screens/customer_detail_screen.dart';

// Inventory Module screens
import '../../features/inventory/presentation/screens/inventory_dashboard_screen.dart';
import '../../features/inventory/presentation/screens/item_list_screen.dart';
import '../../features/inventory/presentation/screens/item_detail_screen.dart';
import '../../features/inventory/presentation/screens/stock_entry_list_screen.dart';
import '../../features/inventory/presentation/screens/stock_entry_form_screen.dart';
import '../../features/inventory/presentation/screens/warehouse_list_screen.dart';

// HR Module screens
import '../../features/hr/presentation/screens/hr_dashboard_screen.dart';
import '../../features/hr/presentation/screens/employee_list_screen.dart';
import '../../features/hr/presentation/screens/employee_detail_screen.dart';
import '../../features/hr/presentation/screens/attendance_list_screen.dart';
import '../../features/hr/presentation/screens/leave_application_list_screen.dart';
import '../../features/hr/presentation/screens/salary_slip_list_screen.dart';

import '../widgets/custom_navigation_wrapper.dart';
import '../constants/module_constants.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  // Build route-to-doctype mapping from appModules
  final Map<String, String?> routeToDoctype = {};
  for (final module in appModules) {
    if (module.route != null && module.doctype != null) {
      routeToDoctype[module.route!] = module.doctype;
    }
    if (module.subItems != null) {
      for (final sub in module.subItems!) {
        if (sub.route != null && sub.doctype != null) {
          routeToDoctype[sub.route!] = sub.doctype;
        }
      }
    }
  }

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';

      // Permission check for authenticated users
      if (isLoggedIn) {
        final currentPath = state.matchedLocation;
        
        // Skip permission check for non-module routes
        if (currentPath == '/' ||
            currentPath.startsWith('/resource/') ||
            currentPath.startsWith('/settings') ||
            currentPath.startsWith('/profile') ||
            currentPath.startsWith('/notifications') ||
            currentPath.startsWith('/more') ||
            currentPath.startsWith('/unauthorized')) {
          return null;
        }

        // Check if this route has an associated doctype
        final doctype = routeToDoctype[currentPath];
        if (doctype != null) {
          final permission = ref.read(userPermissionsProvider(doctype));
          
          permission.whenData((perms) {
            if (!perms.canRead) {
              context.push('/unauthorized');
            }
          });
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/unauthorized', builder: (context, state) => const UnauthorizedScreen()),
      ShellRoute(
        builder: (context, state, child) => CustomNavigationWrapper(
          currentPath: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/resource/:doctype',
            builder: (context, state) =>
                GenericListScreen(doctype: state.pathParameters['doctype']!),
          ),
          GoRoute(
            path: '/resource/:doctype/:name',
            builder: (context, state) => GenericFormScreen(
              doctype: state.pathParameters['doctype']!,
              name: state.pathParameters['name'],
            ),
          ),
          GoRoute(
            path: '/resource/:doctype/new',
            builder: (context, state) =>
                GenericFormScreen(doctype: state.pathParameters['doctype']!),
          ),

          // ─── Purchase Module Routes ───
          GoRoute(
            path: '/purchase',
            builder: (context, state) => const PurchaseDashboardScreen(),
          ),
          GoRoute(
            path: '/purchase/orders',
            builder: (context, state) => const PurchaseOrderListScreen(),
          ),
          GoRoute(
            path: '/purchase/orders/new',
            builder: (context, state) => const PurchaseOrderFormScreen(),
          ),
          GoRoute(
            path: '/purchase/orders/:name',
            builder: (context, state) => PurchaseOrderFormScreen(
              name: state.pathParameters['name'],
            ),
          ),
          GoRoute(
            path: '/purchase/invoices',
            builder: (context, state) => const PurchaseInvoiceListScreen(),
          ),
          GoRoute(
            path: '/purchase/invoices/new',
            builder: (context, state) => const PurchaseInvoiceFormScreen(),
          ),
          GoRoute(
            path: '/purchase/invoices/:name',
            builder: (context, state) => PurchaseInvoiceFormScreen(
              name: state.pathParameters['name'],
            ),
          ),
          GoRoute(
            path: '/purchase/suppliers',
            builder: (context, state) => const SupplierListScreen(),
          ),
          GoRoute(
            path: '/purchase/suppliers/:name',
            builder: (context, state) => SupplierDetailScreen(
              name: state.pathParameters['name']!,
            ),
          ),

          // ─── Sales Module Routes ───
          GoRoute(
            path: '/sales',
            builder: (context, state) => const SalesDashboardScreen(),
          ),
          GoRoute(
            path: '/sales/orders',
            builder: (context, state) => const SalesOrderListScreen(),
          ),
          GoRoute(
            path: '/sales/orders/new',
            builder: (context, state) => const SalesOrderFormScreen(),
          ),
          GoRoute(
            path: '/sales/orders/:name',
            builder: (context, state) => SalesOrderFormScreen(
              name: state.pathParameters['name'],
            ),
          ),
          GoRoute(
            path: '/sales/invoices',
            builder: (context, state) => const SalesInvoiceListScreen(),
          ),
          GoRoute(
            path: '/sales/invoices/new',
            builder: (context, state) => const SalesInvoiceFormScreen(),
          ),
          GoRoute(
            path: '/sales/invoices/:name',
            builder: (context, state) => SalesInvoiceFormScreen(
              name: state.pathParameters['name'],
            ),
          ),
          GoRoute(
            path: '/sales/customers',
            builder: (context, state) => const CustomerListScreen(),
          ),
          GoRoute(
            path: '/sales/customers/:name',
            builder: (context, state) => CustomerDetailScreen(
              customer: state.pathParameters['name']!,
            ),
          ),

          // ─── Inventory Module Routes ───
          GoRoute(
            path: '/inventory',
            builder: (context, state) => const InventoryDashboardScreen(),
          ),
          GoRoute(
            path: '/inventory/items',
            builder: (context, state) => const ItemListScreen(),
          ),
          GoRoute(
            path: '/inventory/items/:name',
            builder: (context, state) => ItemDetailScreen(
              name: state.pathParameters['name']!,
            ),
          ),
          GoRoute(
            path: '/inventory/stock-entries',
            builder: (context, state) => const StockEntryListScreen(),
          ),
          GoRoute(
            path: '/inventory/stock-entries/new',
            builder: (context, state) => const StockEntryFormScreen(),
          ),
          GoRoute(
            path: '/inventory/stock-entries/:name',
            builder: (context, state) => StockEntryFormScreen(
              name: state.pathParameters['name'],
            ),
          ),
          GoRoute(
            path: '/inventory/warehouses',
            builder: (context, state) => const WarehouseListScreen(),
          ),

          // ─── HR & Payroll Module Routes ───
          GoRoute(
            path: '/hr',
            builder: (context, state) => const HRDashboardScreen(),
          ),
          GoRoute(
            path: '/hr/employees',
            builder: (context, state) => const EmployeeListScreen(),
          ),
          GoRoute(
            path: '/hr/employees/:name',
            builder: (context, state) => EmployeeDetailScreen(
              employee: state.pathParameters['name']!,
            ),
          ),
          GoRoute(
            path: '/hr/attendance',
            builder: (context, state) => const AttendanceListScreen(),
          ),
          GoRoute(
            path: '/hr/leaves',
            builder: (context, state) => const LeaveApplicationListScreen(),
          ),
          GoRoute(
            path: '/hr/salary-slips',
            builder: (context, state) => const SalarySlipListScreen(),
          ),

          // Placeholder routes for bottom nav items
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationScreen(),
          ),
          GoRoute(
            path: '/more',
            builder: (context, state) => const MoreScreen(),
          ),
        ],
      ),
    ],
  );
});

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    _subscription = ref.listen(
      authProvider,
      (previous, next) => notifyListeners(),
    );
  }

  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
