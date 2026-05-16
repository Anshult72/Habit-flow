import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/hf_premium_widgets.dart';

/// Splash screen shown during auth state resolution.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: HFScaffoldWrapper(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Eagle logo asset
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.primaryGlow.withValues(alpha: 0.4),
                        blurRadius: 40)
                  ],
                ),
                child: Image.asset(
                  'assets/images/eagle-logo-transparent.png',
                  fit: BoxFit.contain,
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack),
        
              SizedBox(height: 24.h),
              Text('HABITFLOW',
                      style: GoogleFonts.outfit(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMain,
                          letterSpacing: 6))
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.3),
        
              SizedBox(height: 6.h),
              Text('MOBILE COMMAND CENTER',
                      style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          color: AppTheme.textMuted,
                          letterSpacing: 3))
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms),
        
              SizedBox(height: 48.h),
              SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(
                    color: AppTheme.primary, strokeWidth: 1.5),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
