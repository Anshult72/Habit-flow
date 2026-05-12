import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class _Badge { final String title, desc; final IconData icon; final Color color; final bool unlocked;
  const _Badge(this.title, this.desc, this.icon, this.color, {this.unlocked = false});
}

const _badges = [
  _Badge('First Step', 'Complete your first habit', Icons.directions_walk_rounded, Color(0xFF10B981), unlocked: true),
  _Badge('Week Warrior', '7-day streak', Icons.local_fire_department_rounded, Color(0xFFFF6B2C), unlocked: true),
  _Badge('Habit Machine', 'Complete 50 habits', Icons.precision_manufacturing_rounded, Color(0xFF3B82F6), unlocked: true),
  _Badge('Early Bird', 'Complete 5 habits before 8 AM', Icons.wb_sunny_rounded, Color(0xFFFFD700), unlocked: true),
  _Badge('Month Master', '30-day streak', Icons.calendar_month_rounded, Color(0xFFA855F7)),
  _Badge('Century Club', '100-day streak', Icons.military_tech_rounded, Color(0xFFEF4444)),
  _Badge('Scholar', 'Complete 10 Learning Hub topics', Icons.school_rounded, Color(0xFF06B6D4)),
  _Badge('Mission Possible', 'Complete your first mission', Icons.rocket_launch_rounded, Color(0xFFEC4899), unlocked: true),
  _Badge('Brain Dump', 'Create 25 memos', Icons.psychology_rounded, Color(0xFF8B5CF6)),
  _Badge('Saver', 'Save ₹10,000 in wishlist', Icons.savings_rounded, Color(0xFF14B8A6)),
  _Badge('Planner Pro', 'Complete all 6 time slots', Icons.event_available_rounded, Color(0xFFF59E0B)),
  _Badge('Matrix Mind', 'Clear all Q1 tasks', Icons.grid_view_rounded, Color(0xFF6366F1)),
  _Badge('Duel Victor', 'Win 5 duels', Icons.emoji_events_rounded, Color(0xFFE11D48)),
  _Badge('Squad Leader', 'Create a squad', Icons.groups_rounded, Color(0xFF0EA5E9)),
  _Badge('Visionary', 'Achieve 3 vision board goals', Icons.visibility_rounded, Color(0xFFD946EF)),
  _Badge('Legend', 'Reach Level 50', Icons.star_rounded, Color(0xFFFF6B2C)),
];

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unlocked = _badges.where((b) => b.unlocked).length;

    return Scaffold(backgroundColor: AppTheme.background, body: SafeArea(child: Column(children: [
      // Header
      Padding(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h), child: Row(children: [
        GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppTheme.surfaceBorder)),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp))),
        SizedBox(width: 16.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TROPHY CASE', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2.5)),
          Text('Achievements', style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white)),
        ])),
      ])).animate().fadeIn(duration: 400.ms),

      // Stats bar
      Padding(padding: EdgeInsets.symmetric(horizontal: 20.w), child: Container(
        padding: EdgeInsets.all(14.w), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: AppTheme.surfaceBorder)),
        child: Row(children: [
          Container(padding: EdgeInsets.all(10.w), decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
            child: Icon(Icons.emoji_events_rounded, size: 22.sp, color: AppTheme.primary)),
          SizedBox(width: 12.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$unlocked / ${_badges.length} Unlocked', style: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(height: 4.h),
            ClipRRect(borderRadius: BorderRadius.circular(4.r), child: LinearProgressIndicator(
              value: unlocked / _badges.length, minHeight: 6.h,
              backgroundColor: Colors.white.withValues(alpha: 0.05), valueColor: AlwaysStoppedAnimation(AppTheme.primary))),
          ])),
        ]))),
      SizedBox(height: 16.h),

      // Badges Grid
      Expanded(child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12.h, crossAxisSpacing: 12.w, childAspectRatio: 0.9),
        itemCount: _badges.length,
        itemBuilder: (_, i) => _card(_badges[i], i),
      )),
    ])));
  }

  Widget _card(_Badge b, int index) {
    return Container(decoration: BoxDecoration(
      color: b.unlocked ? b.color.withValues(alpha: 0.06) : AppTheme.surface,
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: b.unlocked ? b.color.withValues(alpha: 0.3) : AppTheme.surfaceBorder)),
      child: Padding(padding: EdgeInsets.all(16.w), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: EdgeInsets.all(10.w), decoration: BoxDecoration(
              color: b.unlocked ? b.color.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r)),
              child: Icon(b.icon, size: 24.sp, color: b.unlocked ? b.color : Colors.white12)),
            SizedBox(height: 12.h),
            Text(b.title, style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w700,
              color: b.unlocked ? Colors.white : Colors.white24)),
            SizedBox(height: 4.h),
            Text(b.desc, style: GoogleFonts.inter(fontSize: 11.sp, color: b.unlocked ? AppTheme.textMuted : Colors.white10),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(b.unlocked ? 'UNLOCKED' : 'LOCKED', style: GoogleFonts.outfit(fontSize: 8.sp,
              fontWeight: FontWeight.w800, color: b.unlocked ? b.color : Colors.white10, letterSpacing: 1.5)),
            Icon(b.unlocked ? Icons.lock_open_rounded : Icons.lock_rounded, size: 14.sp,
              color: b.unlocked ? b.color.withValues(alpha: 0.5) : Colors.white10),
          ]),
        ])),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms);
  }
}
