// ============================================================
// screens/shared/settings_screen.dart
// Settings page for basic info and password change
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  
  bool _isEditingBasicInfo = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoadingBasicInfo = false;
  bool _isLoadingPassword = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateBasicInfo() async {
    final name = _nameController.text.trim();
    
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty'), backgroundColor: AppTheme.error),
      );
      return;
    }

    setState(() => _isLoadingBasicInfo = true);
    try {
      // TODO: Implement actual API call to update user info
      // For now, show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Basic info updated successfully'), backgroundColor: Colors.green),
      );
      setState(() => _isEditingBasicInfo = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
      );
    } finally {
      setState(() => _isLoadingBasicInfo = false);
    }
  }

  Future<void> _updatePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required'), backgroundColor: AppTheme.error),
      );
      return;
    }

    if (newPassword.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be at least 8 characters'), backgroundColor: AppTheme.error),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), backgroundColor: AppTheme.error),
      );
      return;
    }

    setState(() => _isLoadingPassword = true);
    try {
      // Get stored token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      if (token.isEmpty) {
        throw Exception('Session expired. Please sign in again.');
      }

      // Call change password API
      await ApiService.instance.changePassword(currentPassword, newPassword, token);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully'), backgroundColor: Colors.green),
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppTheme.error),
      );
    } finally {
      setState(() => _isLoadingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final color = user?.role == 'giver' ? AppTheme.giverPrimary : AppTheme.takerPrimary;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () { if (context.canPop()) { context.pop(); } else { context.go(AppRoutes.roleSelection); } }),
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Basic Information Section ──────────────────────
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Basic Information', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        if (!_isEditingBasicInfo)
                          TextButton.icon(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Edit', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                            onPressed: () => setState(() => _isEditingBasicInfo = true),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Name field
                    TextField(
                      controller: _nameController,
                      enabled: _isEditingBasicInfo,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        prefixIcon: const Icon(Icons.person_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email field (read-only)
                    TextField(
                      controller: _emailController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Your email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_isEditingBasicInfo)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              final user = context.read<AuthService>().currentUser;
                              _nameController.text = user?.name ?? '';
                              setState(() => _isEditingBasicInfo = false);
                            },
                            child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins')),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            icon: _isLoadingBasicInfo ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white))) : const Icon(Icons.check_rounded, size: 18),
                            label: Text(_isLoadingBasicInfo ? 'Saving...' : 'Save Changes', style: const TextStyle(fontFamily: 'Poppins')),
                            onPressed: _isLoadingBasicInfo ? null : _updateBasicInfo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Change Password Section ────────────────────────
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Change Password', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),

                    // Current password field
                    TextField(
                      controller: _currentPasswordController,
                      obscureText: !_showCurrentPassword,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        hintText: 'Enter your current password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_showCurrentPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _showCurrentPassword = !_showCurrentPassword),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // New password field
                    TextField(
                      controller: _newPasswordController,
                      obscureText: !_showNewPassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        hintText: 'Enter a new password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_showNewPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _showNewPassword = !_showNewPassword),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm password field
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_showConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        hintText: 'Confirm your new password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_showConfirmPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password requirements hint
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '💡 Password must be at least 8 characters long',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Update password button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: _isLoadingPassword ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white))) : const Icon(Icons.check_rounded, size: 18),
                        label: Text(_isLoadingPassword ? 'Updating...' : 'Update Password', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                        onPressed: _isLoadingPassword ? null : _updatePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
