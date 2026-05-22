import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
// Removed unused import

import 'package:fl_chart/fl_chart.dart';
import '../../core/widgets/hf_premium_widgets.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h, bottom: 120.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('Performance',
                  style: GoogleFonts.outfit(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5)),
              SizedBox(height: 4.h),
              Text('Track your growth metrics',
                  style: GoogleFonts.inter(fontSize: 14.sp, color: AppTheme.textMuted)),
              SizedBox(height: 24.h),

              // Top Stats Grid
              Row(
                children: [
                  _buildStatCard('0', 'TOTAL XP', Icons.star_rounded, AppTheme.primary),
                  SizedBox(width: 12.w),
                  _buildStatCard('Level 1', 'CURRENT', Icons.bolt_rounded, const Color(0xFF3B82F6)),
                ],
              ).animate().fadeIn(duration: 400.ms),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _buildStatCard('92%', 'CONSISTENCY', Icons.trending_up_rounded, const Color(0xFF10B981)),
                  SizedBox(width: 12.w),
                  _buildStatCard('14 Days', 'STREAK', Icons.local_fire_department_rounded, const Color(0xFFFFD700)),
                ],
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              SizedBox(height: 32.h),

              // Weekly Activity Chart
              Text('WEEKLY PRODUCTIVITY',
                  style: GoogleFonts.outfit(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                      letterSpacing: 2)),
              SizedBox(height: 16.h),
              HFGlassCard(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Habit Yield',
                            style: GoogleFonts.outfit(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.r)),
                          child: Text('+14%',
                              style: GoogleFonts.outfit(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF10B981))),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      height: 180.h,
                      child: _buildLineChart(),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              SizedBox(height: 32.h),

              // Category Breakdown (Pie Chart)
              Text('CATEGORY DISTRIBUTION',
                  style: GoogleFonts.outfit(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                      letterSpacing: 2)),
              SizedBox(height: 16.h),
              HFGlassCard(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  children: [
                    SizedBox(
                      width: 140.w,
                      height: 140.w,
                      child: _buildPieChart(),
                    ),
                    SizedBox(width: 24.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _categoryData.take(4).map((d) => _buildLegendItem(d)).toList(),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              SizedBox(height: 32.h),

              // AI Insights
              Text('AI INTELLIGENCE',
                  style: GoogleFonts.outfit(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                      letterSpacing: 2)),
              SizedBox(height: 16.h),
              _buildInsightCard(Icons.trending_up_rounded, 'EFFICIENCY UP',
                  'Your consistency improved by 23% this week.', const Color(0xFF10B981)),
              SizedBox(height: 12.h),
              _buildInsightCard(Icons.access_time_rounded, 'PEAK PERFORMANCE',
                  'You\'re most productive between 9 AM - 12 PM.', const Color(0xFF3B82F6)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: HFGlassCard(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HFGlowContainer(
              glowColor: color,
              glowIntensity: 0.15,
              borderRadius: 10.r,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 18.sp, color: color),
              ),
            ),
            SizedBox(height: 14.h),
            Text(value,
                style: GoogleFonts.outfit(
                    fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white)),
            Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted,
                    letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                if (val.toInt() >= 0 && val.toInt() < days.length) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(days[val.toInt()],
                        style: GoogleFonts.outfit(fontSize: 10.sp, color: AppTheme.textMuted)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3),
              FlSpot(1, 4),
              FlSpot(2, 3.5),
              FlSpot(3, 5),
              FlSpot(4, 4),
              FlSpot(5, 4.5),
              FlSpot(6, 6),
            ],
            isCurved: true,
            color: AppTheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primary.withValues(alpha: 0.2),
                  AppTheme.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 35.w,
        sections: _categoryData.asMap().entries.map((e) {
          final d = e.value;
          return PieChartSectionData(
            color: d.color,
            value: d.pct,
            radius: 12.w,
            showTitle: false,
            badgeWidget: null,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegendItem(_CatData d) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(color: d.color, shape: BoxShape.circle),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(d.name,
                style: GoogleFonts.inter(
                    fontSize: 11.sp, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
          Text('${d.pct.toInt()}%',
              style: GoogleFonts.outfit(
                  fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildInsightCard(IconData icon, String title, String desc, Color color) {
    return HFGlassCard(
      padding: EdgeInsets.all(16.w),
      // Removed undefined backgroundColor
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.sp, color: color),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.outfit(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: 1)),
                SizedBox(height: 4.h),
                Text(desc,
                    style: GoogleFonts.inter(
                        fontSize: 12.sp, color: Colors.white70, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _CatData {
  final String name;
  final double pct;
  final Color color;
  const _CatData(this.name, this.pct, this.color);
}

const _categoryData = [
  _CatData('Health', 35, Color(0xFF10B981)),
  _CatData('Productivity', 25, Color(0xFFEAB308)),
  _CatData('Learning', 20, Color(0xFF3B82F6)),
  _CatData('Mindfulness', 15, Color(0xFFA855F7)),
  _CatData('Finance', 5, Color(0xFF14B8A6)),
];
