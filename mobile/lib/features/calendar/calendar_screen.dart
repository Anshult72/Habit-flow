import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _current = DateTime.now();
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppTheme.background, body: SafeArea(child: Column(children: [
      Padding(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h), child: Row(children: [
        GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppTheme.surfaceBorder)),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp))),
        SizedBox(width: 16.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TEMPORAL VIEW', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2.5)),
          Text('Calendar', style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white)),
        ])),
      ])).animate().fadeIn(duration: 400.ms),

      // Month Nav
      Padding(padding: EdgeInsets.symmetric(horizontal: 20.w), child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: AppTheme.surfaceBorder)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(icon: Icon(Icons.chevron_left_rounded, color: Colors.white54, size: 22.sp),
            onPressed: () => setState(() => _current = DateTime(_current.year, _current.month - 1))),
          Text('${_monthName(_current.month)} ${_current.year}', style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white)),
          IconButton(icon: Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 22.sp),
            onPressed: () => setState(() => _current = DateTime(_current.year, _current.month + 1))),
        ]))),
      SizedBox(height: 12.h),

      // Day Headers
      Padding(padding: EdgeInsets.symmetric(horizontal: 20.w), child: Row(
        children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((d) =>
          Expanded(child: Center(child: Text(d, style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1))))).toList())),
      SizedBox(height: 8.h),

      // Calendar Grid
      Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 20.w), child: _buildGrid())),
    ])));
  }

  Widget _buildGrid() {
    final first = DateTime(_current.year, _current.month, 1);
    final daysInMonth = DateTime(_current.year, _current.month + 1, 0).day;
    final startWeekday = first.weekday; // Mon=1
    final now = DateTime.now();

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
      itemCount: daysInMonth + startWeekday - 1,
      itemBuilder: (_, i) {
        if (i < startWeekday - 1) return const SizedBox();
        final day = i - startWeekday + 2;
        final date = DateTime(_current.year, _current.month, day);
        final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
        final isSelected = _selected != null && date.year == _selected!.year && date.month == _selected!.month && date.day == _selected!.day;

        return GestureDetector(
          onTap: () => setState(() => _selected = date),
          child: Container(
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : isToday ? AppTheme.primary.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
              border: isToday && !isSelected ? Border.all(color: AppTheme.primary.withValues(alpha: 0.4)) : null,
            ),
            alignment: Alignment.center,
            child: Text('$day', style: GoogleFonts.outfit(
              fontSize: 14.sp, fontWeight: isToday || isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected ? Colors.white : isToday ? AppTheme.primary : Colors.white70)),
          ),
        );
      });
  }

  String _monthName(int m) => ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];
}
