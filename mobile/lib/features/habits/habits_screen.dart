import 'package:flutter/material.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/xp_level_engine.dart';

// Removed unused import
import '../../models/habit_model.dart';
import '../../core/state/habits_provider.dart';
// Removed unused import
import 'add_habit_dialog.dart';

/// Habits management screen using web's glass-card design language.
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(habitsProvider),
          color: AppTheme.primary,
          backgroundColor: AppTheme.background,
          child: ListView(
            padding: EdgeInsets.only(bottom: 140.h),
            children: [
              // ─── Header: Protocol Config ─────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Protocol Config',
                          style: GoogleFonts.outfit(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textMain,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.auto_awesome, color: AppTheme.primary, size: 24.sp),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Define and calibrate your daily operational habits.',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppTheme.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // ─── Action Buttons: Templates & New Protocol ────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        label: 'Templates',
                        icon: Icons.layers_outlined,
                        color: AppTheme.primary,
                        onTap: () => _showTemplates(context, ref),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildActionButton(
                        label: 'New Protocol',
                        icon: Icons.add,
                        color: AppTheme.primary,
                        isPrimary: true,
                        onTap: () => _showAddHabit(context),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // ─── Filters Section ───────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildSearchBar(),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 5,
                      child: _buildFilterBar(),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // ─── Habits List ──────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: habitsAsync.when(
                  data: (habits) {
                    if (habits.isEmpty) return _buildEmptyState(context);
                    return Column(
                      children: habits.asMap().entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _buildHabitItem(context, entry.value, ref, entry.key),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const HFShimmerList(height: 80, count: 5),
                  error: (e, _) => _buildErrorState(ref),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTemplates(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Protocol Templates',
                      style: GoogleFonts.outfit(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'SELECT A PRE-CONFIGURED STACK',
                      style: GoogleFonts.outfit(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: Colors.white38, size: 24.sp),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            _buildBundleCard(
              'Core Life Habit',
              'INITIALIZE 5 CORE PROTOCOLS',
              AppTheme.primary,
              onTap: () {
                Navigator.pop(context);
                _initializeCoreHabits(context, ref);
              },
            ),
            SizedBox(height: 12.h),
            // Future templates can be added here
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.03), style: BorderStyle.solid),
              ),
              child: Center(
                child: Text(
                  'MORE TEMPLATES COMING SOON',
                  style: GoogleFonts.outfit(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white12,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeCoreHabits(BuildContext context, WidgetRef ref) async {
    final habits = [
      'Drink enough water daily',
      'Exercise or walk for at least 30 minutes',
      'Sleep on time and wake up early',
      'Avoid excessive social media scrolling',
      'Learn or read something new every day',
    ];

    try {
      // Show loading overlay or toast
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Initializing Core Protocols...'), duration: Duration(seconds: 1)),
      );

      for (final title in habits) {
        await ref.read(habitServiceProvider).createHabit({
          'title': title,
          'frequency': 'Daily',
          'difficulty': 'Standard',
          'category': 'Health',
          'icon': 'Zap',
          'color': '#FF6B2C',
          'targetDays': 30, // Initialized for 30 days
        });
      }

      ref.invalidate(habitsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Core Life Habits Initialized ⚡'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize: $e'), backgroundColor: AppTheme.danger),
        );
      }
    }
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return HFScalableButton(
      onTap: onTap,
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primary : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isPrimary
                ? AppTheme.primaryGlow.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppTheme.primaryGlow.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBundleCard(String title, String action, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.bolt_rounded, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppTheme.textMain)),
                  Text(action, style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 42.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white38, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Search...',
              style: GoogleFonts.inter(color: Colors.white30, fontSize: 13.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 42.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, color: Colors.white.withValues(alpha: 0.7), size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Classifications',
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white38, size: 16.sp),
        ],
      ),
    );
  }

  void _showAddHabit(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => const AddHabitDialog(),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: HFErrorState(
        onRetry: () => ref.invalidate(habitsProvider),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 40.h),
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1), style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, size: 48.sp, color: AppTheme.primary.withValues(alpha: 0.4)),
            SizedBox(height: 16.h),
            Text('NO PROTOCOLS DEPLOYED', style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1.5)),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () => _showAddHabit(context),
              child: Text('Deploy your first habit', style: GoogleFonts.inter(fontSize: 14.sp, color: AppTheme.primary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitItem(BuildContext context, HabitModel habit, WidgetRef ref, int index) {
    final categoryColor = AppTheme.categoryColors[habit.category] ?? AppTheme.primary;

    return HFGlassCard(
      borderRadius: AppTheme.radiusXl,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Category Dot
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: categoryColor,
                  boxShadow: [
                    BoxShadow(color: categoryColor.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  habit.title,
                  style: GoogleFonts.outfit(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textMain,
                  ),
                ),
              ),
              _buildItemMenu(context, habit, ref),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              if (habit.category != null && habit.category!.isNotEmpty) ...[
                _buildBadge(habit.category!.toUpperCase(), categoryColor),
                SizedBox(width: 8.w),
              ],
              _buildBadge(XpLevelEngine.normalizeDifficulty(habit.difficulty).toUpperCase(), Colors.white10, textColor: Colors.white70),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(color: Colors.white10),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TARGET', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1)),
                  SizedBox(height: 4.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('30', style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
                      SizedBox(width: 4.w),
                      Text('days/mo', style: GoogleFonts.inter(fontSize: 11.sp, color: AppTheme.textMuted)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('XP REWARD', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1)),
                  SizedBox(height: 4.h),
                  // Show dynamic XP or TRACKING ONLY badge.
                  // Use == true (not direct bool access) to safely handle any
                  // runtime null on this field (hot reload, stale cache, etc.)
                  if (habit.isXpEligible == true)
                    Text(
                      '+${(_xpForHabit(habit)) } XP',
                      style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFFF97316)),
                    )
                  else if (habit.isXpEligible == false)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Text(
                        'TRACKING ONLY',
                        style: GoogleFonts.outfit(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white38,
                          letterSpacing: 0.8,
                        ),
                      ),
                    )
                  else
                    // Null fallback (should never show in production) — default to XP display
                    Text(
                      '+${_getComplexityXp(habit.difficulty)} XP',
                      style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFFF97316)),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index), duration: 400.ms).slideY(begin: 0.05);
  }

  /// Safely returns XP to display for a habit.
  /// isXpEligible and xpValue are both nullable (see HabitModel) to handle
  /// hot-reload stale instances or absent JSON keys gracefully.
  int _xpForHabit(HabitModel habit) {
    final stored = habit.xpValue; // int?
    if (stored != null && stored > 0) return stored;
    return XpLevelEngine.getXpForDifficulty(habit.difficulty);
  }

  /// Returns XP per completion based on complexity label.
  /// Delegates to XpLevelEngine — single source of truth, mirrors backend.
  int _getComplexityXp(String difficulty) =>
      XpLevelEngine.getXpForDifficulty(difficulty);

  Widget _buildBadge(String text, Color color, {Color? textColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 9.sp,
          fontWeight: FontWeight.w800,
          color: textColor ?? color,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildItemMenu(BuildContext context, HabitModel habit, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, color: Colors.white24, size: 20.sp),
      color: const Color(0xFF111111),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'delete', child: Text('Delete Protocol', style: TextStyle(color: Colors.redAccent))),
      ],
      onSelected: (val) async {
        if (val == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF0A0A0A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
              title: Text('Delete Protocol?', style: GoogleFonts.outfit(color: AppTheme.textMain, fontWeight: FontWeight.w700)),
              content: Text('This will permanently remove "${habit.title}".', style: const TextStyle(color: AppTheme.textMuted)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted))),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
              ],
            ),
          );
          if (confirm == true) {
            await ref.read(habitsProvider.notifier).deleteHabit(habit.id);
          }
        }
      },
    );
  }
}
