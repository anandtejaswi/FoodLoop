// ============================================================
// screens/shell/app_shell.dart  –  Bottom Navigation Shell
// Widgets: Scaffold, BottomNavigationBar, BottomNavigationBarItem,
//          SafeArea, Stack, AnimatedSwitcher
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';

class AppShell extends StatelessWidget {
  final Widget child;   // Current page from GoRouter ShellRoute
  final String role;    // 'giver' | 'taker'

  const AppShell({super.key, required this.child, required this.role});

  // ── Tab destinations per role ──────────────────────────────
  List<Map<String, dynamic>> get _tabs => role == 'giver'
      ? [
          {'icon': Icons.dashboard_rounded,     'label': 'Home',     'route': AppRoutes.giverDashboard},
          {'icon': Icons.add_circle_outline,    'label': 'Post',     'route': AppRoutes.postFood},
          {'icon': Icons.assignment_outlined,   'label': 'Requests', 'route': AppRoutes.giverRequests},
          {'icon': Icons.person_outline_rounded,'label': 'Profile',  'route': AppRoutes.giverProfile},
        ]
      : [
          {'icon': Icons.map_outlined,          'label': 'Map',      'route': AppRoutes.takerDashboard},
          {'icon': Icons.list_alt_rounded,      'label': 'Browse',   'route': AppRoutes.foodList},
          {'icon': Icons.inbox_outlined,        'label': 'Requests', 'route': AppRoutes.takerRequests},
          {'icon': Icons.person_outline_rounded,'label': 'Profile',  'route': AppRoutes.takerProfile},
        ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final tabs = _tabs;
    for (int i = 0; i < tabs.length; i++) {
      if (location.startsWith(tabs[i]['route'] as String)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final tabs   = _tabs;
    final idx    = _currentIndex(context);
    final color  = role == 'giver' ? AppTheme.giverPrimary : AppTheme.takerPrimary;

    // Scaffold – wraps the shell with bottom nav
    return Scaffold(
      // AnimatedSwitcher – smoothly transitions between pages
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: child,
      ),

      // BottomNavigationBar – tab bar at the bottom
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: BottomNavigationBar(
          currentIndex: idx,
          selectedItemColor: color,
          unselectedItemColor: AppTheme.textSecondary,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 11),
          onTap: (i) => context.go(tabs[i]['route'] as String),
          // BottomNavigationBarItem – each tab icon+label
          items: tabs.asMap().entries.map((entry) {
            final isActive = entry.key == idx;
            return BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? color.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(entry.value['icon'] as IconData),
              ),
              label: entry.value['label'] as String,
            );
          }).toList(),
        ),
      ),
    );
  }
}
