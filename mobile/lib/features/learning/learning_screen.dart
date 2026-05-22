import 'package:flutter/material.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/learning_model.dart';
import '../../services/learning_service.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'subject_detail_screen.dart';

class LearningScreen extends ConsumerStatefulWidget {
  const LearningScreen({super.key});
  @override
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen> {
  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient Luxury Atmospheric Glows
            Positioned(
              top: -150.h,
              right: -100.w,
              child: Container(
                width: 350.w,
                height: 350.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE25B20).withValues(alpha: 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE25B20).withValues(alpha: 0.03),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),

            Column(
              children: [
                // Top Header Section (LEARNING COMMAND / Active Learning Paths copy)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16.sp),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            subjectsAsync.when(
                              data: (subjects) => Text(
                                'LEARNING COMMAND • ${subjects.length} PATHS IN PROGRESS',
                                style: GoogleFonts.outfit(
                                  fontSize: 8.5.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFE25B20),
                                  letterSpacing: 2,
                                ),
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                            Text(
                              'Active Learning Paths', // Refined Clean Copy
                              style: GoogleFonts.outfit(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5),
                            ),
                          ],
                        ),
                      ),
                      // Top Add Button polished for premium subtlety
                      GestureDetector(
                        onTap: () => _showAddSubject(context, ref),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
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
                          child: Icon(Icons.add_rounded, color: const Color(0xFFE25B20), size: 16.sp),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),

