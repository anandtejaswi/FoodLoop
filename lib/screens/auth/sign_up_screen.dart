// ============================================================
// screens/auth/sign_up_screen.dart
// Widgets: Scaffold, SafeArea, SingleChildScrollView, Column,
//          Text, SizedBox, ElevatedButton, GestureDetector,
//          Container, CircularProgressIndicator
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../utils/security_utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _passwordStrengthMessage;
  PasswordStrength? _passwordStrength;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Validate name ──────────────────────────────────────────
  bool _validateName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Name is required');
      return false;
    }
    if (name.length < 2) {
      setState(() => _nameError = 'Name must be at least 2 characters');
      return false;
    }
    if (!SecurityUtils.isValidName(name)) {
      setState(() => _nameError = 'Name can only contain letters and spaces');
      return false;
    }
    setState(() => _nameError = null);
    return true;
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

  // ── Validate password strength ──────────────────────────────
  bool _validatePassword() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      return false;
    }
    
    final strength = SecurityUtils.checkPasswordStrength(password);
    setState(() {
      _passwordStrength = strength;
      _passwordStrengthMessage = SecurityUtils.getPasswordStrengthMessage(strength);
      if (strength == PasswordStrength.weak) {
        _passwordError = _passwordStrengthMessage;
        return;
      }
      _passwordError = null;
    });
    
    return strength != PasswordStrength.weak;
  }

  Future<void> _handleSignUp() async {
    // Validate all fields
    final nameValid = _validateName();
    final emailValid = _validateEmail();
    final passwordValid = _validatePassword();

    if (!nameValid || !emailValid || !passwordValid) {
      return;
    }

    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), backgroundColor: AppTheme.error),
      );
      return;
    }

    // Check for suspicious patterns
    if (SecurityUtils.hasSuspiciousPatterns(_nameController.text) ||
        SecurityUtils.hasSuspiciousPatterns(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid input detected'), backgroundColor: AppTheme.error),
      );
      return;
    }

    final auth = context.read<AuthService>();
    try {
      final user = await auth.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
      if (!mounted) return;
      if (user == null) return;
      // Always go to role selection for new sign-ups
      context.go(AppRoutes.roleSelection);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign up failed. Please try again.'), backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary),
          onPressed: () => context.go(AppRoutes.signIn),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Heading ────────────────────────────────────
              const Text(
                'Join FoodLoop',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create an account to get started',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // ── Full Name input ────────────────────────────
              TextField(
                controller: _nameController,
                onChanged: (_) => _validateName(),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  errorText: _nameError,
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _nameError != null ? AppTheme.error : Colors.grey.shade300),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.error),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Email input ────────────────────────────────
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

              // ── Password input ────────────────────────────
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enableSuggestions: false,
                autocorrect: false,
                onChanged: (_) => _validatePassword(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Create a password',
                  errorText: _passwordError,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _passwordError != null ? AppTheme.error : Colors.grey.shade300),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.error),
                  ),
                ),
              ),

              // ── Password strength indicator ────────────────
              if (_passwordStrength != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _passwordStrength == PasswordStrength.weak
                              ? 0.33
                              : _passwordStrength == PasswordStrength.medium
                                  ? 0.66
                                  : 1.0,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _passwordStrength == PasswordStrength.weak
                                ? AppTheme.error
                                : _passwordStrength == PasswordStrength.medium
                                    ? const Color(0xFFF39C12)
                                    : AppTheme.takerPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _passwordStrength == PasswordStrength.weak
                          ? 'Weak'
                          : _passwordStrength == PasswordStrength.medium
                              ? 'Medium'
                              : 'Strong',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _passwordStrength == PasswordStrength.weak
                            ? AppTheme.error
                            : _passwordStrength == PasswordStrength.medium
                                ? const Color(0xFFF39C12)
                                : AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // ── Confirm Password input ─────────────────────
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Confirm password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Removed terms checkbox ───────────────────────

              const SizedBox(height: 24),

              // ── Sign Up button ─────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _handleSignUp,
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
                      : const Text('Create Account'),
                ),
              ),

              const SizedBox(height: 20),

              // ── Already have account? ──────────────────────
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppTheme.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.signIn),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
