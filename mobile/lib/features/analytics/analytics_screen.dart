import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import 'dart:math';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(child: SingleChildScrollView(
        padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h, bottom: 100.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Text('Performance', style: GoogleFonts.outfit(fontSize: 32.sp, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
          SizedBox(height: 4.h),
          Text('Track your growth metrics', style: GoogleFonts.inter(fontSize: 14.sp, color: AppTheme.textMuted)),
          SizedBox(height: 24.h),

          // Top Stats
          Row(children: [
            _bigStat('2,450', 'Total XP', Icons.star_rounded, AppTheme.primary),
            SizedBox(width: 12.w),
            _bigStat('Level 8', 'Current', Icons.bolt_rounded, const Color(0xFF3B82F6)),
          ]).animate().fadeIn(duration: 400.ms),
          SizedBox(height: 12.h),
          Row(children: [
            _bigStat('92%', 'Consistency', Icons.trending_up_rounded, const Color(0xFF10B981)),
            SizedBox(width: 12.w),
            _bigStat('14 Days', 'Streak', Icons.local_fire_department_rounded, const Color(0xFFFFD700)),
          ]).animate().fadeIn(delay: 100.ms, duration: 400.ms),

          SizedBox(height: 24.h),

          // Weekly Activity Chart
          Text('WEEKLY ACTIVITY', style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 2)),
          SizedBox(height: 12.h),
          Container(padding: EdgeInsets.all(16.w), decoration: BoxDecoration(color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20.r), border: Border.all(color: AppTheme.surfaceBorder)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Habits Completed', style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r)),
                  child: Text('+14%', style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.w800, color: const Color(0xFF10B981)))),
              ]),
              SizedBox(height: 16.h),
              SizedBox(height: 120.h, child: _BarChart()),
              SizedBox(height: 8.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((d) =>
                  Text(d, style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w600, color: AppTheme.textMuted))).toList()),
            ])).animate().fadeIn(delay: 200.ms, duration: 400.ms),

          SizedBox(height: 24.h),

          // Category Breakdown
          Text('CATEGORY BREAKDOWN', style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 2)),
          SizedBox(height: 12.h),
          ..._categoryData.asMap().entries.map((e) => _categoryRow(e.value, e.key)),

          SizedBox(height: 24.h),

          // Insights
          Text('AI INSIGHTS', style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 2)),
          SizedBox(height: 12.h),
          _insightCard(Icons.trending_up_rounded, 'Efficiency Up', 'Your consistency improved by 23% this week.', const Color(0xFF10B981)),
          SizedBox(height: 8.h),
          _insightCard(Icons.access_time_rounded, 'Peak Hours', 'You\'re most productive between 9 AM - 12 PM.', const Color(0xFF3B82F6)),
          SizedBox(height: 8.h),
          _insightCard(Icons.local_fire_department_rounded, 'Streak Alert', 'Keep going! 14 more days to reach Diamond streak.', AppTheme.primary),
        ]),
      )),
    );
  }

  Widget _bigStat(String value, String label, IconData icon, Color color) {
    return Expanded(child: Container(padding: EdgeInsets.all(16.w), decoration: BoxDecoration(color: AppTheme.surface,
      borderRadius: BorderRadius.circular(18.r), border: Border.all(color: AppTheme.surfaceBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: EdgeInsets.all(8.w), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
          child: Icon(icon, size: 20.sp, color: color)),
        SizedBox(height: 12.h),
        Text(value, style: GoogleFonts.outfit(fontSize: 24.sp, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(label, style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 1)),
      ])));
  }

  Widget _categoryRow(_CatData d, int i) {
    return Container(margin: EdgeInsets.only(bottom: 8.h), padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.surfaceBorder)),
      child: Row(children: [
        Container(width: 8.w, height: 36.h, decoration: BoxDecoration(color: d.color, borderRadius: BorderRadius.circular(4.r))),
        SizedBox(width: 12.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d.name, style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white)),
          SizedBox(height: 4.h),
          ClipRRect(borderRadius: BorderRadius.circular(4.r), child: LinearProgressIndicator(
            value: d.pct / 100, minHeight: 4.h, backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: AlwaysStoppedAnimation(d.color))),
        ])),
        SizedBox(width: 12.w),
        Text('${d.pct}%', style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w800, color: d.color)),
      ])).animate().fadeIn(delay: Duration(milliseconds: 50 * i), duration: 300.ms);
  }

  Widget _insightCard(IconData icon, String title, String desc, Color color) {
    return Container(padding: EdgeInsets.all(14.w), decoration: BoxDecoration(color: color.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16.r), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Row(children: [
        Container(padding: EdgeInsets.all(8.w), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10.r)),
          child: Icon(icon, size: 18.sp, color: color)),
        SizedBox(width: 12.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w800, color: color, letterSpacing: 1)),
          Text(desc, style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.white70, fontStyle: FontStyle.italic)),
        ])),
      ])).animate().fadeIn(duration: 300.ms);
  }
}

class _CatData { final String name; final double pct; final Color color;
  const _CatData(this.name, this.pct, this.color);
}

const _categoryData = [
  _CatData('Health & Fitness', 95, Color(0xFF10B981)),
  _CatData('Productivity', 88, Color(0xFF3B82F6)),
  _CatData('Learning', 72, Color(0xFFA855F7)),
  _CatData('Mindfulness', 65, Color(0xFFFFD700)),
  _CatData('Social', 42, Color(0xFFEC4899)),
];

class _BarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vals = [45, 60, 90, 120, 80, 40, 75];
    final maxV = vals.reduce(max).toDouble();
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: vals.asMap().entries.map((e) {
      final h = (e.value / maxV * 100).h;
      return Expanded(child: Container(margin: EdgeInsets.symmetric(horizontal: 3.w),
        height: h, decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(4.r))));
    }).toList());
  }
}
