import 'package:flutter/material.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../models/learning_model.dart';
import '../../services/learning_service.dart';

class LearningScreen extends ConsumerStatefulWidget {
  const LearningScreen({super.key});
  @override
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen> {
  String? _expandedSubjectId, _expandedChapterId;

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
          child: Column(children: [
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(children: [
              _back(context),
              SizedBox(width: 16.w),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('KNOWLEDGE BASE',
                    style: GoogleFonts.outfit(
                        fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2.5)),
                Text('Learning Hub',
                    style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white)),
              ])),
              GestureDetector(
                  onTap: () => _addSubject(),
                  child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFFE85D04)]),
                          borderRadius: BorderRadius.circular(12.r)),
                      child: Icon(Icons.add_rounded, color: Colors.white, size: 22.sp))),
            ])).animate().fadeIn(duration: 400.ms),

        // Stats
        subjectsAsync.when(
          data: (subjects) => subjects.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppTheme.surfaceBorder)),
                      child: Row(children: [
                        _stat('${subjects.length}', 'Subjects'),
                        SizedBox(width: 16.w),
                        _stat('${subjects.fold<int>(0, (s, sub) => s + (sub.count?.chapters ?? 0))}', 'Chapters'),
                      ]))),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        SizedBox(height: 12.h),

        Expanded(
          child: subjectsAsync.when(
            data: (subjects) => subjects.isEmpty
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.auto_stories_rounded, size: 48.sp, color: Colors.white10),
                    SizedBox(height: 12.h),
                    Text('No Subjects Yet',
                        style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                    SizedBox(height: 4.h),
                    Text('Start building your knowledge base.',
                        style: GoogleFonts.inter(fontSize: 13.sp, color: AppTheme.textMuted)),
                  ]))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: subjects.length,
                    itemBuilder: (_, i) => _SubjectCard(
                          subject: subjects[i],
                          isExpanded: _expandedSubjectId == subjects[i].id,
                          onToggle: () =>
                              setState(() => _expandedSubjectId = _expandedSubjectId == subjects[i].id ? null : subjects[i].id),
                          expandedChapterId: _expandedChapterId,
                          onToggleChapter: (id) => setState(() => _expandedChapterId = _expandedChapterId == id ? null : id),
                        )),
            loading: () => Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: const HFShimmerList(height: 100),
            ),
            error: (e, _) => HFErrorState(
              onRetry: () => ref.refresh(subjectsProvider),
            ),
          ),
        ),
      ])),
    );
  }

  void _addSubject() => _showInput('Subject Name', (v) {
        ref.read(subjectsProvider.notifier).addSubject(v, 'General');
      });

  void _showInput(String label, Function(String) onSave) {
    final c = TextEditingController();
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(label, style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white)),
              SizedBox(height: 16.h),
              TextField(
                  controller: c,
                  autofocus: true,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                      hintText: 'Enter name...',
                      hintStyle: GoogleFonts.inter(color: Colors.white12),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.03),
                      contentPadding: EdgeInsets.all(14.w),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5))))),
              SizedBox(height: 16.h),
              GestureDetector(
                  onTap: () {
                    if (c.text.trim().isNotEmpty) {
                      onSave(c.text.trim());
                      Navigator.pop(ctx);
                    }
                  },
                  child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFFE85D04)]),
                          borderRadius: BorderRadius.circular(14.r)),
                      alignment: Alignment.center,
                      child: Text('Add', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)))),
              SizedBox(height: 16.h),
            ])));
  }

  Widget _stat(String v, String l) => Expanded(
          child: Column(children: [
        Text(v, style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(l, style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 1)),
      ]));

  Widget _back(BuildContext c) => GestureDetector(
      onTap: () => Navigator.pop(c),
      child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppTheme.surfaceBorder)),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp)));
}

class _SubjectCard extends ConsumerWidget {
  final SubjectModel subject;
  final bool isExpanded;
  final VoidCallback onToggle;
  final String? expandedChapterId;
  final Function(String) onToggleChapter;

