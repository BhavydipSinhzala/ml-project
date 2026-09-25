import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color background = Color(0xFFFDFBF7); // Warm neutral off-white
  static const Color cardBg = Color(0xFFFFFFFF); // Pure white cards
  static const Color primaryNavy = Color(0xFF1E293B); // Soft navy / warm slate accent
  static const Color primaryDark = Color(0xFF0F172A); // Deep slate
  static const Color secondarySlate = Color(0xFF64748B); // Muted slate text
  static const Color borderResting = Color(0xFFE2E8F0); // Subtle input border
  static const Color charcoal = Color(0xFF1A202C); // High contrast text

  // Positive Outcome (Low Risk - Sage Green)
  static const Color sageBg = Color(0xFFE6F4EA);
  static const Color sageBorder = Color(0xFFA7F3D0);
  static const Color sageText = Color(0xFF15803D);
  static const Color sageIcon = Color(0xFF2E7D32);

  // Negative Outcome (High Risk - Terracotta / Amber)
  static const Color terracottaBg = Color(0xFFFDF2E9);
  static const Color terracottaBorder = Color(0xFFFDBA74);
  static const Color terracottaText = Color(0xFFC05621);
  static const Color terracottaIcon = Color(0xFFD97706);

  // Card & Container Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 6,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
  ];
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryNavy,
        background: AppColors.background,
        surface: AppColors.cardBg,
        primary: AppColors.primaryNavy,
        secondary: AppColors.secondarySlate,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cardBg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.primaryNavy),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderResting, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.secondarySlate, fontSize: 14, fontWeight: FontWeight.w500),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderResting, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryNavy, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
