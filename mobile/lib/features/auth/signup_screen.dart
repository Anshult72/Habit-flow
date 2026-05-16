import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';

/// Signup screen matching the web app's signup page design language.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      await ref.read(authServiceProvider).signUpWithEmail(email, password);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please check your email to verify.')),
        );
        context.pop(); // Go back to login
      }
    } catch (e) {
      String message = 'Signup failed';
      if (e.toString().contains('already registered')) {
        message = 'Account already exists. Please sign in.';
      } else if (e.toString().contains('network')) {
        message = 'Network error. Check your connection.';
      } else {
        message = e.toString().replaceAll('Exception: ', '');
      }
      setState(() => _errorMessage = message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B), // Very dark background
      body: Stack(
        children: [
          // Ambient subtle dark brown glow top left
          Positioned(
            top: -200,
            left: -100,
            child: Container(
              width: 500.w,
              height: 500.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF4E2A1D).withValues(alpha: 0.15), 
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        SizedBox(height: 48.h),
                        
                        // Center Logo + Text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 600.ms),

                        SizedBox(height: 40.h),

                        // Signup Card
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Create an Account',
                                style: GoogleFonts.outfit(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "Join HabitFlow to start your journey.",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),

                              SizedBox(height: 32.h),

                              if (_errorMessage != null)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(12.w),
                                  margin: EdgeInsets.only(bottom: 24.h),
                                  decoration: BoxDecoration(
                                    color: AppTheme.danger.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                    border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline, color: AppTheme.danger, size: 18.sp),
                                      SizedBox(width: 8.w),
                                      Expanded(child: Text(_errorMessage!, style: TextStyle(color: AppTheme.danger, fontSize: 13.sp))),
                                    ],
                                  ),
                                ).animate().shake(duration: 400.ms),

                              // Email
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 15.sp),
                                decoration: InputDecoration(
                                  hintText: 'Email address',
                                  hintStyle: GoogleFonts.inter(color: const Color(0xFF6B7280)),
                                  prefixIcon: Icon(Icons.mail_outline, color: const Color(0xFF6B7280), size: 20.sp),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  contentPadding: EdgeInsets.symmetric(vertical: 18.h),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                    borderSide: const BorderSide(color: Colors.white),
                                  ),
                                ),
                              ),

                              SizedBox(height: 16.h),

                              // Password
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 15.sp),
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: GoogleFonts.inter(color: const Color(0xFF6B7280)),
                                  prefixIcon: Icon(Icons.lock_outline, color: const Color(0xFF6B7280), size: 20.sp),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF6B7280), size: 20.sp),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  contentPadding: EdgeInsets.symmetric(vertical: 18.h),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                    borderSide: const BorderSide(color: Colors.white),
                                  ),
                                ),
                              ),

                              SizedBox(height: 16.h),

                              // Confirm Password
                              TextField(
                                controller: _confirmPasswordController,
                                obscureText: _obscurePassword,
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 15.sp),
                                decoration: InputDecoration(
                                  hintText: 'Confirm Password',
                                  hintStyle: GoogleFonts.inter(color: const Color(0xFF6B7280)),
                                  prefixIcon: Icon(Icons.lock_outline, color: const Color(0xFF6B7280), size: 20.sp),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  contentPadding: EdgeInsets.symmetric(vertical: 18.h),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                    borderSide: const BorderSide(color: Colors.white),
                                  ),
                                ),
                              ),

                              SizedBox(height: 24.h),

                              // Sign Up Button
                              SizedBox(
                                width: double.infinity,
                                height: 54.h,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleSignup,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD1D5DB), // Light gray/silver
                                    foregroundColor: Colors.black,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? SizedBox(width: 22.w, height: 22.h, child: const CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.bolt, size: 20.sp),
                                            SizedBox(width: 8.w),
                                            Text('Create Account', style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                ),
                              ),

                              SizedBox(height: 32.h),

                              // OR Divider
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                                    child: Text('OR', style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                                  ),
                                  Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                                ],
                              ),

                              SizedBox(height: 32.h),

                              // Google Button
                              SizedBox(
                                width: double.infinity,
                                height: 54.h,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    try {
                                      await ref.read(authServiceProvider).signInWithGoogle();
                                    } catch (e) {
                                      setState(() => _errorMessage = 'Google sign up failed');
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Google 'G'
                                      Text('G', style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.w900)),
                                      SizedBox(width: 12.w),
                                      Text('Sign up with Google', style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: 40.h),

                              // Sign in text
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 14.sp),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.pop(),
                                    child: Text(
                                      'Sign in',
                                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.05),
                        
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
