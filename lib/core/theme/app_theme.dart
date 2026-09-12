import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    const textTheme = TextTheme(
      displayLarge: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700, fontSize: 32, height: 1.4, color: AppColors.text),
      headlineMedium: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700, fontSize: 22, height: 1.45, color: AppColors.text),
      titleLarge: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700, fontSize: 18, height: 1.5, color: AppColors.text),
      titleMedium: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w600, fontSize: 16, height: 1.5, color: AppColors.text),
      bodyLarge: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w400, fontSize: 16, height: 1.7, color: AppColors.text),
      bodyMedium: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w400, fontSize: 14, height: 1.7, color: AppColors.text),
      labelLarge: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w600, fontSize: 15, height: 1.4, color: AppColors.text),
      labelSmall: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w500, fontSize: 12, height: 1.4, color: AppColors.muted),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Vazirmatn',
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.navy,
        onPrimary: Colors.white,
        secondary: AppColors.gold,
        onSecondary: AppColors.navyDark,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        error: AppColors.danger,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Vazirmatn',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: AppColors.navy,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.divider),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.muted, fontFamily: 'Vazirmatn'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.navy, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.navy),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navyDark,
        contentTextStyle: const TextStyle(fontFamily: 'Vazirmatn', color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerColor: AppColors.divider,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.navy,
        unselectedItemColor: AppColors.muted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12),
      ),
    );
  }
}
