import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../core/constants/app_constants.dart';
import '../notifications/notifications_modal.dart';
import 'edit_profile_dialog.dart';
import 'settings_modal.dart';

/// Profile/Vault screen with web-matching design.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: userAsync.when(
          data: (user) => ListView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 120.h),
            children: [
              // Header
              Text('VAULT', style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 2)),
              SizedBox(height: 4.h),
              Text('Profile & Settings', style: GoogleFonts.outfit(fontSize: 24.sp, fontWeight: FontWeight.w800, color: AppTheme.textMain, letterSpacing: -0.5)),

              SizedBox(height: 28.h),

              // Profile card
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: AppTheme.glassCard(borderRadius: AppTheme.radiusXxl),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (ctx) => EditProfileDialog(user: user),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Icon(Icons.edit, color: Colors.white54, size: 16.sp),
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 44.r,
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      backgroundImage: user.avatarUrl != null 
                          ? (user.avatarUrl!.startsWith('http')
                              ? NetworkImage(user.avatarUrl!)
                              : FileImage(File(user.avatarUrl!)) as ImageProvider)
                          : null,
                      child: user.avatarUrl == null ? Icon(Icons.person, size: 40.sp, color: Colors.white24) : null,
                    ),
                    SizedBox(height: 16.h),
                    Text(user.name ?? 'Unknown Operator', style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
                    SizedBox(height: 4.h),
                    Text(user.email ?? '', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13.sp)),
                    if (user.userId.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text('ID: ${user.userId}', style: GoogleFonts.inter(color: Colors.white24, fontSize: 10.sp)),
                    ],
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms),

              SizedBox(height: 16.h),

              // Stats grid
              Row(
                children: [
                  _buildStatTile('TOTAL XP', '${user.xp}', AppTheme.primary),
                  SizedBox(width: 8.w),
                  _buildStatTile('LEVEL', '${user.level}', const Color(0xFF3B82F6)),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  _buildStatTile('SHIELDS', '${user.streakShields}', AppTheme.success),
                  SizedBox(width: 8.w),
                  _buildStatTile('STREAK', '🔥', AppTheme.accent),
                ],
              ),

              SizedBox(height: 24.h),

              // Menu items
              _buildMenuTile(Icons.tune_rounded, 'Settings', 'App preferences', () {
                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => const SettingsModal());
              }),
              _buildMenuTile(Icons.shield_outlined, 'Security', 'Password, 2FA', null),
              _buildMenuTile(Icons.notifications_active_outlined, 'Notifications', 'Manage alerts', () {
                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => const NotificationsModal());
              }),
              _buildMenuTile(Icons.info_outline_rounded, 'About', 'v${AppConstants.appVersion}', null),

              SizedBox(height: 16.h),

              // Logout
              GestureDetector(
                onTap: () => _confirmLogout(context, ref),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.danger.withValues(alpha: 0.15)),
                  ),
                  child: Center(
                    child: Text('SIGN OUT', style: GoogleFonts.outfit(color: AppTheme.danger, fontWeight: FontWeight.w700, fontSize: 13.sp, letterSpacing: 1.5)),
                  ),
                ),
              ),
            ],
          ),
          loading: () => Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: const HFShimmerList(height: 150, count: 1),
          ),
          error: (e, _) => HFErrorState(
            onRetry: () => ref.invalidate(userProfileProvider),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
        title: Text('Sign Out?', style: GoogleFonts.outfit(color: AppTheme.textMain, fontWeight: FontWeight.w700)),
        content: Text('You will need to log in again.', style: GoogleFonts.inter(color: AppTheme.textMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authServiceProvider).signOut();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: AppTheme.glowCard(glowColor: color, glowIntensity: 0.1, borderRadius: AppTheme.radiusMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.outfit(color: AppTheme.textMuted, fontSize: 9.sp, fontWeight: FontWeight.w700, letterSpacing: 1)),
            SizedBox(height: 4.h),
            Text(value, style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, String subtitle, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: AppTheme.glassCard(borderRadius: AppTheme.radiusMd),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 18.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(color: AppTheme.textMain, fontWeight: FontWeight.w600, fontSize: 14.sp)),
                  Text(subtitle, style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11.sp)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white24, size: 18.sp),
          ],
        ),
      ),
    );
  }
}
