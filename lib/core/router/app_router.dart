import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/more_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../frappe_core/presentation/screens/generic_list_screen.dart';
import '../../frappe_core/presentation/screens/generic_form_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';

import '../widgets/custom_navigation_wrapper.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
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
