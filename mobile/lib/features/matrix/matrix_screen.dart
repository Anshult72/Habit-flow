import 'package:flutter/material.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
            // Top App Bar Area
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.radar_rounded, color: Colors.white, size: 28.sp),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Eisenhower\nMatrix', style: GoogleFonts.outfit(fontSize: 32.sp, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, letterSpacing: -0.5)),
                              SizedBox(height: 12.h),
                              Text('Master your focus through strategic\npriority management.', style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white54, height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),

                    // Add Button
                    GestureDetector(
                      onTap: () => _showAdd(context),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFFE85D04)]),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8)),
                          ]
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
                            SizedBox(width: 8.w),
                            Text('Add High Priority Task', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Quadrants
                    matrixAsync.when(
                      data: (tasks) => Column(
                        children: _quads.map((q) {
                          final qTasks = tasks.where((t) => t.quadrant == q.id).toList();
                          return _buildQuadrantCard(q, qTasks);
                        }).toList(),
                      ),
                      loading: () => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: const HFShimmerList(height: 80, count: 4),
                      ),
                      error: (e, _) => HFErrorState(
                        onRetry: () => ref.refresh(matrixProvider),
                      ),
                    ),

                    SizedBox(height: 120.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuadrantCard(_Quad q, List<MatrixModel> tasks) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.all(28.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [q.color.withValues(alpha: 0.15), Colors.transparent],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: q.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(q.icon, color: q.color, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(q.title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.w900)),
                      Text(q.subtitle.toUpperCase(), style: GoogleFonts.outfit(color: q.color, fontSize: 10.sp, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text('${tasks.length}', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 18.sp, fontWeight: FontWeight.w800)),
                    Text('Tasks', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                  ],
                ),
                SizedBox(width: 16.w),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Icon(Icons.info_outline_rounded, color: Colors.white38, size: 16.sp),
                ),
              ],
            ),
          ),
          
          Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
          
          // Tasks or Empty State
          Padding(
            padding: EdgeInsets.all(28.w),
            child: tasks.isEmpty 
              ? Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Icon(Icons.add_rounded, color: Colors.white38, size: 24.sp),
                    ),
                    SizedBox(height: 16.h),
                    Text('No tasks in this quadrant', style: GoogleFonts.inter(color: Colors.white54, fontSize: 13.sp)),
                    SizedBox(height: 8.h),
                    Text('FOCUS ON WHAT MATTERS', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                  ],
                )
              : Column(
                  children: tasks.map((t) => _taskTile(t, q.color)).toList(),
                ),
          ),
        ],
      ),
    );
  }

  Widget _taskTile(MatrixModel t, Color c) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => ref.read(matrixProvider.notifier).toggleCompletion(t.id, t.completed),
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
            onTap: () => ref.read(matrixProvider.notifier).removeTask(t.id),
            child: Icon(Icons.close_rounded, size: 18.sp, color: Colors.white24),
          ),
        ],
      ),
    );
  }

  void _showAdd(BuildContext context) {
    final tc = TextEditingController(); 
    final dc = TextEditingController();
    String urg = 'urgent', imp = 'important';
    
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: const Color(0xFF111111), 
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          padding: EdgeInsets.all(28.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Center(
                child: Container(
                  width: 48.w, 
                  height: 4.h, 
                  decoration: BoxDecoration(
                    color: Colors.white24, 
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.add_rounded, color: Colors.white, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Strategic Initialization', style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.w900, color: Colors.white)),
                        Text('MATRIX TASK DEPLOYMENT', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: Colors.white54, letterSpacing: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              
              _label('OBJECTIVE TITLE'),
              SizedBox(height: 8.h),
              TextField(
                controller: tc, 
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp), 
                decoration: _dec('What is your primary focus?'),
              ),
              SizedBox(height: 20.h),
              
              _label('INTELLIGENCE BRIEF'),
              SizedBox(height: 8.h),
              TextField(
                controller: dc, 
                maxLines: 3, 
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp), 
                decoration: _dec('Additional tactical details...'),
              ),
              SizedBox(height: 24.h),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('TIME URGENCY'),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(child: _toggleBtn('URGENT', urg == 'urgent', () => ss(() => urg = 'urgent'))),
                            SizedBox(width: 8.w),
                            Expanded(child: _toggleBtn('NOT URGENT', urg == 'not-urgent', () => ss(() => urg = 'not-urgent'))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('VALUE IMPACT'),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(child: _toggleBtn('IMPORTANT', imp == 'important', () => ss(() => imp = 'important'))),
                            SizedBox(width: 8.w),
                            Expanded(child: _toggleBtn('NOT IMPORTANT', imp == 'not-important', () => ss(() => imp = 'not-important'))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('TEMPORAL DEADLINE'),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Select date...', style: GoogleFonts.inter(color: Colors.white38, fontSize: 14.sp)),
                              Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white38, size: 20.sp),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('YIELD FORECAST'),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.auto_awesome, color: AppTheme.primary, size: 16.sp),
                                  SizedBox(width: 8.w),
                                  Text('50 XP Reward', style: GoogleFonts.outfit(color: AppTheme.primary, fontSize: 13.sp, fontWeight: FontWeight.w800)),
                                ],
                              ),
                              Icon(Icons.shield_outlined, color: AppTheme.primary.withValues(alpha: 0.5), size: 16.sp),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        alignment: Alignment.center,
                        child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
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
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFFE85D04)]),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        alignment: Alignment.center,
                        child: Text('Commit to Matrix', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 1.5));

  Widget _toggleBtn(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: isActive ? AppTheme.primary : Colors.white.withValues(alpha: 0.05)),
        ),
        alignment: Alignment.center,
        child: Text(text, style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w800, color: isActive ? Colors.white : Colors.white38)),
      ),
    );
  }

  InputDecoration _dec(String h) => InputDecoration(
    hintText: h, 
    hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 14.sp),
    filled: true, 
    fillColor: Colors.white.withValues(alpha: 0.02), 
    contentPadding: EdgeInsets.all(16.w),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3))),
  );
}
