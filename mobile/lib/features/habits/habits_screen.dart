import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../services/habit_service.dart';
import '../../models/habit_model.dart';
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
            // ─── Header ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PROTOCOLS', style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 2)),
                      SizedBox(height: 4.h),
                      Text('Habit Management', style: GoogleFonts.outfit(fontSize: 24.sp, fontWeight: FontWeight.w800, color: AppTheme.textMain, letterSpacing: -0.5)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showAddHabit(context),
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                      ),
                      child: Icon(Icons.add, color: AppTheme.primary, size: 22.sp),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // ─── Habits List ─────────────────────────────────
            Expanded(
              child: habitsAsync.when(
                data: (habits) {
                  if (habits.isEmpty) return _buildEmptyState(context);
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 120.h),
                    itemCount: habits.length,
                    itemBuilder: (context, index) => _buildHabitItem(context, habits[index], ref, index),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2)),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sync failed', style: GoogleFonts.inter(color: AppTheme.textMain, fontSize: 16.sp)),
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: () => ref.invalidate(habitsProvider),
                        child: Text('RETRY', style: GoogleFonts.outfit(color: AppTheme.primary, fontWeight: FontWeight.w700, letterSpacing: 1)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1), style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, size: 48.sp, color: AppTheme.primary.withValues(alpha: 0.5)),
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
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: AppTheme.glassCard(borderRadius: AppTheme.radiusMd),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(_getIcon(habit.icon), color: AppTheme.primary, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.title, style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppTheme.textMain)),
                SizedBox(height: 2.h),
                Text('${habit.frequency} • ${habit.difficulty}', style: GoogleFonts.inter(fontSize: 11.sp, color: AppTheme.textMuted)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white24, size: 18.sp),
            color: const Color(0xFF0A0A0A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.redAccent))),
            ],
            onSelected: (val) async {
              if (val == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF0A0A0A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
                    title: Text('Delete Protocol?', style: GoogleFonts.outfit(color: AppTheme.textMain, fontWeight: FontWeight.w700)),
                    content: Text('This will permanently remove "${habit.title}".', style: TextStyle(color: AppTheme.textMuted)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(color: AppTheme.textMuted))),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(habitServiceProvider).deleteHabit(habit.id);
                  ref.invalidate(habitsProvider);
                }
              }
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index), duration: 400.ms).slideX(begin: 0.03);
  }

  IconData _getIcon(String name) {
    switch (name.toLowerCase()) {
      case 'zap': return Icons.bolt_rounded;
      case 'book': return Icons.menu_book_rounded;
      case 'gym': return Icons.fitness_center_rounded;
      case 'water': return Icons.water_drop_rounded;
      case 'code': return Icons.code_rounded;
      case 'run': return Icons.directions_run_rounded;
      default: return Icons.star_rounded;
    }
  }
}
