import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import '../../models/planner_model.dart';
import '../../services/planner_service.dart';
import '../../services/user_service.dart';

// ─── Planner Screen ────────────────────────────────────────────────────────
class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  DateTime _currentDate = DateTime.now();
  int _selectedSlotIndex = 0; // First block expanded by default
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

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

  TextEditingController _getController(String slotId) {
    return _controllers.putIfAbsent(slotId, () => TextEditingController());
  }

  FocusNode _getFocusNode(String slotId) {
    return _focusNodes.putIfAbsent(slotId, () => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final f in _focusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plannerAsync = ref.watch(plannerProvider(_dateKey));

    return Scaffold(
      backgroundColor: const Color(0xFF08080A), // Deepest luxury charcoal-black console
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Area (Cohesive back button layout)
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 8.h, bottom: 4.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.015),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded, 
                        color: Colors.white, 
                        size: 12.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Text(
                    'TACTICAL CONSOLE',
                    style: GoogleFonts.outfit(
                      fontSize: 10.2.sp, 
                      fontWeight: FontWeight.w900, 
                      color: const Color(0xFFE25B20).withValues(alpha: 0.8), 
                      letterSpacing: 2.2,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            Expanded(
              child: plannerAsyncWhenBody(plannerAsync),
            ),
          ],
        ),
      ),
    );
  }

  Widget plannerAsyncWhenBody(AsyncValue<PlannerDayModel> plannerAsync) {
    return plannerAsync.when(
      data: (day) {
        final total = day.slots.fold(0, (sum, s) => sum + s.tasks.length);
        final completed = day.slots.fold(0, (sum, s) => sum + s.tasks.where((t) => t.completed).length);

        return RefreshIndicator(
          color: const Color(0xFFE25B20),
          backgroundColor: const Color(0xFF111113),
          onRefresh: () async {
            ref.invalidate(plannerProvider(_dateKey));
            ref.invalidate(userProfileProvider);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            children: [
              _buildHeaderCard(),
              SizedBox(height: 14.h),
              
              // Layout time blocks (Selected-focus slot model)
              ...day.slots.asMap().entries.map((e) {
                final slotIndex = e.key;
                final slot = e.value;
                final isSelected = slotIndex == _selectedSlotIndex;
                
                return _buildIntelligentSlotCard(slot, isSelected, slotIndex)
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 25 * slotIndex), duration: 200.ms);
              }),
              
              SizedBox(height: 4.h),
              
              // Tactical Analytics Dashboard
              _buildAnalyticsCard(total, completed)
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 250.ms),
                  
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          children: [
            _buildHeaderCard(),
            SizedBox(height: 14.h),
            _buildPlannerSkeleton(),
          ],
        ),
      ),
      error: (e, _) => HFErrorState(
        onRetry: () => ref.refresh(plannerProvider(_dateKey)),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 13.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111113), Color(0xFF0C0C0E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.5.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFE25B20).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: const Color(0xFFE25B20).withValues(alpha: 0.2), width: 0.8),
                ),
                child: Icon(Icons.shield_outlined, color: const Color(0xFFE25B20), size: 13.5.sp),
              ),
              SizedBox(width: 8.w),
              Text(
                'DAILY DEPLOYMENT', 
                style: GoogleFonts.outfit(
                  color: const Color(0xFFE25B20), 
                  fontSize: 10.2.sp, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 1.8,
                ),
              ),
              const Spacer(),
              
              // Tactical status tag
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                ),
                child: Text(
                  'TACTICAL PREVIEW', 
                  style: GoogleFonts.outfit(
                    color: Colors.white24, 
                    fontSize: 7.5.sp, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'Daily Protocol', 
            style: GoogleFonts.outfit(
              color: Colors.white, 
              fontSize: 32.sp, 
              fontWeight: FontWeight.w900, 
              letterSpacing: -0.6,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Orchestrate your day with high-precision time blocks and structured focus zones.', 
            style: GoogleFonts.inter(
              color: Colors.white54, 
              fontSize: 13.5.sp, 
              height: 1.25,
            ),
          ),
          SizedBox(height: 12.h),
          
          // Date Selector Console
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: const Color(0xFF060608),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _currentDate = _currentDate.subtract(const Duration(days: 1)));
                  }, 
                  child: Icon(Icons.chevron_left_rounded, color: Colors.white38, size: 20.sp),
                ),
                Column(
                  children: [
                    Text(
                      _dayName(_currentDate).toUpperCase(), 
                      style: GoogleFonts.outfit(
                        color: Colors.white, 
                        fontSize: 13.sp, 
                        fontWeight: FontWeight.w900, 
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      _formatDate(_currentDate).toUpperCase(), 
                      style: GoogleFonts.outfit(
                        color: Colors.white38, 
                        fontSize: 8.6.sp, 
                        fontWeight: FontWeight.w800, 
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _currentDate = _currentDate.add(const Duration(days: 1)));
                  }, 
                  child: Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 20.sp),
                ),
              ],
            ),
          ),
          
          if (!_isToday(_currentDate)) ...[
            SizedBox(height: 10.h),
            Center(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() => _currentDate = DateTime.now());
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE25B20).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFFE25B20).withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    'RESET TO TODAY', 
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFE25B20), 
                      fontSize: 9.6.sp, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIntelligentSlotCard(PlannerSlotModel slot, bool isSelected, int index) {
    final slotTotal = slot.tasks.length;
    final slotCompleted = slot.tasks.where((t) => t.completed).length;
    final isCompleted = slotTotal > 0 && slotCompleted == slotTotal;
    final isEmpty = slotTotal == 0;

    // Softer Orange selection emphasis: Reduced glowing border and softened selection tones
    final Color strokeColor = isSelected 
        ? const Color(0xFFE25B20).withValues(alpha: 0.15) // Softened border emphasis
        : isCompleted 
            ? const Color(0xFF10B981).withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.03);
            
    final Color bgColor = isSelected 
        ? const Color(0xFF0F0E0D) 
        : const Color(0xFF0C0C0E); 
        
    const double borderThickness = 1.0; // Soft outline border

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedSlotIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: 180.ms,
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(bottom: 7.h), // Tightened from 8.h
        padding: isSelected 
            ? EdgeInsets.fromLTRB(14.w, 9.h, 14.w, 8.h) // Compressed vertical active padding
            : EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h), // 30% vertical padding reduction on collapsed slots
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r), 
          border: Border.all(color: strokeColor, width: borderThickness),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFFE25B20).withValues(alpha: 0.02), 
                blurRadius: 8, 
                spreadRadius: 0,
                offset: const Offset(0, 2),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18), 
                blurRadius: 4,
                offset: const Offset(0, 1.5),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header Block
            Row(
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                AnimatedContainer(
                  duration: 150.ms,
                  padding: EdgeInsets.all(isSelected ? 5.w : 4.w), // Compressed collapsed icon padding
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFFE25B20).withValues(alpha: 0.08)
                        : isCompleted
                            ? const Color(0xFF10B981).withValues(alpha: 0.05)
                            : Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(5.r),
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFFE25B20).withValues(alpha: 0.2)
                          : isCompleted 
                              ? const Color(0xFF10B981).withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.04),
                      width: 0.8,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isSelected
                        ? Icons.center_focus_strong_rounded 
                        : isCompleted
                            ? Icons.done_all_rounded 
                            : Icons.access_time_rounded, 
                    color: isSelected 
                        ? const Color(0xFFE25B20) 
                        : isCompleted
                            ? const Color(0xFF10B981)
                            : Colors.white38, 
                    size: 15.8.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                
                // Time Range (Clean time hierarchy)
                Expanded(
                  child: Text(
                    slot.timeRange, 
                    style: GoogleFonts.outfit(
                      color: isCompleted ? Colors.white30 : Colors.white.withValues(alpha: 0.85), 
                      fontSize: 16.sp, 
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                      letterSpacing: 0.5,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                
                // Completion Ratio Tag / Expandable Chevron Affordance (Micro Polish Alignment)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!isEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                        decoration: BoxDecoration(
                          color: isCompleted 
                              ? const Color(0xFF10B981).withValues(alpha: 0.04)
                              : const Color(0xFFE25B20).withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(5.r),
                          border: Border.all(
                            color: isCompleted
                                ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                : const Color(0xFFE25B20).withValues(alpha: 0.1),
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          '$slotCompleted/$slotTotal', 
                          style: GoogleFonts.outfit(
                            color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFE25B20), 
                            fontSize: 9.6.sp, 
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    
                    SizedBox(width: 8.w),
                    Icon(
                      isSelected ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: isSelected ? const Color(0xFFE25B20).withValues(alpha: 0.5) : Colors.white24,
                      size: 16.2.sp,
                    ),
                  ],
                ),
              ],
            ),
            
            // Expanded Content Body (Tasks & Inputs)
            if (isSelected) ...[
              SizedBox(height: 4.h), // Compressing active time block vertical heights
              Container(height: 0.5.h, color: Colors.white.withValues(alpha: 0.04)),
              SizedBox(height: 4.h),
              
              if (isEmpty) ...[
                // Upgraded Empty State: Compressing excessive heights, and polish contrasts
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2.h), 
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.space_dashboard_outlined, 
                        size: 18.sp, 
                        color: Colors.white.withValues(alpha: 0.25), 
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'ZONE UNALLOCATED', 
                        style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.45), 
                          fontSize: 10.2.sp, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 1.8,
                        ),
                      ),
                      Text(
                        'Deploy objectives to secure this time frame.', 
                        style: GoogleFonts.inter(
                          color: Colors.white38, 
                          fontSize: 11.5.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Task Items List
                ...slot.tasks.map((task) => _buildTaskItem(task, slot.id)),
                SizedBox(height: 4.h),
                Container(height: 0.5.h, color: Colors.white.withValues(alpha: 0.04)),
              ],
              
              SizedBox(height: 4.h),
              
              _buildTaskInputConsole(slot),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInputConsole(PlannerSlotModel slot) {
    final controller = _getController(slot.id);
    final focusNode = _getFocusNode(slot.id);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp),
              decoration: InputDecoration(
                hintText: 'Allocate strategic objective...',
                hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 14.5.sp), 
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8.h),
              ),
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  HapticFeedback.mediumImpact();
                  ref.read(plannerProvider(_dateKey).notifier).addTask(slot.id, val.trim());
                  controller.clear();
                  focusNode.requestFocus(); 
                }
              },
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () {
              final val = controller.text;
              if (val.trim().isNotEmpty) {
                HapticFeedback.mediumImpact();
                ref.read(plannerProvider(_dateKey).notifier).addTask(slot.id, val.trim());
                controller.clear();
                focusNode.unfocus();
              }
            },
            child: Icon(
              Icons.add_circle_outline_rounded, 
              color: const Color(0xFFE25B20), 
              size: 21.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(PlannerTaskModel task, String slotId) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.01),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(plannerProvider(_dateKey).notifier).toggleTask(task.id, !task.completed);
              },
              child: AnimatedContainer(
                duration: 150.ms,
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: task.completed ? const Color(0xFFE25B20).withValues(alpha: 0.15) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.completed ? const Color(0xFFE25B20) : Colors.white24,
                    width: 1.0,
                  ),
                ),
                child: Icon(
                  Icons.check_rounded, 
                  size: 9.sp, 
                  color: task.completed ? const Color(0xFFE25B20) : Colors.transparent,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                task.title, 
                style: GoogleFonts.inter(
                  color: task.completed ? Colors.white30 : Colors.white.withValues(alpha: 0.85), 
                  fontSize: 13.5.sp, 
                  fontWeight: task.completed ? FontWeight.normal : FontWeight.w500,
                  decoration: task.completed ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(plannerProvider(_dateKey).notifier).removeTask(task.id);
              },
              child: Icon(Icons.close_rounded, size: 14.sp, color: Colors.white24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(int total, int completed) {
    final progress = total > 0 ? ((completed / total) * 100).round() : 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0E), // High-end dashboard background
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Intelligence Header (Polished tactical title indicator)
          Row(
            children: [
              Container(
                width: 4.w,
                height: 4.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE25B20),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                'COMMAND INTELLIGENCE', 
                style: GoogleFonts.outfit(
                  fontSize: 9.8.sp, 
                  fontWeight: FontWeight.w900, 
                  color: Colors.white54,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Sharp row alignment between progress indicator and texts
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Double Metric display
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mission Continuity', 
                      style: GoogleFonts.outfit(
                        color: Colors.white, 
                        fontSize: 18.sp, 
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      total > 0
                          ? 'Equilibrium secured. Complete remaining operational focus zones to maximize peak signal.'
                          : 'Strategic initialization required. Allocate focus nodes in the slots above to begin daily tracking.', 
                      style: GoogleFonts.inter(
                        color: Colors.white38, 
                        fontSize: 13.sp, 
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 14.w),

              // Sharper, Prominent Glow Progress Ring (Compact)
              SizedBox(
                width: 74.w,
                height: 74.w,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: total > 0 ? completed / total : 0,
                      strokeWidth: 5.w, 
                      backgroundColor: Colors.white.withValues(alpha: 0.03),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFE25B20)),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$progress%', 
                            style: GoogleFonts.outfit(
                              color: Colors.white, 
                              fontSize: 14.5.sp, 
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'SECURED', 
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFE25B20), 
                              fontSize: 6.sp, 
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 10.h),
          Container(height: 0.5.h, color: Colors.white.withValues(alpha: 0.04)),
          SizedBox(height: 8.h),

          // Sharp clean action buttons row
          Row(
            children: [
              Expanded(
                child: _actionBtn(
                  Icons.bolt_rounded, 
                  'PEAK PERFORMANCE', 
                  const Color(0xFFE25B20),
                  true, 
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _actionBtn(
                  Icons.trending_up_rounded, 
                  'GROWTH SIGNAL', 
                  Colors.white38,
                  false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color, bool isHighlighted) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.5.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isHighlighted 
            ? const Color(0xFFE25B20).withValues(alpha: 0.03) 
            : Colors.white.withValues(alpha: 0.015),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: isHighlighted 
              ? const Color(0xFFE25B20).withValues(alpha: 0.15) 
              : color.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon, 
            color: isHighlighted ? const Color(0xFFE25B20) : color, 
            size: 13.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            label, 
            style: GoogleFonts.outfit(
              color: isHighlighted ? const Color(0xFFE25B20) : color, 
              fontSize: 9.2.sp, 
              fontWeight: FontWeight.w900, 
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlannerSkeleton() {
    return Column(
      children: List.generate(3, (index) => Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF0C0C0E),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 100.w, height: 16.h, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(6.r))),
            SizedBox(height: 14.h),
            Container(width: double.infinity, height: 12.h, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(4.r))),
            SizedBox(height: 6.h),
            Container(width: 140.w, height: 12.h, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(4.r))),
          ],
        ),
      )).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.02)),
    );
  }
}