                Expanded(
                  child: subjectsAsync.when(
                    data: (subjects) => subjects.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(28.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF111111),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                  ),
                                  child: Icon(LucideIcons.brain, size: 40.sp, color: Colors.white38),
                                ),
                                SizedBox(height: 24.h),
                                Text(
                                  'NO ACTIVE PATHS',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white38,
                                    letterSpacing: 3,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                            itemCount: subjects.length,
                            itemBuilder: (_, i) => _SubjectCard(
                              subject: subjects[i],
                              index: i,
                            ),
                          ),
                    loading: () => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: const HFShimmerList(height: 140, count: 3),
                    ),
                    error: (e, _) => HFErrorState(
                      onRetry: () => ref.refresh(subjectsProvider),
                    ),
                  ),
                ),
                SizedBox(height: 80.h), // Bottom nav padding
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSubject(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final suggestions = [
      'Programming',
      'Physics',
      'AI',
      'UI Design',
      'Marketing',
    ];

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h), // Optimized padding height
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
                // Top Header Section & Minimal Close Trigger
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Initialize Path',
                          style: GoogleFonts.outfit(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'PERSONAL LEARNING GENERATOR',
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
                SizedBox(height: 6.h), // Tightened height spacing
                Text(
                  'Create a personalized learning path for any subject.', // Context Consistency Copy Fix
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    color: Colors.white38,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12.h), // Tightened height spacing
                Text(
                  'LEARNING SUBJECT',
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
                    hintText: 'e.g., Quantum Computing',
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
                  onChanged: (val) {
                    setModalState(() {});
                  },
                ),
                SizedBox(height: 10.h), // Tightened height spacing
                // Premium Horizontal Scroll Suggestions Chip Row
                SizedBox(
                  height: 30.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: suggestions.length,
                    separatorBuilder: (_, __) => SizedBox(width: 6.w),
                    itemBuilder: (context, i) {
                      final item = suggestions[i];
                      final isSelected = controller.text.trim().toLowerCase() == item.toLowerCase();
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            controller.text = item;
                            controller.selection = TextSelection.fromPosition(
                              TextSelection.fromPosition(
                                TextPosition(offset: controller.text.length),
                              ).base,
                            );
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFE25B20) : Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFE25B20) : Colors.white.withValues(alpha: 0.04),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            item,
                            style: GoogleFonts.outfit(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : Colors.white38,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 14.h), // Tightened height spacing
                GestureDetector(
                  onTap: () {
                    if (controller.text.trim().isNotEmpty) {
                      ref.read(subjectsProvider.notifier).addSubject(controller.text.trim(), 'General');
                      Navigator.pop(ctx);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10.5.h), // Height optimized by 10%
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF7E47), Color(0xFFE25B20)],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE25B20).withValues(alpha: 0.08), // Softened glow
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Start Learning Path',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final int index;

  const _SubjectCard({required this.subject, required this.index});

  // Dynamic visual anchors matching subjects/categories
  Widget _getSubjectIcon(String title, String? category) {
    final t = title.toLowerCase();
    final c = (category ?? '').toLowerCase();

    IconData iconData = LucideIcons.bookOpen;
    if (t.contains('quantum') || t.contains('physic') || t.contains('chem') || t.contains('science')) {
      iconData = LucideIcons.atom;
    } else if (t.contains('code') || t.contains('program') || t.contains('python') || t.contains('dev') || t.contains('tech') || t.contains('java') || t.contains('web')) {
      iconData = LucideIcons.code2;
    } else if (t.contains('design') || t.contains('ui') || t.contains('ux') || t.contains('art') || t.contains('palette')) {
      iconData = LucideIcons.palette;
    } else if (t.contains('psych') || t.contains('brain') || t.contains('mind') || t.contains('neuro') || t.contains('think')) {
      iconData = LucideIcons.brain;
    } else if (t.contains('lang') || t.contains('speak') || t.contains('english') || t.contains('spanish') || t.contains('german')) {
      iconData = LucideIcons.languages;
    } else if (c.contains('math') || t.contains('math') || t.contains('calculus') || t.contains('algebra')) {
      iconData = LucideIcons.binary;
    } else {
      iconData = LucideIcons.graduationCap;
    }

    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE25B20).withValues(alpha: 0.04),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        iconData,
        color: const Color(0xFFE25B20),
        size: 18.sp,
      ),
    );
  }

  // Proper Logical Conditional UI State metrics
  Widget _buildMotivationalStrip(SubjectModel subject) {
    if (subject.progress == 0) {
      // 1) NOT STARTED STATE: "0 modules completed", no streak/metrics shown.
      return Row(
        children: [
          Icon(LucideIcons.bookOpen, color: const Color(0xFF8A8A8A), size: 12.sp),
          SizedBox(width: 4.w),
          Text(
            '0 modules completed',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF8A8A8A),
            ),
          ),
        ],
      );
    } else if (subject.progress >= 100) {
      // 2) COMPLETED STATE: Mastered/Review state metrics.
      return Row(
        children: [
          Icon(LucideIcons.trophy, color: Colors.amberAccent, size: 12.sp),
          SizedBox(width: 4.w),
          Text(
            'Knowledge Mastered',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: Colors.amberAccent,
            ),
          ),
        ],
      );
    } else {
      final streak = subject.streakCount;
      final chapters = subject.chapters ?? [];
      final completed = chapters.where((ch) => ch.status == 'Completed').length;
      final left = chapters.isEmpty 
          ? (10 - (subject.progress * 10 ~/ 100)).clamp(1, 10)
          : (chapters.length - completed).clamp(0, 99);

      return Row(
        children: [
          Icon(LucideIcons.flame, color: Colors.orangeAccent, size: 12.sp),
          SizedBox(width: 4.w),
          Text(
            '$streak-day streak',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: Colors.orangeAccent,
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 3.w,
            height: 3.w,
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
          ),
          SizedBox(width: 12.w),
          Icon(LucideIcons.target, color: const Color(0xFFE25B20), size: 12.sp),
          SizedBox(width: 4.w),
          Text(
            '$left modules left',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white54,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressVal = (subject.progress / 100).clamp(0.0, 1.0);

    // Conditional Label Logic
    String stateLabel;
    Color stateColor;
    String ctaLabel;
    Color ctaBgColor;
    
    if (subject.progress == 0) {
      stateLabel = 'PATH NOT STARTED';
      stateColor = const Color(0xFF8A8A8A);
      ctaLabel = 'Start Path';
      ctaBgColor = const Color(0xFFE25B20);
    } else if (subject.progress >= 100) {
      stateLabel = 'PATH COMPLETED';
      stateColor = Colors.greenAccent;
      ctaLabel = 'Review';
      ctaBgColor = const Color(0xFF1E1E1E);
    } else {
      stateLabel = '${subject.progress}% XP';
      stateColor = const Color(0xFFE25B20);
      ctaLabel = 'Continue';
      ctaBgColor = const Color(0xFFE25B20);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            // Micro ambient interior light mapping
            Positioned(
              top: -50.h,
              left: -50.w,
              child: Container(
                width: 150.w,
                height: 150.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE25B20).withValues(alpha: 0.02),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE25B20).withValues(alpha: 0.02),
                      blurRadius: 40,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Visual Anchor + Title & Category Tag
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _getSubjectIcon(subject.title, subject.category),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            SizedBox(height: 4.h),
                            Text(
                              subject.title,
                              style: GoogleFonts.outfit(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h), // Spacing Rhythm Balanced

                  // Row 2: Strong Progress Feedback (XP State Improvement)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'KNOWLEDGE STAGE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white30,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        stateLabel,
                        style: GoogleFonts.outfit(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w900,
                          color: stateColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Sleek Progress Tracker Bar (Glow & Contrast polished)
                  Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 7.h, // Cleaned thickness
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.09), // Enhanced visible premium contrast track
                          borderRadius: BorderRadius.circular(7.r),
                        ),
                      ),
                      if (subject.progress > 0)
                        FractionallySizedBox(
                          widthFactor: progressVal,
                          child: Container(
                            height: 7.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: subject.progress >= 100
                                  ? [Colors.greenAccent, Colors.tealAccent]
                                  : [const Color(0xFFFF7E47), const Color(0xFFE25B20)],
                              ),
                              borderRadius: BorderRadius.circular(7.r),
                              boxShadow: [
                                BoxShadow(
                                  color: (subject.progress >= 100 ? Colors.greenAccent : const Color(0xFFE25B20))
                                      .withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  spreadRadius: 0.5,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h), // Spacing Rhythm Balanced

                  // Row 3: Psychological loop metrics + Compact Action in alignment
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.white.withValues(alpha: 0.03),
                  ),
                  SizedBox(height: 10.h), // Spacing Rhythm Balanced

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMotivationalStrip(subject),
                      // Compact polished CTA supporting the card states
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubjectDetailScreen(subjectId: subject.id),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.5.h), // Reduced by 10-15% width/height
                          decoration: BoxDecoration(
                            color: ctaBgColor,
                            borderRadius: BorderRadius.circular(12.r),
                            border: subject.progress >= 100 
                              ? Border.all(color: Colors.white.withValues(alpha: 0.08)) 
                              : null,
                            boxShadow: [
                              if (subject.progress < 100)
                                BoxShadow(
                                  color: const Color(0xFFE25B20).withValues(alpha: 0.05), // Softened glow
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ctaLabel,
                                style: GoogleFonts.outfit(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                subject.progress >= 100 
                                  ? Icons.refresh_rounded 
                                  : Icons.arrow_forward_ios_rounded, 
                                color: Colors.white, 
                                size: 8.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 60).ms, duration: 300.ms);
  }
}
