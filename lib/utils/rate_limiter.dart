// ============================================================
// utils/rate_limiter.dart  –  Client-side Rate Limiting
// ============================================================

class RateLimiter {
  final int maxAttempts;
  final Duration lockoutDuration;
  
  int _attemptCount = 0;
  DateTime? _lockoutTime;

  RateLimiter({
    this.maxAttempts = 5,
    this.lockoutDuration = const Duration(minutes: 15),
  });

  // ─── Check if rate limited ────────────────────────────────────
  bool isRateLimited() {
    if (_lockoutTime != null) {
      final now = DateTime.now();
      if (now.isBefore(_lockoutTime!)) {
        return true;
      } else {
        // Lockout expired, reset
        _lockoutTime = null;
        _attemptCount = 0;
      }
    }
    return false;
  }

  // ─── Get remaining lockout duration ───────────────────────────
  Duration? getRemainingLockoutDuration() {
    if (_lockoutTime == null) return null;
    final now = DateTime.now();
    if (now.isBefore(_lockoutTime!)) {
      return _lockoutTime!.difference(now);
    }
    return null;
  }

  // ─── Record attempt ───────────────────────────────────────────
  bool recordAttempt() {
    if (isRateLimited()) return false;
    
    _attemptCount++;
    if (_attemptCount >= maxAttempts) {
      _lockoutTime = DateTime.now().add(lockoutDuration);
      return false;
    }
    return true;
  }

  // ─── Reset (after successful login) ───────────────────────────
  void reset() {
    _attemptCount = 0;
    _lockoutTime = null;
  }

  // ─── Get remaining attempts ───────────────────────────────────
  int getRemainingAttempts() {
    return (maxAttempts - _attemptCount).clamp(0, maxAttempts);
  }
}
