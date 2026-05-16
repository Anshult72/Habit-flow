import 'package:flutter/material.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

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
        child: Column(
          children: [
            // ─── Header: Protocol Config ─────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
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
                  SizedBox(height: 8.h),
                  Text(
                    'Define and calibrate your daily\noperational habits.',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppTheme.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

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
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildActionButton(
                      label: 'New\nProtocol',
                      icon: Icons.add,
                      color: Colors.white,
                      isPill: true,
                      onTap: () => _showAddHabit(context),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // ─── Habits Scrollable Content ───────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(habitsProvider),
                color: AppTheme.primary,
                backgroundColor: AppTheme.background,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 120.h),
                  children: [
                    // ─── Bundles Section ───────────────────────
                    _buildBundleCard('Morning Routine', 'ACTIVATE BUNDLE', const Color(0xFFF97316)),
                    SizedBox(height: 12.h),
                    _buildBundleCard('Deep Work', 'ACTIVATE BUNDLE', const Color(0xFFF97316)),
                    
                    SizedBox(height: 24.h),

                    // ─── Filters Section ───────────────────────
                    _buildSearchBar(),
                    SizedBox(height: 12.h),
                    _buildFilterBar(),

                    SizedBox(height: 24.h),

                    // ─── Habits List ──────────────────────────
                    habitsAsync.when(
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
                      loading: () => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: const HFShimmerList(height: 80, count: 5),
                      ),
                      error: (e, _) => _buildErrorState(ref),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isPill = false,
  }) {
    return HFScalableButton(
      onTap: onTap,
      child: Container(
        height: 72.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isPill ? Colors.white : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(isPill ? 36.r : 20.r),
          border: isPill ? null : Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPill ? Colors.black : color, size: 20.sp),
            SizedBox(width: 10.w),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: isPill ? Colors.black : Colors.white,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBundleCard(String title, String action, Color iconColor) {
    return Container(
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
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white38, size: 20.sp),
          SizedBox(width: 12.w),
          Text('Search protocols...', style: GoogleFonts.inter(color: Colors.white24, fontSize: 14.sp)),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, color: Colors.white38, size: 20.sp),
          SizedBox(width: 12.w),
          Text('All Classifications', style: GoogleFonts.inter(color: Colors.white24, fontSize: 14.sp)),
        ],
      ),
    );
  }

  void _showAddHabit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
      padding: EdgeInsets.all(24.w),
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
          SizedBox(height: 12.h),
          Row(
            children: [
              if (habit.category != null && habit.category!.isNotEmpty) ...[
                _buildBadge(habit.category!.toUpperCase(), categoryColor),
                SizedBox(width: 8.w),
              ],
              _buildBadge(habit.difficulty.toUpperCase(), Colors.white10, textColor: Colors.white70),
            ],
          ),
          SizedBox(height: 20.h),
          const Divider(color: Colors.white10),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TARGET', style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1)),
                  SizedBox(height: 4.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('30', style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
                      SizedBox(width: 4.w),
                      Text('Days/Mo', style: GoogleFonts.inter(fontSize: 12.sp, color: AppTheme.textMuted)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('XP VALUE', style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1)),
                  SizedBox(height: 4.h),
                  Text('25 XP', style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFFF97316))),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index), duration: 400.ms).slideY(begin: 0.05);
  }

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
