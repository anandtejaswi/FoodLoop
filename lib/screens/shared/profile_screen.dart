// ============================================================
// screens/shared/profile_screen.dart
// Widgets: Scaffold, SliverAppBar, SliverList, CustomScrollView,
//          CircleAvatar, Text, Row, Column, Card, GridView,
//          ElevatedButton, Icon, Divider, LinearProgressIndicator
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ── Stat card ─────────────────────────────────────────────
  Widget _stat(String value, String label, Color color) => Column(
    children: [
      Text(value, style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.textSecondary), textAlign: TextAlign.center),
    ],
  );

  // ── Badge tile ────────────────────────────────────────────
  Widget _badge(String emoji, String label, bool earned) => Column(
    children: [
      Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: earned ? const Color(0xFFFFF3CD) : Colors.grey.shade100,
          border: Border.all(color: earned ? const Color(0xFFF39C12) : Colors.grey.shade300, width: 2),
        ),
        child: Center(child: Text(emoji, style: TextStyle(fontSize: 28, color: earned ? null : Colors.grey))),
      ),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: earned ? AppTheme.textPrimary : AppTheme.textSecondary), textAlign: TextAlign.center),
    ],
  );

  // ── Menu tile ─────────────────────────────────────────────
  Widget _menuTile(IconData icon, String title, VoidCallback onTap, {Color? iconColor}) => ListTile(
    leading: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: (iconColor ?? AppTheme.giverPrimary).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: iconColor ?? AppTheme.giverPrimary, size: 20),
    ),
    title: Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500)),
    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
    onTap: onTap,
  );

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final isGiver = user?.role == 'giver';
    final impact  = user?.impactScore ?? 0;
    final points  = user?.points ?? 0;

    // Scaffold – page root
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar – collapsible profile header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // CircleAvatar – user photo
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                        child: user?.avatarUrl == null ? const Icon(Icons.person_rounded, size: 44, color: Colors.white) : null,
                      ),
                      const SizedBox(height: 12),
                      Text(user?.name ?? 'User', style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                        child: Text(isGiver ? '🍱 Giver' : '🤝 Taker', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // SliverList – scrollable profile body
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),

              // ── Stats row ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat('$impact kg', 'Food Saved', AppTheme.primary),
                        Container(width: 1, height: 40, color: Colors.grey.shade200),
                        _stat('$points',    'Points',     const Color(0xFFF39C12)),
                        Container(width: 1, height: 40, color: Colors.grey.shade200),
                        _stat(user?.rating.toStringAsFixed(1) ?? '–', 'Rating', AppTheme.primary),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Impact progress ────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🌱 Impact Progress', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700)),
                            const Spacer(),
                            Text('$impact / 100 kg', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppTheme.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // LinearProgressIndicator – impact bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (impact / 100).clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Keep sharing to unlock the next badge!', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Badges ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Badges', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    // Row – scrollable badge icons
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _badge('🌟', 'First Share',  points > 0),
                          const SizedBox(width: 16),
                          _badge('🏆', 'Super Giver',  impact >= 50),
                          const SizedBox(width: 16),
                          _badge('💚', '100 kg Saved', impact >= 100),
                          const SizedBox(width: 16),
                          _badge('🔥', '10-Day Streak', false),
                          const SizedBox(width: 16),
                          _badge('🌍', 'Eco Hero',     impact >= 200),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Menu items ─────────────────────────────
              const Divider(indent: 20, endIndent: 20),
              _menuTile(Icons.swap_horiz_rounded,   'Switch Role',  () => context.go(AppRoutes.roleSelection), iconColor: Colors.grey),
              _menuTile(Icons.settings_outlined,    'Settings',     () => context.go(AppRoutes.settings), iconColor: AppTheme.primary),
              _menuTile(Icons.logout_rounded,       'Sign Out',
                () async {
                  await context.read<AuthService>().signOut();
                  if (context.mounted) context.go(AppRoutes.signIn);
                },
                iconColor: AppTheme.error,
              ),

              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }
}
