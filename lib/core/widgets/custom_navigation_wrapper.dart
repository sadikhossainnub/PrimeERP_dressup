import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class CustomNavigationWrapper extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const CustomNavigationWrapper({
    super.key,
    required this.child,
    required this.currentPath,
  });

  int _getSelectedIndex(String path) {
    if (path.startsWith('/settings')) return 0;
    if (path.startsWith('/profile')) return 1;
    if (path == '/') return 2;
    if (path.startsWith('/notifications')) return 3;
    if (path.startsWith('/more')) return 4;
    return 2; // Default to Home
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/settings');
        break;
      case 1:
        context.go('/profile');
        break;
      case 2:
        context.go('/');
        break;
      case 3:
        context.go('/notifications');
        break;
      case 4:
        context.go('/more');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Crucial for CurvedNavigationBar to look right
      body: child,
      bottomNavigationBar: CurvedNavigationBar(
        index: _getSelectedIndex(currentPath),
        backgroundColor: Colors.transparent, // Background of the gap
        color: AppTheme.primaryColor, // Background of the bar itself
        buttonBackgroundColor:
            AppTheme.primaryColor, // Background of the active button circle
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.settings, color: Colors.white, size: 26),
          Icon(Icons.person, color: Colors.white, size: 26),
          Icon(Icons.home, color: Colors.white, size: 26),
          Icon(Icons.notifications, color: Colors.white, size: 26),
          Icon(Icons.more_vert, color: Colors.white, size: 26),
        ],
        onTap: (index) => _onTap(context, index),
      ),
    );
  }
}
