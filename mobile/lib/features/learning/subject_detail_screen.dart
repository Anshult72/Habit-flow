import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import '../../core/widgets/soft_unlock_dialog.dart';
import '../../models/learning_model.dart';
import '../../services/learning_service.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'chapter_detail_screen.dart';

class SubjectDetailScreen extends ConsumerWidget {
  final String subjectId;

  const SubjectDetailScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectAsync = ref.watch(subjectDetailsProvider(subjectId));

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: subjectAsync.when(
          data: (subject) => _buildContent(context, ref, subject),
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE25B20))),
          error: (e, _) => HFErrorState(onRetry: () => ref.refresh(subjectDetailsProvider(subjectId))),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, SubjectModel subject) {
    final chapters = subject.chapters ?? [];
    final completedChapters = chapters.where((c) => c.status == 'Completed').length;
    final isNotStarted = subject.progress == 0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _backButton(context),
                SizedBox(height: 20.h),
                
                // Top Rich Summary Card (Enhanced info density & Active Conditional states)
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF141414), // Premium dark luxury depth
                        Color(0xFF0C0C0C),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE25B20).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              subject.category?.toUpperCase() ?? 'GENERAL',
                              style: GoogleFonts.outfit(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFE25B20),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          Text(
                            isNotStarted ? 'AWAITING INITIALIZATION' : '${subject.progress}% ACQUIRED', // Terminology & Empty state fix
                            style: GoogleFonts.outfit(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w900,
                              color: isNotStarted ? Colors.white30 : const Color(0xFFE25B20),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        subject.title,
                        style: GoogleFonts.outfit(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      
                      // Clean 3-Column Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _statItem(
                              LucideIcons.graduationCap,
                              'MODULES',
                              '$completedChapters / ${chapters.length}',
                            ),
                          ),
                          Expanded(
                            child: _statItem(
                              LucideIcons.zap,
                              'XP EARNED',
                              '${subject.xpEarned} XP',
                            ),
                          ),
                          Expanded(
                            child: _statItem(
                              LucideIcons.flame,
                              'STREAK',
                              '${subject.streakCount} ${subject.streakCount == 1 ? "Day" : "Days"}',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      
                      // Premium Glowing Progress Bar (Emotional Active Empty Track Fix)
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 7.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.09),
                              borderRadius: BorderRadius.circular(7.r),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: isNotStarted ? 0.05 : (subject.progress / 100).clamp(0.0, 1.0),
                            child: Container(
                              height: 7.h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isNotStarted
                                      ? [const Color(0xFFE25B20).withValues(alpha: 0.3), const Color(0xFFE25B20).withValues(alpha: 0.1)]
                                      : [const Color(0xFFFF7E47), const Color(0xFFE25B20)],
                                ),
                                borderRadius: BorderRadius.circular(7.r),
                                boxShadow: [
                                  if (!isNotStarted)
                                    BoxShadow(
                                      color: const Color(0xFFE25B20).withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      spreadRadius: 0.5,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                
                SizedBox(height: 28.h),
                
                // Chapter Header (Anchored Inline Plus Button Placement)
                Row(
                  children: [
                    Icon(LucideIcons.binary, color: const Color(0xFFE25B20), size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Chapter Protocol',
                      style: GoogleFonts.outfit(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _addButton(context, ref, subject.id), // Anchored properly in header!
                  ],
                ),
              ],
            ),
          ),
        ),
        
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: chapters.isEmpty
              ? SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C0C0C),
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
                    ),
                    child: Center(
                      child: Text(
                        'NO ACTIVE CHAPTER MODULES',
                        style: GoogleFonts.outfit(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white24,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final isSequenceLocked = index > 0 && chapters[index - 1].status != 'Completed';
                      final isUserUnlocked = subject.unlockedModules[chapters[index].id] == true;
                      return _ChapterCard(
                        chapter: chapters[index],
                        subjectId: subject.id,
                        index: index,
                        isLocked: isSequenceLocked && !isUserUnlocked,
                        previousChapterTitle: index > 0 ? chapters[index - 1].title : null,
                      );
                    },
                    childCount: chapters.length,
                  ),
                ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
      ],
    );
  }

  // Premium Ecosystem-grade Navigation (Unified Header Hierarchy Fix)
  Widget _backButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_ios_new_rounded, color: const Color(0xFFE25B20), size: 12.sp),
            SizedBox(width: 10.w),
            Text(
              'LEARNING HUB',
              style: GoogleFonts.outfit(
                fontSize: 9.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white60,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              '/',
              style: GoogleFonts.outfit(
                fontSize: 9.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white24,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              'CHAPTER PROTOCOL',
              style: GoogleFonts.outfit(
                fontSize: 9.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFE25B20),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE25B20), size: 14.sp),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white30,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _addButton(BuildContext context, WidgetRef ref, String subjectId) {
    return GestureDetector(
      onTap: () => _showAddChapter(context, ref, subjectId),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE25B20).withValues(alpha: 0.12), width: 0.6),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE25B20).withValues(alpha: 0.04),
              blurRadius: 4,
              spreadRadius: 1,
            )
          ],
        ),
        child: Icon(Icons.add_rounded, color: const Color(0xFFE25B20), size: 14.sp),
      ),
    );
  }

  // Premium Centered Inject Module Command Center Modal
  void _showAddChapter(BuildContext context, WidgetRef ref, String subjectId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D), // Premium high-density solid-glass dark surface
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 40,
                spreadRadius: 2,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header & Close Trigger
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inject Module',
                        style: GoogleFonts.outfit(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'PROTOCOL CHAPTER V1.0',
                        style: GoogleFonts.outfit(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFE25B20),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.02),
                      ),
                      child: Icon(Icons.close_rounded, color: Colors.white38, size: 14.sp),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                'Add a new module to expand your learning path.',
                style: GoogleFonts.inter(
                  fontSize: 11.5.sp,
                  color: Colors.white38,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'MODULE TITLE',
                style: GoogleFonts.outfit(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white30,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 6.h),
              TextField(
                controller: controller,
                autofocus: true,
                style: GoogleFonts.inter(fontSize: 13.5.sp, fontWeight: FontWeight.w600, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g., Quantum Neural Networks',
                  hintStyle: GoogleFonts.inter(color: Colors.white12, fontSize: 13.sp),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.02),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: const Color(0xFFE25B20).withValues(alpha: 0.4)),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.5.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Abort',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5.sp,
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
                        if (controller.text.trim().isNotEmpty) {
                          ref.read(subjectDetailsProvider(subjectId).notifier).addChapter(controller.text.trim());
                          Navigator.pop(ctx);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.5.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF7E47), Color(0xFFE25B20)],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE25B20).withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Initialize',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5.sp,
                          ),
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
    );
  }
}

