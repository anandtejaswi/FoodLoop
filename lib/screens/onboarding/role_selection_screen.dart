// ============================================================
// screens/onboarding/role_selection_screen.dart
// Widgets: Scaffold, SafeArea, Column, Text, SizedBox,
//          GestureDetector, Container, AnimatedContainer,
//          Icon, ElevatedButton, Row, Expanded
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole; // 'giver' | 'taker' | null
  bool _saving = false;

  // ── Role card builder ─────────────────────────────────────
  Widget _roleCard({
    required String role,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required List<String> perks,
  }) {
    final isSelected = _selectedRole == role;

    // GestureDetector – tap to select role
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      // AnimatedContainer – animates border/shadow on selection
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 6))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row – icon badge + title + selected checkmark
            Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: isSelected ? color : AppTheme.textPrimary)),
                      Text(subtitle, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                // AnimatedOpacity – show checkmark when selected
                AnimatedOpacity(
                  opacity: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // List of perks
            ...perks.map((perk) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 16, color: color),
                  const SizedBox(width: 8),
                  Text(perk, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppTheme.textPrimary)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    if (_selectedRole == null) return;
    setState(() => _saving = true);
    try {
      await context.read<AuthService>().updateRole(_selectedRole!);
      if (!mounted) return;
      if (_selectedRole == 'giver') {
        context.go(AppRoutes.giverDashboard);
      } else {
        context.go(AppRoutes.takerDashboard);
      }
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold – Material page scaffold
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────
              const Text('I want to…', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppTheme.textSecondary, letterSpacing: 1.5)),
              const SizedBox(height: 6),
              const Text('Choose Your Role', style: TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              const Text('You can switch roles later from your profile.', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppTheme.textSecondary)),

              const SizedBox(height: 32),

              // ── Giver card ───────────────────────────────────
              _roleCard(
                role: 'giver',
                icon: Icons.volunteer_activism_rounded,
                title: 'Giver 🍱',
                subtitle: 'Share surplus food with others',
                color: AppTheme.giverPrimary,
                perks: ['Post available food listings', 'Track how much you\'ve shared', 'Earn points & impact badges'],
              ),

              const SizedBox(height: 20),

              // ── Taker card ───────────────────────────────────
              _roleCard(
                role: 'taker',
                icon: Icons.shopping_bag_outlined,
                title: 'Taker / NGO 🤝',
                subtitle: 'Find free food near you',
                color: AppTheme.takerPrimary,
                perks: ['Browse food on interactive map', 'Request & claim food easily', 'Rate your experience'],
              ),

              const SizedBox(height: 36),

              // ── Confirm button ───────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_selectedRole == null || _saving) ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text(_selectedRole == null ? 'Select a Role to Continue' : 'Continue as ${_selectedRole == "giver" ? "Giver" : "Taker"}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
