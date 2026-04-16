// ============================================================
// services/auth_service.dart  –  Email/Password Auth + Session Manager
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/rate_limiter.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  // ─── State ───────────────────────────────────────────────────
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  final RateLimiter _rateLimiter = RateLimiter(maxAttempts: 5, lockoutDuration: const Duration(minutes: 15));
  DateTime? _sessionTimeout;

  static const Duration _sessionDuration = Duration(hours: 24);

  UserModel? get currentUser  => _currentUser;
  bool get isLoading          => _isLoading;
  bool get isAuthenticated    => _currentUser != null;
  bool get isGiver            => _currentUser?.role == 'giver';
  bool get isTaker            => _currentUser?.role == 'taker';
  String? get error           => _error;
  bool get isRateLimited      => _rateLimiter.isRateLimited();
  Duration? get remainingLockout => _rateLimiter.getRemainingLockoutDuration();
  int get remainingAttempts   => _rateLimiter.getRemainingAttempts();

  // ─── Initialize – restore session from prefs ─────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final sessionTime = prefs.getString('session_time');
    
    if (token != null && sessionTime != null) {
      final sessionStart = DateTime.parse(sessionTime);
      final now = DateTime.now();
      
      // Check if session has expired
      if (now.difference(sessionStart) > _sessionDuration) {
        await prefs.remove('auth_token');
        await prefs.remove('session_time');
        return;
      }

      try {
        final userData = await ApiService.instance.getMe(token);
        _currentUser = userData;
        _sessionTimeout = now.add(_sessionDuration);
        notifyListeners();
      } catch (_) {
        await prefs.remove('auth_token');
        await prefs.remove('session_time');
      }
    }
  }

  // ─── Email Sign In ───────────────────────────────────────────
  Future<UserModel?> signIn(String email, String password) async {
    // Check rate limiting
    if (_rateLimiter.isRateLimited()) {
      _error = 'Too many failed attempts. Please try again later.';
      notifyListeners();
      throw Exception(_error);
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.instance.signIn(email, password);
      _currentUser = result['user'] as UserModel;

      // Persist token and session time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', result['token'] as String);
      await prefs.setString('session_time', DateTime.now().toIso8601String());
      
      // Set session timeout
      _sessionTimeout = DateTime.now().add(_sessionDuration);

      // Reset rate limiter on successful login
      _rateLimiter.reset();

      _isLoading = false;
      notifyListeners();
      return _currentUser;
    } catch (e) {
      // Record failed attempt
      _rateLimiter.recordAttempt();
      
      // Generic error message to avoid leaking info
      _error = 'Sign in failed. Please check your credentials and try again.';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ─── Email Sign Up ───────────────────────────────────────────
  Future<UserModel?> signUp(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await ApiService.instance.signUp(email, password, name);
      _currentUser = result['user'] as UserModel;

      // Persist token and session time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', result['token'] as String);
      await prefs.setString('session_time', DateTime.now().toIso8601String());
      
      // Set session timeout
      _sessionTimeout = DateTime.now().add(_sessionDuration);

      _isLoading = false;
      notifyListeners();
      return _currentUser;
    } catch (e) {
      _error = 'Sign up failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ─── Update user role (after Role Selection screen) ──────────
  Future<void> updateRole(String role) async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    await ApiService.instance.updateUserRole(_currentUser!.id, role, token);
    _currentUser = _currentUser!.copyWith(role: role);
    notifyListeners();
  }

  // ─── Sign Out ────────────────────────────────────────────────
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('session_time');
    _currentUser = null;
    _error = null;
    _sessionTimeout = null;
    notifyListeners();
  }

  // ─── Clear error ──────────────────────────────────────────────
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─── Check if session expired ─────────────────────────────────
  bool isSessionExpired() {
    if (_sessionTimeout == null) return true;
    return DateTime.now().isAfter(_sessionTimeout!);
  }
}
