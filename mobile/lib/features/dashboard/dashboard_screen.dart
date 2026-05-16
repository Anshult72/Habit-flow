import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import '../../services/user_service.dart';
// Removed unused import
import '../../core/state/habits_provider.dart';
import '../../models/user_model.dart';
import '../../models/habit_model.dart';
import '../../services/analytics_service.dart';
import '../notifications/notifications_modal.dart';
import '../main_layout.dart'; // To access bottomNavIndexProvider
import '../../services/missions_service.dart';
import '../../services/learning_service.dart';
import '../../models/mission_model.dart';
import '../../models/learning_model.dart';
import '../../services/matrix_service.dart';
import '../matrix/matrix_screen.dart';
import '../memo/memo_screen.dart';
import '../missions/missions_screen.dart';
import '../learning/learning_screen.dart';

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
    final missionsAsync = ref.watch(missionsProvider);
    final subjectsAsync = ref.watch(subjectsProvider);
    final matrixAsync = ref.watch(matrixProvider);

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
            ref.invalidate(missionsProvider);
            ref.invalidate(subjectsProvider);
            ref.invalidate(focusStatsProvider);
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
                loading: () => Container(
                  height: 100.h,
                  width: double.infinity,
                  decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.02)),
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
                loading: () => _buildLoadingCard(height: 150),
                error: (_, __) => const SizedBox.shrink(),
              ),

              SizedBox(height: 24.h),

              // ─── Quick Actions Grid ──────────────────────────
              _buildQuickActions(context, ref),

              SizedBox(height: 24.h),

              // ─── Matrix Strategy ─────────────────────────────
              matrixAsync.when(
                data: (tasks) => _buildMatrixCard(context, tasks),
                loading: () => _buildLoadingCard(height: 160),
                error: (_, __) => const SizedBox.shrink(),
              ),

              SizedBox(height: 24.h),

              // ─── Cognitive Sync ──────────────────────────────
              _buildModuleCard(
                title: 'COGNITIVE SYNC',
                icon: Icons.description_outlined,
                actionText: 'LAUNCH BRAIN',
                onAction: () {
                  HapticFeedback.selectionClick();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoScreen()));
                },
                content: _buildModuleEmptyState('Tap LAUNCH BRAIN to view your cognitive cache.'),
              ),

              SizedBox(height: 24.h),

              // ─── Active Missions ─────────────────────────────
              missionsAsync.when(
                data: (missions) => _buildModuleCard(
                  title: 'ACTIVE MISSIONS',
                  icon: Icons.rocket_launch_outlined,
                  actionText: 'ALL MISSIONS',
                  onAction: () {
                    HapticFeedback.selectionClick();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MissionsScreen()));
                  },
                  content: missions.isEmpty 
                    ? _buildModuleEmptyState('No active missions initialized.', isSmall: true)
                    : _buildDashboardMissionItem(missions.first),
                ),
                loading: () => _buildLoadingCard(height: 140),
                error: (_, __) => const SizedBox.shrink(),
              ),

              SizedBox(height: 24.h),

              // ─── Learning Hub ────────────────────────────────
              subjectsAsync.when(
                data: (subjects) => _buildModuleCard(
                  title: 'LEARNING HUB',
                  icon: Icons.menu_book_outlined,
                  actionText: 'MODULES',
                  onAction: () {
                    HapticFeedback.selectionClick();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningScreen()));
                  },
                  content: subjects.isEmpty
                    ? _buildModuleEmptyState('NO ACTIVE MODULES')
                    : _buildDashboardSubjectItem(subjects.first),
                ),
                loading: () => _buildLoadingCard(height: 140),
                error: (_, __) => const SizedBox.shrink(),
              ),
              
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  // ─── New Section Builders ──────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      childAspectRatio: 1.6,
      children: [
        _buildQuickActionItem(
          label: 'Deep Focus',
          icon: Icons.play_arrow_outlined,
          color: const Color(0xFF3B82F6),
          onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 2, // Focus
        ),
        _buildQuickActionItem(
          label: 'New Memo',
          icon: Icons.add,
          color: const Color(0xFFF97316),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoScreen()));
          },
        ),
        _buildQuickActionItem(
          label: 'Study Session',
          icon: Icons.menu_book_outlined,
          color: const Color(0xFFA855F7),
          onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 4, // More
        ),
        _buildQuickActionItem(
          label: 'Matrix View',
          icon: Icons.track_changes_outlined,
          color: const Color(0xFF22C55E),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MatrixScreen()));
          },
        ),
      ],
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildQuickActionItem({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return HFScalableButton(
      onTap: onTap,
      child: HFGlassCard(
        borderRadius: AppTheme.radiusMd,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: color,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrixCard(BuildContext context, List<dynamic> tasks) {
    int q1 = tasks.where((t) => t.quadrant == 1 && !t.completed).length;
    int q2 = tasks.where((t) => t.quadrant == 2 && !t.completed).length;
    int q3 = tasks.where((t) => t.quadrant == 3 && !t.completed).length;
    int q4 = tasks.where((t) => t.quadrant == 4 && !t.completed).length;

    return HFGlassCard(
      borderRadius: AppTheme.radiusXxl,
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.track_changes_outlined, color: AppTheme.primary, size: 20.sp),
                  SizedBox(width: 12.w),
                  Text(
                    'MATRIX STRATEGY',
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textMain,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MatrixScreen()));
                },
                child: Text(
                  'FULL VIEW',
                  style: GoogleFonts.outfit(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1.4,
            children: [
              _buildMatrixQuadrant('Q1: DO', '$q1', Colors.redAccent),
              _buildMatrixQuadrant('Q2: PLAN', '$q2', Colors.yellowAccent),
              _buildMatrixQuadrant('Q3: DELEGATE', '$q3', Colors.blueAccent),
              _buildMatrixQuadrant('Q4: REMOVE', '$q4', Colors.greenAccent),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1);
  }

  Widget _buildMatrixQuadrant(String label, String count, Color dotColor) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            count,
            style: GoogleFonts.outfit(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required String title,
    required IconData icon,
    required String actionText,
    required VoidCallback onAction,
    required Widget content,
  }) {
    return HFGlassCard(
      borderRadius: AppTheme.radiusXxl,
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppTheme.primary, size: 20.sp),
                  SizedBox(width: 12.w),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textMain,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onAction,
                child: Text(
                  actionText,
                  style: GoogleFonts.outfit(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          content,
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1);
  }

  Widget _buildModuleEmptyState(String text, {bool isSmall = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), style: BorderStyle.solid),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: isSmall 
            ? GoogleFonts.inter(fontSize: 13.sp, color: Colors.white24, fontStyle: FontStyle.italic)
            : GoogleFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                letterSpacing: 1.5,
              ),
        ),
      ),
    );
  }

  Widget _buildDashboardMissionItem(MissionModel mission) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(mission.title, style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
          SizedBox(height: 4.h),
          Text(mission.category ?? 'General', style: GoogleFonts.inter(fontSize: 10.sp, color: AppTheme.primary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildDashboardSubjectItem(SubjectModel subject) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject.title, style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('${subject.progress}%', style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w800, color: AppTheme.primary)),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: subject.progress / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
              minHeight: 4.h,
            ),
          ),
        ],
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
            // Eagle logo asset — matches web's eagle-logo-transparent.png
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGlow.withValues(alpha: 0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/eagle-logo-transparent.png',
                fit: BoxFit.contain,
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
          child: HFGlowContainer(
            glowColor: stat.color,
            glowIntensity: 0.15,
            borderRadius: AppTheme.radiusMd,
            child: Container(
              margin: EdgeInsets.only(right: i < 2 ? 8.w : 0, left: i > 0 ? 4.w : 0),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.surfaceBorder),
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
          ),
          ).animate().fadeIn(delay: Duration(milliseconds: 100 * i), duration: 500.ms).slideY(begin: 0.1),
        );
      }).toList(),
    );
  }

  /// "Today's Protocol" card matching web's glass-card habit list
  Widget _buildProtocolsCard(List<HabitModel> habits, WidgetRef ref) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final completedToday = habits.where((h) => h.completions.any((c) => c.date == today && c.completed)).length;

    return HFGlassCard(
      borderRadius: AppTheme.radiusXxl,
      padding: EdgeInsets.all(24.w),
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

    return HFScalableButton(
      onTap: () async {
        HapticFeedback.mediumImpact();
        await ref.read(habitsProvider.notifier).toggleHabit(habit.id, today);
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
    return HFGlassCard(
      borderRadius: AppTheme.radiusXxl,
      padding: EdgeInsets.all(24.w),
      child: Container(
        decoration: BoxDecoration(
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
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideX(begin: 0.05);
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
          Icon(Icons.checklist_rtl_rounded, size: 32.sp, color: Colors.white12),
          SizedBox(height: 16.h),
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
            'Create your first habit to begin tracking.',
            style: GoogleFonts.inter(fontSize: 13.sp, color: AppTheme.primary, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
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

  Widget _buildLoadingCard({double height = 200}) {
    return Container(
      height: height.h,
      decoration: AppTheme.glassCard(borderRadius: AppTheme.radiusXxl),
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 150.w, height: 24.h, decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(8.r))),
              Container(width: 40.w, height: 40.w, decoration: const BoxDecoration(color: AppTheme.surface, shape: BoxShape.circle)),
            ],
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.02));
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
              HapticFeedback.lightImpact();
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
