import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(backgroundColor: AppTheme.background, body: SafeArea(child: Column(children: [
      Padding(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h), child: Row(children: [
        GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppTheme.surfaceBorder)),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp))),
        SizedBox(width: 16.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PERFORMANCE DATA', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2.5)),
          Text('Reports', style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white)),
        ])),
      ])).animate().fadeIn(duration: 400.ms),

      Expanded(child: ListView(padding: EdgeInsets.symmetric(horizontal: 20.w), children: [
        SizedBox(height: 8.h),
        _reportCard('Weekly Summary', 'Performance overview of your past 7 days', Icons.bar_chart_rounded, '87%', AppTheme.primary),
        _reportCard('Habit Consistency', 'Track your streak and completion rates', Icons.trending_up_rounded, '92%', const Color(0xFF10B981)),
        _reportCard('Focus Time', 'Total deep work hours this week', Icons.timer_rounded, '14.5h', const Color(0xFF3B82F6)),
        _reportCard('Mission Progress', 'Aggregate mission completion status', Icons.flag_rounded, '65%', const Color(0xFFA855F7)),
        _reportCard('XP Earned', 'Total experience points this month', Icons.star_rounded, '2,450', const Color(0xFFFFD700)),
        _reportCard('Planner Efficiency', 'Task completion across time blocks', Icons.calendar_view_day_rounded, '78%', const Color(0xFFEC4899)),
        SizedBox(height: 80.h),
      ])),
    ])));
  }

  Widget _reportCard(String title, String desc, IconData icon, String value, Color color) {
    return Container(margin: EdgeInsets.only(bottom: 12.h), padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: AppTheme.surfaceBorder)),
      child: Row(children: [
        Container(padding: EdgeInsets.all(12.w), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14.r)),
          child: Icon(icon, size: 24.sp, color: color)),
        SizedBox(width: 14.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white)),
          SizedBox(height: 2.h),
          Text(desc, style: GoogleFonts.inter(fontSize: 11.sp, color: AppTheme.textMuted)),
        ])),
        Container(padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
          child: Text(value, style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w800, color: color))),
      ]),
    ).animate().fadeIn(duration: 300.ms);
  }
}
