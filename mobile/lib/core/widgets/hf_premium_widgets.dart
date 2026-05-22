import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// A premium glassmorphism card that matches the web's .glass-card class.
/// Uses BackdropFilter for real blur and semantic border colors.
class HFGlassCard extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final double blur;
  final double opacity;
  final List<BoxShadow>? shadows;

  const HFGlassCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.borderColor,
    this.blur = 24.0,
    this.opacity = 0.03,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppTheme.radiusXxl;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadows ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: borderColor ?? AppTheme.surfaceBorder,
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A container that adds a "Glow" effect, matching web's primary-glow utilities.
class HFGlowContainer extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double glowIntensity;
  final double borderRadius;
  final bool showGlow;

  const HFGlowContainer({
    super.key,
    required this.child,
    this.glowColor = AppTheme.primary,
    this.glowIntensity = 0.3,
    this.borderRadius = 32.0,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: glowColor.withValues(alpha: glowIntensity),
                  blurRadius: 30,
                  spreadRadius: -5,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

/// A button that scales down when pressed and provides haptic feedback.
class HFScalableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleDown;

  const HFScalableButton({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleDown = 0.96,
  });

  @override
  State<HFScalableButton> createState() => _HFScalableButtonState();
}

class _HFScalableButtonState extends State<HFScalableButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleDown).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Vignette and Noise overlays to match the web's cinematic feel.
class HFScaffoldWrapper extends StatelessWidget {
  final Widget child;
  final bool showNoise;
  final bool showVignette;

  const HFScaffoldWrapper({
    super.key,
    required this.child,
    this.showNoise = true,
    this.showVignette = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (showVignette)
          IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    Color(0x4D000000), // 30% black at edges
                  ],
                  stops: [0.4, 1.0],
                ),
              ),
            ),
          ),
        if (showNoise)
          IgnorePointer(
            child: Opacity(
              opacity: 0.015,
              child: Image.asset(
                'assets/images/noise.png', // We'll need to add this or use a custom painter
                repeat: ImageRepeat.repeat,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
      ],
    );
  }
}

/// A premium shimmer skeleton list to replace generic CircularProgressIndicators
class HFShimmerList extends StatelessWidget {
  final int count;
  final double height;
  final double width;
  final double? borderRadius;
  
  const HFShimmerList({
    super.key,
    this.count = 3,
    this.height = 80.0,
    this.width = double.infinity,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (index) => Container(
        height: height.h,
        width: width,
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusMd),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
      )).animate(onPlay: (c) => c.repeat()).shimmer(
        duration: 1500.ms, 
        color: Colors.white.withValues(alpha: 0.03),
      ),
    );
  }
}

/// A premium empty/error state view to replace raw exception dumps.
class HFErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const HFErrorState({
    super.key,
    this.title = 'MODULE OFFLINE',
    this.message = 'Unable to establish link with command center.\nVerify uplink or check local cache.',
    this.icon = Icons.satellite_alt_rounded,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: AppTheme.danger, size: 32.sp),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: AppTheme.danger,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppTheme.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 32.h),
              HFScalableButton(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onRetry!();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, color: AppTheme.textMain, size: 16.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'RETRY CONNECTION',
                        style: GoogleFonts.outfit(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMain,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

/// A premium primary button used throughout the application.
class HFPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? borderRadius;
  final double? width;

  const HFPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.padding,
    this.color,
    this.borderRadius,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primary;

    return HFScalableButton(
      onTap: isLoading ? () {} : onTap,
      child: Container(
        width: width ?? double.infinity,
        padding: padding ?? EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : effectiveColor,
          borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusMd),
          border: isOutlined
              ? Border.all(color: Colors.white.withValues(alpha: 0.1))
              : null,
          boxShadow: !isOutlined
              ? [
                  BoxShadow(
                    color: effectiveColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 18.sp),
                      SizedBox(width: 12.w),
                    ],
                    Text(
                      label.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: isOutlined ? AppTheme.textMuted : Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
