// ============================================================
// utils/security_utils.dart  –  Security & Validation Utilities
// ============================================================

class SecurityUtils {
  // ─── Email validation ─────────────────────────────────────────
  static bool isValidEmail(String email) {
    // RFC 5322 simplified email regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&' + "'" + r'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );
    return emailRegex.hasMatch(email);
  }

  // ─── Password strength validation ──────────────────────────────
  static PasswordStrength checkPasswordStrength(String password) {
    if (password.length < 8) return PasswordStrength.weak;
    
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int strength = 0;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasDigits) strength++;
    if (hasSpecial) strength++;

    if (strength < 2) return PasswordStrength.weak;
    if (strength < 3) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  // ─── Get password strength message ─────────────────────────────
  static String getPasswordStrengthMessage(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Password must be at least 8 characters long and include uppercase, lowercase, numbers, and special characters';
      case PasswordStrength.medium:
        return 'Password is good but could be stronger';
      case PasswordStrength.strong:
        return 'Strong password!';
    }
  }

  // ─── Sanitize input ───────────────────────────────────────────
  static String sanitizeInput(String input) {
    // Remove leading/trailing whitespace
    String sanitized = input.trim();
    // Remove null bytes
    sanitized = sanitized.replaceAll('\x00', '');
    // Remove control characters
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    return sanitized;
  }

  // ─── Validate name ────────────────────────────────────────────
  static bool isValidName(String name) {
    final nameRegex = RegExp(r'^[a-zA-Z\s]{2,50}$');
    return nameRegex.hasMatch(name);
  }

  // ─── Check for SQL injection patterns ──────────────────────────
  static bool hasSuspiciousPatterns(String input) {
    final suspiciousPatterns = [
      RegExp(r"('\s*(OR|AND)\s*'1'=\'1)", caseSensitive: false),
      RegExp(r'(--|#|\/\*|\*\/)', caseSensitive: false),
      RegExp(r'(UNION|SELECT|INSERT|UPDATE|DELETE|DROP|CREATE)', caseSensitive: false),
      RegExp(r'(xp_|sp_|exec|execute)', caseSensitive: false),
    ];

    return suspiciousPatterns.any((pattern) => pattern.hasMatch(input));
  }
}

enum PasswordStrength { weak, medium, strong }