class _ChapterCard extends ConsumerWidget {
  final ChapterModel chapter;
  final String subjectId;
  final int index;
  final bool isLocked;
  final String? previousChapterTitle;

  const _ChapterCard({
    required this.chapter,
    required this.subjectId,
    required this.index,
    required this.isLocked,
    this.previousChapterTitle,
  });

  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    bool shouldNavigate = !isLocked;

    if (isLocked && previousChapterTitle != null && context.mounted) {
      shouldNavigate = await SoftUnlockDialog.show(
        context,
        title: 'Sequence Override',
        message: 'This module normally follows a previous learning step.\nYou can continue now if your learning path requires it.',
        previousModuleTitle: previousChapterTitle!,
      );

      if (shouldNavigate) {
        ref.read(subjectDetailsProvider(subjectId).notifier).unlockModule(chapter.id);
      }
    }

    if (shouldNavigate && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChapterDetailScreen(
            subjectId: subjectId,
            chapterId: chapter.id,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = chapter.status == 'Completed';
    final isInProgress = chapter.status == 'In Progress';

    String ctaLabel;
    Color ctaBgColor;
    Color statusColor;
    String statusText;
    Widget progressCircle;

    if (isLocked) {
      ctaLabel = 'Locked';
      ctaBgColor = const Color(0xFF141414);
      statusColor = const Color(0xFF444444);
      statusText = 'Locked';
      progressCircle = Container(
        width: 30.w, height: 30.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.01), shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
        ),
        alignment: Alignment.center,
        child: Icon(LucideIcons.lock, color: Colors.white12, size: 12.sp),
      );
    } else if (isCompleted) {
      ctaLabel = 'Review';
      ctaBgColor = const Color(0xFF1E1E1E);
      statusColor = Colors.greenAccent;
      statusText = 'Completed';
      progressCircle = Container(
        width: 30.w, height: 30.w,
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle,
          border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2)),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.check_rounded, color: Colors.greenAccent, size: 14.sp),
      );
    } else if (isInProgress) {
      ctaLabel = 'Resume';
      ctaBgColor = const Color(0xFFE25B20);
      statusColor = Colors.orangeAccent;
      statusText = 'In Progress';
      progressCircle = SizedBox(
        width: 30.w, height: 30.w,
        child: Stack(alignment: Alignment.center, children: [
          SizedBox(
            width: 22.w, height: 22.w,
            child: CircularProgressIndicator(
              value: (chapter.progress / 100).clamp(0.0, 1.0),
              strokeWidth: 2, color: const Color(0xFFE25B20),
              backgroundColor: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Text('${chapter.progress}%', style: GoogleFonts.outfit(fontSize: 6.sp, fontWeight: FontWeight.w900, color: const Color(0xFFE25B20))),
        ]),
      );
    } else {
      ctaLabel = 'Start';
      ctaBgColor = const Color(0xFFE25B20);
      statusColor = const Color(0xFF8A8A8A);
      statusText = 'Available';
      progressCircle = Container(
        width: 30.w, height: 30.w,
        decoration: BoxDecoration(
          color: const Color(0xFFE25B20).withValues(alpha: 0.08), shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE25B20).withValues(alpha: 0.2)),
        ),
        alignment: Alignment.center,
        child: Icon(LucideIcons.playCircle, color: const Color(0xFFE25B20), size: 13.sp),
      );
    }

    return GestureDetector(
      onTap: () => _handleTap(context, ref),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF141414), Color(0xFF0C0C0C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            progressCircle,
            SizedBox(width: 10.w),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(chapter.title, style: GoogleFonts.outfit(fontSize: 14.5.sp, fontWeight: FontWeight.w800, color: isLocked ? Colors.white30 : Colors.white, letterSpacing: -0.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 5.h),
                Row(children: [
                  _tag(statusText, statusColor),
                  SizedBox(width: 8.w),
                  Container(width: 2.5.w, height: 2.5.w, decoration: BoxDecoration(color: isLocked ? Colors.white10 : Colors.white24, shape: BoxShape.circle)),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      '${chapter.topics?.length ?? 0} ${chapter.topics?.length == 1 ? 'TOPIC' : 'TOPICS'}',
                      style: GoogleFonts.outfit(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w900,
                        color: isLocked ? Colors.white12 : Colors.white30,
                        letterSpacing: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isLocked && chapter.progress > 0 && chapter.progress < 100) ...[
                    SizedBox(width: 8.w),
                    Container(width: 2.5.w, height: 2.5.w, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle)),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        '${chapter.progress}% ACQUIRED',
                        style: GoogleFonts.outfit(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white30,
                          letterSpacing: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ]),
              ]),
            ),
            SizedBox(width: 12.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.5.h),
              decoration: BoxDecoration(
                color: ctaBgColor, borderRadius: BorderRadius.circular(12.r),
                border: (isCompleted || isLocked) ? Border.all(color: Colors.white.withValues(alpha: 0.08)) : null,
                boxShadow: [if (!isCompleted && !isLocked) BoxShadow(color: const Color(0xFFE25B20).withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(ctaLabel, style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w900, color: isLocked ? Colors.white12 : Colors.white, letterSpacing: 0.3)),
                SizedBox(width: 4.w),
                Icon(isLocked ? LucideIcons.lock : (isCompleted ? Icons.refresh_rounded : Icons.arrow_forward_ios_rounded), color: isLocked ? Colors.white12 : Colors.white, size: 8.sp),
              ]),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: -0.05);
  }

  Widget _tag(String statusText, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4.r), border: Border.all(color: color.withValues(alpha: 0.15))),
      child: Text(statusText.toUpperCase(), style: GoogleFonts.outfit(fontSize: 7.sp, fontWeight: FontWeight.w900, color: color)),
    );
  }
}
