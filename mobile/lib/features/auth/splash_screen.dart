import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

/// Splash screen shown during auth state resolution.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.accent]),
                boxShadow: [BoxShadow(color: AppTheme.primaryGlow.withValues(alpha: 0.4), blurRadius: 30)],
              ),
              child: Center(
                child: Text('HF', style: GoogleFonts.outfit(fontSize: 32.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -2)),
              ),
            ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack),

            SizedBox(height: 24.h),
            Text('HABITFLOW', style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.textMain, letterSpacing: 6))
                .animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.3),

            SizedBox(height: 6.h),
            Text('MOBILE COMMAND CENTER', style: GoogleFonts.inter(fontSize: 9.sp, color: AppTheme.textMuted, letterSpacing: 3))
                .animate().fadeIn(delay: 600.ms, duration: 600.ms),

            SizedBox(height: 48.h),
            SizedBox(
              width: 22.w,
              height: 22.w,
              child: const CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
