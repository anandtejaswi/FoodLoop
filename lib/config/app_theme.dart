// ============================================================
// config/app_theme.dart  –  Global Theme Definitions
// Giver = Orange palette | Taker = Green palette
// ============================================================

import 'package:flutter/material.dart';

class AppTheme {
  // ─── Minimalist colours ──────────────────────────────────────
  static const Color primary        = Color(0xFF1E1E1E);   // Dark Gray / Black
  static const Color secondary      = Color(0xFF757575);   // Medium Gray
  static const Color background     = Color(0xFFFAFAFA);   // Off white

  // Aliases to avoid massive breakages while refactoring
  static const Color giverPrimary   = primary;
  static const Color giverSecondary = secondary;
  static const Color giverBg        = background;
  
  static const Color takerPrimary   = primary;
  static const Color takerSecondary = secondary;
  static const Color takerBg        = background;

  static const Color darkSurface    = Color(0xFF121212);
  static const Color cardSurface    = Color(0xFFFFFFFF);
  static const Color textPrimary    = Color(0xFF212121);
  static const Color textSecondary  = Color(0xFF757575);
  static const Color error          = Color(0xFFD32F2F);
  static const Color success        = Color(0xFF388E3C);

  // ─── Text Theme (System Default / Simple) ────────────────────
  static const TextTheme _textTheme = TextTheme(
    displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: textPrimary),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: textPrimary),
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),
    headlineMedium:TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
    titleLarge:    TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textPrimary),
    titleMedium:   TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
    bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary),
    bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
    labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  );

  // ─── Unified Theme ──────────────────────────────────────────
  static ThemeData get appTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      surface: cardSurface,
      error: error,
    ),
    textTheme: _textTheme,
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade400)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade400)),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: primary, width: 1.5)),
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(color: textSecondary),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade200,
      selectedColor: primary,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textPrimary),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      color: cardSurface,
      margin: EdgeInsets.zero,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primary,
      unselectedItemColor: textSecondary,
      backgroundColor: cardSurface,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
  );
  
  // Backwards compatibility so old code compiles before refactor
  static ThemeData get giverTheme => appTheme;
  static ThemeData get takerTheme => appTheme;
}

