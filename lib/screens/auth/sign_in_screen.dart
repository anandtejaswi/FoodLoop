// ============================================================
// screens/auth/sign_in_screen.dart
// Widgets: Scaffold, SafeArea, SingleChildScrollView, Column,
//          Container, Text, SizedBox, ElevatedButton, GestureDetector,
//          InkWell, CircularProgressIndicator, Divider
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../utils/security_utils.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Validate email ─────────────────────────────────────────
  bool _validateEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return false;
    }
    if (!SecurityUtils.isValidEmail(email)) {
      setState(() => _emailError = 'Invalid email format');
      return false;
    }
    setState(() => _emailError = null);
    return true;
  }

  // ── Sign In handler ────────────────────────────────────
  Future<void> _handleSignIn() async {
    if (!_validateEmail()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password is required'), backgroundColor: AppTheme.error),
      );
      return;
    }

    // Check for suspicious input patterns
    if (SecurityUtils.hasSuspiciousPatterns(email) || SecurityUtils.hasSuspiciousPatterns(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid input detected'), backgroundColor: AppTheme.error),
      );
      return;
    }

    final auth = context.read<AuthService>();

    // Check rate limiting
    if (auth.isRateLimited) {
      final remaining = auth.remainingLockout;
      final minutes = remaining?.inMinutes ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Too many failed attempts. Please try again in ${minutes + 1} minutes'),
          backgroundColor: AppTheme.error,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    try {
      await auth.signIn(email, password);
      if (!mounted) return;

      final user = auth.currentUser;
      if (user == null) return;

      // Route based on role
      if (user.role.isEmpty) {
        context.go(AppRoutes.roleSelection);
      } else if (user.role == 'giver') {
        context.go(AppRoutes.giverDashboard);
      } else {
        context.go(AppRoutes.takerDashboard);
      }
    } catch (e) {
      if (!mounted) return;
      final auth = context.read<AuthService>();
      final remaining = auth.remainingAttempts;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign in failed. ${remaining > 0 ? 'Attempts remaining: $remaining' : ''}'),
          backgroundColor: AppTheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        decoration: const BoxDecoration(
          color: AppTheme.background,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                const SizedBox(height: 80),

                // ── Welcome title ──────────────────────────
                const Text(
                  'Welcome to\nFoodLoop',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 34,
                    height: 1.1,
                    letterSpacing: -0.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary, // Using primary color to make it pop!
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // ── Sub-title ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Share surplus food, connect your community, and make a difference today',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      height: 1.5,
                      letterSpacing: 0.2,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Email input ────────────────────────────
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => _validateEmail(),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    errorText: _emailError,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _emailError != null ? AppTheme.error : Colors.grey.shade300),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.error),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Password input ─────────────────────────
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Sign In button ─────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: (auth.isLoading || auth.isRateLimited) ? null : _handleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Sign In'),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Don't have account? ────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account? ',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppTheme.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.signUp),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
