// ============================================================
// screens/splash/splash_screen.dart
// Widgets: Scaffold, AnimatedOpacity, Column, Image, Text,
//          CircularProgressIndicator, SizedBox, Center
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // AnimationController drives the fade-in logo animation
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    // ── Animation setup ──────────────────────────────────────
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim  = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    // ── Navigate after 2.5 s ─────────────────────────────────
    Future.delayed(const Duration(milliseconds: 2500), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final auth = context.read<AuthService>();
    await auth.init();

    if (!mounted) return;
    if (!auth.isAuthenticated) {
      context.go(AppRoutes.signIn);
    } else if (auth.currentUser!.role.isEmpty) {
      context.go(AppRoutes.roleSelection);
    } else if (auth.isGiver) {
      context.go(AppRoutes.giverDashboard);
    } else {
      context.go(AppRoutes.takerDashboard);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold – full screen with gradient background
    return Scaffold(
      body: Container(
        // Gradient background from orange to amber
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.giverPrimary, AppTheme.giverSecondary],
          ),
        ),
        // Center – centres all children
        child: Center(
          // Column – stacks logo, title, subtitle, loader vertically
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // AnimatedBuilder – drives scale + fade on logo
              AnimatedBuilder(
                animation: _controller,
                builder: (_, child) => Opacity(
                  opacity: _fadeAnim.value,
                  child: Transform.scale(
                    scale: _scaleAnim.value,
                    child: child,
                  ),
                ),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  // Icon – food/loop brand icon
                  child: const Icon(Icons.loop_rounded, size: 64, color: AppTheme.giverPrimary),
                ),
              ),

              const SizedBox(height: 28),

              // AnimatedOpacity – fade in app name
              FadeTransition(
                opacity: _fadeAnim,
                child: const Text(
                  'FoodLoop',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Text – tagline
              FadeTransition(
                opacity: _fadeAnim,
                child: const Text(
                  'Sharing Food. Reducing Waste.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // CircularProgressIndicator – loading spinner
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
