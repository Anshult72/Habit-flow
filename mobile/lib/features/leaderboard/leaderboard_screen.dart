import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class _User { final int rank; final String name, avatar, title, xp; final int score, streak, level, completion; final bool isYou;
  const _User(this.rank, this.name, this.avatar, this.title, this.score, this.streak, this.level, this.xp, this.completion, {this.isYou = false});
}

const _top3 = [
  _User(2, 'Elena Vasquez', 'EV', 'Productivity Elite', 9420, 84, 42, '84.2K', 94),
  _User(1, 'Arjun Mehta', 'AM', 'Consistency Master', 11250, 127, 58, '116K', 98),
  _User(3, 'Sofia Chen', 'SC', 'Focus Champion', 8890, 63, 37, '72.5K', 91),
];

const _rest = [
  _User(4, 'Marcus Johnson', 'MJ', 'Habit Warrior', 8210, 52, 34, '66.1K', 89),
  _User(5, 'Yuki Tanaka', 'YT', 'Streak Hunter', 7840, 47, 31, '58.9K', 87),
  _User(6, 'Priya Sharma', 'PS', 'Growth Seeker', 7520, 41, 29, '54.3K', 85, isYou: true),
  _User(7, "Liam O'Brien", 'LO', 'Rising Star', 7100, 38, 27, '49.8K', 83),
  _User(8, 'Amara Obi', 'AO', 'Momentum Builder', 6780, 34, 25, '45.2K', 80),
  _User(9, 'Noah Kim', 'NK', 'Daily Achiever', 6400, 29, 23, '41.6K', 78),
  _User(10, 'Zara Ahmed', 'ZA', 'Path Finder', 6050, 25, 21, '38.1K', 76),
];

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

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
          Text('GLOBAL RANKINGS', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2.5)),
          Text('Leaderboard', style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white)),
        ])),
      ])).animate().fadeIn(duration: 400.ms),

      Expanded(child: ListView(padding: EdgeInsets.symmetric(horizontal: 20.w), children: [
        // Podium
        SizedBox(height: 12.h),
        _podium(),
        SizedBox(height: 24.h),

        // Full Rankings Header
        Row(children: [
          Icon(Icons.trending_up_rounded, size: 14.sp, color: AppTheme.primary.withValues(alpha: 0.6)),
          SizedBox(width: 6.w),
          Text('FULL RANKINGS', style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1.5)),
          const Spacer(),
          Text('Updated live', style: GoogleFonts.inter(fontSize: 10.sp, color: Colors.white12)),
        ]),
        SizedBox(height: 12.h),

        // Rows
        ..._rest.asMap().entries.map((e) => _row(e.value, e.key)),
        SizedBox(height: 80.h),
      ])),
    ])));
  }

  Widget _podium() {
    return SizedBox(height: 280.h, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(child: _podiumCard(_top3[0], 200.h)), // #2
      SizedBox(width: 8.w),
      Expanded(child: _podiumCard(_top3[1], 260.h)), // #1
      SizedBox(width: 8.w),
      Expanded(child: _podiumCard(_top3[2], 180.h)), // #3
    ]));
  }

  Widget _podiumCard(_User u, double h) {
    final isChamp = u.rank == 1;
    final rankColors = {1: AppTheme.primary, 2: const Color(0xFFC0C0C0), 3: const Color(0xFFCD7F32)};
    final c = rankColors[u.rank]!;

    return Container(height: h, decoration: BoxDecoration(
      color: isChamp ? AppTheme.primary.withValues(alpha: 0.08) : AppTheme.surface,
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: isChamp ? AppTheme.primary.withValues(alpha: 0.3) : AppTheme.surfaceBorder)),
      child: Padding(padding: EdgeInsets.all(12.w), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Rank
        Container(padding: EdgeInsets.all(6.w), decoration: BoxDecoration(
          color: isChamp ? AppTheme.primary : c.withValues(alpha: 0.2), shape: BoxShape.circle,
          border: isChamp ? null : Border.all(color: c.withValues(alpha: 0.4))),
          child: isChamp ? Icon(Icons.workspace_premium_rounded, size: 14.sp, color: Colors.white)
            : Text('#${u.rank}', style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w800, color: c))),
        SizedBox(height: 8.h),
        // Avatar
        Container(width: isChamp ? 52.w : 44.w, height: isChamp ? 52.w : 44.w, decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFFFFB347)]),
          borderRadius: BorderRadius.circular(14.r)),
          alignment: Alignment.center,
          child: Text(u.avatar, style: GoogleFonts.outfit(fontSize: isChamp ? 18.sp : 14.sp, fontWeight: FontWeight.w800, color: Colors.white))),
        SizedBox(height: 8.h),
        Text(u.name, style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white),
          textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(u.title, style: GoogleFonts.inter(fontSize: 9.sp, color: isChamp ? AppTheme.primary : AppTheme.textMuted),
          textAlign: TextAlign.center),
        SizedBox(height: 6.h),
        Text('${u.score}', style: GoogleFonts.outfit(fontSize: isChamp ? 20.sp : 16.sp, fontWeight: FontWeight.w900, color: Colors.white)),
        Text('SCORE', style: GoogleFonts.outfit(fontSize: 7.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1.5)),
        SizedBox(height: 6.h),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.local_fire_department_rounded, size: 12.sp, color: AppTheme.primary),
          SizedBox(width: 2.w),
          Text('${u.streak}', style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.white70)),
        ]),
      ])),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _row(_User u, int index) {
    return Container(margin: EdgeInsets.only(bottom: 8.h), padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: u.isYou ? AppTheme.primary.withValues(alpha: 0.05) : AppTheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: u.isYou ? AppTheme.primary.withValues(alpha: 0.25) : AppTheme.surfaceBorder)),
      child: Row(children: [
        SizedBox(width: 28.w, child: Text('${u.rank}', style: GoogleFonts.outfit(
          fontSize: 14.sp, fontWeight: FontWeight.w700, color: u.isYou ? AppTheme.primary : Colors.white24))),
        Container(width: 38.w, height: 38.w, decoration: BoxDecoration(
          color: u.isYou ? AppTheme.primary : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10.r),
          border: u.isYou ? null : Border.all(color: Colors.white.withValues(alpha: 0.1))),
          alignment: Alignment.center,
          child: Text(u.avatar, style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w700,
            color: u.isYou ? Colors.white : Colors.white54))),
        SizedBox(width: 12.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text(u.name, style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w600,
              color: u.isYou ? Colors.white : Colors.white70), overflow: TextOverflow.ellipsis)),
            if (u.isYou) ...[SizedBox(width: 6.w), Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
              decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4.r)),
              child: Text('YOU', style: GoogleFonts.outfit(fontSize: 8.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 1)))],
          ]),
          Text(u.title, style: GoogleFonts.inter(fontSize: 10.sp, color: AppTheme.textMuted)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${u.score}', style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w800,
            color: u.isYou ? AppTheme.primary : Colors.white54)),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.local_fire_department_rounded, size: 10.sp, color: AppTheme.primary.withValues(alpha: 0.6)),
            Text(' ${u.streak}', style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.white38)),
          ]),
        ]),
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms);
  }
}
