import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class SettingsModal extends ConsumerWidget {
  const SettingsModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(top: 24.h, bottom: MediaQuery.of(context).padding.bottom + 24.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
        border: const Border(top: BorderSide(color: AppTheme.surfaceBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text('SETTINGS', style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppTheme.textMain, letterSpacing: 1.5)),
          ),
          SizedBox(height: 24.h),

          _buildToggle(context, 'Push Notifications', 'Alerts for Duels & Squads', true),
          _buildToggle(context, 'Haptic Feedback', 'Vibrations on success', true),
          _buildToggle(context, 'Dark Theme', 'Enforced by protocol', true, disabled: true),
          
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text('More settings coming in Phase 7', style: GoogleFonts.inter(color: Colors.white38, fontSize: 11.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(BuildContext context, String title, String subtitle, bool value, {bool disabled = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(color: disabled ? Colors.white38 : AppTheme.textMain, fontWeight: FontWeight.w600, fontSize: 14.sp)),
                Text(subtitle, style: GoogleFonts.inter(color: Colors.white24, fontSize: 11.sp)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: disabled ? null : (v) {},
            activeThumbColor: AppTheme.primary,
            activeTrackColor: AppTheme.primary.withValues(alpha: 0.2),
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }
}
