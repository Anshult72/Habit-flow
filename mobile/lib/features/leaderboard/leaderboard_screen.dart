import 'package:flutter/material.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../models/leaderboard_model.dart';
import '../../services/analytics_service.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
          child: Column(children: [
        // Header
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(children: [
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppTheme.surfaceBorder)),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp))),
              SizedBox(width: 16.w),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('GLOBAL RANKINGS',
                    style: GoogleFonts.outfit(
                        fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2.5)),
                Text('Leaderboard', style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white)),
              ])),
            ])).animate().fadeIn(duration: 400.ms),

        Expanded(
          child: leaderboardAsync.when(
            data: (users) {
              if (users.isEmpty) {
                return Center(
                    child: Text('No rankings available yet.',
                        style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 14.sp)));
              }

              final top3 = users.take(3).toList();
              final rest = users.skip(3).toList();

              return ListView(padding: EdgeInsets.symmetric(horizontal: 20.w), children: [
                // Podium
                SizedBox(height: 12.h),
                if (top3.isNotEmpty) _podium(top3),
                SizedBox(height: 24.h),

                // Full Rankings Header
                Row(children: [
                  Icon(Icons.trending_up_rounded, size: 14.sp, color: AppTheme.primary.withValues(alpha: 0.6)),
                  SizedBox(width: 6.w),
                  Text('FULL RANKINGS',
                      style: GoogleFonts.outfit(
                          fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1.5)),
                  const Spacer(),
                  Text('Updated live', style: GoogleFonts.inter(fontSize: 10.sp, color: Colors.white12)),
                ]),
                SizedBox(height: 12.h),

                // Rows
                ...rest.asMap().entries.map((e) => _row(e.value, e.key)),
                SizedBox(height: 80.h),
              ]);
            },
            loading: () => Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: const HFShimmerList(height: 70, count: 6),
            ),
            error: (e, _) => HFErrorState(
              onRetry: () => ref.refresh(leaderboardProvider),
            ),
          ),
        ),
      ])),
    );
  }

  Widget _podium(List<LeaderboardUserModel> top3) {
    // Expected order: #2, #1, #3
    LeaderboardUserModel? p1, p2, p3;
    if (top3.isNotEmpty) p1 = top3[0];
    if (top3.length > 1) p2 = top3[1];
    if (top3.length > 2) p3 = top3[2];

    return SizedBox(
        height: 280.h,
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (p2 != null) Expanded(child: _podiumCard(p2, 200.h)) else const Spacer(),
          SizedBox(width: 8.w),
          if (p1 != null) Expanded(child: _podiumCard(p1, 260.h)) else const Spacer(),
          SizedBox(width: 8.w),
          if (p3 != null) Expanded(child: _podiumCard(p3, 180.h)) else const Spacer(),
        ]));
  }

  Widget _podiumCard(LeaderboardUserModel u, double h) {
    final isChamp = u.rank == 1;
    final rankColors = {1: AppTheme.primary, 2: const Color(0xFFC0C0C0), 3: const Color(0xFFCD7F32)};
    final c = rankColors[u.rank] ?? Colors.white54;

    return Container(
      height: h,
      decoration: BoxDecoration(
          color: isChamp ? AppTheme.primary.withValues(alpha: 0.08) : AppTheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: isChamp ? AppTheme.primary.withValues(alpha: 0.3) : AppTheme.surfaceBorder)),
      child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Rank
            Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                    color: isChamp ? AppTheme.primary : c.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: isChamp ? null : Border.all(color: c.withValues(alpha: 0.4))),
                child: isChamp
                    ? Icon(Icons.workspace_premium_rounded, size: 14.sp, color: Colors.white)
                    : Text('#${u.rank}',
                        style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w800, color: c))),
            SizedBox(height: 8.h),
            // Avatar
            Container(
                width: isChamp ? 52.w : 44.w,
                height: isChamp ? 52.w : 44.w,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFFFFB347)]),
                    borderRadius: BorderRadius.circular(14.r)),
                alignment: Alignment.center,
                child: Text(u.name?.substring(0, 1).toUpperCase() ?? '?',
                    style: GoogleFonts.outfit(fontSize: isChamp ? 18.sp : 14.sp, fontWeight: FontWeight.w800, color: Colors.white))),
            SizedBox(height: 8.h),
            Text(u.name ?? 'Anonymous',
                style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text('Level ${u.level}',
                style: GoogleFonts.inter(fontSize: 9.sp, color: isChamp ? AppTheme.primary : AppTheme.textMuted),
                textAlign: TextAlign.center),
            SizedBox(height: 6.h),
            Text('${u.xp}',
                style: GoogleFonts.outfit(fontSize: isChamp ? 20.sp : 16.sp, fontWeight: FontWeight.w900, color: Colors.white)),
            Text('XP',
                style: GoogleFonts.outfit(fontSize: 7.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1.5)),
            SizedBox(height: 6.h),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.local_fire_department_rounded, size: 12.sp, color: AppTheme.primary),
              SizedBox(width: 2.w),
              Text('${u.level}',
                  style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.white70)),
            ]),
          ])),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _row(LeaderboardUserModel u, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppTheme.surfaceBorder)),
      child: Row(children: [
        SizedBox(
            width: 28.w,
            child: Text('${u.rank}',
                style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white24))),
        Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
            alignment: Alignment.center,
            child: Text(u.name?.substring(0, 1).toUpperCase() ?? '?',
                style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white54))),
        SizedBox(width: 12.w),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(u.name ?? 'Anonymous',
              style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white70),
              overflow: TextOverflow.ellipsis),
          Text('Level ${u.level}', style: GoogleFonts.inter(fontSize: 10.sp, color: AppTheme.textMuted)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${u.xp}', style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w800, color: Colors.white54)),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.stars_rounded, size: 10.sp, color: AppTheme.primary.withValues(alpha: 0.6)),
            Text(' XP', style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.white38)),
          ]),
        ]),
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms);
  }
}
