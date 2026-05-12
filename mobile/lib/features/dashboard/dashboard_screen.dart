import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../services/user_service.dart';
import '../../services/habit_service.dart';
import '../../models/user_model.dart';
import '../../models/habit_model.dart';
import '../../services/analytics_service.dart';
import '../notifications/notifications_modal.dart';

/// Dashboard — "Control Center" matching the web's app/app/page.jsx
///
/// Layout mirrors web exactly:
///   1. Badge + "Control Center" heading
///   2. 3-column stat grid (XP, Shields, Productivity)
///   3. Today's Protocols with circular progress
///   4. XP progress card
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final habitsAsync = ref.watch(habitsProvider);
    final productivityAsync = ref.watch(productivityScoreProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          backgroundColor: AppTheme.background,
          onRefresh: () async {
            ref.invalidate(userProfileProvider);
            ref.invalidate(habitsProvider);
            ref.invalidate(productivityScoreProvider);
          },
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h), // bottom padding for floating dock
            children: [
              // ─── Mobile Header (from web layout.jsx mobile header) ──
              _buildMobileHeader(context),
              SizedBox(height: 24.h),

              // ─── Header Badge + Title (from web dashboard) ──────────
              userAsync.when(
                data: (user) => _buildDashboardHeader(user, habitsAsync),
                loading: () => _buildHeaderSkeleton(),
                error: (e, _) => _buildErrorCard('Profile sync failed', ref),
              ),

              SizedBox(height: 24.h),

              // ─── Stat Grid (web: grid grid-cols-1 md:grid-cols-3) ───
              userAsync.when(
                data: (user) => _buildStatGrid(user, productivityAsync),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              SizedBox(height: 24.h),

              // ─── Today's Protocol (web: glass-card p-8 rounded-[2.5rem]) ─
              habitsAsync.when(
                data: (habits) => _buildProtocolsCard(habits, ref),
                loading: () => _buildLoadingCard(),
                error: (e, _) => _buildErrorCard('Habit sync failed', ref),
              ),

              SizedBox(height: 16.h),

              // ─── XP Progress Card (web: right sidebar) ──────────────
              userAsync.when(
                data: (user) => _buildXpProgressCard(user),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mobile header bar matching web: logo + "HabitFlow" + streak badge
  Widget _buildMobileHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Eagle logo placeholder — matches web's eagle-logo-transparent.png
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primary, AppTheme.accent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGlow.withValues(alpha: 0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'HF',
                  style: GoogleFonts.outfit(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'HabitFlow',
              style: GoogleFonts.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMain,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => const NotificationsModal(),
                );
              },
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.notifications_none_rounded, color: Colors.white70, size: 20.sp),
              ),
            ),
            SizedBox(width: 12.w),
            // Streak badge — matches web's streak pill
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department, size: 14.sp, color: AppTheme.primary),
                  SizedBox(width: 4.w),
                  Text(
                    '0 DAY',
                    style: GoogleFonts.outfit(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMain,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  /// Dashboard header: badge + "Control Center" + progress text
  Widget _buildDashboardHeader(UserModel user, AsyncValue<List<HabitModel>> habitsAsync) {
    final habitCount = habitsAsync.valueOrNull?.length ?? 0;
    final completedToday = habitsAsync.valueOrNull?.where((h) {
      final today = DateTime.now().toIso8601String().split('T')[0];
      return h.completions.any((c) => c.date == today && c.completed);
    }).length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Web: badge "System Synchronized"
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 12.sp, color: AppTheme.accent),
              SizedBox(width: 6.w),
              Text(
                'SYSTEM SYNCHRONIZED',
                style: GoogleFonts.outfit(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accent,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),

        SizedBox(height: 16.h),

        // Web: h1 "Control Center" with logo
        Text(
          'Control Center',
          style: GoogleFonts.outfit(
            fontSize: 32.sp,
            fontWeight: FontWeight.w800,
            color: AppTheme.textMain,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 600.ms),

        SizedBox(height: 6.h),

        // Web: "Sequence active. X of Y objectives synchronized."
        Text.rich(
          TextSpan(
            text: 'Sequence active. ',
            style: GoogleFonts.inter(fontSize: 15.sp, color: AppTheme.textMuted, fontWeight: FontWeight.w300),
            children: [
              TextSpan(
                text: '$completedToday of $habitCount',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.textMain),
              ),
              const TextSpan(text: ' objectives synchronized.'),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
      ],
    );
  }

  /// 3-column stat grid matching web:
  /// Total XP | Streak Shields | Productivity
  Widget _buildStatGrid(UserModel user, AsyncValue<int> productivityAsync) {
    final prodScore = productivityAsync.valueOrNull?.toString() ?? '...';
    final stats = [
      _StatData('Total XP', '${user.xp}', Icons.bolt, AppTheme.primary),
      _StatData('Streak Shields', '${user.streakShields}', Icons.shield, const Color(0xFF60A5FA)),
      _StatData('Productivity', '$prodScore%', Icons.trending_up, AppTheme.success),
    ];

    return Row(
      children: stats.asMap().entries.map((entry) {
        final i = entry.key;
        final stat = entry.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 8.w : 0, left: i > 0 ? 4.w : 0),
            padding: EdgeInsets.all(16.w),
            decoration: AppTheme.glowCard(
              glowColor: stat.color,
              glowIntensity: 0.15,
              borderRadius: AppTheme.radiusMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon box — web: w-12 h-12 rounded-xl bg-white/5 border border-white/10
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Icon(stat.icon, size: 18.sp, color: stat.color),
                ),
                SizedBox(height: 12.h),
                // Label — web: text-xs text-textMuted uppercase tracking
                Text(
                  stat.label.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4.h),
                // Value — web: text-3xl font-display font-bold
                Text(
                  stat.value,
                  style: GoogleFonts.outfit(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textMain,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 100 * i), duration: 500.ms)
              .slideY(begin: 0.1),
        );
      }).toList(),
    );
  }

  /// "Today's Protocol" card matching web's glass-card habit list
  Widget _buildProtocolsCard(List<HabitModel> habits, WidgetRef ref) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final completedToday = habits.where((h) => h.completions.any((c) => c.date == today && c.completed)).length;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: AppTheme.glassCard(borderRadius: AppTheme.radiusXxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with title + progress circle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Protocol",
                    style: GoogleFonts.outfit(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textMain,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Daily directives for current operation',
                    style: GoogleFonts.inter(fontSize: 12.sp, color: AppTheme.textMuted),
                  ),
                ],
              ),
              // Circular progress (matches web SVG circle)
              _buildCircularProgress(completedToday, habits.length),
            ],
          ),

          SizedBox(height: 24.h),

          // Habit list
          if (habits.isEmpty)
            _buildEmptyProtocols()
          else
            ...habits.asMap().entries.map((entry) {
              final i = entry.key;
              final habit = entry.value;
              return _buildHabitRow(habit, today, ref, i);
            }),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideY(begin: 0.05);
  }

  /// Circular progress indicator matching web's SVG ring
  Widget _buildCircularProgress(int completed, int total) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: SizedBox(
        width: 52.w,
        height: 52.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 52.w,
              height: 52.w,
              child: CircularProgressIndicator(
                value: total > 0 ? completed / total : 0,
                strokeWidth: 4,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              '$completed/$total',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Single habit row matching web's habit item design
  Widget _buildHabitRow(HabitModel habit, String today, WidgetRef ref, int index) {
    final isCompleted = habit.completions.any((c) => c.date == today && c.completed);
    final categoryColor = AppTheme.categoryColors[habit.difficulty] ?? AppTheme.primary;

    return GestureDetector(
      onTap: () async {
        await ref.read(habitServiceProvider).toggleHabit(habit.id, today);
        ref.invalidate(habitsProvider);
        ref.invalidate(userProfileProvider);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          // Web: isCompleted ? bg-[#FF6B2C]/5 border-[#FF6B2C]/40 : bg-white/[0.01] border-white/5
          color: isCompleted
              ? AppTheme.primary.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.01),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isCompleted
                ? AppTheme.primary.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.05),
          ),
          boxShadow: isCompleted
              ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, 0))]
              : null,
        ),
        child: Row(
          children: [
            // Checkbox — web: w-8 h-8 rounded-xl
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: isCompleted ? AppTheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(
                  color: isCompleted ? AppTheme.primary : Colors.white.withValues(alpha: 0.1),
                  width: isCompleted ? 0 : 2,
                ),
                boxShadow: isCompleted
                    ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.6), blurRadius: 20)]
                    : null,
              ),
              child: isCompleted
                  ? Icon(Icons.check_rounded, size: 16.sp, color: Colors.white)
                  : null,
            ),

            SizedBox(width: 16.w),

            // Title + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          habit.title,
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: isCompleted ? AppTheme.textMain.withValues(alpha: 0.4) : AppTheme.textMain,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Category badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          habit.frequency.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 7.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${habit.difficulty} • ${_getDifficultyXp(habit.difficulty)} XP',
                    style: GoogleFonts.inter(fontSize: 10.sp, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            // Status dot — web: w-4 h-4 rounded-full
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: categoryColor.withValues(alpha: isCompleted ? 1.0 : 0.3),
                boxShadow: isCompleted
                    ? [BoxShadow(color: categoryColor, blurRadius: 12)]
                    : null,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 500 + index * 80), duration: 400.ms)
        .slideX(begin: -0.05);
  }

  /// XP Progress card matching web's right-sidebar XP widget
  Widget _buildXpProgressCard(UserModel user) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: AppTheme.glassCard(borderRadius: AppTheme.radiusXxl).copyWith(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withValues(alpha: 0.08),
            Colors.transparent,
            AppTheme.secondary.withValues(alpha: 0.06),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // XP icon box
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 20),
                  ],
                ),
                child: Icon(Icons.bolt, size: 22.sp, color: AppTheme.accent),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'WEEKLY YIELD',
                    style: AppTheme.labelStyle(),
                  ),
                  Text(
                    '${user.xp} XP',
                    style: GoogleFonts.outfit(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textMain,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Level progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${user.level}',
                style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppTheme.textMain),
              ),
              Text(
                '${500 - (user.xp % 500)} XP to Rank Up',
                style: GoogleFonts.inter(fontSize: 12.sp, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Progress bar — web: h-4 bg-black/50 rounded-full p-1
          Container(
            height: 14.h,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            padding: EdgeInsets.all(3.w),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * ((user.xp % 500) / 500),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, Color(0xFFFFB347)],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 500.ms, duration: 600.ms)
        .slideX(begin: 0.05);
  }

  Widget _buildEmptyProtocols() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Text(
            'NO HABITS FOUND',
            style: GoogleFonts.outfit(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create your first habit',
            style: GoogleFonts.inter(fontSize: 13.sp, color: AppTheme.primary, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 140.w, height: 28.h, decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20.r))),
        SizedBox(height: 16.h),
        Container(width: 200.w, height: 32.h, decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(8.r))),
        SizedBox(height: 8.h),
        Container(width: 250.w, height: 16.h, decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(8.r))),
      ],
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.03));
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 200.h,
      decoration: AppTheme.glassCard(borderRadius: AppTheme.radiusXxl),
      child: const Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2)),
    );
  }

  Widget _buildErrorCard(String message, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: AppTheme.glowCard(glowColor: AppTheme.danger, glowIntensity: 0.15, borderRadius: AppTheme.radiusMd),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.danger, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(child: Text(message, style: TextStyle(color: AppTheme.danger, fontSize: 12.sp))),
          IconButton(
            icon: Icon(Icons.refresh, color: AppTheme.danger, size: 18.sp),
            onPressed: () {
              ref.invalidate(userProfileProvider);
              ref.invalidate(habitsProvider);
            },
          ),
        ],
      ),
    );
  }

  int _getDifficultyXp(String difficulty) {
    switch (difficulty) {
      case 'Easy': return 10;
      case 'Medium': return 25;
      case 'Hard': return 50;
      case 'Elite': return 100;
      default: return 25;
    }
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatData(this.label, this.value, this.icon, this.color);
}
