import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';

/// Redesigned cinematic login screen with carousel background and native Google auth.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<String> _backgroundImages = [
    'https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?auto=format&fit=crop&q=80', // Productivity
    'https://images.unsplash.com/photo-1506784919141-93ad5499295d?auto=format&fit=crop&q=80', // Planning
    'https://images.unsplash.com/photo-1533227268428-f9ed0900fb3b?auto=format&fit=crop&q=80', // Focus
  ];

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showEmailFields = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 8), (Timer timer) {
      if (_currentPage < _backgroundImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOutQuart,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      // On success, the AuthNotifier will handle the redirection via the router's redirect logic.
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('cancelled') 
            ? null 
            : 'Google Sign-In failed. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleEmailSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter both email and password');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      await ref.read(authServiceProvider).signInWithEmail(email, password);
    } catch (e) {
      setState(() => _errorMessage = 'Login failed. Check your credentials.');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ─── Cinematic Background Carousel ─────────────────────────────
          PageView.builder(
            controller: _pageController,
            itemCount: _backgroundImages.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _backgroundImages[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(color: Colors.black);
                    },
                  ),
                  // Dark Vignette Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black,
                        ],
                        stops: const [0.0, 0.4, 0.9],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ─── Main Content ──────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  
                  // Brand Identity
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.2),
                              blurRadius: 40,
                              spreadRadius: 10,
                            )
                          ],
                        ),
                        child: Icon(
                          LucideIcons.shieldCheck,
                          color: Colors.white,
                          size: 40.sp,
                        ),
                      ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                      
                      SizedBox(height: 24.h),
                      
                      Text(
                        'HABITFLOW',
                        style: GoogleFonts.outfit(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                      
                      SizedBox(height: 12.h),
                      
                      Text(
                        'ELITE PERFORMANCE OS',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.5),
                          letterSpacing: 2,
                        ),
                      ).animate().fadeIn(delay: 500.ms),
                    ],
                  ),

                  const Spacer(flex: 4),

                  // Auth Actions
                  Column(
                    children: [
                      if (_errorMessage != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 24.h),
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.inter(
                              color: Colors.redAccent,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().shake(),
                        ),

                      // Primary Action: Google Sign-In
                      _isLoading 
                      ? const CircularProgressIndicator(color: AppTheme.primary)
                      : Column(
                        children: [
                          _AuthButton(
                            label: 'Continue with Google',
                            icon: LucideIcons.globe,
                            onPressed: _handleGoogleSignIn,
                            isPrimary: true,
                          ).animate().slideY(begin: 0.3, duration: 600.ms),
                          
                          SizedBox(height: 16.h),

                          // Secondary Action: Email
                          if (!_showEmailFields)
                            _AuthButton(
                              label: 'Continue with Email',
                              icon: LucideIcons.mail,
                              onPressed: () => setState(() => _showEmailFields = true),
                              isPrimary: false,
                            ).animate().fadeIn(delay: 200.ms),
                        ],
                      ),

                      // Hidden Email Fields
                      if (_showEmailFields && !_isLoading)
                        Column(
                          children: [
                            SizedBox(height: 16.h),
                            _CustomTextField(
                              controller: _emailController,
                              hint: 'Email Address',
                              icon: LucideIcons.mail,
                            ),
                            SizedBox(height: 12.h),
                            _CustomTextField(
                              controller: _passwordController,
                              hint: 'Password',
                              icon: LucideIcons.lock,
                              isPassword: true,
                            ),
                            SizedBox(height: 24.h),
                            _AuthButton(
                              label: 'Sign In',
                              onPressed: _handleEmailSignIn,
                              isPrimary: true,
                            ),
                            TextButton(
                              onPressed: () => setState(() => _showEmailFields = false),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.5)),
                              ),
                            ),
                          ],
                        ).animate().fadeIn().slideY(begin: 0.1),

                      SizedBox(height: 48.h),
                      
                      // Footer
                      Text(
                        'BY ACCESSING HABITFLOW YOU AGREE TO OUR\nTERMS OF SERVICE AND PRIVACY POLICY',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 8.sp,
                          color: Colors.white.withValues(alpha: 0.3),
                          letterSpacing: 1,
                          height: 1.5,
                        ),
                      ).animate().fadeIn(delay: 800.ms),
                    ],
                  ),
                  
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),

          // Top Loading Bar
          if (_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary.withValues(alpha: 0.5)),
                minHeight: 3.h,
              ),
            ),
        ],
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _AuthButton({
    required this.label,
    this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.05),
          foregroundColor: isPrimary ? Colors.black : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: isPrimary ? BorderSide.none : BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20.sp),
              SizedBox(width: 12.w),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;

  const _CustomTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.3)),
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.3), size: 18.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        ),
      ),
    );
  }
}
