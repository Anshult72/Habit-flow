import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  //
  // Web:  --theme-background: #050505
  static const Color background = Color(0xFF050505);

  // Web:  --theme-surface: rgba(255, 255, 255, 0.03)
  static const Color surface = Color(0x08FFFFFF); // ~3% white

  // Web:  --theme-surface-border: rgba(255, 255, 255, 0.05)
  static const Color surfaceBorder = Color(0x0DFFFFFF); // ~5% white

  // Web:  --theme-primary: #FF6B2C
  static const Color primary = Color(0xFFFF6B2C);

  // Web:  --theme-primary-glow: rgba(255, 107, 44, 0.5)
  static const Color primaryGlow = Color(0x80FF6B2C);

  // Web:  --theme-secondary: #E85D04
  static const Color secondary = Color(0xFFE85D04);

  // Web:  --theme-accent: #FF8C42
  static const Color accent = Color(0xFFFF8C42);

  // Web:  --color-success: #10B981
  static const Color success = Color(0xFF10B981);

  // Web:  --color-danger: #EF4444
  static const Color danger = Color(0xFFEF4444);

  // Web:  --theme-text-main: #F8FAFC
  static const Color textMain = Color(0xFFF8FAFC);

  // Web:  --theme-text-muted: #94A3B8
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

  // ─── Border Radii (from web Tailwind classes) ──────────────────────
  //
  // Web cards use rounded-[2rem] = 32px, rounded-[2.5rem] = 40px
  static const double radiusXs = 8.0;   // rounded-lg
  static const double radiusSm = 12.0;  // rounded-xl
  static const double radiusMd = 16.0;  // rounded-2xl
  static const double radiusLg = 24.0;  // rounded-3xl
  static const double radiusXl = 32.0;  // rounded-[2rem]
  static const double radiusXxl = 40.0; // rounded-[2.5rem]

  // ─── Glass Card Decoration (from .glass-card utility) ──────────────
  //
  // Web:
  //   background-color: rgba(255, 255, 255, 0.03);
  //   backdrop-filter: blur(24px);
  //   border: 1px solid rgba(255, 255, 255, 0.05);
  //   box-shadow: 0 8px 32px rgba(0,0,0,0.1);
  static BoxDecoration glassCard({
    double borderRadius = 32.0,
    Color? borderColor,
    List<BoxShadow>? extraShadows,
  }) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? surfaceBorder,
        width: 1,
      ),
      boxShadow: extraShadows ?? [
        const BoxShadow(
          color: Color(0x1A000000), // rgba(0,0,0,0.1)
          blurRadius: 32,
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  // ─── Glow Decoration (from web shadow-[0_0_20px_...]) ──────────────
  static BoxDecoration glowCard({
    Color glowColor = primary,
    double glowIntensity = 0.2,
    double borderRadius = 32.0,
  }) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: surfaceBorder),
      boxShadow: [
        BoxShadow(
          color: glowColor.withValues(alpha: glowIntensity),
          blurRadius: 20,
          spreadRadius: 0,
        ),
        const BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 32,
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  // ─── Label Style (from web text-[10px] uppercase tracking-[0.2em]) ─
  static TextStyle labelStyle() {
    return GoogleFonts.outfit(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: textMuted,
      letterSpacing: 2.0, // 0.2em at 10px
    );
  }

  // ─── ThemeData ─────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: danger,
        onPrimary: Colors.white,
        onSurface: textMain,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: textMain,
          fontWeight: FontWeight.w800,
          fontSize: 36,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          color: textMain,
          fontWeight: FontWeight.w700,
          fontSize: 28,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          color: textMain,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        titleMedium: GoogleFonts.outfit(
          color: textMain,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: GoogleFonts.inter(
          color: textMain,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textMuted,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.inter(
          color: textMuted,
          fontSize: 12,
        ),
        labelSmall: GoogleFonts.outfit(
          color: textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: textMain,
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textMain,
          side: const BorderSide(color: surfaceBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.5)),
        ),
        hintStyle: const TextStyle(color: Color(0x40FFFFFF)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: surfaceBorder,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF0A0A0A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
    );
  }
}
