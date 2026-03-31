import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF0A1F44);
  static const Color accent = Color(0xFFC0392B);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF4F6FA);
  static const Color textPrimary = Color(0xFF0A1F44);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color statusTodo = Color(0xFFBDC3C7);
  static const Color statusInProgress = Color(0xFF2980B9);
  static const Color statusDone = Color(0xFF27AE60);
  static const Color blocked = Color(0xFFF0F0F0);
}

ThemeData buildAppTheme() {
  final baseTextTheme = GoogleFonts.interTextTheme();

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
      error: AppColors.accent,
    ),
    textTheme: baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8F9FD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
