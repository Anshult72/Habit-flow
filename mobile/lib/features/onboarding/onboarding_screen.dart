import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentIndex = 0;
  Timer? _timer;

  // We define the paths for the onboarding images.
  // The user should place their 5 images in 'assets/images/onboarding/'
  final List<String> _images = [
    'assets/images/onboarding/1.jpg',
    'assets/images/onboarding/2.jpg',
    'assets/images/onboarding/3.jpg',
    'assets/images/onboarding/4.jpg',
    'assets/images/onboarding/5.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Preload images to avoid lag
    for (var image in _images) {
      precacheImage(AssetImage(image), context);
    }
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _images.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: Stack(
        children: [
          // Background Image Carousel with Cinematic Cross-Fade
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1200),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            child: Image.asset(
              _images[_currentIndex],
              key: ValueKey<int>(_currentIndex),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                key: ValueKey<String>('error_$_currentIndex'),
                color: const Color(0xFF1C1C1E),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image_not_supported, color: Colors.white24, size: 40.sp),
                      SizedBox(height: 16.h),
                      Text(
                        'Missing Image:\n${_images[_currentIndex]}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: Colors.white24, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Dark Cinematic Overlay (Linear Gradient)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF09090B).withValues(alpha: 0.1),  // Top
                  const Color(0xFF09090B).withValues(alpha: 0.4),  // Mid
                  const Color(0xFF09090B).withValues(alpha: 0.98), // Bottom
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Fixed UI Layer
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Logo (Optional depending on preference, but good for branding)
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/eagle-logo-transparent.png',
                        width: 32.w,
                        height: 32.w,
                        color: Colors.white,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.shield, color: Colors.white, size: 24.sp),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'HabitFlow',
                        style: GoogleFonts.outfit(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2),

                  const Spacer(),

                  // Bottom Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Tagline
                      Text(
                        'ELITE PERFORMANCE',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFF6B00), // Orange glow accent
                          letterSpacing: 4.0,
                        ),
                      ).animate().fadeIn(delay: 300.ms, duration: 800.ms).slideY(begin: 0.2),
                      
                      SizedBox(height: 16.h),
                      
                      Text(
                        'Rewire your brain.\nLevel up your life.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 34.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.15,
                          letterSpacing: -1,
                        ),
                      ).animate().fadeIn(delay: 500.ms, duration: 800.ms).slideY(begin: 0.2),
                      
                      SizedBox(height: 48.h),

                      // Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_images.length, (index) {
                          final isSelected = _currentIndex == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            height: 4.h,
                            width: isSelected ? 24.w : 8.w,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          );
                        }),
                      ).animate().fadeIn(delay: 700.ms, duration: 800.ms),

                      SizedBox(height: 40.h),

                      // Glassmorphism Get Started Button
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: double.infinity,
                            height: 60.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.0),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  _timer?.cancel();
                                  context.push('/login'); // Using push instead of go so back button could work if needed, or go if no back.
                                },
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Get Started',
                                        style: GoogleFonts.inter(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20.sp),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 900.ms, duration: 800.ms).slideY(begin: 0.2),
                      
                      SizedBox(height: 16.h),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
