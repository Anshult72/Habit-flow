import 'package:flutter/material.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../models/matrix_model.dart';
import '../../services/matrix_service.dart';

class _Quad { 
  final int id; 
  final String title, subtitle; 
  final Color color; 
  final IconData icon;
  const _Quad(this.id, this.title, this.subtitle, this.color, this.icon);
}

const _quads = [
  _Quad(1, 'Do First', 'Urgent & Important', Color(0xFFFF4D4D), Icons.bolt_rounded),
  _Quad(2, 'Schedule', 'Not Urgent & Important', Color(0xFFFFD700), Icons.calendar_today_rounded),
  _Quad(3, 'Delegate', 'Urgent & Unimportant', Color(0xFF3B82F6), Icons.adjust_rounded),
  _Quad(4, 'Eliminate', 'Not Urgent & Unimportant', Color(0xFF10B981), Icons.coffee_rounded),
];


class MatrixScreen extends ConsumerStatefulWidget {
  const MatrixScreen({super.key});
  @override
  ConsumerState<MatrixScreen> createState() => _MatrixScreenState();
}

class _MatrixScreenState extends ConsumerState<MatrixScreen> {
  @override
  Widget build(BuildContext context) {
    final matrixAsync = ref.watch(matrixProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF000000), 
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Area (Compact vertical padding with native breathing space)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16.sp),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h), // Clean mobile margins
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Strategic Header (Bold mobile-native layout)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE25B20).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE25B20).withValues(alpha: 0.2)),
                          ),
                          child: Icon(Icons.radar_rounded, color: const Color(0xFFE25B20), size: 22.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Eisenhower Matrix',
                                style: GoogleFonts.outfit(
                                  fontSize: 26.sp, 
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'STRATEGIC PRIORITIZATION',
                                style: GoogleFonts.outfit(
                                  fontSize: 8.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white38,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Mobile Stacked Priority Cockpit
                    matrixAsync.when(
                      data: (tasks) => Column(
                        children: [
                          _buildQuadrantCard(
                            _quads[0], 
                            tasks.where((t) => t.quadrant == 1).toList(),
                          ),
                          SizedBox(height: 12.h),
                          _buildQuadrantCard(
                            _quads[1], 
                            tasks.where((t) => t.quadrant == 2).toList(),
                          ),
                          SizedBox(height: 12.h),
                          _buildQuadrantCard(
                            _quads[2], 
                            tasks.where((t) => t.quadrant == 3).toList(),
                          ),
                          SizedBox(height: 12.h),
                          _buildQuadrantCard(
                            _quads[3], 
                            tasks.where((t) => t.quadrant == 4).toList(),
                          ),
                        ],
                      ),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(color: Color(0xFFE25B20)),
                        ),
                      ),
                      error: (e, _) => HFErrorState(
                        onRetry: () => ref.refresh(matrixProvider),
                      ),
                    ),
                    SizedBox(height: 80.h), // Reclaimed bottom padding to prevent FAB overlapping matrix card content
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 12.h, right: 8.w), // Respects safe area / bottom navigation spacing
        child: GestureDetector(
          onTap: () => _showAdd(context),
          child: Container(
            width: 60.w, // Reduced size slightly (60-68px range) for an elegant, less overpowering presence
            height: 60.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7E47), Color(0xFFE25B20)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE25B20).withValues(alpha: 0.20),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 26.sp, // Scale icon proportionally
            ),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(0.96, 0.96),
            end: const Offset(1.04, 1.04),
            duration: 2000.ms,
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );
  }



  Widget _buildQuadrantCard(_Quad q, List<MatrixModel> tasks) {
    final isEmpty = tasks.isEmpty;
    return GestureDetector(
      onTap: () {
        if (isEmpty) {
          _showAdd(context, initialQuadrant: q.id);
        } else {
          _showQuadrantDetail(context, q, tasks);
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 16.w), // Reduced card width slightly for elegant nested breathing space
        constraints: BoxConstraints(
          minHeight: isEmpty ? 162.h : 178.h, // Increased base card height by ~14% for improved visual balance
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
          boxShadow: [
            BoxShadow(
              color: q.color.withValues(alpha: 0.015),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              // Subtle upper section ambient glow (top 15-20% area maximum, low opacity)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 36.h,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        q.color.withValues(alpha: 0.05), // Feather-light 5% opacity maximum
                        q.color.withValues(alpha: 0.0),  // Seamlessly fade into solid dark background
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h), // Clean luxury dark glass look
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Card Header Row
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(5.w),
                          decoration: BoxDecoration(
                            color: q.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(q.icon, color: q.color, size: 14.sp)
                              .animate(onPlay: (controller) => controller.repeat(reverse: true))
                              .scale(begin: const Offset(0.94, 0.94), end: const Offset(1.06, 1.06), duration: 2400.ms, curve: Curves.easeInOut),
                        ),
                        SizedBox(width: 10.w), // Increased horizontal header spacing
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    q.title.toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  // Task Count Badge
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                                    decoration: BoxDecoration(
                                      color: q.color.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6.r),
                                      border: Border.all(color: q.color.withValues(alpha: 0.15), width: 0.5),
                                    ),
                                    child: Text(
                                      '${tasks.length}',
                                      style: GoogleFonts.outfit(
                                        color: q.color,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h), // Internal subtitle breathing room
                              Text(
                                q.subtitle,
                                style: GoogleFonts.inter(
                                  color: Colors.white38,
                                  fontSize: 8.5.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h), // Increased vertical separator spacing
                    Container(height: 0.5.h, color: Colors.white.withValues(alpha: 0.04)),
                    SizedBox(height: 12.h), // Increased vertical separator spacing
                    
                    // Empty State or Tasks List preview
                    isEmpty
                        ? Padding(
                            padding: EdgeInsets.only(top: 4.h, bottom: 8.h), // Balanced breathing room inside empty cards
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      q.icon, 
                                      color: q.color.withValues(alpha: 0.4),
                                      size: 14.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Nothing here yet',
                                      style: GoogleFonts.inter(
                                        color: Colors.white38,
                                        fontSize: 11.5.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h), // Improved spacing
                                Padding(
                                  padding: EdgeInsets.only(left: 22.w),
                                  child: Text(
                                    'Tap to add a task',
                                    style: GoogleFonts.inter(
                                      color: q.color.withValues(alpha: 0.6),
                                      fontSize: 9.5.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...tasks.take(6).map((t) => _miniTaskTile(t, q.color)),
                              if (tasks.length > 6) ...[
                                SizedBox(height: 6.h), // Improved vertical spacing
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                      decoration: BoxDecoration(
                                        color: q.color.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(6.r),
                                        border: Border.all(color: q.color.withValues(alpha: 0.15), width: 0.5),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '+${tasks.length - 6} more tasks',
                                            style: GoogleFonts.outfit(
                                              color: q.color,
                                              fontSize: 8.5.sp,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            '•',
                                            style: TextStyle(
                                              color: q.color.withValues(alpha: 0.5),
                                              fontSize: 8.sp,
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'View All',
                                            style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontSize: 8.5.sp,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniTaskTile(MatrixModel t, Color c) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: Row(
        children: [
          // Quick completion touch target
          GestureDetector(
            onTap: () {
              ref.read(matrixProvider.notifier).toggleCompletion(t.id, !t.completed);
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(4.w), // Comfortable tap area
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: t.completed ? c.withValues(alpha: 0.15) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: t.completed ? c : Colors.white24, width: 1.2),
                ),
                child: Icon(
                  Icons.check_rounded, 
                  size: 10.sp, 
                  color: t.completed ? c : Colors.transparent
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: t.completed ? Colors.white24 : Colors.white70,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    decoration: t.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (t.desc.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    t.desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white24,
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Optional metadata/due date tag
          if (t.dueDate != null) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_rounded, size: 7.5.sp, color: Colors.white30),
                  SizedBox(width: 4.w),
                  Text(
                    _formatDueDate(t.dueDate!),
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDueDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(dt.year, dt.month, dt.day);
    final diff = taskDay.difference(today).inDays;
    
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff > 1 && diff < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[dt.weekday - 1];
    }
    return '${dt.day}/${dt.month}';
  }

  String _emptyMessage(int quadId) {
    switch (quadId) {
      case 1:
        return "Attack highest-impact";
      case 2:
        return "Plan future progress";
      case 3:
        return "Offload non-focus tasks";
      case 4:
      default:
        return "Remove energy drains";
    }
  }

  void _showQuadrantDetail(BuildContext context, _Quad q, List<MatrixModel> initialTasks) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final allTasks = ref.watch(matrixProvider).valueOrNull ?? [];
          final qTasks = allTasks.where((t) => t.quadrant == q.id).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                SizedBox(height: 12.h),
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q.title,
                            style: GoogleFonts.outfit(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            q.subtitle.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              color: q.color,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded, color: Colors.white38, size: 16.sp),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Container(height: 0.5.h, color: Colors.white.withValues(alpha: 0.08)),
                
                // Tasks List
                Expanded(
                  child: qTasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                q.icon, 
                                color: q.color.withValues(alpha: 0.1), 
                                size: 48.sp
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                _emptyMessage(q.id),
                                style: GoogleFonts.inter(
                                  color: Colors.white38,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                          itemCount: qTasks.length,
                          itemBuilder: (context, index) {
                            final t = qTasks[index];
                            return _taskTile(t, q.color, setModalState);
                          },
                        ),
                ),
                
                // Bottom Dedicated Quick Add Button inside full sheet
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _showAdd(context, initialQuadrant: q.id);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: q.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: q.color.withValues(alpha: 0.2)),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded, color: q.color, size: 20.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'Add Task to ${q.title}',
                            style: GoogleFonts.inter(
                              color: q.color,
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _taskTile(MatrixModel t, Color c, StateSetter setModalState) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              await ref.read(matrixProvider.notifier).toggleCompletion(t.id, t.completed);
              setModalState(() {});
            },
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: t.completed ? c.withValues(alpha: 0.2) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: t.completed ? c : Colors.white24),
              ),
              child: Icon(Icons.check_rounded, size: 14.sp, color: t.completed ? c : Colors.transparent),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title, 
                  style: GoogleFonts.inter(
                    fontSize: 14.sp, 
                    fontWeight: FontWeight.w600,
                    color: t.completed ? Colors.white38 : Colors.white,
                    decoration: t.completed ? TextDecoration.lineThrough : null
                  )
                ),
                if (t.desc.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    t.desc, 
                    style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.white38),
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis
                  ),
                ]
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              await ref.read(matrixProvider.notifier).removeTask(t.id);
              setModalState(() {});
            },
            child: Icon(Icons.close_rounded, size: 18.sp, color: Colors.white24),
          ),
        ],
      ),
    );
  }

  void _showAdd(BuildContext context, {int? initialQuadrant}) {
    final tc = TextEditingController(); 
    final dc = TextEditingController();
    
    // Auto-setup based on clicked quadrant
    String urg = 'urgent', imp = 'important';
    if (initialQuadrant != null) {
      if (initialQuadrant == 1) { urg = 'urgent'; imp = 'important'; }
      if (initialQuadrant == 2) { urg = 'not-urgent'; imp = 'important'; }
      if (initialQuadrant == 3) { urg = 'urgent'; imp = 'not-important'; }
      if (initialQuadrant == 4) { urg = 'not-urgent'; imp = 'not-important'; }
    }
    
    showDialog(
      context: context, 
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        alignment: const Alignment(0, -0.15), // Shift slightly upward for visual centering correction
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: StatefulBuilder(
          builder: (ctx, ss) => Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111111), 
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(5.w), // Tighter padding for cleaner header
                            decoration: BoxDecoration(
                              color: const Color(0xFFE25B20).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(Icons.add_rounded, color: const Color(0xFFE25B20), size: 16.sp), // Slightly smaller top-left icon
                          ),
                          SizedBox(width: 8.w), // Tighter spacing
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Strategic Initialization', 
                                style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              Text(
                                'MATRIX TASK DEPLOYMENT', 
                                style: GoogleFonts.outfit(fontSize: 8.sp, fontWeight: FontWeight.w800, color: Colors.white38, letterSpacing: 1.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: EdgeInsets.all(4.w), // Reduced size to match ghost close button style
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.02),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded, color: Colors.white38, size: 14.sp), // Reduced size
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h), // Reduced height from 24.h
                  
                  _label('OBJECTIVE TITLE'),
                  SizedBox(height: 6.h), // Tighter spacing
                  TextField(
                    controller: tc, 
                    style: GoogleFonts.inter(
                      color: Colors.white, 
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                    ), 
                    decoration: _dec('What is your primary focus?'),
                  ),
                  SizedBox(height: 12.h), // Reduced spacing
                  
                  _label('INTELLIGENCE BRIEF'),
                  SizedBox(height: 6.h), // Tighter spacing
                  TextField(
                    controller: dc, 
                    maxLines: 2, 
                    style: GoogleFonts.inter(
                      color: Colors.white, 
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                    ), 
                    decoration: _dec('Additional tactical details...'),
                  ),
                  SizedBox(height: 12.h), // Reduced spacing
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('TIME URGENCY'),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Expanded(child: _toggleBtn('URGENT', urg == 'urgent', () => ss(() => urg = 'urgent'))),
                                SizedBox(width: 8.w),
                                Expanded(child: _toggleBtn('NOT\nURGENT', urg == 'not-urgent', () => ss(() => urg = 'not-urgent'))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('VALUE IMPACT'),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Expanded(child: _toggleBtn('IMPORTANT', imp == 'important', () => ss(() => imp = 'important'))),
                                SizedBox(width: 8.w),
                                Expanded(child: _toggleBtn('NOT\nIMPORTANT', imp == 'not-important', () => ss(() => imp = 'not-important'))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h), // Clean premium spacing before CTAs
                  
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              color: Colors.transparent, // Cleaner premium secondary ghost action
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)), // Subtle white outline
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Cancel', 
                              style: GoogleFonts.inter(
                                color: Colors.white54, // Cleaner white54 instead of white38
                                fontSize: 13.sp, 
                                fontWeight: FontWeight.w700, // Balanced emphasis
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            if (tc.text.trim().isEmpty) return;
                            int q = 4;
                            if (urg == 'urgent' && imp == 'important') {
                              q = 1;
                            } else if (urg == 'not-urgent' && imp == 'important') {
                              q = 2;
                            } else if (urg == 'urgent' && imp == 'not-important') {
                              q = 3;
                            }
                            
                            ref.read(matrixProvider.notifier).addTask({
                              'title': tc.text.trim(),
                              'desc': dc.text.trim(),
                              'quadrant': q,
                            });
                            Navigator.pop(ctx);
                          }, 
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF7E47), Color(0xFFE25B20)],
                              ),
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE25B20).withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Commit to Matrix', 
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 13.5.sp, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Text(
          text, 
          style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 2),
        ),
      );

  Widget _toggleBtn(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42.h, // fixed height for perfect visual symmetry across all option chips
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE25B20).withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: isActive ? const Color(0xFFE25B20).withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05)),
        ),
        alignment: Alignment.center,
        child: Text(
          text, 
          textAlign: TextAlign.center, // centered horizontally
          style: GoogleFonts.outfit(
            fontSize: 9.sp, 
            fontWeight: FontWeight.w800, 
            color: isActive ? const Color(0xFFE25B20) : Colors.white30,
            height: 1.15, // proper balanced line height for multi-line layout
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String h) => InputDecoration(
        hintText: h, 
        hintStyle: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.28), fontSize: 13.sp),
        filled: true, 
        fillColor: Colors.white.withValues(alpha: 0.03), 
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r), 
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r), 
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: const Color(0xFFE25B20).withValues(alpha: 0.4)),
        ),
      );
}