  const _SubjectCard({
    required this.subject,
    required this.isExpanded,
    required this.onToggle,
    this.expandedChapterId,
    required this.onToggleChapter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppTheme.surfaceBorder)),
      child: Column(children: [
        GestureDetector(
            onTap: onToggle,
            child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(children: [
                  Container(
                      padding: EdgeInsets.all(10.w),
                      decoration:
                          BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
                      child: Icon(Icons.book_rounded, size: 20.sp, color: AppTheme.primary)),
                  SizedBox(width: 12.w),
                  Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(subject.title, style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                    SizedBox(height: 4.h),
                    Row(children: [
                      Text('${subject.count?.chapters ?? 0} chapters',
                          style: GoogleFonts.inter(fontSize: 11.sp, color: AppTheme.textMuted)),
                      SizedBox(width: 8.w),
                      Text('${subject.progress}%',
                          style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                    ]),
                    SizedBox(height: 4.h),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                            value: subject.progress / 100,
                            minHeight: 4.h,
                            backgroundColor: Colors.white.withValues(alpha: 0.05),
                            valueColor: const AlwaysStoppedAnimation(AppTheme.primary))),
                  ])),
                  Row(children: [
                    GestureDetector(
                        onTap: () => ref.read(subjectsProvider.notifier).removeSubject(subject.id),
                        child: Icon(Icons.delete_rounded, size: 16.sp, color: Colors.white10)),
                    SizedBox(width: 8.w),
                    Icon(isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 20.sp, color: Colors.white38),
                  ]),
                ]))),
        if (isExpanded) _SubjectDetails(subjectId: subject.id, expandedChapterId: expandedChapterId, onToggleChapter: onToggleChapter),
      ]),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _SubjectDetails extends ConsumerWidget {
  final String subjectId;
  final String? expandedChapterId;
  final Function(String) onToggleChapter;

  const _SubjectDetails({required this.subjectId, this.expandedChapterId, required this.onToggleChapter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(subjectDetailsProvider(subjectId));

    return detailsAsync.when(
      data: (details) => Column(children: [
        Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
        Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(children: [
              ...details.chapters!.map((ch) => _ChapterTile(
                    subjectId: subjectId,
                    chapter: ch,
                    isExpanded: expandedChapterId == ch.id,
                    onToggle: () => onToggleChapter(ch.id),
                  )),
              SizedBox(height: 8.h),
              GestureDetector(
                  onTap: () => _showInput(context, 'Chapter Name', (v) {
                        ref.read(subjectDetailsProvider(subjectId).notifier).addChapter(v);
                      }),
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_rounded, size: 16.sp, color: Colors.white24),
                        SizedBox(width: 6.w),
                        Text('Add Chapter',
                            style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.white24, fontWeight: FontWeight.w600)),
                      ]))),
            ])),
      ]),
      loading: () => const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppTheme.primary)),
      error: (e, _) => HFErrorState(
        onRetry: () => ref.refresh(subjectsProvider),
      ),
    );
  }

  void _showInput(BuildContext context, String label, Function(String) onSave) {
    final c = TextEditingController();
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(label, style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white)),
              SizedBox(height: 16.h),
              TextField(
                  controller: c,
                  autofocus: true,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                      hintText: 'Enter name...',
                      hintStyle: GoogleFonts.inter(color: Colors.white12),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.03),
                      contentPadding: EdgeInsets.all(14.w),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5))))),
              SizedBox(height: 16.h),
              GestureDetector(
                  onTap: () {
                    if (c.text.trim().isNotEmpty) {
                      onSave(c.text.trim());
                      Navigator.pop(ctx);
                    }
                  },
                  child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFFE85D04)]),
                          borderRadius: BorderRadius.circular(14.r)),
                      alignment: Alignment.center,
                      child: Text('Add', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)))),
              SizedBox(height: 16.h),
            ])));
  }
}

class _ChapterTile extends ConsumerWidget {
  final String subjectId;
  final ChapterModel chapter;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ChapterTile({required this.subjectId, required this.chapter, required this.isExpanded, required this.onToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
        child: Column(children: [
          GestureDetector(
              onTap: onToggle,
              child: Row(children: [
                Expanded(
                    child: Text(chapter.title,
                        style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white))),
                Text('${chapter.progress}%',
                    style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                SizedBox(width: 6.w),
                Icon(isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 18.sp, color: Colors.white24),
              ])),
          if (isExpanded) ...[
            SizedBox(height: 8.h),
            ...chapter.topics!.map((t) => GestureDetector(
                onTap: () => ref.read(subjectDetailsProvider(subjectId).notifier).toggleTopic(chapter.id, t.id, !t.completed),
                child: Container(
                    margin: EdgeInsets.only(bottom: 4.h),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(10.r)),
                    child: Row(children: [
                      Icon(t.completed ? Icons.check_circle_rounded : Icons.circle_outlined,
                          size: 18.sp, color: t.completed ? AppTheme.primary : Colors.white24),
                      SizedBox(width: 8.w),
                      Expanded(
                          child: Text(t.title,
                              style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  color: t.completed ? Colors.white24 : Colors.white70,
                                  decoration: t.completed ? TextDecoration.lineThrough : null))),
                    ])))),
            SizedBox(height: 6.h),
            GestureDetector(
                onTap: () => _showInput(context, 'Topic Name', (v) {
                      ref.read(subjectDetailsProvider(subjectId).notifier).addTopic(chapter.id, v);
                    }),
                child: Row(children: [
                  Icon(Icons.add_rounded, size: 14.sp, color: Colors.white12),
                  SizedBox(width: 4.w),
                  Text('Add Topic', style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.white12)),
                ])),
          ],
        ]));
  }

  void _showInput(BuildContext context, String label, Function(String) onSave) {
    final c = TextEditingController();
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(label, style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white)),
              SizedBox(height: 16.h),
              TextField(
                  controller: c,
                  autofocus: true,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                      hintText: 'Enter name...',
                      hintStyle: GoogleFonts.inter(color: Colors.white12),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.03),
                      contentPadding: EdgeInsets.all(14.w),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5))))),
              SizedBox(height: 16.h),
              GestureDetector(
                  onTap: () {
                    if (c.text.trim().isNotEmpty) {
                      onSave(c.text.trim());
                      Navigator.pop(ctx);
                    }
                  },
                  child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFFE85D04)]),
                          borderRadius: BorderRadius.circular(14.r)),
                      alignment: Alignment.center,
                      child: Text('Add', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)))),
              SizedBox(height: 16.h),
            ])));
  }
}
