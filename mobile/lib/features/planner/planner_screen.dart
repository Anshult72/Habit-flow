import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import '../../models/planner_model.dart';
import '../../services/planner_service.dart';

// ─── Planner Screen ────────────────────────────────────────────────────────
class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  DateTime _currentDate = DateTime.now();

  String get _dateKey {
    return '${_currentDate.year}-${_currentDate.month.toString().padLeft(2, '0')}-${_currentDate.day.toString().padLeft(2, '0')}';
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}${_getDaySuffix(d.day)}, ${d.year}';
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'TH';
    switch (day % 10) {
      case 1: return 'ST';
      case 2: return 'ND';
      case 3: return 'RD';
      default: return 'TH';
    }
  }

  String _dayName(DateTime d) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return _isToday(d) ? 'Today' : days[d.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final plannerAsync = ref.watch(plannerProvider(_dateKey));

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // AppTheme.background usually
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 12.h, bottom: 8.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Column(
                  children: [
                    _buildHeaderCard(),
                    SizedBox(height: 24.h),
                    plannerAsync.when(
                      data: (day) => Column(
                        children: [
                          ...day.slots.asMap().entries.map((e) {
                            // First slot is active for visual parity with screenshot 1, unless specified. 
                            // We can use index 0 as active for now just to match the visual.
                            final isActive = e.key == 0;
                            return _buildSlotCard(e.value, isActive).animate().fadeIn(delay: Duration(milliseconds: 50 * e.key), duration: 300.ms);
                          }),
                          SizedBox(height: 12.h),
                          _buildAnalyticsCard(day).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                          SizedBox(height: 120.h),
                        ],
                      ),
                      loading: () => _buildPlannerSkeleton(),
                      error: (e, _) => HFErrorState(
                        onRetry: () => ref.refresh(plannerProvider(_dateKey)),
                      ),
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

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                ),
                child: Icon(Icons.calendar_today_outlined, color: AppTheme.primary, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Text('STRATEGIC PLANNING', style: GoogleFonts.outfit(color: AppTheme.primary, fontSize: 11.sp, fontWeight: FontWeight.w800, letterSpacing: 2.5)),
            ],
          ),
          SizedBox(height: 20.h),
          Text('Daily Protocol', style: GoogleFonts.outfit(color: Colors.white, fontSize: 36.sp, fontWeight: FontWeight.w900, letterSpacing: -1)),
          SizedBox(height: 12.h),
          Text('Orchestrate your day with high-precision time blocks and mission objectives.', style: GoogleFonts.inter(color: Colors.white54, fontSize: 13.sp, height: 1.5)),
          SizedBox(height: 32.h),
          // Date Selector
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(onTap: () => setState(() => _currentDate = _currentDate.subtract(const Duration(days: 1))), child: Icon(Icons.chevron_left_rounded, color: Colors.white38, size: 24.sp)),
                Column(
                  children: [
                    Text(_dayName(_currentDate).toUpperCase(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w800, letterSpacing: 2)),
                    SizedBox(height: 4.h),
                    Text(_formatDate(_currentDate).toUpperCase(), style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.w700, letterSpacing: 2)),
                  ],
                ),
                GestureDetector(onTap: () => setState(() => _currentDate = _currentDate.add(const Duration(days: 1))), child: Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 24.sp)),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _currentDate = DateTime.now()),
              child: Text('RESET TO TODAY', style: GoogleFonts.outfit(color: AppTheme.primary, fontSize: 11.sp, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(PlannerSlotModel slot, bool isActive) {
    final slotCompleted = slot.tasks.where((t) => t.completed).length;

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primary : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.access_time_rounded, color: isActive ? Colors.white : Colors.white54, size: 18.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(slot.timeRange, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ),
              Text('$slotCompleted/${slot.tasks.length}', style: GoogleFonts.outfit(color: AppTheme.primary, fontSize: 13.sp, fontWeight: FontWeight.w800, letterSpacing: 1)),
            ],
          ),
          SizedBox(height: 32.h),
          
          if (slot.tasks.isEmpty) ...[
            Center(
              child: Column(
                children: [
                  Icon(Icons.checklist_rtl_rounded, size: 36.sp, color: Colors.white.withValues(alpha: 0.1)),
                  SizedBox(height: 12.h),
                  Text('ZONE UNALLOCATED', style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.2), fontSize: 11.sp, fontWeight: FontWeight.w800, letterSpacing: 2)),
                ],
              ),
            ),
            SizedBox(height: 32.h),
          ] else ...[
            ...slot.tasks.map((task) => _buildTaskItem(task, slot.id)),
            SizedBox(height: 24.h),
          ],
          
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.05),
            margin: EdgeInsets.only(bottom: 24.h),
          ),
          
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: TextField(
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp),
                    decoration: InputDecoration(
                      hintText: 'Allocate task...',
                      hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 13.sp),
                      border: InputBorder.none,
                    ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          HapticFeedback.mediumImpact();
                          ref.read(plannerProvider(_dateKey).notifier).addTask(slot.id, val.trim());
                        }
                      },
                    ),
                  ),
                ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Icon(Icons.add_rounded, color: Colors.white54, size: 20.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(PlannerTaskModel task, String slotId) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(plannerProvider(_dateKey).notifier).toggleTask(task.id, !task.completed);
            },
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: task.completed ? AppTheme.primary.withValues(alpha: 0.2) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: task.completed ? AppTheme.primary : Colors.white24),
              ),
              child: Icon(Icons.check_rounded, size: 14.sp, color: task.completed ? AppTheme.primary : Colors.transparent),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(task.title, style: GoogleFonts.inter(color: task.completed ? Colors.white38 : Colors.white, fontSize: 14.sp, decoration: task.completed ? TextDecoration.lineThrough : null)),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(plannerProvider(_dateKey).notifier).removeTask(task.id);
            },
            child: Icon(Icons.close_rounded, size: 18.sp, color: Colors.white24),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(PlannerDayModel day) {
    final total = day.slots.fold(0, (sum, s) => sum + s.tasks.length);
    final completed = day.slots.fold(0, (sum, s) => sum + s.tasks.where((t) => t.completed).length);
    final progress = total > 0 ? ((completed / total) * 100).round() : 0;

    return Container(
      padding: EdgeInsets.all(36.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 140.w,
            height: 140.w,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: total > 0 ? completed / total : 0,
                  strokeWidth: 8.w,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                ),
                Center(
                  child: Text('$progress%', style: GoogleFonts.outfit(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
          SizedBox(height: 36.h),
          Text('Mission Continuity Analysis', textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          SizedBox(height: 12.h),
          Text('Strategic initiative required. Align your focus with high-impact objectives to regain system equilibrium.', textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white54, fontSize: 13.sp, height: 1.5)),
          SizedBox(height: 32.h),
          _actionBtn(Icons.bolt_rounded, 'PEAK PERFORMANCE', AppTheme.primary),
          SizedBox(height: 16.h),
          _actionBtn(Icons.trending_up_rounded, 'GROWTH SIGNAL', Colors.white54),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(width: 10.w),
          Text(label, style: GoogleFonts.outfit(color: color, fontSize: 11.sp, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildPlannerSkeleton() {
    return Column(
      children: List.generate(3, (index) => Container(
        margin: EdgeInsets.only(bottom: 20.h),
        padding: EdgeInsets.all(28.w),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(32.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 150.w, height: 24.h, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8.r))),
            SizedBox(height: 32.h),
            Container(width: double.infinity, height: 20.h, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(4.r))),
            SizedBox(height: 12.h),
            Container(width: 200.w, height: 20.h, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(4.r))),
          ],
        ),
      )).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.03)),
    );
  }
}

