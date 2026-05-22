import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import '../../core/widgets/hf_progression_toast.dart';
import '../../models/learning_model.dart';
import '../../services/learning_service.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ChapterDetailScreen extends ConsumerWidget {
  final String subjectId;
  final String chapterId;

  const ChapterDetailScreen({super.key, required this.subjectId, required this.chapterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectAsync = ref.watch(subjectDetailsProvider(subjectId));

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: subjectAsync.when(
          data: (subject) {
            final chapter = subject.chapters?.firstWhere((c) => c.id == chapterId);
            if (chapter == null) return const Center(child: Text('Chapter not found'));
            return _buildContent(context, ref, subject, chapter);
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE25B20))),
          error: (e, _) => HFErrorState(onRetry: () => ref.refresh(subjectDetailsProvider(subjectId))),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, SubjectModel subject, ChapterModel chapter) {
    final topics = chapter.topics ?? [];
    final completedTopics = topics.where((t) => t.status == 'Completed').length;
    final activeTopics = topics.length - completedTopics;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                _backButton(context, subject.title),
                SizedBox(height: 20.h), // Spacing optimized by 15%
                
                // Chapter Summary Card (Tightened proportions & unified circular progress)
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
                              'MODULE SEGMENT',
                              style: GoogleFonts.outfit(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFE25B20),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          _circularProgress(chapter.progress), // Unified progress visualization language
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        chapter.title,
                        style: GoogleFonts.outfit(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Complete all topic nodes to finalize this chapter module.',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.white38,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                
                SizedBox(height: 12.h), // Tightened section spacing
                
                // Scrolling Footer Stats integrated directly above the list (Density & flow fix)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0C0C),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _footerStat('TOTAL NODES', '${topics.length}', Colors.white),
                      _divider(),
                      _footerStat('FINALIZED', '$completedTopics', Colors.greenAccent),
                      _divider(),
                      _footerStat('ACTIVE PROGRESS', '$activeTopics', const Color(0xFFE25B20)),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                
                SizedBox(height: 24.h), // Symmetrical layout divider spacing
                
                // Topic Nodes Header (Anchored inline button & clean spacing)
                Row(
                  children: [
                    Icon(LucideIcons.listTodo, color: const Color(0xFFE25B20), size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Topic Nodes',
                      style: GoogleFonts.outfit(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _addTopicButton(context, ref), // Inline aligned plus trigger
                  ],
                ),
                SizedBox(height: 14.h),
              ],
            ),
          ),
          
          SliverPadding(
            padding: EdgeInsets.zero,
            sliver: topics.isEmpty
                ? SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C0C0C),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.listCollapse, size: 36.sp, color: Colors.white12),
                          SizedBox(height: 12.h),
                          Text(
                            'READY TO INITIATE NODES', // Empty State Psychology Fix
                            style: GoogleFonts.outfit(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white24,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _TopicItem(
                        topic: topics[index],
                        index: index,
                        onToggle: () async {
                          final currentStatus = topics[index].status;
                          if (currentStatus == 'Not Started' || currentStatus == 'Ready to Begin') {
                            ref.read(subjectDetailsProvider(subjectId).notifier).updateTopicStatus(
                              chapterId, 
                              topics[index].id, 
                              'In Progress',
                            );
                          } else if (currentStatus == 'In Progress') {
                            final result = await ref.read(subjectDetailsProvider(subjectId).notifier).completeTopicWithXp(
                              chapterId, 
                              topics[index].id,
                            );
                            if (result != null && context.mounted) {
                              final totalXp = result['totalXp'] as int;
                              final xpEarned = result['xpEarned'] as int;
                              final moduleBonus = result['moduleBonus'] as int;
                              final chapterBonus = result['chapterBonus'] as int;
                              final streak = result['streak'] as int;
                              final isMilestone = result['isStreakMilestone'] != null;

                              String toastTitle = 'Topic Completed!';
                              String toastSubtitle = 'Acquired base topic knowledge';

                              if (chapterBonus > 0) {
                                toastTitle = 'Path Fully Mastered! 🏆';
                                toastSubtitle = 'Subject completion bonus unlocked!';
                              } else if (moduleBonus > 0) {
                                toastTitle = 'Module Completed! 🎉';
                                toastSubtitle = 'Module completion bonus unlocked!';
                              } else if (xpEarned == 0) {
                                toastTitle = 'Topic Reviewed';
                                toastSubtitle = 'Anti-farming limit reached for this module';
                              }

                              HFProgressionToast.show(
                                context,
                                title: toastTitle,
                                subtitle: toastSubtitle,
                                xpEarned: totalXp,
                                streakCount: streak,
                                isMilestone: isMilestone,
                              );
                            }
                          } else {
                            ref.read(subjectDetailsProvider(subjectId).notifier).updateTopicStatus(
                              chapterId, 
                              topics[index].id, 
                              'Ready to Begin',
                            );
                          }
                        },
                      ),
                      childCount: topics.length,
                    ),
                  ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 80.h)),
        ],
      ),
    );
  }

  // Premium Navigation System (Unified Header Hierarchy)
  Widget _backButton(BuildContext context, String subjectTitle) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_ios_new_rounded, color: const Color(0xFFE25B20), size: 12.sp),
            SizedBox(width: 8.w),
            Text(
              subjectTitle.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 8.5.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white70,
                letterSpacing: 1.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(width: 6.w),
            Text(
              '/',
              style: GoogleFonts.outfit(
                fontSize: 8.5.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white24,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              'TOPIC NODES',
              style: GoogleFonts.outfit(
                fontSize: 8.5.sp,
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

  // Unified circular progress visualization displaying percentage directly inside
  Widget _circularProgress(int progress) {
    final isCompleted = progress == 100;
    return SizedBox(
      width: 48.w,
      height: 48.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 48.w,
            height: 48.w,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 3.5.w,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          SizedBox(
            width: 48.w,
            height: 48.w,
            child: CircularProgressIndicator(
              value: progress / 100,
              strokeWidth: 3.5.w,
              color: const Color(0xFFE25B20),
              strokeCap: StrokeCap.round,
            ),
          ),
          Center(
            child: isCompleted
                ? Icon(Icons.emoji_events_rounded, color: Colors.greenAccent, size: 16.sp)
                : Text(
                    '$progress%',
                    style: GoogleFonts.outfit(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFE25B20),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _addTopicButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showAddTopic(context, ref),
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

  Widget _footerStat(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 7.sp,
            fontWeight: FontWeight.w900,
            color: Colors.white30,
            letterSpacing: 1.0,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(width: 1.w, height: 20.h, color: Colors.white.withValues(alpha: 0.05));

  // Premium Centered Inject Node Command Modal
  void _showAddTopic(BuildContext context, WidgetRef ref) {
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
                        'Initialize Node',
                        style: GoogleFonts.outfit(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'TOPIC DATA STREAM V1.0',
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
                'Add a new topic node to build chapter completion progress.',
                style: GoogleFonts.inter(
                  fontSize: 11.5.sp,
                  color: Colors.white38,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'NODE TITLE',
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
                  hintText: 'e.g., Backpropagation Part I',
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
                          ref.read(subjectDetailsProvider(subjectId).notifier).addTopic(chapterId, controller.text.trim());
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
                          'Confirm',
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

class _TopicItem extends StatelessWidget {
  final TopicModel topic;
  final int index;
  final VoidCallback onToggle;

  const _TopicItem({required this.topic, required this.index, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final status = topic.status;
    final isCompleted = status == 'Completed';
    final isInProgress = status == 'In Progress';
    
    Color borderColor;
    Widget checkboxChild;
    Color checkboxBorderColor;
    Color checkboxBgColor;
    Color statusColor;
    Color titleColor;
    String statusText;

    if (isCompleted) {
      borderColor = Colors.green.withValues(alpha: 0.15);
      checkboxChild = Icon(Icons.check_rounded, color: Colors.greenAccent, size: 12.sp);
      checkboxBorderColor = Colors.greenAccent.withValues(alpha: 0.3);
      checkboxBgColor = Colors.green.withValues(alpha: 0.1);
      statusColor = Colors.greenAccent;
      titleColor = Colors.white30;
      statusText = 'Completed';
    } else if (isInProgress) {
      borderColor = const Color(0xFFE25B20).withValues(alpha: 0.2);
      checkboxChild = Icon(Icons.check_rounded, color: const Color(0xFFE25B20), size: 12.sp);
      checkboxBorderColor = const Color(0xFFE25B20);
      checkboxBgColor = const Color(0xFFE25B20).withValues(alpha: 0.05);
      statusColor = const Color(0xFFE25B20);
      titleColor = Colors.white;
      statusText = 'In Progress';
    } else {
      borderColor = Colors.white.withValues(alpha: 0.04);
      checkboxChild = const SizedBox.shrink();
      checkboxBorderColor = Colors.white24;
      checkboxBgColor = Colors.transparent;
      statusColor = Colors.white30;
      titleColor = Colors.white;
      statusText = 'Ready to Begin';
    }

    // Simulated Topic Meta (15 mins + Medium difficulty)
    final durationText = '${12 + (index * 4) % 15} mins';
    final difficultyText = index % 3 == 0 ? 'Advanced' : (index % 3 == 1 ? 'Standard' : 'Basic');

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF141414), Color(0xFF0C0C0C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: borderColor),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  // Left Custom Premium Checkbox
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      color: checkboxBgColor,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: checkboxBorderColor, width: 1.5.w),
                    ),
                    alignment: Alignment.center,
                    child: checkboxChild,
                  ),
                  SizedBox(width: 14.w),
                  // Center Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.title,
                          style: GoogleFonts.outfit(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4.r),
                                border: Border.all(color: statusColor.withValues(alpha: 0.15)),
                              ),
                              child: Text(
                                statusText.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  fontSize: 7.sp,
                                  fontWeight: FontWeight.w900,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              width: 2.w,
                              height: 2.w,
                              decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              durationText.toUpperCase(),
                              style: GoogleFonts.outfit(
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white30,
                                  letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              width: 2.w,
                              height: 2.w,
                              decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              difficultyText.toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white30,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Right interactive arrow cues
                  Icon(
                    isCompleted ? Icons.check_circle_outline_rounded : Icons.play_circle_outline_rounded,
                    color: isCompleted ? Colors.greenAccent.withValues(alpha: 0.4) : const Color(0xFFE25B20).withValues(alpha: 0.4),
                    size: 16.sp,
                  ),
                ],
              ),
            ),
            if (isCompleted)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 2.h,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.greenAccent, Colors.green],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
