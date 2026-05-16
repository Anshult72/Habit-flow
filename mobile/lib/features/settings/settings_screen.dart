import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = true;
  final bool _darkMode = true;
  bool _haptics = true;
  bool _autoSync = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppTheme.background, body: SafeArea(child: Column(children: [
      // Header
      Padding(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h), child: Row(children: [
        GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppTheme.surfaceBorder)),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp))),
        SizedBox(width: 16.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SYSTEM CONFIG', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2.5)),
          Text('Settings', style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white)),
        ])),
      ])).animate().fadeIn(duration: 400.ms),

      Expanded(child: ListView(padding: EdgeInsets.symmetric(horizontal: 20.w), children: [
        SizedBox(height: 8.h),

        _sectionLabel('PREFERENCES'),
        _toggleTile('Notifications', 'Push alerts for habits & missions', Icons.notifications_rounded, _notifications, (v) => setState(() => _notifications = v)),
        _toggleTile('Dark Mode', 'Currently the only mode', Icons.dark_mode_rounded, _darkMode, null),
        _toggleTile('Haptic Feedback', 'Vibration on interactions', Icons.vibration_rounded, _haptics, (v) => setState(() => _haptics = v)),
        _toggleTile('Auto-Sync', 'Sync data with cloud', Icons.sync_rounded, _autoSync, (v) => setState(() => _autoSync = v)),

        SizedBox(height: 20.h),
        _sectionLabel('ACCOUNT'),
        _actionTile('Edit Profile', 'Change name, avatar, bio', Icons.person_rounded, () {}),
        _actionTile('Change Password', 'Update your password', Icons.lock_rounded, () {}),
        _actionTile('Export Data', 'Download all your data', Icons.download_rounded, () {}),

        SizedBox(height: 20.h),
        _sectionLabel('ABOUT'),
        _infoTile('Version', '1.0.0'),
        _infoTile('Backend', 'Railway (Production)'),
        _infoTile('Build', 'Flutter 3.x'),

        SizedBox(height: 20.h),
        _sectionLabel('DANGER ZONE'),
        GestureDetector(
          onTap: () async {
            final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
              backgroundColor: AppTheme.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              title: Text('Logout', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700)),
              content: Text('Are you sure you want to logout?', style: GoogleFonts.inter(color: AppTheme.textMuted)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54))),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Logout', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.w700))),
              ]));
            if (confirmed == true) {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
          child: Container(margin: EdgeInsets.only(bottom: 8.h), padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.red.withValues(alpha: 0.2))),
            child: Row(children: [
              Icon(Icons.logout_rounded, size: 20.sp, color: Colors.redAccent),
              SizedBox(width: 12.w),
              Text('Logout', style: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.redAccent)),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, size: 20.sp, color: Colors.red.withValues(alpha: 0.3)),
            ])),
        ),

        GestureDetector(
          onTap: () {
            showDialog(context: context, builder: (ctx) => AlertDialog(
              backgroundColor: AppTheme.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              title: Text('Delete Account', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.w700)),
              content: Text('This action is irreversible. All your data will be lost forever.', style: GoogleFonts.inter(color: AppTheme.textMuted)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54))),
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text('I understand', style: GoogleFonts.inter(color: Colors.redAccent))),
              ]));
          },
          child: Container(margin: EdgeInsets.only(bottom: 8.h), padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.red.withValues(alpha: 0.1))),
            child: Row(children: [
              Icon(Icons.delete_forever_rounded, size: 20.sp, color: Colors.red.withValues(alpha: 0.5)),
              SizedBox(width: 12.w),
              Text('Delete Account', style: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.red.withValues(alpha: 0.5))),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, size: 20.sp, color: Colors.red.withValues(alpha: 0.15)),
            ])),
        ),

        SizedBox(height: 80.h),
      ])),
    ])));
  }

  Widget _sectionLabel(String t) => Padding(padding: EdgeInsets.only(bottom: 10.h),
    child: Text(t, style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 2)));

  Widget _toggleTile(String title, String desc, IconData icon, bool value, Function(bool)? onChanged) {
    return Container(margin: EdgeInsets.only(bottom: 8.h), padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: AppTheme.surfaceBorder)),
      child: Row(children: [
        Container(padding: EdgeInsets.all(8.w), decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
          child: Icon(icon, size: 18.sp, color: AppTheme.primary)),
        SizedBox(width: 12.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white)),
          Text(desc, style: GoogleFonts.inter(fontSize: 11.sp, color: AppTheme.textMuted)),
        ])),
        Switch.adaptive(value: value, onChanged: onChanged, activeThumbColor: AppTheme.primary,
          activeTrackColor: AppTheme.primary.withValues(alpha: 0.3)),
      ]));
  }

  Widget _actionTile(String title, String desc, IconData icon, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: AppTheme.surfaceBorder)),
      child: Row(children: [
        Container(padding: EdgeInsets.all(8.w), decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10.r)),
          child: Icon(icon, size: 18.sp, color: Colors.white54)),
        SizedBox(width: 12.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white)),
          Text(desc, style: GoogleFonts.inter(fontSize: 11.sp, color: AppTheme.textMuted)),
        ])),
        Icon(Icons.chevron_right_rounded, size: 20.sp, color: Colors.white12),
      ])));
  }

  Widget _infoTile(String label, String value) {
    return Container(margin: EdgeInsets.only(bottom: 8.h), padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: AppTheme.surfaceBorder)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white)),
        Text(value, style: GoogleFonts.inter(fontSize: 13.sp, color: AppTheme.textMuted)),
      ]));
  }
}
