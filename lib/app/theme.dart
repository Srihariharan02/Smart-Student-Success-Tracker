import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: AppColors.lightInk900),
      displayMedium: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: AppColors.lightInk900),
      displaySmall: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: AppColors.lightInk900),
      headlineMedium: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: AppColors.lightInk900),
      headlineSmall: GoogleFonts.lexend(fontWeight: FontWeight.w600, color: AppColors.lightInk900),
      titleLarge: GoogleFonts.lexend(fontWeight: FontWeight.w600, color: AppColors.lightInk900),
      titleMedium: GoogleFonts.lexend(fontWeight: FontWeight.w600, color: AppColors.lightInk900),
      titleSmall: GoogleFonts.lexend(fontWeight: FontWeight.w600, color: AppColors.lightInk900),
      bodyLarge: GoogleFonts.inter(color: AppColors.lightInk900),
      bodyMedium: GoogleFonts.inter(color: AppColors.lightInk700),
      bodySmall: GoogleFonts.inter(color: AppColors.lightInk500),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.brand500,
      scaffoldBackgroundColor: AppColors.lightCanvas,
      colorScheme: const ColorScheme.light(
        primary: AppColors.brand500,
        secondary: AppColors.blue500,
        surface: AppColors.lightSurface,
        error: AppColors.danger500,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightInk900,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.lightInk900),
        titleTextStyle: GoogleFonts.lexend(
          color: AppColors.lightInk900,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand500,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightInk700,
          side: const BorderSide(color: AppColors.lightBorder),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brand500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger500),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.lightInk500, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: AppColors.lightInk700, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.brand500,
        unselectedItemColor: AppColors.lightInk500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: AppColors.darkInk900),
      displayMedium: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: AppColors.darkInk900),
      displaySmall: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: AppColors.darkInk900),
      headlineMedium: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: AppColors.darkInk900),
      headlineSmall: GoogleFonts.lexend(fontWeight: FontWeight.w600, color: AppColors.darkInk900),
      titleLarge: GoogleFonts.lexend(fontWeight: FontWeight.w600, color: AppColors.darkInk900),
      titleMedium: GoogleFonts.lexend(fontWeight: FontWeight.w600, color: AppColors.darkInk900),
      titleSmall: GoogleFonts.lexend(fontWeight: FontWeight.w600, color: AppColors.darkInk900),
      bodyLarge: GoogleFonts.inter(color: AppColors.darkInk900),
      bodyMedium: GoogleFonts.inter(color: AppColors.darkInk700),
      bodySmall: GoogleFonts.inter(color: AppColors.darkInk500),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.brand500,
      scaffoldBackgroundColor: AppColors.darkCanvas,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brand500,
        secondary: AppColors.blue500,
        surface: AppColors.darkSurface,
        error: AppColors.danger500,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkInk900,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.darkInk900),
        titleTextStyle: GoogleFonts.lexend(
          color: AppColors.darkInk900,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand500,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkInk700,
          side: const BorderSide(color: AppColors.darkBorder),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brand500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger500),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.darkInk500, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: AppColors.darkInk700, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.brand500,
        unselectedItemColor: AppColors.darkInk500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
