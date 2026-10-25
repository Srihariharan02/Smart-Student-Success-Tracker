import 'package:flutter/material.dart';

/// S3T Design Tokens & Colors matching the web design system
class AppColors {
  AppColors._();

  // Brand Palette
  static const Color brand50 = Color(0xFFEEF1FF);
  static const Color brand100 = Color(0xFFE0E5FF);
  static const Color brand500 = Color(0xFF4F46E5); // Primary Brand
  static const Color brand600 = Color(0xFF4338CA);
  static const Color brand700 = Color(0xFF3730A3);

  // Accent Blue
  static const Color blue500 = Color(0xFF2563EB);
  static const Color blue100 = Color(0xFFDBEAFE);

  // Semantic Status: Success (Green)
  static const Color success500 = Color(0xFF16A34A);
  static const Color success100 = Color(0xFFDCFCE7);
  static const Color success700 = Color(0xFF15803D);

  // Semantic Status: Warning (Amber)
  static const Color warn500 = Color(0xFFD97706);
  static const Color warn100 = Color(0xFFFEF3C7);
  static const Color warn700 = Color(0xFFB45309);

  // Semantic Status: Danger (Red)
  static const Color danger500 = Color(0xFFDC2626);
  static const Color danger100 = Color(0xFFFEE2E2);
  static const Color danger700 = Color(0xFFB91C1C);

  // Light Mode Inks & Surfaces
  static const Color lightCanvas = Color(0xFFF6F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE6E9F2);
  static const Color lightInk900 = Color(0xFF0F172A);
  static const Color lightInk700 = Color(0xFF334155);
  static const Color lightInk500 = Color(0xFF64748B);
  static const Color lightInk300 = Color(0xFFCBD5E1);
  static const Color lightInk100 = Color(0xFFF1F5F9);

  // Dark Mode Inks & Surfaces
  static const Color darkCanvas = Color(0xFF0C0F1C);
  static const Color darkSurface = Color(0xFF151A2C);
  static const Color darkBorder = Color(0xFF262C46);
  static const Color darkInk900 = Color(0xFFF1F4FF);
  static const Color darkInk700 = Color(0xFFCBD2F0);
  static const Color darkInk500 = Color(0xFF8790B8);
  static const Color darkInk100 = Color(0xFF1C2238);

  // Brand Gradient
  static const LinearGradient brandGradient = LinearGradient(
    colors: [brand500, blue500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Helper to get tone color by score/percentage
  static Color scoreColor(num score) {
    if (score >= 80) return success500;
    if (score >= 65) return warn500;
    return danger500;
  }

  /// Helper to get status color from status string
  static Color statusColor(String? status) {
    if (status == null) return brand500;
    final s = status.toLowerCase();
    if (s.contains('excellent') || s.contains('good') || s.contains('low') || s.contains('normal') || s.contains('active') || s.contains('passed') || s.contains('completed')) {
      return success500;
    }
    if (s.contains('needs') || s.contains('medium') || s.contains('warning') || s.contains('due soon') || s.contains('moderate')) {
      return warn500;
    }
    if (s.contains('high') || s.contains('critical') || s.contains('risk') || s.contains('failed')) {
      return danger500;
    }
    return brand500;
  }
}
