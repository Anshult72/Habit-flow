import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// HabitFlow Design System — extracted directly from the web app's globals.css.
///
/// Every value here matches the web frontend's CSS custom properties:
///   --theme-background, --theme-surface, --theme-primary, etc.
///
/// The web uses Tailwind + CSS custom properties. This file is the
/// Flutter equivalent of globals.css + the glass-card utility class.
class AppTheme {
  AppTheme._();

  // ─── Colors (from globals.css :root / [data-theme="dark"]) ─────────
  static const Color background = Color(0xFF050505);
  static const Color surface = Color(0x08FFFFFF); // rgba(255, 255, 255, 0.03)
  static const Color surfaceBorder = Color(0x0DFFFFFF); // rgba(255, 255, 255, 0.05)
  static const Color primary = Color(0xFFFF6B2C);
  static const Color primaryGlow = Color(0x80FF6B2C); // rgba(255, 107, 44, 0.5)
  static const Color secondary = Color(0xFFE85D04);
  static const Color accent = Color(0xFFFF8C42);
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color textMain = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);

  // ─── Category Colors (from dashboard getCategoryHexColor) ──────────
  static const Map<String, Color> categoryColors = {
    'Health': Color(0xFF10B981),
    'Mindfulness': Color(0xFFA855F7),
    'Learning': Color(0xFF3B82F6),
    'Fitness': Color(0xFFEF4444),
    'Productivity': Color(0xFFEAB308),
    'Finance': Color(0xFF14B8A6),
    'Deep Work': Color(0xFF6366F1),
    'Detox': Color(0xFFEC4899),
  };

  // ─── Gradients (from globals.css) ──────────────────────────────────
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x0DFFFFFF), // rgba(255, 255, 255, 0.05)
      Color(0x03FFFFFF), // rgba(255, 255, 255, 0.01)
    ],
  );

  // ─── Border Radii ──────────────────────────────────────────────────
  static const double radiusXs = 8.0;   // rounded-lg
  static const double radiusSm = 12.0;  // rounded-xl
  static const double radiusMd = 16.0;  // rounded-2xl
  static const double radiusLg = 24.0;  // rounded-3xl
  static const double radiusXl = 32.0;  // rounded-[2rem]
  static const double radiusXxl = 40.0; // rounded-[2.5rem]

  // ─── Utility Decorations ───────────────────────────────────────────
  static BoxDecoration glassCard({double? borderRadius}) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(borderRadius ?? radiusMd),
      border: Border.all(color: surfaceBorder, width: 1.5),
    );
  }

  static BoxDecoration glowCard({
    required Color glowColor,
    double glowIntensity = 0.1,
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(borderRadius ?? radiusMd),
      border: Border.all(color: surfaceBorder),
      boxShadow: [
        BoxShadow(
          color: glowColor.withValues(alpha: glowIntensity),
          blurRadius: 20,
          spreadRadius: -5,
        ),
      ],
    );
  }

  static TextStyle labelStyle({Color? color}) {
    return GoogleFonts.outfit(
      color: color ?? textMuted,
      fontSize: 10.sp,
      fontWeight: FontWeight.w700,
      letterSpacing: 2,
    );
  }

  // ─── ThemeData ─────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final baseTheme = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    return baseTheme.copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: background,
        onSurface: textMain,
        error: danger,
      ),
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: textMain,
          fontWeight: FontWeight.w800,
          fontSize: 32.sp,
          letterSpacing: -1,
        ),
        displayMedium: GoogleFonts.outfit(
          color: textMain,
          fontWeight: FontWeight.w700,
          fontSize: 24.sp,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          color: textMain,
          fontWeight: FontWeight.w700,
          fontSize: 20.sp,
        ),
        bodyLarge: GoogleFonts.inter(
          color: textMain,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textMuted,
          fontSize: 14.sp,
        ),
        labelSmall: GoogleFonts.outfit(
          color: textMuted,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: textMain,
          fontWeight: FontWeight.w700,
          fontSize: 16.sp,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14.sp, letterSpacing: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 1),
        ),
        hintStyle: TextStyle(color: textMuted.withValues(alpha: 0.5)),
      ),
    );
  }
}

